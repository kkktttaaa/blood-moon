extends Node
class_name StateMachine

@export var initial_state: NodePath

@onready var actor := get_parent() as CharacterBody2D

var current_state: StateMachineState


func _ready() -> void:
	if actor == null:
		push_error("%s must be a child of CharacterBody2D." % name)
		set_physics_process(false)
		return

	for child in get_children():
		var state := child as StateMachineState
		if state == null:
			continue

		state.actor = actor
		state.state_machine = self
		state.setup()

	var state := get_node_or_null(initial_state) as StateMachineState
	if state == null:
		state = get_first_state()

	if state == null:
		push_error("%s has no StateMachineState children." % name)
		set_physics_process(false)
		return

	transition_to(state.name)


func _physics_process(delta: float) -> void:
	if current_state == null:
		return

	current_state.physics_update(delta)

	var next_state := current_state.get_next_state()
	if next_state != &"":
		transition_to(next_state)


func transition_to(state_name: StringName) -> void:
	var next_state := get_node_or_null(String(state_name)) as StateMachineState
	if next_state == null or next_state == current_state:
		return

	if current_state != null:
		current_state.exit()

	current_state = next_state
	current_state.enter()


func get_first_state() -> StateMachineState:
	for child in get_children():
		var state := child as StateMachineState
		if state != null:
			return state

	return null
