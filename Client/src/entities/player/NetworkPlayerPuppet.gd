extends KinematicBody2D
class_name NetworkPlayerPuppet

const SPEED = 700
const RUNNING_SPEED = 1100

var player_uuid = ""
var username = ""

# todo add pushbox physic
var pushboxes = []

var movement_direction = Vector2.ZERO
var is_running = false

var current_state = "Idle"

onready var anim = $Sprites/Anim

func _ready():
	NetworkSocket.connect("player_position_update", self, "player_position_update")
	$Name.text = username

func _physics_process(delta):
	
	# facing
	if movement_direction != Vector2.ZERO:
		if movement_direction.x > 0:
			$Sprites.scale.x = 1
		elif movement_direction.x < 0:
			$Sprites.scale.x = -1
	
	# Animation
	if movement_direction != Vector2.ZERO:
		set_state("Move")
	else:
		set_state("Idle")
	
	var push_force = Vector2.ZERO
	for pushbox in pushboxes:
		push_force += (global_position - pushbox.global_position).normalized() * 100
	
	var speed = SPEED
	if is_running:
		speed = RUNNING_SPEED
	move_and_slide(movement_direction.normalized() * speed + push_force)

func set_state(new_state):
	match(new_state):
		"Idle":
			if anim != null && anim is AnimationHandler:
				anim.play_anim("Idle")
		"Move":
			if anim != null && anim is AnimationHandler:
				anim.play_anim("RunForward")
		"Death":
			pass
	if new_state != current_state:
		current_state = new_state

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
		is_running = data.is_running


