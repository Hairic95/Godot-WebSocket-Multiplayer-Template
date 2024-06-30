extends Position2D

var enemies = []

func is_avaiable():
	return enemies.empty()

func _on_Area2D_area_entered(area):
	if area.is_in_group("Enemy_Hitbox"):
		enemies.append(area)

func _on_Area2D_area_exited(area):
	if enemies.has(area):
		enemies.erase(area)
