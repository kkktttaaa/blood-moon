extends Node
class_name SpinComponent

@export_group("Input")
@export var spin_action := "jump"

@export_group("Spin")
@export var spin_velocity := -260.0
@export var gravity_multiplier := 0.75
@export var max_fall_speed_multiplier := 0.75
@export var animation_name: StringName = &"spin"
@export var detection_radius := 48.0

@export_group("References")
@export var animation_path: NodePath = ^"../AnimationComponent"

@onready var body := get_parent() as CharacterBody2D
@onready var animation := get_node_or_null(animation_path) as AnimationComponent

var is_available := false
var is_spinning := false
var requested_this_frame := false
var near_spin_target_count := 0


func _ready() -> void:
	if body == null or animation == null:
		push_error("%s needs CharacterBody2D and AnimationComponent." % name)
		return

	_setup_detection_area()


func _setup_detection_area() -> void:
	var area := Area2D.new()
	area.name = "SpinDetectionArea"
	area.collision_layer = 0
	area.collision_mask = 1 << 3

	var shape := CircleShape2D.new()
	shape.radius = detection_radius
	var collision := CollisionShape2D.new()
	collision.shape = shape
	collision.debug_color = Color.SKY_BLUE
	area.add_child(collision)

	area.area_entered.connect(_on_detection_entered)
	area.area_exited.connect(_on_detection_exited)
	area.body_entered.connect(_on_detection_entered)
	area.body_exited.connect(_on_detection_exited)

	body.add_child(area)


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
