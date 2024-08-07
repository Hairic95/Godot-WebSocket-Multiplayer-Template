extends Position2D

var enemies = []

func is_avaiable():
	return enemies.empty()

func _on_Area2D_area_entered(area):
	var area_parent = area.get_parent()
	if area_parent is NetworkPlatformerPlayer:
		enemies.append(area_parent)

func _on_Area2D_area_exited(area):
	var area_parent = area.get_parent()
	if area_parent is NetworkPlatformerPlayer && enemies.has(area_parent):
		enemies.erase(area_parent)
