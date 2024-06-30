extends Node

var scenes = {
	"network": preload("res://src/scenes/NetworkScene.tscn"),
	"network_platformer": preload("res://src/scenes/NetworkPlatformerScene.tscn"),
}

func _ready():
	EventBus.connect("change_scene", self, "change_scene")
	EventBus.connect("create_scene", self, "create_scene")
	
	change_scene("network")

func change_scene(new_scene_tag, params = null):
	if scenes.has(new_scene_tag):
		for child in $CurrentScene.get_children():
			child.queue_free()
		
		var new_scene = scenes[new_scene_tag].instance()
		$CurrentScene.add_child(new_scene)
		if new_scene_tag == "network" && params != null:
			if params.player_disconnected:
				new_scene.show_player_disconnected()
	else:
		change_scene("main_menu")

func create_scene(scene):
	if scene != null:
		for child in $CurrentScene.get_children():
			child.queue_free()
		
		$CurrentScene.add_child(scene.instance())
	else:
		change_scene("main_menu")
