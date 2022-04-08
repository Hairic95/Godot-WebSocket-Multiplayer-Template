extends Node2D
class_name AnimationHandler

export (Texture) var gun_skin = load("res://assets/textures/battle/characters/Mage/mage_gun.png")

func play_anim(anim_name):
	$Anim.play(anim_name, -1, 1.8)

func get_gun_position():
	return $GunPosition.position
