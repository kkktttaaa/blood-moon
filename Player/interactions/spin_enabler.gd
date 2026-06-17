extends Area2D
class_name SpinEnabler


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	var spin := body.get_node_or_null("SpinComponent") as SpinComponent
	if spin != null:
		spin.enable()
