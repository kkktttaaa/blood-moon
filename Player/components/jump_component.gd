extends Node
class_name JumpComponent

@export_group("Input")
@export var jump_action := "jump"

@export_group("Jump")
@export var jump_velocity := -300.0
@export var jump_cut_multiplier := 0.45
@export var coyote_time := 0.15
@export var jump_buffer_time := 0.15

@onready var body := get_parent() as CharacterBody2D

var coyote_timer := 0.0
var buffer_timer := 0.0


func _ready() -> void:
	if body == null:
		push_error("%s must be a child of CharacterBody2D." % name)
		set_physics_process(false)


func _physics_process(delta: float) -> void:
	physics_step(delta)


func physics_step(delta: float) -> void:
	update_timers(delta)

	if Input.is_action_just_pressed(jump_action):
		buffer_timer = jump_buffer_time

	if can_jump():
		jump()

	if Input.is_action_just_released(jump_action) and body.velocity.y < 0.0:
		body.velocity.y *= jump_cut_multiplier


func update_timers(delta: float) -> void:
	coyote_timer = coyote_time if body.is_on_floor() else maxf(coyote_timer - delta, 0.0)
	buffer_timer = maxf(buffer_timer - delta, 0.0)


func can_jump() -> bool:
	return coyote_timer > 0.0 and buffer_timer > 0.0


func jump() -> void:
	body.velocity.y = jump_velocity
	coyote_timer = 0.0
	buffer_timer = 0.0
