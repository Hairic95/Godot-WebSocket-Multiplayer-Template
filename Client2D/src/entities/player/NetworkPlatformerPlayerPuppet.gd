extends KinematicBody2D
class_name NetworkPlatformerPlayerPuppet

const WALL_JUMP_X_FORCE = 100.0
const WALL_JUMP_X_DECELERATION = 1.3
const JUMP_FORCE = 240.0
const GRAVITY = 800.0
const SPEED = 120
const DASH_SPEED = 260


var player_uuid = ""
var username = ""

# todo add pushbox physic
var pushboxes = []

var movement_direction = Vector2.ZERO

var current_state = "Idle"
var is_dashing = false

onready var anim = $Sprites/Anim

func _ready():
	NetworkSocket.connect("player_position_update", self, "player_position_update")
	NetworkSocket.connect("shoot_bullet", self, "shoot_bullet")
	NetworkSocket.connect("player_death", self, "player_death")
	$CenterTrail.parent = self
	$DashTrail.parent = self
	$DashTrail2.parent = self

func _physics_process(delta):
	var push_force = Vector2.ZERO
	for pushbox in pushboxes:
		push_force += (global_position - pushbox.global_position).normalized() * 100
	
	var speed = SPEED
	if is_dashing:
		speed = DASH_SPEED
	var collider_data = move_and_collide(movement_direction.normalized() * speed * delta, true, true, true)
	if !collider_data:
		var result_movement = move_and_slide(movement_direction.normalized() * speed)

func set_state(new_state):
	if new_state != current_state:
		current_state = new_state
		if anim != null:
			match(new_state):
				"Idle":
					anim.play("Idle")
				"Move":
					anim.play("Running")
				"Jumping":
					anim.play("Jumping")
				"Falling":
					anim.play("Falling")

func _on_PushBox_area_entered(area):
	if area.is_in_group("pushbox"):
		if !pushboxes.has(area):
			pushboxes.append(area)

func _on_PushBox_area_exited(area):
	if area.is_in_group("pushbox"):
		if pushboxes.has(area):
			pushboxes.erase(area)

func player_position_update(data):
	if data.id == player_uuid:
		global_position = Vector2(data.position.x, data.position.y)
		movement_direction = Vector2(data.direction.x, data.direction.y)
		set_state(data.state)
		set_dash_trails(data.is_dashing)
		is_dashing = data.is_dashing
		$Sprites.scale.x = data.facing

func hurt(damage):
	pass

func _on_Hitbox_area_entered(area):
	if area is BulletPuppet:
		hurt(area.damage)

func set_dash_trails(value):
	$CenterTrail.active = value
	$DashTrail.active = value
	$DashTrail2.active = value

func shoot_bullet(data):
	if data.owner_id == player_uuid:
		$ShootSFX.stop()
		$ShootSFX.pitch_scale = .8 + randf() * .3
		$ShootSFX.play()
	

func player_death(data):
	if data.player_id == player_uuid:
		EventBus.emit_signal("opponent_death")
		queue_free()
