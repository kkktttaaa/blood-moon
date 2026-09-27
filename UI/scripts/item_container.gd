extends PanelContainer

@export var unselectStyleBox: StyleBoxFlat
@export var selectStyleBox: StyleBoxFlat
@export var ability_scene: PackedScene
@export var icon: Texture2D

@onready var texture_rect: TextureRect = $TextureRect


func _ready() -> void:
	focus_mode = Control.FOCUS_ALL

	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)

	_on_focus_exited()


func _on_focus_entered() -> void:
	add_theme_stylebox_override("panel", selectStyleBox)


func _on_focus_exited() -> void:
	add_theme_stylebox_override("panel", unselectStyleBox)
