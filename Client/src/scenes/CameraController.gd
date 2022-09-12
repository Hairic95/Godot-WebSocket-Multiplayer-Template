extends Node2D

var latest_force

func _ready():
	randomize()
	EventBus.connect("create_screenshake", self, "start_screenshake")

func start_screenshake(force):
	latest_force = force
	shake(force)
	$Frequency.start()
	$Duration.start()

func shake(force):
	var offset = Vector2(rand_range(-force, force), rand_range(-force, force))
	$ScreenShakerTween.interpolate_property($Camera2D, "offset", $Camera2D.offset, 
			offset, $Frequency.wait_time, 
			Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$ScreenShakerTween.start()

func _on_Frequency_timeout():
	shake(latest_force)

func _on_Duration_timeout():
	$Frequency.stop()
	latest_force = 0
	$ScreenShakerTween.interpolate_property($Camera2D, "offset", $Camera2D.offset, 
			Vector2(0, 0), $Frequency.wait_time)
	$ScreenShakerTween.start()
