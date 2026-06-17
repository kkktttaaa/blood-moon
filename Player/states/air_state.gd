extends PlayerState
class_name AirState


func physics_update(delta: float) -> void:
	update_player(delta)


func get_next_state() -> StringName:
	return &"Ground" if actor.is_on_floor() else &""
