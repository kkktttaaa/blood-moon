extends PlayerState
class_name SpinState


func enter() -> void:
	if not has_components:
		return

	spin.start()


func exit() -> void:
	if not has_components:
		return

	spin.finish()


func physics_update(delta: float) -> void:
	if not has_components:
		return

	spin.physics_step()

	if spin.requested_this_frame:
		spin.finish()
		spin.start()

	movement.physics_step(
		delta,
		movement.get_input_direction(),
		1.0,
		spin.gravity_multiplier,
		spin.max_fall_speed_multiplier
	)
	animation.physics_step()


func get_next_state() -> StringName:
	if actor.is_on_floor():
		return &"Ground"

	return &""
