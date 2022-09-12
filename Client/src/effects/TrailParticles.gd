extends CPUParticles2D


var lifetime_timer = 0

func _ready():
	emitting = true


func _process(delta):
	if lifetime_timer >= lifetime:
		queue_free()
	else:
		lifetime_timer += delta
