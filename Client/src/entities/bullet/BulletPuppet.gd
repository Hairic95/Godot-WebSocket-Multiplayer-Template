extends Area2D
class_name BulletPuppet

var bullet_id = ""
var owner_id = ""

var trail_particle_effect_reference = load("res://src/effects/RedTrailParticles.tscn")
var end_bullet_effect_reference = load("res://src/effects/EndBulletEffect.tscn")

var particle_time_max = .01
var particle_timer = .01

export (int) var damage = 1
export (float) var speed = 600
export (float) var push_force = 80

var direction := Vector2.ZERO

func _ready():
	NetworkSocket.connect("bullet_end", self, "bullet_end")
	$Trail2D.parent = self
	rotation = direction.angle()


func _physics_process(delta):
	global_position += direction * speed * delta
	#global_position = get_global_mouse_position()
	
	if particle_timer >= particle_time_max:
		EventBus.emit_signal("create_effect", trail_particle_effect_reference.instance(), global_position)
		particle_timer = 0
	else:
		particle_timer += delta

func bullet_end(bullet_data):
	if self.bullet_id == bullet_data.bullet_id:
		EventBus.emit_signal("create_effect", end_bullet_effect_reference.instance(), global_position)
		queue_free()


func _on_Bullet_area_entered(area):
	if area.is_in_group("Enemy_Hitbox"):
		EventBus.emit_signal("create_effect", end_bullet_effect_reference.instance(), global_position)
		NetworkSocket.send_message_to_lobby({
			"type": Constants.GenericAction_BulletEnd,
			"bullet_id": bullet_id
		})
		queue_free()


func _on_Bullet_body_entered(body):
	EventBus.emit_signal("create_effect", end_bullet_effect_reference.instance(), global_position)
	queue_free()
