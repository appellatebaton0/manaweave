class_name OpenDoorState extends DoorStateBit
## The state of a door that is currently open.

func _on_user_entered(_user:Bot) -> void:
	print("ENTERED")

func _on_user_interact() -> void:
	print("INTERACT -> ", self)
	door.pass_through()
	
