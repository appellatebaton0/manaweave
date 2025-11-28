class_name RoomBit extends Bit
## The bit for a room. Manages everything pertaining to the room.

@export var room_size := Vector2i(1,1) ## The size of the room.
@export var area:RoomManager.AREAS ## The area of the maze this room belongs in.
@export var locked := false ## Whether or not the room will always stay in the same spot.

@onready var doors := get_doors()
func get_doors() -> Dictionary[RoomManager.ENTRANCES, DoorBit]:
	var response:Dictionary[RoomManager.ENTRANCES, DoorBit]
	
	for child in get_children(): if child is DoorBit:
		response[child.slot] = child
	
	return response
