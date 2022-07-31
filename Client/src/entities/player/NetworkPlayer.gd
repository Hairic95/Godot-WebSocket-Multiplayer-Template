extends KinematicBody2D
class_name NetworkPlayer

const SPEED = 700
const RUNNING_SPEED = 1100

var active = true

# todo add pushbox physic
var pushboxes = []

var movement_direction = Vector2.ZERO

var current_state = "Idle"

onready var anim = $Sprites/Anim
onready var weapon = $Weapon/NetworkWeapon

var packet_time = 0
var packet_timer = .02

func _ready():
	$Name.text = NetworkSocket.current_username

func _physics_process(delta):
	movement_direction = Vector2.ZERO
	
	if active:
		
		# MOVEMENT
		if Input.is_action_pressed("move_up"):
			movement_direction.y = -1
		if Input.is_action_pressed("move_down"):
			movement_direction.y = 1
		if Input.is_action_pressed("move_left"):
			movement_direction.x = -1
		if Input.is_action_pressed("move_right"):
			movement_direction.x = 1
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
	var is_running = Input.is_action_pressed("running")
	weapon.can_shoot = !is_running
	if is_running:
		speed = RUNNING_SPEED
	
	move_and_slide(movement_direction.normalized() * speed + push_force)
	
	if packet_time >= packet_timer:
		packet_time = 0
		NetworkSocket.send_message_to_lobby({
			"id": NetworkSocket.current_web_id,
			"type": Constants.GenericAction_UpdatePosition,
			"is_running": is_running,
			"position": {
				"x": global_position.x,
				"y": global_position.y
			},
			"direction":  {
				"x": movement_direction.x,
				"y": movement_direction.y
			},
		})
	else:
		packet_time += delta
	

func set_state(new_state):
	match(new_state):
		"Idle":
			if anim != null && anim is AnimationHandler:
				anim.play_anim("Idle")
		"Move":
			if anim != null && anim is AnimationHandler:
				anim.play_anim("RunForward")
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

func hurt(damage):
	pass

func _on_Hitbox_area_entered(area):
	if area is BulletPuppet:
		hurt(area.damage)
