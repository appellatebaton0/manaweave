@tool
class_name RoomBit extends Bit
## The bit for a room. Manages everything pertaining to the room.

@export_tool_button("test") var _run_test = test
func test(): print("test success.")


@export_tool_button("Hello world")
var hello_world:
	get: return func(): print("Hello world")

@onready var doors := get_doors()
func get_doors() -> Array[DoorBit]:
	var response:Array[DoorBit]
	
	for child in get_children(): if child is DoorBit: response.append(child)
	
	return response
#
#func _init() -> void:
	#print(self, "'s doors: ", len(test))
#
#func _ready() -> void:
	#print(self, "'s doors: ", doors)
