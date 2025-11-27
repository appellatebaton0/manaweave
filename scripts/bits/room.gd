class_name RoomBit extends Bit
## The bit for a room. Manages everything pertaining to the room.

@onready var doors := get_doors()
func get_doors() -> Dictionary[RoomManager.ENTRANCES, DoorBit]:
	var response:Dictionary[RoomManager.ENTRANCES, DoorBit]
	
	for child in get_children(): if child is DoorBit:
		response[child.slot] = child
	
	return response
