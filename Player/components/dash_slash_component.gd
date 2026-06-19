extends Node
class_name DashSlashComponent

signal hit(target: Node, damage: int, direction: Vector2)
signal dash_started(direction: Vector2)
signal dash_finished

enum Phase {
	IDLE,
	AIMING,
	DASHING,
	FINISHED,
}

@export_group("Input")
@export var attack_action := "attack"
@export var aim_left_action := "move_left"
@export var aim_right_action := "move_right"
@export var aim_up_action := "aim_up"
@export var aim_down_action := "aim_down"
@export var stick_deadzone := 0.35

@export_group("Aim")
@export_range(0.05, 1.0, 0.05) var aim_time_scale := 0.2
@export var aim_speed_multiplier := 0.25
@export var aim_gravity_multiplier := 0.25
@export var aim_fall_speed_multiplier := 0.35
@export var aim_entry_velocity_multiplier := 0.35

@export_group("Dash")
@export var dash_speed := 420.0
@export var dash_distance := 60.0
@export var exit_speed := 200.0
@export var damage := 2
@export var hitbox_offset := 13.0
@export var animation_name: StringName = &"dash_slash"

@export_group("Visual")
@export var effect_center_offset := Vector2(0.0, -8.0)
@export var effect_distance := 14.0

@export_group("References")
@export var movement_path: NodePath = ^"../MovementComponent"
@export var animation_path: NodePath = ^"../AnimationComponent"
@export var sprite_path: NodePath = ^"../Sprite2D"
@export var hitbox_path: NodePath = ^"../AttackHitbox"
@export var hitbox_shape_path: NodePath = ^"../AttackHitbox/CollisionShape2D"
@export var effect_scene: PackedScene

@onready var body := get_parent() as CharacterBody2D
@onready var movement := get_node_or_null(movement_path) as MovementComponent
@onready var animation := get_node_or_null(animation_path) as AnimationComponent
@onready var sprite := get_node_or_null(sprite_path) as Sprite2D
@onready var hitbox := get_node_or_null(hitbox_path) as Area2D
@onready var hitbox_shape := get_node_or_null(hitbox_shape_path) as CollisionShape2D

var phase := Phase.IDLE
var direction := Vector2.RIGHT
var distance_traveled := 0.0
var previous_time_scale := 1.0
var effect: AnimatedSprite2D
var hit_targets: Dictionary = {}


func _ready() -> void:
	if body == null or movement == null or animation == null or sprite == null:
		push_error("%s is missing player references." % name)

	if hitbox == null or hitbox_shape == null:
		push_error("%s is missing an attack hitbox." % name)
		return

	hitbox.area_entered.connect(_on_hitbox_entered)
	hitbox.body_entered.connect(_on_hitbox_entered)


func _exit_tree() -> void:
	_restore_time_scale()


func start_aiming() -> void:
	if body == null:
		return

	phase = Phase.AIMING
	direction = _get_initial_direction()
	body.velocity *= aim_entry_velocity_multiplier
	previous_time_scale = Engine.time_scale
	Engine.time_scale = aim_time_scale
	animation.set_animation_override(animation_name, true)
	_spawn_effect()
	if is_instance_valid(effect):
		effect.modulate.a = 0.45
	update_visual_direction()


func physics_step(delta: float) -> void:
	match phase:
		Phase.AIMING:
			_update_aim()
			movement.physics_step(
				delta,
				movement.get_input_direction(),
				aim_speed_multiplier,
				aim_gravity_multiplier,
				aim_fall_speed_multiplier
			)

			if Input.is_action_just_released(attack_action):
				_start_dash()
		Phase.DASHING:
			_dash(delta)


func finish() -> void:
	_restore_time_scale()
	_disable_hitbox()
	_clear_effect()
	animation.clear_animation_override()
	phase = Phase.IDLE


func is_finished() -> bool:
	return phase == Phase.FINISHED


func _update_aim() -> void:
	var stick := Input.get_vector(
		aim_left_action,
		aim_right_action,
		aim_up_action,
		aim_down_action
	)
	if stick.length() >= stick_deadzone:
		direction = stick.normalized()
	else:
		var mouse_direction := body.get_global_mouse_position() - body.global_position
		if not mouse_direction.is_zero_approx():
			direction = mouse_direction.normalized()

	update_visual_direction()


func _get_initial_direction() -> Vector2:
	var mouse_direction := body.get_global_mouse_position() - body.global_position
	if not mouse_direction.is_zero_approx():
		return mouse_direction.normalized()

	return Vector2.LEFT if sprite.flip_h else Vector2.RIGHT


func _start_dash() -> void:
	_restore_time_scale()
	phase = Phase.DASHING
	distance_traveled = 0.0
	hit_targets.clear()
	body.velocity = direction * dash_speed
	_enable_hitbox()
	if is_instance_valid(effect):
		effect.modulate.a = 1.0
	dash_started.emit(direction)


func _dash(delta: float) -> void:
	body.velocity = direction * dash_speed
	body.move_and_slide()
	distance_traveled += dash_speed * delta

	if body.get_slide_collision_count() > 0 or distance_traveled >= dash_distance:
		phase = Phase.FINISHED
		_disable_hitbox()
		_clear_effect()
		body.velocity = direction * exit_speed
		dash_finished.emit()


func _enable_hitbox() -> void:
	hitbox.position = direction * hitbox_offset + Vector2(0.0, -8.0)
	hitbox.rotation = direction.angle()
	hitbox_shape.set_deferred("disabled", false)


func _disable_hitbox() -> void:
	if hitbox_shape != null:
		hitbox_shape.set_deferred("disabled", true)

	if hitbox != null:
		hitbox.rotation = 0.0


func _on_hitbox_entered(collider: Node) -> void:
	if phase != Phase.DASHING:
		return

	var target := _find_damage_target(collider)
	if target == null or hit_targets.has(target.get_instance_id()):
		return

	hit_targets[target.get_instance_id()] = true
	if target.has_method("take_damage"):
		target.call("take_damage", damage)
	hit.emit(target, damage, direction)


func _find_damage_target(node: Node) -> Node:
	while node != null and node != get_tree().root:
		if (
			node.has_method("take_damage")
			or node.is_in_group(&"damageable")
			or node.is_in_group(&"enemy")
			or node.is_in_group(&"spin_target")
		):
			return node
		node = node.get_parent()

	return null


func _spawn_effect() -> void:
	if effect_scene == null:
		return

	effect = effect_scene.instantiate() as AnimatedSprite2D
	if effect == null:
		return

	body.add_child(effect)
	effect.frame = 0
	effect.frame_progress = 0.0
	effect.play()
	update_visual_direction()


func update_visual_direction() -> void:
	sprite.flip_h = direction.x < 0.0

	if not is_instance_valid(effect):
		return

	effect.position = effect_center_offset + direction * effect_distance
	effect.rotation = direction.angle()
	effect.flip_v = direction.x < 0.0


func _clear_effect() -> void:
	if is_instance_valid(effect):
		effect.queue_free()
	effect = null


func _restore_time_scale() -> void:
	if phase == Phase.AIMING:
		Engine.time_scale = previous_time_scale
