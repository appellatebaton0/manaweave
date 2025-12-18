@tool
class_name RoomBit extends Bit
## The bit for a room. Manages everything pertaining to the room.

@export_storage var test:int = 1
@export var data:RoomData

@export_tool_button("Save") var run_save = save
func save(): 
	print("--")
	if data == null:
		print("No data existed, creating...")
		data = RoomData.new()
	
	print("Saving...")
	
	## Save the doors
	data.doors.clear()
	for door in doors:
		data.doors.append(data.DoorData.new(door))
	
	var me = self
	## Save the global position
	data.room_position = me.global_position
	
	print("Saved!")

@onready var doors := get_doors()
func get_doors() -> Array[DoorBit]:
	var response:Array[DoorBit]
	
	for child in get_children(): if child is DoorBit: response.append(child)
	
	return response

func _init() -> void:
	save()
