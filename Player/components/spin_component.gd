extends Node
class_name SpinComponent

@export_group("Input")
@export var spin_action := "jump"

@export_group("Spin")
@export var spin_velocity := -260.0
@export var gravity_multiplier := 0.75
@export var max_fall_speed_multiplier := 0.75
@export var animation_name: StringName = &"spin"

@export_group("References")
@export var animation_path: NodePath = ^"../AnimationComponent"

@onready var body := get_parent() as CharacterBody2D
@onready var animation := get_node_or_null(animation_path) as AnimationComponent

var is_available := false
var is_spinning := false
var requested_this_frame := false


func _ready() -> void:
	if body == null or animation == null:
		push_error("%s needs CharacterBody2D and AnimationComponent." % name)


func physics_step() -> void:
	requested_this_frame = false

	if body == null:
		return

	if body.is_on_floor():
		reset()
		return

	requested_this_frame = is_available and Input.is_action_just_pressed(spin_action)


func enable() -> void:
	is_available = true


func reset() -> void:
	is_available = false
	is_spinning = false
	requested_this_frame = false


func start() -> void:
	is_available = false
	is_spinning = true
	body.velocity.y = spin_velocity
	animation.set_animation_override(animation_name)


func finish() -> void:
	is_spinning = false
	animation.clear_animation_override()
