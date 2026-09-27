extends Node
class_name AbilityComponent


@export var use_action := "use_item"
@export var menu_action := "ability_menu"

@onready var ability_menu = $"../RadiantContainer"

var selected_ability: PackedScene


func _ready() -> void:
	add_to_group("ability_component")

	ability_menu.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(menu_action):
		_open_ability_menu()

	elif event.is_action_pressed(use_action):
		use_selected_ability()


func _open_ability_menu() -> void:
	ability_menu.visible = true
	ability_menu.grab_first_item()


func set_selected_ability(ability_scene: PackedScene) -> void:
	selected_ability = ability_scene


func use_selected_ability() -> void:
	if selected_ability == null:
		return

	var ability = selected_ability.instantiate()

	get_parent().add_child(ability)

	ability.use(get_parent())

	ability.queue_free()
