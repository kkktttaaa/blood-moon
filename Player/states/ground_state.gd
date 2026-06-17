extends PlayerState
class_name GroundState


func physics_update(delta: float) -> void:
	update_player(delta)


func get_next_state() -> StringName:
	if not has_components:
		return &""

	if attack.wants_attack():
		return &"Attack"

	return &"Air" if not actor.is_on_floor() else &""
