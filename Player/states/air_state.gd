extends PlayerState
class_name AirState


func physics_update(delta: float) -> void:
	if not has_components:
		return

	spin.physics_step()
	if spin.requested_this_frame:
		jump.cancel_buffer()

	update_player(delta, not spin.requested_this_frame)


func get_next_state() -> StringName:
	if not has_components:
		return &""

	if spin.requested_this_frame:
		return &"Spin"

	if attack.wants_attack():
		return &"Attack"

	return &"Ground" if actor.is_on_floor() else &""
