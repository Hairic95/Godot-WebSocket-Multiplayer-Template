extends NetworkBody
class_name NetworkBall


var movement_direciton = Vector2.DOWN
# Called when the node enters the scene tree for the first time.
func _ready():
	speed = 100
	is_neutral = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_client_owner():
		if !is_on_floor():
			move_and_slide(movement_direciton * speed)
	else:
		global_position = lerp(global_position, target_position, .6) 
