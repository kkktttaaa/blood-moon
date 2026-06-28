extends Node
class_name HealthComponent

signal changed(current: int, maximum: int)
signal damaged(amount: int)
signal healed(amount: int)
signal died

@export_range(1, 9999, 1) var max_health := 100
@export var start_full := true

var current_health := 0


func _ready() -> void:
	current_health = max_health if start_full else clampi(current_health, 0, max_health)
	changed.emit(current_health, max_health)


func take_damage(amount: int) -> void:
	if amount <= 0 or current_health <= 0:
		return

	var previous := current_health
	current_health = maxi(current_health - amount, 0)
	damaged.emit(previous - current_health)
	changed.emit(current_health, max_health)

	if current_health == 0:
		died.emit()


func heal(amount: int) -> void:
	if amount <= 0 or current_health <= 0:
		return

	var previous := current_health
	current_health = mini(current_health + amount, max_health)
	if current_health == previous:
		return

	healed.emit(current_health - previous)
	changed.emit(current_health, max_health)


func reset() -> void:
	current_health = max_health
	changed.emit(current_health, max_health)


func is_alive() -> bool:
	return current_health > 0
