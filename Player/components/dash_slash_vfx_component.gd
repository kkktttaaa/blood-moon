extends Node
class_name DashSlashVFXComponent

@export_group("Afterimage")
@export var afterimage_spacing := 12.0
@export var afterimage_lifetime := 0.12
@export var afterimage_color := Color("ff29618b")

@export_group("Speed Lines")
@export var line_spacing := 18.0
@export var line_length := 12.0
@export var line_lifetime := 0.08
@export var line_color := Color(0.88, 0.92, 0.82, 0.9)

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

var afterimage_distance := 0.0
var line_distance := 0.0


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
	afterimage_distance += traveled
	line_distance += traveled

	if afterimage_distance >= afterimage_spacing:
		afterimage_distance = 0.0
		_spawn_afterimage()

	if line_distance >= line_spacing:
		line_distance = 0.0
		_spawn_speed_line()


func _on_dash_started(_direction: Vector2) -> void:
	afterimage_distance = afterimage_spacing
	line_distance = line_spacing
	CombatFeedback.hit_stop(release_stop_duration, 0.08)
	CombatFeedback.shake(release_shake_strength, 0.06)


func _on_dash_finished() -> void:
	afterimage_distance = 0.0
	line_distance = 0.0


func _on_hit(_target: Node, _damage: int, _direction: Vector2) -> void:
	CombatFeedback.impact(hit_stop_duration, hit_shake_strength)


func _spawn_afterimage() -> void:
	var ghost := Sprite2D.new()
	ghost.texture = sprite.texture
	ghost.region_enabled = sprite.region_enabled
	ghost.region_rect = sprite.region_rect
	ghost.hframes = sprite.hframes
	ghost.vframes = sprite.vframes
	ghost.frame = sprite.frame
	ghost.flip_h = sprite.flip_h
	ghost.flip_v = sprite.flip_v
	ghost.modulate = afterimage_color
	ghost.global_position = sprite.global_position.round()
	ghost.z_index = sprite.z_index - 1
	body.get_parent().add_child(ghost)
	_fade_steps(ghost, afterimage_lifetime)


func _spawn_speed_line() -> void:
	var line := Line2D.new()
	var direction := dash_slash.direction
	var perpendicular := direction.orthogonal()
	var side := perpendicular * randf_range(-6.0, 6.0)
	var end := body.global_position + side - direction * 8.0
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
