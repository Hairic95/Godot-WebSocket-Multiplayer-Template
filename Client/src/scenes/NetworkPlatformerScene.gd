extends Node2D

var player_points = 0
var opponent_points = 0

var network_player_reference = load("res://src/entities/player/NetworkPlatformerPlayer.tscn")
var camera_controller_reference = load("res://src/entities/camera/CameraController.tscn")
var network_bullet_puppet_reference = load("res://src/entities/bullet/BulletPuppet.tscn")

var maps = {
	"Map001": load("res://src/maps/Map01.tscn")
}

var current_map = null

# Called when the node enters the scene tree for the first time.
func _ready():
	NetworkSocket.connect("get_own_lobby", self, "get_own_lobby")
	
	EventBus.connect("create_bullet", self, "create_bullet")
	EventBus.connect("create_effect", self, "create_effect")
	NetworkSocket.connect("shoot_bullet", self, "create_bullet_puppet")
	
	EventBus.connect("player_death", self, "player_death")
	EventBus.connect("opponent_death", self, "opponent_death")
	NetworkSocket.connect("player_spawn", self, "player_spawn")
	EventBus.connect("player_health_update", self, "player_health_update")
	NetworkSocket.send_message_get_own_lobby()
	
	if maps.has(NetworkSocket.current_map_key):
		current_map = maps[NetworkSocket.current_map_key].instance()
	else:
		current_map = load("res://src/maps/Map01.tscn").instance()
	$Map.add_child(current_map)
	_on_RespawnTimer_timeout()
	#var respawn_point = current_map.get_respawn_points()[NetworkSocket.get_position_in_lobby()]
	#$Entities/PlatformerPlayer.global_position = respawn_point.global_position

func _process(delta):
	if $RespawnTimer.wait_time >= 0:
		$RespawnTimerUI/Panel/Countdown.text = str(int($RespawnTimer.time_left) + 1)

func get_own_lobby(lobby):
	#for player in lobby.players:
		#if player.id != NetworkSocket.current_web_id:
		#	player_spawn(player)
	pass

func create_bullet(bullet_instance, starting_position, direction):
	bullet_instance.global_position = starting_position
	bullet_instance.direction = direction
	$Bullets.add_child(bullet_instance)
	NetworkSocket.send_message_to_lobby({
		"owner_id": NetworkSocket.current_web_id,
		"bullet_id": bullet_instance.bullet_id,
		"type": Constants.GenericAction_ShootBullet,
		"position": {
			"x": starting_position.x,
			"y": starting_position.y
		},
		"direction": {
			"x": direction.x,
			"y": direction.y
		},
	})

func create_effect(effect_instance, starting_position):
	effect_instance.global_position = starting_position
	$Effects.add_child(effect_instance)


func player_spawn(data):
	var starting_position = Vector2(data.position.x, data.position.y)
	var new_puppet = network_player_reference.instance()
	new_puppet.owner_uuid = data.owner_id
	new_puppet.entity_uuid = data.entity_id
	new_puppet.global_position = starting_position
	new_puppet.target_position = starting_position
	new_puppet.movement_direction = Vector2.ZERO
	$Entities.add_child(new_puppet)

func create_bullet_puppet(bullet_data):
	var new_bullet_puppet = network_bullet_puppet_reference.instance()
	new_bullet_puppet.owner_id = bullet_data.owner_id
	new_bullet_puppet.bullet_id = bullet_data.bullet_id
	new_bullet_puppet.global_position = Vector2(bullet_data.position.x, bullet_data.position.y)
	new_bullet_puppet.direction = Vector2(bullet_data.direction.x, bullet_data.direction.y)
	$Bullets.add_child(new_bullet_puppet)

func player_death():
	current_map.set_camera_active(true)
	opponent_points += 1
	$PlayerUI/OpponentPoints.text = str(opponent_points)
	$RespawnTimer.start()
	$RespawnTimerUI.show()
	
func opponent_death():
	player_points += 1
	$PlayerUI/PlayerPoints.text = str(player_points)

func _on_RespawnTimer_timeout():
	var new_player = network_player_reference.instance()
	var spawn_position = Vector2(90, 120)
	var respawn_points = get_avaiable_respawn_points()
	if respawn_points.size() > 0:
		spawn_position = respawn_points[randi()% respawn_points.size()].global_position
	
	new_player.global_position = spawn_position
	new_player.owner_uuid = NetworkSocket.current_web_id
	
	$Entities.add_child(new_player)
	new_player.add_child(camera_controller_reference.instance())
	current_map.set_camera_active(false)
	
	NetworkSocket.send_message_to_lobby({
		"type": Constants.GenericAction_PlayerSpawn,
		"owner_id": NetworkSocket.current_web_id,
		"entity_id": new_player.entity_uuid,
		"position": {
			"x": spawn_position.x,
			"y": spawn_position.y,
		}
	})
	$RespawnTimerUI.hide()

func player_health_update(health):
	$PlayerUI/HealthBar.set_value(health)

func get_avaiable_respawn_points():
	var result = []
	for respawn_point in current_map.get_respawn_points():
		if respawn_point.is_avaiable():
			result.append(respawn_point)
	return result
