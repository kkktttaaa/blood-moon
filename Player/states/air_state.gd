extends PlayerState
class_name AirState


func physics_update(delta: float) -> void:
	if has_components:
		spin.physics_step()

	update_player(delta)


func get_next_state() -> StringName:
	if not has_components:
		return &""

	if attack.wants_attack():
		return &"Attack"

	if spin.requested_this_frame:
		return &"Spin"

	return &"Ground" if actor.is_on_floor() else &""
