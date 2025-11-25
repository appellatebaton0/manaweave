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
	TOP_LEFT,    TOP_RIGHT,    
	RIGHT_TOP,    RIGHT_BOTTOM,
	BOTTOM_RIGHT, BOTTOM_LEFT, 
	LEFT_BOTTOM,  LEFT_TOP     
}

## An enum for the possible states of an entrance.
enum ENTRANCE_STATE {
	OPEN,   ## The entrance is open, and can be walked through freely.
	CLOSED, ## The entrance is closed, and can't be walked through until next shuffle.
	LOCKED, ## The entrance is locked, and needs some sort of key to open.
	INVALID ## There is no supported entrance here.
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
	
