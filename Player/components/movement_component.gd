extends Node
class_name MovementComponent

signal landed

@export_group("Input")
@export var left_action := "move_left"
@export var right_action := "move_right"

@export_group("Horizontal")
@export var max_speed := 120.0
@export var acceleration := 900.0
@export var deceleration := 1200.0
@export var turn_acceleration := 1800.0

@export_group("Vertical")
@export var gravity := 900.0
@export var max_fall_speed := 240.0

@onready var body := get_parent() as CharacterBody2D

var floor_state_initialized := false
var was_on_floor := false


func _ready() -> void:
	if body == null:
		push_error("%s must be a child of CharacterBody2D." % name)


func get_input_direction() -> float:
	if body == null:
		return 0.0

	return Input.get_axis(left_action, right_action)


func physics_step(
	delta: float,
	direction: float,
	speed_multiplier := 1.0,
	gravity_multiplier := 1.0,
	max_fall_speed_multiplier := 1.0
) -> void:
	if body == null:
		return

	apply_horizontal(delta, direction, speed_multiplier)
	apply_gravity(delta, gravity_multiplier, max_fall_speed_multiplier)
	body.move_and_slide()
	update_floor_state()


func update_floor_state() -> void:
	var is_on_floor := body.is_on_floor()
	if floor_state_initialized and not was_on_floor and is_on_floor:
		landed.emit()

	was_on_floor = is_on_floor
	floor_state_initialized = true


func apply_horizontal(delta: float, direction: float, speed_multiplier := 1.0) -> void:
	var target_speed := direction * max_speed * speed_multiplier
	var rate := acceleration if direction != 0.0 else deceleration

	if direction != 0.0 and not is_zero_approx(body.velocity.x) and signf(body.velocity.x) != signf(direction):
		rate = turn_acceleration

	body.velocity.x = move_toward(body.velocity.x, target_speed, rate * delta)


func apply_gravity(delta: float, gravity_multiplier := 1.0, max_fall_speed_multiplier := 1.0) -> void:
	if body.is_on_floor() and body.velocity.y > 0.0:
		body.velocity.y = 0.0
		return

	var fall_speed := max_fall_speed * max_fall_speed_multiplier
	body.velocity.y = minf(body.velocity.y + gravity * gravity_multiplier * delta, fall_speed)
