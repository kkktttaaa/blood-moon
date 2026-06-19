extends PlayerState
class_name DashSlashState


func enter() -> void:
	if has_components:
		dash_slash.start_aiming()


func exit() -> void:
	if has_components:
		dash_slash.finish()


func physics_update(delta: float) -> void:
	if not has_components:
		return

	dash_slash.physics_step(delta)
	animation.physics_step()
	dash_slash.update_visual_direction()


func get_next_state() -> StringName:
	if not has_components or not dash_slash.is_finished():
		return &""

	return &"Ground" if actor.is_on_floor() else &"Air"
