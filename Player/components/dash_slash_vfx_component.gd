extends Node
class_name DashSlashVFXComponent

@export_group("Trail")
@export var trail_width := 4.0
@export var trail_lifetime := 0.14
@export var trail_color := Color("ff2961ff")
@export var trail_center_offset := Vector2(0.0, -8.0)
@export_range(3, 48, 1) var trail_steps := 25

@export_group("Aim Afterimage")
@export var aim_afterimage_interval := 0.045
@export var aim_afterimage_lifetime := 0.22
@export var aim_afterimage_color := Color(1.0, 0.16, 0.38, 0.55)

@export_group("Speed Lines")
@export var line_spacing := 18.0
@export var line_length := 12.0
@export var line_lifetime := 0.08
@export var line_color := Color(0.88, 0.92, 0.82, 0.9)
@export var line_center_offset := Vector2(0.0, -8.0)

@export_group("Feedback")
@export var release_stop_duration := 0.025
@export var hit_stop_duration := 0.055

@export_group("References")
@export var dash_slash_path: NodePath = ^"../DashSlashComponent"
@export var sprite_path: NodePath = ^"../Sprite2D"

@onready var body := get_parent() as CharacterBody2D
@onready var dash_slash := get_node_or_null(dash_slash_path) as DashSlashComponent
@onready var sprite := get_node_or_null(sprite_path) as Sprite2D

var line_distance := 0.0
var trail_start := Vector2.ZERO
var trail: Polygon2D
var last_aim_afterimage_ms := 0


func _ready() -> void:
	if body == null or dash_slash == null or sprite == null:
		push_error("%s is missing dash slash references." % name)
		return

	dash_slash.dash_started.connect(_on_dash_started)
	dash_slash.dash_finished.connect(_on_dash_finished)
	dash_slash.hit.connect(_on_hit)


func _physics_process(delta: float) -> void:
	if dash_slash.phase == DashSlashComponent.Phase.AIMING:
		_update_aim_afterimage()
		return

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
	last_aim_afterimage_ms = 0
	_create_trail()
	CombatFeedback.hit_stop(release_stop_duration, 0.08)


func _on_dash_finished() -> void:
	line_distance = 0.0
	if is_instance_valid(trail):
		_fade_steps(trail, trail_lifetime)
	trail = null


func _on_hit(_target: Node, _damage: int, _direction: Vector2) -> void:
	CombatFeedback.hit_stop(hit_stop_duration)


func _update_aim_afterimage() -> void:
	var now := Time.get_ticks_msec()
	var interval_ms := int(aim_afterimage_interval * 1000.0)
	if last_aim_afterimage_ms > 0 and now - last_aim_afterimage_ms < interval_ms:
		return

	last_aim_afterimage_ms = now
	_spawn_aim_afterimage()


func _spawn_aim_afterimage() -> void:
	var parent := body.get_parent()
	if parent == null:
		return

	var ghost := Sprite2D.new()
	ghost.texture = sprite.texture
	ghost.region_enabled = sprite.region_enabled
	ghost.region_rect = sprite.region_rect
	ghost.hframes = sprite.hframes
	ghost.vframes = sprite.vframes
	ghost.frame = sprite.frame
	ghost.flip_h = sprite.flip_h
	ghost.flip_v = sprite.flip_v
	ghost.modulate = aim_afterimage_color
	ghost.global_position = sprite.global_position.round()
	ghost.z_index = sprite.z_index - 1
	parent.add_child(ghost)
	_fade_steps(ghost, aim_afterimage_lifetime)


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
	trail.polygon = _build_pixel_trail(
		parent,
		trail_start,
		current,
		perpendicular
	)


func _build_pixel_trail(
	parent: Node2D,
	start: Vector2,
	end: Vector2,
	perpendicular: Vector2
) -> PackedVector2Array:
	var upper := PackedVector2Array()
	var lower := PackedVector2Array()

	for index in range(trail_steps + 1):
		var progress := float(index) / trail_steps
		var point := start.lerp(end, progress)
		var width := sin(progress * PI) * trail_width * 0.5
		var next_progress := float(index + 1) / trail_steps
		var segment_end := start.lerp(end, minf(next_progress, 1.0))

		upper.append(parent.to_local(point + perpendicular * width).round())
		upper.append(parent.to_local(segment_end + perpendicular * width).round())
		lower.append(parent.to_local(point - perpendicular * width).round())
		lower.append(parent.to_local(segment_end - perpendicular * width).round())

	lower.reverse()
	upper.append_array(lower)
	return upper


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
		await get_tree().create_timer(lifetime / 3.0, true, false, true).timeout
		if not is_instance_valid(node):
			return
		node.modulate.a = alpha

	if is_instance_valid(node):
		node.queue_free()
