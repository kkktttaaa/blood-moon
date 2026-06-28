extends Camera2D
class_name ScreenCamera

@export var screen_size := Vector2(320.0, 180.0)
@export var use_viewport_size := true
@export var grid_origin := Vector2.ZERO
@export_range(0.0, 2.0, 0.05) var transition_duration := 0.3
@export var transition_type := Tween.TRANS_QUAD
@export var transition_ease := Tween.EASE_IN_OUT

@onready var target := get_parent() as Node2D

var current_screen := Vector2i.ZERO
var transition: Tween


func _ready() -> void:
	if target == null:
		push_error("%s must be a child of the camera target." % name)
		return

	if use_viewport_size:
		screen_size = get_viewport_rect().size
	screen_size = Vector2(
		maxf(screen_size.x, 1.0),
		maxf(screen_size.y, 1.0)
	)

	top_level = true
	current_screen = get_screen_at(target.global_position)
	global_position = get_screen_center(current_screen)


func _process(_delta: float) -> void:
	if target == null:
		return

	var next_screen := get_screen_at(target.global_position)
	if next_screen != current_screen:
		move_to_screen(next_screen)


func move_to_screen(screen: Vector2i) -> void:
	current_screen = screen
	if transition != null:
		transition.kill()

	var destination := get_screen_center(current_screen)
	if transition_duration <= 0.0:
		global_position = destination
		return

	transition = create_tween()
	transition.set_trans(transition_type)
	transition.set_ease(transition_ease)
	transition.tween_property(self, "global_position", destination, transition_duration)


func get_screen_at(world_position: Vector2) -> Vector2i:
	var local_position := world_position - grid_origin
	return Vector2i(
		floori(local_position.x / screen_size.x),
		floori(local_position.y / screen_size.y)
	)


func get_screen_center(screen: Vector2i) -> Vector2:
	return grid_origin + Vector2(
		(screen.x + 0.5) * screen_size.x,
		(screen.y + 0.5) * screen_size.y
	)
