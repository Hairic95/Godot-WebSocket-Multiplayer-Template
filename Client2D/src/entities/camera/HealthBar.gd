extends Node2D


func set_value(value):
	if value < 0 && value > 5:
		return
	
	for i in 5:
		if (i + 1) <= value:
			$Ticks.get_child(i).visible = true
		else:
			$Ticks.get_child(i).visible = false
