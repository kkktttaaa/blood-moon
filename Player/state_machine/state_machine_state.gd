extends Node
class_name StateMachineState

var actor: CharacterBody2D
var state_machine: StateMachine


func setup() -> void:
	pass


func enter() -> void:
	pass


func exit() -> void:
	pass


func physics_update(_delta: float) -> void:
	pass


func get_next_state() -> StringName:
	return &""
