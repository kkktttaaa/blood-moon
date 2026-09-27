extends Ability


func use(user: Node) -> void:
	print("ABILITY USED")
	print("使用者：", user.name)
