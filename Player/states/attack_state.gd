extends PlayerState
class_name AttackState

@export var speed_multiplier := 0.45
@export var air_gravity_multiplier := 0.45
@export var air_max_fall_speed_multiplier := 0.55


func enter() -> void:
	if not has_components:
		return

	attack.start()


func exit() -> void:
	if not has_components:
		return

	attack.disable_hitbox()
	animation.clear_animation_override()


func physics_update(delta: float) -> void:
	if not has_components:
		return

	attack.physics_step()
	jump.physics_step(delta)

	if jump.jumped_this_frame:
		attack.cancel()

	movement.physics_step(
		delta,
		movement.get_input_direction(),
		speed_multiplier,
		get_gravity_multiplier(),
		get_max_fall_speed_multiplier()
	)
	animation.physics_step()


func get_next_state() -> StringName:
	if jump.jumped_this_frame:
		return &"Air"

	if not attack.is_finished:
		return &""

	return &"Ground" if actor.is_on_floor() else &"Air"


func get_gravity_multiplier() -> float:
	return 1.0 if actor.is_on_floor() else air_gravity_multiplier


func get_max_fall_speed_multiplier() -> float:
	return 1.0 if actor.is_on_floor() else air_max_fall_speed_multiplier
