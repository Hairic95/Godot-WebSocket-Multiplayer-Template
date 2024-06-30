extends Node

signal change_scene(new_scene)
signal create_scene(scene)

signal create_bullet(bullet_instance, start_pos, rotation)
signal create_effect(effect_instance, start_pos)

signal create_screenshake(force)

signal player_health_update(current_hit_points)

signal player_death()
signal opponent_death()

signal start_screenshake(shake_force)
