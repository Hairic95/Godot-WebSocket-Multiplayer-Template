extends KinematicBody2D
class_name NetworkBody

var active: bool = true
var is_neutral = false
var current_speed = 0
var speed = 0

var packet_time = 0
var packet_timer = .05
var owner_uuid = ""
var entity_uuid = ""

var target_position: Vector2 = Vector2.ZERO
var movement_direction: Vector2 = Vector2.ZERO

func _ready():
	if is_client_owner():
		entity_uuid = Uuid.v4()
	target_position = global_position
	NetworkSocket.connect("entity_position_update", self, "remote_entity_position_update")
	NetworkSocket.connect("entity_update_state", self, "remote_entity_update_state")
	NetworkSocket.connect("entity_hard_position_update", self, "remote_entity_hard_update_position")
	NetworkSocket.connect("entity_misc_process_data", self, "remote_entity_misc_process_data")
	NetworkSocket.connect("entity_misc_one_off", self, "remote_entity_misc_one_off")
	NetworkSocket.connect("entity_death", self, "remote_entity_death")


func _process(delta):
	if is_client_owner():
		NetworkSocket.send_message_to_lobby({
			"entity_id": entity_uuid, #NetworkSocket.current_web_id,
			"type": Constants.GenericAction_EntityUpdatePosition,
			"position": {
				"x": global_position.x,
				"y": global_position.y,
			},
			"speed": current_speed,
		})

func remote_entity_position_update(data):
	if data.entity_id == entity_uuid:
		target_position = Vector2(data.position.x, data.position.y)
		movement_direction = Vector2(data.position.x, data.position.y) - target_position
		speed = data.speed

func remote_entity_update_state(data):
	if data.entity_id == entity_uuid:
		pass

func remote_entity_hard_update_position(data):
	if data.entity_id == entity_uuid:
		global_position = Vector2(data.position.x, data.position.y)

func remote_entity_misc_process_data(data):
	if data.entity_id == entity_uuid:
		pass

func remote_entity_death(data):
	if data.entity_id == entity_uuid:
		queue_free()

func remote_entity_misc_one_off(data):
	if data.entity_id == entity_uuid:
		pass

func is_client_owner():
	return owner_uuid == NetworkSocket.current_web_id || (is_neutral && NetworkSocket.is_lobby_master)
