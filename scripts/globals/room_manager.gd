extends Node

const ROOM_PATH = "res://scenes/rooms/"

const ROOM_SIZE = 128
const TILE_SIZE = 128
const ROOM_PIXEL_SIZE = ROOM_SIZE * TILE_SIZE

## An enum for the possible open entrances of a room, arranged clockwise from top left.
## Rooms have 8 entrances; (each X is an entrance)
## / X - X \
## X       X
## |       |
## X       X
## \ X - X /
enum ENTRANCES {
	TOP_LEFT,     ## The entrance on the left of the top side.
	TOP_RIGHT,    ## The entrance on the right of the top side.
	RIGHT_TOP,    ## The entrance on the top of the right side.
	RIGHT_BOTTOM, ## The entrance on the bottom of the right side.
	BOTTOM_RIGHT, ## The entrance on the right of the bottom side.
	BOTTOM_LEFT,  ## The entrance on the left of the bottom side.
	LEFT_BOTTOM,  ## The entrance on the bottom of the left side.
	LEFT_TOP      ## The entrance on the top of the left side.
}

@onready var room_paths := get_room_paths()
func get_room_paths(path := ROOM_PATH) -> PackedStringArray:
	
	var paths:PackedStringArray = []
	
	var dir = DirAccess.open(path)
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			## Add any files from subfolders.
			if dir.current_is_dir(): paths.append_array(get_room_paths(path + file_name + "/"))
			## Add any files in the given folder.
			else: paths.append(path + file_name)
			
			file_name = dir.get_next()
	else:
		push_error("An error occurred when trying to access the path: ", path)
	return paths

func _ready() -> void:
	## Make sure there are rooms to load... please...
	assert(len(room_paths) > 0, "No rooms found in "+ ROOM_PATH)
	
