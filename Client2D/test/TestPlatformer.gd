extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	EventBus.connect("create_bullet", self, "create_bullet")
	EventBus.connect("create_effect", self, "create_effect")

func create_bullet(bullet_instance, starting_position, direction):
	bullet_instance.global_position = starting_position
	bullet_instance.direction = direction
	$Bullets.add_child(bullet_instance)

func create_effect(effect_instance, starting_position):
	effect_instance.global_position = starting_position
	$Effects.add_child(effect_instance)
