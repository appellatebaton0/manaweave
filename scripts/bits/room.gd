class_name RoomBit extends Bit
## The bit for a room. Manages everything pertaining to the room.

@export_storage var data:Dictionary

@onready var doors := get_doors()
func get_doors() -> Array[DoorBit]:
	var response:Array[DoorBit]
	
	for child in get_children(): if child is DoorBit: response.append(child)
	
	return response

#func _init() -> void:
	#save()
