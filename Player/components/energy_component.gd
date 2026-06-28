extends Node
class_name EnergyComponent

signal changed(current: int, maximum: int)

@export_range(1, 20, 1) var max_energy := 5
@export var start_full := true

var current_energy := 0


func _ready() -> void:
	current_energy = max_energy if start_full else clampi(current_energy, 0, max_energy)
	changed.emit(current_energy, max_energy)


func can_spend(amount := 1) -> bool:
	return amount >= 0 and current_energy >= amount


func spend(amount := 1) -> bool:
	if amount <= 0:
		return true

	if not can_spend(amount):
		return false

	current_energy -= amount
	changed.emit(current_energy, max_energy)
	return true


func restore(amount := 1) -> void:
	if amount <= 0:
		return

	var next := mini(current_energy + amount, max_energy)
	if next == current_energy:
		return

	current_energy = next
	changed.emit(current_energy, max_energy)


func reset() -> void:
	current_energy = max_energy
	changed.emit(current_energy, max_energy)
