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
@export var detection_area_path: NodePath = ^"../SpinDetectionArea"

@onready var body := get_parent() as CharacterBody2D
@onready var animation := get_node_or_null(animation_path) as AnimationComponent
@onready var detection_area := get_node_or_null(detection_area_path) as Area2D

var is_available := false
var is_spinning := false
var requested_this_frame := false
var near_spin_target_count := 0


func _ready() -> void:
	if body == null or animation == null:
		push_error("%s needs CharacterBody2D and AnimationComponent." % name)
		return

	if detection_area == null:
		push_error("%s is missing detection Area2D." % name)
		return

	detection_area.area_entered.connect(_on_detection_entered)
	detection_area.area_exited.connect(_on_detection_exited)
	detection_area.body_entered.connect(_on_detection_entered)
	detection_area.body_exited.connect(_on_detection_exited)


func _on_detection_entered(node: Node2D) -> void:
	if node.is_in_group(&"spin_target"):
		near_spin_target_count += 1


func _on_detection_exited(node: Node2D) -> void:
	if node.is_in_group(&"spin_target"):
		near_spin_target_count = maxi(0, near_spin_target_count - 1)


func _can_trigger_spin() -> bool:
	return is_available or near_spin_target_count > 0


func physics_step() -> void:
	requested_this_frame = false

	if body == null:
		return

	if body.is_on_floor():
		reset()
		return

	requested_this_frame = _can_trigger_spin() and Input.is_action_just_pressed(spin_action)


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
