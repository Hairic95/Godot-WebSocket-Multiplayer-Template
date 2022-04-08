extends Area2D
class_name PlayerBullet

var bullet_id = ""

export (int) var damage = 1
export (float) var speed = 1800
export (float) var push_force = 80

var direction := Vector2.ZERO

func _ready():
	bullet_id = Uuid.v4()
	rotation = direction.angle()

func _physics_process(delta):
	global_position += direction * speed * delta

func _on_Bullet_body_entered(body):
	queue_free()

func _on_Bullet_area_entered(area):
	queue_free()
