class_name RoomData extends Resource
## Stores all the data that a Room needs to keep
## When it's unloaded/loaded. Ubiquitous.

class DoorData:
	var orientation:DoorBit.ORI # The orientation of the door.
	var path:String # The room it's connected to.
	
	func _init(with:DoorBit) -> void:
		orientation = with.orientation
		path = with.room_path

## The doors' data.
@export_storage var doors:Array[DoorData]

## The global position of the room
@export var room_position:Vector2
