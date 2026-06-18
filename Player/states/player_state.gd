extends StateMachineState
class_name PlayerState

@export var movement_path: NodePath = ^"MovementComponent"
@export var jump_path: NodePath = ^"JumpComponent"
@export var animation_path: NodePath = ^"AnimationComponent"
@export var attack_path: NodePath = ^"AttackComponent"
@export var spin_path: NodePath = ^"SpinComponent"

var movement: MovementComponent
var jump: JumpComponent
var animation: AnimationComponent
var attack: AttackComponent
var spin: SpinComponent
var has_components := false


func setup() -> void:
	movement = actor.get_node_or_null(movement_path) as MovementComponent
	jump = actor.get_node_or_null(jump_path) as JumpComponent
	animation = actor.get_node_or_null(animation_path) as AnimationComponent
	attack = actor.get_node_or_null(attack_path) as AttackComponent
	spin = actor.get_node_or_null(spin_path) as SpinComponent

	has_components = movement != null and jump != null and animation != null and attack != null and spin != null
	if not has_components:
		push_error("%s is missing a player component." % name)


func update_player(delta: float, can_jump := true) -> void:
	if not has_components:
		return

	if can_jump:
		jump.physics_step(delta)

	movement.physics_step(delta, movement.get_input_direction())
	animation.physics_step()
