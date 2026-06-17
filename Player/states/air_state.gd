extends PlayerState
class_name AirState


func physics_update(delta: float) -> void:
	update_player(delta)


func get_next_state() -> StringName:
	if not has_components:
		return &""

	if attack.wants_attack():
		return &"Attack"

	return &"Ground" if actor.is_on_floor() else &""
