extends Node
class_name JumpComponent

signal jumped

@export_group("Input")
@export var jump_action := "jump"

@export_group("Jump")
@export var jump_velocity := -300.0
@export var jump_cut_multiplier := 0.45
@export_range(1, 8, 1) var max_jump_count := 1
@export var coyote_time := 0.15
@export var jump_buffer_time := 0.15

@export_group("Fall")
@export var fall_gravity_multiplier := 1.2
@export var fall_speed_multiplier := 1.35

@onready var body := get_parent() as CharacterBody2D

var coyote_timer := 0.0
var buffer_timer := 0.0
var jump_count := 0
var jumped_this_frame := false


func _ready() -> void:
	if body == null:
		push_error("%s must be a child of CharacterBody2D." % name)


func physics_step(delta: float) -> void:
	jumped_this_frame = false

	if body == null:
		return

	update_timers(delta)

	if Input.is_action_just_pressed(jump_action):
		buffer_timer = jump_buffer_time

	if can_jump():
		jump()

	if Input.is_action_just_released(jump_action) and body.velocity.y < 0.0:
		body.velocity.y *= jump_cut_multiplier


func update_timers(delta: float) -> void:
	if body.is_on_floor():
		coyote_timer = coyote_time
		jump_count = 0
	else:
		coyote_timer = maxf(coyote_timer - delta, 0.0)
		if coyote_timer <= 0.0 and jump_count == 0:
			jump_count = 1

	buffer_timer = maxf(buffer_timer - delta, 0.0)


func can_jump() -> bool:
	return buffer_timer > 0.0 and (
		coyote_timer > 0.0
		or jump_count < max_jump_count
	)


func get_gravity_multiplier(base_multiplier := 1.0) -> float:
	return base_multiplier * fall_gravity_multiplier if body.velocity.y > 0.0 else base_multiplier


func get_fall_speed_multiplier(base_multiplier := 1.0) -> float:
	return base_multiplier * fall_speed_multiplier if body.velocity.y > 0.0 else base_multiplier


func cancel_buffer() -> void:
	buffer_timer = 0.0


func jump() -> void:
	body.velocity.y = jump_velocity
	coyote_timer = 0.0
	buffer_timer = 0.0
	jump_count += 1
	jumped_this_frame = true
	jumped.emit()
