extends KinematicBody2D
class_name NetworkPlatformerPlayer

var bullet_reference = load("res://src/entities/bullet/Bullet.tscn")
var muzzle_effect_reference = load("res://src/effects/MuzzleEffect.tscn")

const WALL_JUMP_X_FORCE = 100.0
const WALL_JUMP_X_DECELERATION = 1.3
const JUMP_FORCE = 240.0
const GRAVITY = 800.0
const SPEED = 120
const DASH_SPEED = 260

var active = true
var can_jump = true
var can_dash = true

var health = 5

var pushboxes = []

var movement_direction = Vector2.ZERO
var dash_direction = Vector2.ZERO
var gravity_movement = Vector2.ZERO

var current_state = "Idle"

onready var anim = $Sprites/Anim

var packet_time = 0
var packet_timer = .01

var jump_forgiveness_max = .11
var jump_forgiveness_timer = .0

var wall_jump_push_time_max = .3
var wall_jump_push_timer = .0

var dash_time_max = .28
var dash_timer = .0

var latest_direction = 1

var can_shoot = true

func _ready():
	EventBus.emit_signal("player_health_update", health)
	$CenterTrail.parent = self
	$DashTrail.parent = self
	$DashTrail2.parent = self

func _physics_process(delta):
	var right_wall_collider_data = move_and_collide(Vector2(1, 0) * SPEED * delta, true, true, true)
	var left_wall_collider_data = move_and_collide(Vector2(-1, 0) * SPEED * delta, true, true, true)
	
	movement_direction = Vector2.ZERO
	# Jump Checking
	if !is_on_floor():
		
		if (Input.is_action_pressed("move_right") && right_wall_collider_data) || (Input.is_action_pressed("move_left") && left_wall_collider_data):
			if gravity_movement.y >= 0 && current_state != "Slamming":
				gravity_movement.y *= .5
		
		if can_jump:
			if jump_forgiveness_timer >= jump_forgiveness_max:
				can_jump = false
			else:
				jump_forgiveness_timer += delta
		
		if current_state != "Dashing":
			gravity_movement.y += delta * GRAVITY
		else:
			gravity_movement.y = min(0, gravity_movement.y)
	else:
		gravity_movement.y = 0
		jump_forgiveness_timer = 0
		can_jump = true
		if current_state == "Slamming":
			set_state("Idle")
			set_dash_trails(false)
	
	if is_on_ceiling():
		if gravity_movement.y < 0:
			gravity_movement.y = 0
	
	if active:
		if current_state != "Slamming" && current_state != "Dashing":
			# MOVEMENT
			if Input.is_action_pressed("move_left"):
				movement_direction.x = -1
				latest_direction = -1
			if Input.is_action_pressed("move_right"):
				movement_direction.x = 1
				latest_direction = 1
			if Input.is_action_just_pressed("jump"):
				if Input.is_action_pressed("move_left") && left_wall_collider_data:
					gravity_movement.y = -JUMP_FORCE * sin(PI / 3.0)
					#gravity_movement.x = WALL_JUMP_X_FORCE
					can_jump = false
				if Input.is_action_pressed("move_right") && right_wall_collider_data:
					gravity_movement.y = -JUMP_FORCE * sin(PI / 3.0)
					#jump_movement.x = -WALL_JUMP_X_FORCE
					can_jump = false
			if Input.is_action_just_pressed("jump") && can_jump:
				gravity_movement.y = -JUMP_FORCE
				can_jump = false
			if Input.is_action_just_pressed("shoot"):
				shoot()
			if Input.is_action_just_pressed("dash") && can_dash:
				set_state("Dashing")
				set_dash_trails(true)
				dash_direction.x = latest_direction
			if Input.is_action_just_pressed("slam") && !is_on_floor():
				set_state("Slamming")
				set_dash_trails(true)
		# facing
		if get_global_mouse_position().x > global_position.x:
			$Sprites.scale.x = 1
		elif get_global_mouse_position().x < global_position.x:
			$Sprites.scale.x = -1
		
		
	
	var push_force = Vector2.ZERO
	for pushbox in pushboxes:
		push_force += (global_position - pushbox.global_position).normalized() * 100
		push_force.y = 0
	
	var result_movement = Vector2.ZERO
	if current_state != "Slamming" && current_state != "Dashing":
		# Horizontal obstacle check and movement
		var collider_data = move_and_collide(movement_direction.normalized() * SPEED * delta, true, true, true)
		if !collider_data:
			result_movement = move_and_slide(movement_direction.normalized() * SPEED)
		
		
		# Animation
		if gravity_movement.y < 0:
			set_state("Jumping")
		elif gravity_movement.y > 0:
			set_state("Falling")
		elif abs(movement_direction.x) >= .5:
			set_state("Move")
		else:
			set_state("Idle")
		
	elif current_state == "Dashing":
		
		var stop_dash = false
		var collider_data = move_and_collide(dash_direction.normalized() * DASH_SPEED * delta, true, true, true)
		if !collider_data:
			result_movement = move_and_slide(dash_direction.normalized() * DASH_SPEED)
		else:
			stop_dash = true
		if dash_timer >= dash_time_max:
			stop_dash = true
		else:
			dash_timer += delta
		
		if stop_dash:
			dash_timer = 0
			set_state("Idle")
			set_dash_trails(false)
	elif current_state == "Slamming":
		if gravity_movement.y < 0:
			gravity_movement.y = 0
		gravity_movement.y *= 1.4
	
	# Vertical movement
	result_movement += move_and_slide(push_force + gravity_movement, Vector2.UP)
	
	if packet_time >= packet_timer:
		packet_time = 0
		NetworkSocket.send_message_to_lobby({
			"id": NetworkSocket.current_web_id,
			"type": Constants.GenericAction_UpdatePosition,
			"facing": $Sprites.scale.x,
			"state": current_state,
			"is_dashing": current_state == "Dashing" || current_state == "Slamming",
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
	
	if active:
		Input.set_custom_mouse_cursor(load("res://assets/textures/platformer/cursor_x3.png"))
	else:
		Input.set_custom_mouse_cursor(null)
	

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

func hurt(damage):
	health = max(0, health - damage)
	EventBus.emit_signal("player_health_update", health)
	if health == 0:
		active = false
		EventBus.emit_signal("player_death")
		NetworkSocket.send_message_to_lobby({
				"type": Constants.GenericAction_PlayerDeath,
				"player_id": NetworkSocket.current_web_id
			}
		)
		queue_free()

func _on_Hitbox_area_entered(area):
	if area is BulletPuppet:
		hurt(area.damage)

func shoot():
	var bullet_direction = (get_global_mouse_position() -  $Sprites/BulletSpawn.global_position).normalized()
	EventBus.emit_signal("create_bullet", bullet_reference.instance(), $Sprites/BulletSpawn.global_position + bullet_direction * 5, bullet_direction)
	var new_muzzle_effect = muzzle_effect_reference.instance()
	new_muzzle_effect.rotation = bullet_direction.angle()
	EventBus.emit_signal("create_effect", new_muzzle_effect, $Sprites/BulletSpawn.global_position + bullet_direction * 5)
	EventBus.emit_signal("create_screenshake", 6)
	$ShootSFX.stop()
	$ShootSFX.pitch_scale = .8 + randf() * .3
	$ShootSFX.play()

func set_dash_trails(value):
	$CenterTrail.active = value
	$DashTrail.active = value
	$DashTrail2.active = value
