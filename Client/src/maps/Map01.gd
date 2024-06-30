extends Node2D

func get_respawn_points():
	return $RespawnPoints.get_children()

func set_camera_active(value):
	$Camera2D.current = value
