extends KinematicBody2D
class_name NetworkBody

var active: bool = true
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
	NetworkSocket.connect("entity_position_update", self, "entity_position_update")
	NetworkSocket.connect("entity_update_state", self, "entity_update_state")
	NetworkSocket.connect("entity_hard_position_update", self, "entity_hard_update_position")
	NetworkSocket.connect("entity_misc_data", self, "entity_misc_data")


func _process(delta):
	if is_client_owner():
		NetworkSocket.send_message_to_lobby({
			"id": entity_uuid, #NetworkSocket.current_web_id,
			"type": Constants.GenericAction_EntityUpdatePosition,
			"position": {
				"x": global_position.x,
				"y": global_position.y,
			},
			"speed": current_speed,
		})

func entity_position_update(data):
	if data.id == entity_uuid:
		target_position = Vector2(data.position.x, data.position.y)
		movement_direction = Vector2(data.position.x, data.position.y) - target_position
		speed = data.speed
		#target_position = lerp(global_position, Vector2(data.position.x, data.position.y), .5)
		
		#$Sprites/PlayerWeapon.rotation = data.weapon_rotation

func entity_update_state(data):
	if data.id == entity_uuid:
		pass

func entity_hard_update_position(data):
	if data.id == entity_uuid:
		global_position = Vector2(data.position.x, data.position.y)

func entity_misc_data(data):
	if data.id == entity_uuid:
		pass

func is_client_owner():
	return owner_uuid == NetworkSocket.current_web_id
