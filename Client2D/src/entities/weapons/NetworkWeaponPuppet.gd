extends Node2D

var target_direction = Vector2.RIGHT

func _ready():
	NetworkSocket.connect("weapon_update", self, "weapon_update")

func _physics_process(delta):
	
	
	if (target_direction != Vector2.ZERO):
		rotation = lerp_angle(rotation, target_direction.normalized().angle(), .8)
		scale.y = -1 if cos(rotation) < 0.0 else 1

func weapon_update(weapon_data):
	target_direction = Vector2(weapon_data.rotation_direction.x, weapon_data.rotation_direction.y)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
