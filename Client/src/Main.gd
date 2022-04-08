extends Node

var scenes = {
	"network": preload("res://src/scenes/NetworkScene.tscn"),
	"network_battle": preload("res://src/scenes/NetworkBattleScene.tscn")
}

func _ready():
	EventBus.connect("change_scene", self, "change_scene")
	EventBus.connect("create_scene", self, "create_scene")
	
	change_scene("network")

func change_scene(new_scene):
	if scenes.has(new_scene):
		for child in $CurrentScene.get_children():
			child.queue_free()
		
		$CurrentScene.add_child(scenes[new_scene].instance())
	else:
		change_scene("main_menu")

func create_scene(scene):
	if scene != null:
		for child in $CurrentScene.get_children():
			child.queue_free()
		
		$CurrentScene.add_child(scene.instance())
	else:
		change_scene("main_menu")
