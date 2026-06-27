extends Control
class_name PlayerHUD

@export_group("Layout")
@export var health_size := Vector2(80.0, 5.0)
@export var energy_block_size := Vector2(6.0, 6.0)
@export var energy_gap := 2.0
@export var energy_top := 9.0

@export_group("Colors")
@export var background_color := Color(0.06, 0.06, 0.08, 0.9)
@export var health_color := Color.WHITE
@export var energy_color := Color(1.0, 0.161, 0.38, 1.0)
@export var empty_energy_color := Color("863449")

@export_group("References")
@export var health_path: NodePath = ^"../../HealthComponent"
@export var energy_path: NodePath = ^"../../EnergyComponent"

@onready var health := get_node_or_null(health_path) as HealthComponent
@onready var energy := get_node_or_null(energy_path) as EnergyComponent


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if health == null or energy == null:
		push_error("%s is missing player resource components." % name)
		return

	health.changed.connect(_on_resource_changed)
	energy.changed.connect(_on_resource_changed)
	queue_redraw()


func _draw() -> void:
	if health == null or energy == null:
		return

	var health_ratio := float(health.current_health) / maxf(health.max_health, 1.0)
	draw_rect(Rect2(Vector2.ZERO, health_size), background_color)
	draw_rect(
		Rect2(Vector2.ZERO, Vector2(floorf(health_size.x * health_ratio), health_size.y)),
		health_color
	)

	for index in energy.max_energy:
		var position := Vector2(
			index * (energy_block_size.x + energy_gap),
			energy_top
		)
		var color := energy_color if index < energy.current_energy else empty_energy_color
		draw_rect(Rect2(position, energy_block_size), color)


func _on_resource_changed(_current: int, _maximum: int) -> void:
	queue_redraw()
