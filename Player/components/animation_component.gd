extends Node
class_name AnimationComponent

@export var sprite_path: NodePath = ^"../Sprite2D"
@export var animation_player_path: NodePath = ^"../AnimationPlayer"

@export_group("Animations")
@export var idle_animation: StringName = &"idle"
@export var run_animation: StringName = &"run"
@export var jump_animation: StringName = &"up"
@export var transition_animation: StringName = &"tran"
@export var fall_animation: StringName = &"down"

@export var horizontal_deadzone := 5.0
@export var apex_deadzone := 70.0

@onready var body := get_parent() as CharacterBody2D
@onready var sprite := get_node_or_null(sprite_path) as Sprite2D
@onready var animation_player := get_node_or_null(animation_player_path) as AnimationPlayer

var animation_override: StringName = &""


func _ready() -> void:
	if body == null or sprite == null or animation_player == null:
		push_error("%s needs CharacterBody2D, Sprite2D, and AnimationPlayer." % name)


func physics_step() -> void:
	if body == null or sprite == null or animation_player == null:
		return

	update_facing()
	play(animation_override if animation_override != &"" else get_locomotion_animation())


func set_animation_override(animation: StringName, restart := false) -> void:
	animation_override = animation
	if restart and animation_player != null and animation_player.has_animation(animation):
		animation_player.play(animation)


func clear_animation_override() -> void:
	animation_override = &""


func update_facing() -> void:
	if absf(body.velocity.x) > horizontal_deadzone:
		sprite.flip_h = body.velocity.x < 0.0


func get_locomotion_animation() -> StringName:
	if not body.is_on_floor():
		if absf(body.velocity.y) <= apex_deadzone:
			return transition_animation

		return jump_animation if body.velocity.y < 0.0 else fall_animation

	if absf(body.velocity.x) > horizontal_deadzone:
		return run_animation

	return idle_animation


func play(animation: StringName) -> void:
	if animation_player.current_animation == animation:
		return

	if animation_player.has_animation(animation):
		animation_player.play(animation)
