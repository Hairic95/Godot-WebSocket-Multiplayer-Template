extends Node2D

export (PackedScene) var bullet_reference = preload("res://src/entities/bullet/Bullet.tscn")

var target_direction = Vector2.RIGHT

var is_reloading = false

var packet_time = 0
var packet_timer = .02

var can_shoot = true

func _ready():
	pass

func _process(delta):
	target_direction = Vector2.ZERO
	
	if Input.is_action_pressed("shoot_up"):
		target_direction.y = -1
	if Input.is_action_pressed("shoot_down"):
		target_direction.y = 1
	if Input.is_action_pressed("shoot_right"):
		target_direction.x = 1
	if Input.is_action_pressed("shoot_left"):
		target_direction.x = -1
	if Input.is_action_pressed("shoot_up") || Input.is_action_pressed("shoot_down") || Input.is_action_pressed("shoot_right") || Input.is_action_pressed("shoot_left"):
		if !is_reloading && can_shoot:
			is_reloading = true
			shoot()
	
	if (target_direction != Vector2.ZERO):
		rotation = lerp_angle(rotation, target_direction.normalized().angle(), .8)
		scale.y = -1 if cos(rotation) < 0.0 else 1
	
	if packet_time >= packet_timer:
		packet_time = 0
		NetworkSocket.send_message_to_lobby({
			"id": NetworkSocket.current_web_id,
			"type": Constants.GenericAction_UpdateWeapon,
			"rotation_direction": {
				"x": target_direction.x,
				"y": target_direction.y
			},
		})
	else:
		packet_time += delta



func shoot():
	if bullet_reference != null:
		var bullet_direction = ($BulletOrigin.global_position - global_position).normalized()
		EventBus.emit_signal("create_bullet", bullet_reference.instance(), 
				$BulletOrigin.global_position, bullet_direction.normalized())
	#$Gun/Anim.stop()
	#$Gun/Anim.play("Shoot")
	EventBus.emit_signal("start_screenshake", 22)
	$Shoot.pitch_scale = 0.4 + randf()
	$Shoot.play()
	$ReloadTimer.start()
	


func _on_ReloadTimer_timeout():
	is_reloading = false
