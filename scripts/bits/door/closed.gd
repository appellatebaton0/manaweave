class_name ClosedDoorState extends DoorStateBit
## The state of a door that is currently closed.


func _on_active():
	door.body.process_mode = Node.PROCESS_MODE_PAUSABLE
#
#func _active(_delta:float):
	#if door.user_in_range and Input.is_action_just_pressed("Interact") and on_interact != null:
		#print("")
		#door.change_state(on_interact)
