class_name OpenDoorState extends DoorStateBit
## The state of a door that is currently open.

func _on_active():
	door.body.process_mode = Node.PROCESS_MODE_DISABLED
