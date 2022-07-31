extends Node2D

var network_puppet_reference = load("res://src/entities/player/NetworkPlayerPuppet.tscn")
var network_bullet_puppet_reference = load("res://src/entities/bullet/BulletPuppet.tscn")

func _ready():
	randomize()
	$Entities/Player.global_position = Vector2(randi()%100 - 50, randi()%100 - 50)
	
	NetworkSocket.connect("web_socket_disconnected", self, "web_socket_disconnected")
	NetworkSocket.connect("get_own_lobby", self, "get_own_lobby")
	NetworkSocket.send_message_get_own_lobby()
	
	EventBus.connect("create_bullet", self, "create_bullet")
	NetworkSocket.connect("shoot_bullet", self, "create_bullet_puppet")


func get_own_lobby(lobby):
	for player in lobby.players:
		if player.id != NetworkSocket.current_web_id:
			add_puppet(player)

func player_join(user_data):
	add_puppet(user_data)

func player_left(webId):
	for player in $Entities.get_children():
		if player is NetworkPlayerPuppet:
			if player.player_uuid == webId:
				player.queue_free()

func web_socket_disconnected():
	EventBus.emit_signal("change_scene", "network")

func update_user_list(success, users):
	if success:
		for user in users:
			if user.id != NetworkSocket.current_web_id:
				if !puppet_exist(user.id):
					add_puppet(user)

func add_puppet(user_data):
	var starting_position = Vector2(user_data.position.x, user_data.position.y)
	var starting_direction = Vector2(user_data.direction.x, user_data.direction.y)
	var new_puppet = network_puppet_reference.instance()
	new_puppet.player_uuid = user_data.id
	new_puppet.username = user_data.username
	new_puppet.global_position = starting_position
	new_puppet.movement_direction = starting_direction
	$Entities.add_child(new_puppet)

func puppet_exist(puppet_id):
	for player in $Entities.get_children():
		if player is NetworkPlayerPuppet:
			if player.player_uuid == puppet_id:
				return true
	return false

func create_bullet(bullet_instance, start_pos, direction):
	bullet_instance.global_position = start_pos
	bullet_instance.direction = direction.normalized()
	$Bullets.add_child(bullet_instance)
	NetworkSocket.send_message_to_lobby({
		"owner_id": NetworkSocket.current_web_id,
		"type": Constants.GenericAction_ShootBullet,
		"position": {
			"x": start_pos.x,
			"y": start_pos.y
		},
		"direction": {
			"x": direction.x,
			"y": direction.y
		},
	})

func create_bullet_puppet(bullet_data):
	var new_bullet_puppet = network_bullet_puppet_reference.instance()
	new_bullet_puppet.owner_id = bullet_data.owner_id
	new_bullet_puppet.global_position = Vector2(bullet_data.position.x, bullet_data.position.y)
	new_bullet_puppet.direction = Vector2(bullet_data.direction.x, bullet_data.direction.y)
	$Bullets.add_child(new_bullet_puppet)
