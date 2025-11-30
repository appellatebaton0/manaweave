extends Node

const ROOM_PATH = "res://scenes/rooms/"

const ROOM_SIZE := 128
const TILE_SIZE := 128
const ROOM_PIXEL_SIZE := ROOM_SIZE * TILE_SIZE

@onready var PARENT:Node = get_tree().get_first_node_in_group("RoomParent")

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

## An enum for the areas.
enum AREAS {BRASS=0}

class area_data:
	
	func _by_area(a:RoomBit, b:RoomBit) -> bool:
		var aa = a.room_size.x * a.room_size.y
		var ba = b.room_size.x * b.room_size.y
		return aa >= ba
	func shuffle() -> void:
		
		## Shuffles all the rooms within the area.
		
		var rooms:Array[RoomBit]
		
		for key in data.keys():
			var value := data[key]
			
			if value.locked: return # Ignore locked ones.
			
			data.erase(key) # Remove the key from data.
			rooms.append(value) # Save the room for shuffling.
		
		# Sort the array by the area each room takes up.
		rooms.sort_custom(_by_area)
		# Place the rooms by size, erring if something goes wrong.
		for room in rooms:
			var pos := place(room)
			
			if pos == Vector2i.MIN: push_error("Failed to place ", room, " while shuffling.")
			else: # The position is valid; relocate the room.
				room.global_position = RoomManager.room_to_world(pos)
				
				## NOTE: Anything else?
			
		
	#	
	#	X1 - Unassign all unlocked rooms from their slots.
	#	X2 - Start re-placing all the rooms, from biggest to smallest area.
	# 	|- Need a way to tell if a room can be placed regardless of its size. (Reminds of Robodungeon)
	#	3 - Do a final pass to update the positions and door states, or do this while placing
	#	|- Make open ones set to the initial_state field, so they can be locked OR open.
	#	
			
		pass
	
	func _init(set_data:Dictionary[Vector2i, RoomBit], set_size:Vector2i) -> void:
		data = set_data
		size = set_size
		
		for key in data.keys():
			var value = data[key]
			
			RoomManager.PARENT.add_child(value)
		
		shuffle()
			
		pass
	
	## Try to place a room at a position, returning whether it suceeded.
	func insert(key:Vector2i, value:RoomBit) -> bool: 
		# IF it doesn't fit, fail.
		if key + value.room_size > size: return false
		
		var x_range = range(key.x, key.x + value.room_size.x)
		var y_range = range(key.y, key.y + value.room_size.y)
		
		# Make sure all the slots it's attempting to fill are empty.
		for i in x_range: for j in y_range:
			if data.has(Vector2i(i,j)): return false # Nope.
		
		for i in x_range: for j in y_range:
			data[Vector2i(i,j)] = value
		
		return true # Placed sucessfully, so return true.
	## Attempt to place a room anywhere in the space.
	func place(value:RoomBit) -> Vector2i:
		
		var options:Array[Vector2i]
		for i in range(size.x - value.room_size.x + 1): 
			for j in range(size.y - value.room_size.y + 1):
				var pos = Vector2i(i,j)
				## Append any non-full AND possible positions.
				if not data.has(pos): options.append(pos)
		
		# Try to place it in a random position, and stop if
		# succeded, otherwise try another position. Repeat
		# until sucess or none left.
		while len(options) > 0:
			var try:Vector2i = options.pick_random()
			options.erase(try)
			
			if insert(try, value): return try
		
		return Vector2i.MIN # No options left, placing failed.
	
	# What rooms are filling coords or smth.
	var data:Dictionary[Vector2i, RoomBit]
	var size := Vector2i(10, 10)
	

var area_database:Dictionary[AREAS, area_data]

## Shuffles all rooms in all the areas.
func shuffle() -> void: for AREA in AREAS: area_database[AREA].shuffle()

func _ready() -> void:
	## Make sure there are rooms to load... please...
	assert(len(room_paths) > 0, "No rooms found in "+ ROOM_PATH)
	
	var set_size := Vector2i(5, 5)
	var set_start :Dictionary[Vector2i, RoomBit]
	
	for i in range(set_size.x): for j in range(set_size.y):
		set_start[Vector2i(i,j)] = load(room_paths.pick_random()).instantiate()
	
	area_database[AREAS.BRASS] = area_data.new(set_start, set_size)
	


## Helper functions.

## Returns the given coordinates as room coordinates
func world_to_room(p:Vector2) -> Vector2i:
	return Vector2( floor(p.x / ROOM_PIXEL_SIZE), floor(p.y / ROOM_PIXEL_SIZE) )
## Returns the given room coordinates as regular coordinates
func room_to_world(p:Vector2) -> Vector2i:
	return p * ROOM_PIXEL_SIZE

## Returns the given coordinates locked to the room grid.
func grid_lock(p:Vector2) -> Vector2:
	return room_to_world(world_to_room(p))


## Get the paths to all valid rooms.
@onready var room_paths := get_room_paths()
func get_room_paths(path := ROOM_PATH) -> Array[String]:
	
	var paths:Array[String] = []
	
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
