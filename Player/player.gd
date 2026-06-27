extends CharacterBody2D

@onready var health := $HealthComponent as HealthComponent


func take_damage(amount: int) -> void:
	var previous := health.current_health
	health.take_damage(amount)
	if health.current_health < previous:
		CombatFeedback.impact()


func heal(amount: int) -> void:
	health.heal(amount)
