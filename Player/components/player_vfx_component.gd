extends Node
class_name PlayerVFXComponent

@export_group("Effects")
@export var jump_dust_scene: PackedScene
@export var land_dust_scene: PackedScene
@export var spin_effect_scene: PackedScene
@export var spin_aura_scene: PackedScene
var spin_aura: AnimatedSprite2D

@export_group("References")
@export var movement_path: NodePath = ^"../MovementComponent"
@export var jump_path: NodePath = ^"../JumpComponent"
@export var spin_path: NodePath = ^"../SpinComponent"
@export var feet_marker_path: NodePath = ^"../VFXMarkers/Feet"
@export var center_marker_path: NodePath = ^"../VFXMarkers/Center"

@onready var body := get_parent() as CharacterBody2D
@onready var movement := get_node_or_null(movement_path) as MovementComponent
@onready var jump := get_node_or_null(jump_path) as JumpComponent
@onready var spin := get_node_or_null(spin_path) as SpinComponent
@onready var feet_marker := get_node_or_null(feet_marker_path) as Marker2D
@onready var center_marker := get_node_or_null(center_marker_path) as Marker2D


func _ready() -> void:
	if body == null or movement == null or jump == null or spin == null:
		push_error("%s is missing a player component." % name)
		return

	if feet_marker == null or center_marker == null:
		push_error("%s is missing a VFX marker." % name)
		return

	jump.jumped.connect(_on_jumped)
	movement.landed.connect(_on_landed)
	spin.started.connect(_on_spin_started)
	spin.finished.connect(_on_spin_finished)

func _on_jumped() -> void:
	_spawn(jump_dust_scene, feet_marker)


func _on_landed() -> void:
	_spawn(land_dust_scene, feet_marker)


func _on_spin_started() -> void:
	_spawn(spin_effect_scene, center_marker)
	_start_spin_aura()

func _start_spin_aura() -> void:
	if spin_aura_scene == null:
		return

	if spin_aura != null:
		return

	spin_aura = spin_aura_scene.instantiate() as AnimatedSprite2D

	if spin_aura == null:
		return

	body.add_child(spin_aura)

	spin_aura.position = center_marker.position
	spin_aura.play()

func _on_spin_finished() -> void:
	_stop_spin_aura()

func _stop_spin_aura() -> void:
	if spin_aura == null:
		return

	spin_aura.queue_free()
	spin_aura = null

func _spawn(scene: PackedScene, marker: Marker2D) -> void:
	if scene == null or marker == null or body.get_parent() == null:
		return

	var effect := scene.instantiate() as AnimatedSprite2D
	if effect == null:
		push_error("%s expects an AnimatedSprite2D effect root." % name)
		return

	body.get_parent().add_child(effect)
	effect.global_position = marker.global_position
	effect.animation_finished.connect(effect.queue_free)
	effect.frame = 0
	effect.frame_progress = 0.0
	effect.play()
