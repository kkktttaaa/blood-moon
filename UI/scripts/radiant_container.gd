@tool
extends Control

@export var radius: float = 50.0:
	set(value):
		radius = value
		_refresh()


var selected_index := 0


func _ready() -> void:
	visible = false

	child_entered_tree.connect(_refresh)
	child_exiting_tree.connect(_on_child_exiting)

	_refresh()


func _refresh(_child = null) -> void:
	if get_child_count() == 0:
		return

	var spacing := TAU / get_child_count()

	for child: Control in get_children():
		var index := child.get_index()
		var angle := spacing * index - PI / 2.0
		var target_direction := Vector2(radius, 0).rotated(angle)

		child.position = target_direction - child.size / 2.0


func _on_child_exiting(_node) -> void:
	await get_tree().process_frame
	_refresh()


func grab_first_item() -> void:
	if get_child_count() == 0:
		return

	selected_index = 0
	get_child(selected_index).grab_focus()


func _input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return

	if event.is_action_pressed("aim_up"):
		_select_direction(Vector2.UP)

	elif event.is_action_pressed("aim_down"):
		_select_direction(Vector2.DOWN)

	elif event.is_action_pressed("move_left"):
		_select_direction(Vector2.LEFT)

	elif event.is_action_pressed("move_right"):
		_select_direction(Vector2.RIGHT)

	elif event.is_action_released("ability_menu"):
		_select_item()


func _select_direction(direction: Vector2) -> void:
	if get_child_count() == 0:
		return

	var best_index := selected_index
	var best_dot := -1.0

	for child: Control in get_children():
		var index := child.get_index()

		var center := child.position + child.size / 2.0
		var menu_center := size / 2.0

		var child_direction := (center - menu_center).normalized()

		var dot := child_direction.dot(direction)

		if dot > best_dot:
			best_dot = dot
			best_index = index

	selected_index = best_index

	get_child(selected_index).grab_focus()


func _select_item() -> void:
	if get_child_count() == 0:
		return

	var selected_node = get_child(selected_index)

	if selected_node == null:
		return

	var selected_scene: PackedScene = selected_node.ability_scene

	if selected_scene == null:
		return

	var ability_component = get_tree().get_first_node_in_group(
		"ability_component"
	)

	if ability_component:
		ability_component.set_selected_ability(selected_scene)

	visible = false
