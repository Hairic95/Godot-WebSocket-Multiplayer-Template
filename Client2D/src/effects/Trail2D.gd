extends Line2D

var parent = null

export (Vector2) var offset = Vector2.ZERO
export (int) var length = 20
export (bool) var active = false

var add_point_time_max = .01
var add_point_timer = .0
var remove_point_time_max = .6
var remove_point_timer = .0

func _process(delta):
	global_position = Vector2.ZERO + offset
	if active:
		if parent != null && parent is Node2D:
			rotation_degrees = -parent.rotation_degrees
			var point = parent.global_position
			
			if add_point_timer >= add_point_time_max:
				if get_point_count() >= length && get_point_count() > 0:
					remove_point(0)
				add_point_timer = 0
				add_point(point)
			else:
				add_point_timer += delta
	else:
		if remove_point_timer >= remove_point_time_max:
			if get_point_count() > 0:
				remove_point(0)
		else:
			remove_point_timer += delta
