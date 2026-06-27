extends Node
class_name SpinComponent

signal started

@export_group("Input")
@export var spin_action := "jump"

@export_group("Spin")
@export var spin_velocity := -260.0
@export var gravity_multiplier := 0.75
@export var max_fall_speed_multiplier := 0.75
@export var animation_name: StringName = &"spin"
@export_range(0, 20, 1) var energy_reward := 1

@export_group("References")
@export var animation_path: NodePath = ^"../AnimationComponent"
@export var detection_area_path: NodePath = ^"../SpinDetectionArea"
@export var energy_path: NodePath = ^"../EnergyComponent"

@onready var body := get_parent() as CharacterBody2D
@onready var animation := get_node_or_null(animation_path) as AnimationComponent
@onready var detection_area := get_node_or_null(detection_area_path) as Area2D
@onready var energy := get_node_or_null(energy_path) as EnergyComponent

var is_available := false
var is_spinning := false
var requested_this_frame := false


func _ready() -> void:
	if body == null or animation == null:
		push_error("%s needs CharacterBody2D and AnimationComponent." % name)

	if detection_area == null:
		push_error("%s is missing detection Area2D." % name)


func _can_trigger_spin() -> bool:
	if is_available:
		return true

	if detection_area == null:
		return false

	for area in detection_area.get_overlapping_areas():
		if _is_spin_target(area):
			return true

	for target_body in detection_area.get_overlapping_bodies():
		if _is_spin_target(target_body):
			return true

	return false


func _is_spin_target(node: Node) -> bool:
	while node != null and node != get_tree().root:
		if node.is_in_group(&"spin_target"):
			return true
		node = node.get_parent()

	return false


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
	if body == null or animation == null:
		return

	is_available = false
	is_spinning = true
	body.velocity.y = spin_velocity
	animation.set_animation_override(animation_name)
	if energy != null:
		energy.restore(energy_reward)
	started.emit()


func finish() -> void:
	is_spinning = false
	if animation != null:
		animation.clear_animation_override()
