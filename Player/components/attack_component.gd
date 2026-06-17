extends Node
class_name AttackComponent

@export_group("Input")
@export var attack_action := "attack"

@export_group("Animation")
@export var animation_path: NodePath = ^"../AnimationComponent"
@export var attack_1_animation: StringName = &"attack_1"
@export var attack_2_animation: StringName = &"attack_2"

@export_group("Hitbox")
@export var sprite_path: NodePath = ^"../Sprite2D"
@export var hitbox_path: NodePath = ^"../AttackHitbox"
@export var hitbox_shape_path: NodePath = ^"../AttackHitbox/CollisionShape2D"
@export var hitbox_offset := Vector2(13.0, -8.0)

@onready var animation := get_node_or_null(animation_path) as AnimationComponent
@onready var sprite := get_node_or_null(sprite_path) as Sprite2D
@onready var hitbox := get_node_or_null(hitbox_path) as Area2D
@onready var hitbox_shape := get_node_or_null(hitbox_shape_path) as CollisionShape2D

var is_attacking := false
var is_finished := false
var combo_window_open := false
var combo_queued := false
var attack_step := 0


func _ready() -> void:
	disable_hitbox()

	if animation == null or sprite == null or hitbox == null or hitbox_shape == null:
		push_error("%s needs AnimationComponent and attack hitbox shape." % name)


func wants_attack() -> bool:
	return Input.is_action_just_pressed(attack_action)


func start() -> void:
	play_attack(1)


func physics_step() -> void:
	if not is_attacking:
		return

	if attack_step == 1 and combo_window_open and wants_attack():
		combo_queued = true


func play_attack(step: int) -> void:
	if animation == null:
		return

	attack_step = step
	is_attacking = true
	is_finished = false
	combo_window_open = false
	combo_queued = false
	disable_hitbox()

	var animation_name := attack_1_animation if step == 1 else attack_2_animation
	animation.set_animation_override(animation_name)


func open_combo_window() -> void:
	combo_window_open = true


func close_combo_window() -> void:
	combo_window_open = false


func finish_attack() -> void:
	if attack_step == 1 and combo_queued:
		play_attack(2)
		return

	end_attack()


func cancel() -> void:
	end_attack()


func end_attack() -> void:
	is_attacking = false
	is_finished = true
	combo_window_open = false
	combo_queued = false
	disable_hitbox()
	animation.clear_animation_override()


func enable_hitbox() -> void:
	update_hitbox_position()

	if hitbox_shape != null:
		hitbox_shape.disabled = false


func disable_hitbox() -> void:
	if hitbox_shape != null:
		hitbox_shape.disabled = true


func update_hitbox_position() -> void:
	if hitbox == null or sprite == null:
		return

	var facing := -1.0 if sprite.flip_h else 1.0
	hitbox.position = Vector2(hitbox_offset.x * facing, hitbox_offset.y)
