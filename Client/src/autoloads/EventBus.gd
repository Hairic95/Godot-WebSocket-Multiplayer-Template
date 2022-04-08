extends Node

signal change_scene(new_scene)
signal create_scene(scene)

signal create_bullet(bullet_instance, start_pos, rotation)
signal create_effect(effect_instance, start_pos)
signal create_paint_mask(mask_global_position, mask_texture, paint_color)

signal player_health_update(current_hit_points, max_hit_points)

signal enemy_death(global_position, enemy_type)
signal player_death()

signal start_screenshake(shake_force)
