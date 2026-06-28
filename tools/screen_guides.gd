@tool
extends Node2D
class_name ScreenGuides

@export var screen_size := Vector2i(320, 180):
	set(value):
		screen_size = Vector2i(maxi(value.x, 1), maxi(value.y, 1))
		queue_redraw()

@export_range(1, 100, 1) var columns := 8:
	set(value):
		columns = value
		queue_redraw()

@export_range(1, 100, 1) var rows := 4:
	set(value):
		rows = value
		queue_redraw()

@export var guide_color := Color(1.0, 1.0, 1.0, 0.35):
	set(value):
		guide_color = value
		queue_redraw()

@export_range(1.0, 4.0, 1.0) var line_width := 1.0:
	set(value):
		line_width = value
		queue_redraw()


func _ready() -> void:
	if not Engine.is_editor_hint():
		queue_free()


func _draw() -> void:
	if not Engine.is_editor_hint():
		return

	var left := float(-screen_size.x * columns)
	var right := float(screen_size.x * columns)
	var top := float(-screen_size.y * rows)
	var bottom := float(screen_size.y * rows)

	for column in range(-columns, columns + 1):
		var x := float(column * screen_size.x)
		draw_line(Vector2(x, top), Vector2(x, bottom), guide_color, line_width)

	for row in range(-rows, rows + 1):
		var y := float(row * screen_size.y)
		draw_line(Vector2(left, y), Vector2(right, y), guide_color, line_width)
