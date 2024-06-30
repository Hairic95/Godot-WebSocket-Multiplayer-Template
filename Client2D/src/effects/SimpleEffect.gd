extends Node2D


func _ready():
	$Anim.play("Play")

func _on_Anim_animation_finished(anim_name):
	queue_free()
