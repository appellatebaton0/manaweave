@tool
class_name RoomBit extends Bit
## The bit for a room. Manages everything pertaining to the room.

@export var data:Dictionary

@export_tool_button("Save") var run_save = save
func save(): 
	print("--")
	if data == null:
		push_error("No data exists to save to!")
		return false
	
	print("Saving...")
	
	## Save the doors
	data.clear()
	data["doors"] = []
	
	for door in doors:
		data["doors"].append({
			"path": door.room_path,
			"orientation": door.orientation
		})
		
		print("Appended ", door)
	
	print("Now ", data.doors)
	
	var me = self
	## Save the global position
	data["room_position"] = me.global_position
	
	print("Saved!")
	return true

@onready var doors := get_doors()
func get_doors() -> Array[DoorBit]:
	var response:Array[DoorBit]
	
	for child in get_children(): if child is DoorBit: response.append(child)
	
	return response

#func _init() -> void:
	#save()
