extends Node
class_name MovementComponent

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


func _ready() -> void:
	if body == null:
		push_error("%s must be a child of CharacterBody2D." % name)
		set_physics_process(false)


func _physics_process(delta: float) -> void:
	physics_step(delta, Input.get_axis(left_action, right_action))


func physics_step(delta: float, direction: float) -> void:
	apply_horizontal(delta, direction)
	apply_gravity(delta)
	body.move_and_slide()


func apply_horizontal(delta: float, direction: float) -> void:
	var target_speed := direction * max_speed
	var rate := acceleration if direction != 0.0 else deceleration

	if direction != 0.0 and not is_zero_approx(body.velocity.x) and signf(body.velocity.x) != signf(direction):
		rate = turn_acceleration

	body.velocity.x = move_toward(body.velocity.x, target_speed, rate * delta)


func apply_gravity(delta: float) -> void:
	if body.is_on_floor() and body.velocity.y > 0.0:
		body.velocity.y = 0.0
		return

	body.velocity.y = minf(body.velocity.y + gravity * delta, max_fall_speed)
