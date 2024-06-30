extends NetworkBody
class_name NetworkBullet

var trail_particle_effect_reference = load("res://src/effects/BlueTrailParticles.tscn")
var end_bullet_effect_reference = load("res://src/effects/EndBulletEffect.tscn")

var particle_time_max = .02
var particle_timer = .02

export (int) var damage = 1
export (float) var push_force = 80

var latest_delta = 1 / 60

var direction := Vector2.ZERO

var fake_destroy = false

func _ready():
	speed = 600
	$Trail2D.parent = self
	rotation = direction.angle()

func _physics_process(delta):
	if is_client_owner():
		global_position += direction * speed * delta
	else:
		global_position = lerp(global_position, target_position, .6)
		latest_delta = delta
	
	if !fake_destroy:
		if particle_timer >= particle_time_max:
			EventBus.emit_signal("create_effect", trail_particle_effect_reference.instance(), global_position)
			particle_timer = 0
		else:
			particle_timer += delta

func destroy_bullet(destroy_completely = true):
	EventBus.emit_signal("create_effect", end_bullet_effect_reference.instance(), global_position)
	if destroy_completely:
		NetworkSocket.send_message_to_lobby({
			"type": Constants.GenericAction_EntityDeath,
			"owner_id": owner_uuid,
			"entity_id": entity_uuid,
			"entity_type": Constants.EntityType_Bullet,
		})
		queue_free()
	else:
		fake_destroy = true
		hide()

func _on_Hitbox_body_entered(body):
	destroy_bullet()

func remote_entity_death(data):
	if data.entity_id == entity_uuid:
		if !fake_destroy:
			EventBus.emit_signal("create_effect", end_bullet_effect_reference.instance(), global_position)
		.remote_entity_death(data)

func remote_entity_position_update(data):
	if data.entity_id == entity_uuid:
		global_position = Vector2(data.position.x, data.position.y)
		target_position = global_position + speed * direction * latest_delta
