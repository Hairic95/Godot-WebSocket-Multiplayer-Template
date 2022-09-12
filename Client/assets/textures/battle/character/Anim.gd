extends Node2D
class_name AnimationHandler

func play_anim(anim_name):
	$Anim.play(anim_name, -1, 1.8)

func get_gun_position():
	return $GunPosition.position
