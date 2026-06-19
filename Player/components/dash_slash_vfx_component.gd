extends Node
class_name DashSlashVFXComponent

@export_group("Trail")
@export var trail_width := 4.0
@export var trail_lifetime := 0.14
@export var trail_color := Color("ff2961ff")
@export var trail_center_offset := Vector2(0.0, -8.0)

@export_group("Speed Lines")
@export var line_spacing := 18.0
@export var line_length := 12.0
@export var line_lifetime := 0.08
@export var line_color := Color(0.88, 0.92, 0.82, 0.9)
@export var line_center_offset := Vector2(0.0, -8.0)

@export_group("Feedback")
@export var release_stop_duration := 0.025
@export var release_shake_strength := 1.0
@export var hit_stop_duration := 0.055
@export var hit_shake_strength := 2.0

@export_group("References")
@export var dash_slash_path: NodePath = ^"../DashSlashComponent"
@export var sprite_path: NodePath = ^"../Sprite2D"

@onready var body := get_parent() as CharacterBody2D
@onready var dash_slash := get_node_or_null(dash_slash_path) as DashSlashComponent
@onready var sprite := get_node_or_null(sprite_path) as Sprite2D

var line_distance := 0.0
var trail_start := Vector2.ZERO
var trail: Polygon2D


func _ready() -> void:
	if body == null or dash_slash == null or sprite == null:
		push_error("%s is missing dash slash references." % name)
		return

	dash_slash.dash_started.connect(_on_dash_started)
	dash_slash.dash_finished.connect(_on_dash_finished)
	dash_slash.hit.connect(_on_hit)


func _physics_process(delta: float) -> void:
	if dash_slash.phase != DashSlashComponent.Phase.DASHING:
		return

	var traveled := dash_slash.dash_speed * delta
	line_distance += traveled
	_update_trail()

	if line_distance >= line_spacing:
		line_distance = 0.0
		_spawn_speed_line()


func _on_dash_started(_direction: Vector2) -> void:
	line_distance = line_spacing
	_create_trail()
	CombatFeedback.hit_stop(release_stop_duration, 0.08)
	CombatFeedback.shake(release_shake_strength, 0.06)


func _on_dash_finished() -> void:
	line_distance = 0.0
	if is_instance_valid(trail):
		_fade_steps(trail, trail_lifetime)
	trail = null


func _on_hit(_target: Node, _damage: int, _direction: Vector2) -> void:
	CombatFeedback.impact(hit_stop_duration, hit_shake_strength)


func _create_trail() -> void:
	var parent := body.get_parent() as Node2D
	if parent == null:
		return

	if is_instance_valid(trail):
		trail.queue_free()

	trail_start = (body.global_position + trail_center_offset).round()
	trail = Polygon2D.new()
	trail.color = trail_color
	trail.z_index = sprite.z_index - 1
	parent.add_child(trail)
	_update_trail()


func _update_trail() -> void:
	if not is_instance_valid(trail):
		return

	var parent := trail.get_parent() as Node2D
	if parent == null:
		return

	var direction := dash_slash.direction
	var perpendicular := direction.orthogonal()
	var current := (body.global_position + trail_center_offset).round()
	var middle := ((trail_start + current) * 0.5).round()
	var half_width := trail_width * 0.5
	trail.polygon = PackedVector2Array([
		parent.to_local(trail_start).round(),
		parent.to_local(middle + perpendicular * half_width).round(),
		parent.to_local(current).round(),
		parent.to_local(middle - perpendicular * half_width).round(),
	])


func _spawn_speed_line() -> void:
	var line := Line2D.new()
	var direction := dash_slash.direction
	var perpendicular := direction.orthogonal()
	var side := perpendicular * randf_range(-6.0, 6.0)
	var end := body.global_position + line_center_offset + side - direction * 8.0
	var parent := body.get_parent() as Node2D
	if parent == null:
		return

	line.width = 1.0
	line.default_color = line_color
	line.points = PackedVector2Array([
		parent.to_local(end - direction * line_length).round(),
		parent.to_local(end).round(),
	])
	line.z_index = sprite.z_index - 1
	body.get_parent().add_child(line)
	_fade_steps(line, line_lifetime)


func _fade_steps(node: CanvasItem, lifetime: float) -> void:
	for alpha in [0.65, 0.35, 0.0]:
		await get_tree().create_timer(lifetime / 3.0).timeout
		if not is_instance_valid(node):
			return
		node.modulate.a = alpha

	if is_instance_valid(node):
		node.queue_free()
