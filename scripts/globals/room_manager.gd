extends Node

const CONFIG_PATH = "res://assets/configs/" # Where the rooms' configs are stored.
const ROOM_PATH = "res://scenes/rooms/" # Where the rooms' scenes are stored

# A class version of a room's "world" config scene.
class Room:
	var filename:StringName # The path to the room's scene.
	var doors:Array[Door] # The doors this room has.
	
	var _config:ConfigFile # The real data.
	
	## Create the Room
	func _init(from:StringName):
		_config = ConfigFile.new()
		
		# Load config, return if error.
		if _config.load(from): 
			free()
			return
		
		filename = _config.get_value("world", "room_filename")
	
	## Create a RoomBit instance from this room.
	func create() -> RoomBit: return load(filename).instantiate()
	
	## Create the doors and hook them up to the other rooms based on the config.
	func load_doors(from:Dictionary[Room, StringName]):
		for dict in _config.get_value("world", "door_connections"): 
			doors.append(Door.new(self, dict, from)) 
	
	## Save back into the config file.
	func save() -> Error:
		
		# Update the door connections
		
		var door_connections:Array[Dictionary]
		for door in doors: door_connections.append({"connected_path": door.connected_to.filename, "connected_index": door.connected_index})
		
		_config.set_value("world", "door_connections", door_connections)
		
		# Save
		
		var config_path = CONFIG_PATH + filename.replace(ROOM_PATH, "").replace(".tscn", ".cfg")
		return _config.save(config_path)
	
	class Door:
		var connected_index:int # The index of the door this door connects to, in its owner (connected_to)
		var connected_to:Room # The room this door connects to.
		var owned_by:Room # The room this door is in.
		
		## Create a new door with a config entry and a dict of all the rooms.
		func _init(belongs_to:Room, from:Dictionary, with:Dictionary[Room, StringName]):
			owned_by = belongs_to # Transfer over the creator.
			
			print(from)
			
			connected_to = with.find_key(from["connected_path"]) # Turn the path into the room.
			connected_index = from["connected_index"] if from["connected_index"] else -1 # Convert the index.
		
		## Connect this door to another.
		func link(door:Door, recur := true) -> bool:
			if connected_to or door.connected_to: return false # Cancel if there's already a connection.
			
			if recur: door.link(self, false) # Connect the other side.
			
			# Connect.
			connected_to = door.owned_by
			connected_index = door.get_index()
			
			return true
		
		## Disconnect this door.
		func unlink(recur := true) -> bool:
			
			if not connected_to: return false
			
			if recur: get_target().unlink(false) # Disconnect the other side.
			
			connected_to = null
			connected_index = -1
			
			return true
		
		## Get the position of this door in its owner's array.
		func get_index() -> int: return owned_by.doors.find(self)
		## Get the door this door is connected to.
		func get_target() -> Door: return connected_to.doors[connected_index]

# An array of all the loaded rooms.
var rooms:Array[Room]

@onready var PARENT:Node = get_tree().get_first_node_in_group("RoomParent")
@onready var PLAYER:Node = get_tree().get_first_node_in_group("Player")

func _ready() -> void:
	
	# Load all the rooms.
	rooms = load_rooms()
	
	# Shuffle their connections.
	shuffle()
	
	# Save the room's connections back into their configs.
	for room in rooms: room.save()
	
	# Create a new instance of the first.
	var new = rooms[0].create()
	get_tree().get_first_node_in_group("RoomParent").add_child(new)
	
	# DEBUG.
	for room in rooms:
		print("- - -")
		print("Room ", room.filename)
		print("-")
		for door in room.doors:
			print("Door ", door)
			print("Connection: ", door.connected_to.filename)
			print("-")

## Load all the room configs into Rooms.
func load_rooms() -> Array[Room]:
	var room_paths:Dictionary[Room, StringName]
	
	# Load all the level cfgs as rooms.
	for path in Lib.get_file_paths_at(CONFIG_PATH):
		var new := Room.new(path)
		
		if new:
			room_paths[new] = path
	
	# Load all the doors for each room.
	for room in room_paths.keys(): if room is Room:
		room.load_doors(room_paths)
		print(room.doors)
	
	return room_paths.keys()

# Shuffles the current room array.
func shuffle():
	
	## Clear the existing connections.
	
	for room in rooms: for door in room.doors: door.unlink()
	
	## Loop NOTE: Assumes no 1-doors, so every room must have 2+ doors.
	for i in range(len(rooms)):
		# Connect every door to its next, and the last to the first.
		var doorA = rooms[i].doors[0]
		var doorB = rooms[0 if i == len(rooms) - 1 else i + 1].doors[1] # The ternary makes the last go to the first.
		
		doorA.link(doorB)
	
	## Resolve (Connect all the rest of the doors).
	var not_done:Array[Room.Door]
	for room in rooms:
		for door in room.doors: if not door.connected_to: not_done.append(door)
	
	# NOTE: The amount of doors HAS to be an even number to connect all of them, obviously.
	if len(not_done) % 2: push_warning("ODD NUMBER OF DOORS. CANNOT SOLVE.")
	
	# Shuffle so it's unlikely to do doors from the same room in sequence.
	# IE, so two doors from one room are less likely to connect to the same room.
	not_done.shuffle() 
	for door in not_done:
		if door.connected_to: continue
		find_connection_for(door, score_sort(door, not_done))

# Returns the room array, sorted against [to] according to score_against(), low to high. (merge sort :D)
func score_sort(to:Room.Door, arr:Array) -> Array:
	var array:Array[Room.Door]
	
	for item in arr:
		if item is Room.Door: array.append(item)
		elif item is Room: array.append_array(item.doors)

	# Sorts the array via merge sort.
	var length = len(array)
	
	if length <= 1: return array
	
	@warning_ignore("integer_division")
	var left = array.slice(0, floor((length + 1) / 2))
	@warning_ignore("integer_division")
	var right = array.slice(floor((length + 1) / 2), length)
	
	
	left  = score_sort(to, left)
	right = score_sort(to, right)
	
	# The array's already sorted.
	if   len(left)  <= 0: return right
	elif len(right) <= 0: return left
	
	var li = 0
	var ri = 0
	
	var response:Array[Room.Door]

	while len(response) < len(left) + len(right):
		
		# One of the arrays is empty; append the other and end.
		if li >= len(left): 
			response.append_array(right.slice(ri))
			break
		elif ri >= len(right):
			response.append_array(left.slice(li))
			break
		
		# Define the condition for switching left[li] and right[ri]
		# print(li, " / ", ri)
		var condition = score_against(left[li], to) > score_against(right[ri], to)
		
		# Otherwise, append the next.
		if condition: 
			response.append(right[ri])
			ri += 1
		else:
			response.append(left[li])
			li += 1
	
	return response

# Score a target door based on some qualities in relation to another door, and return that score.
func score_against(target:Room.Door, against:Room.Door) -> float:
	
	var score := 0
	
	# Adds score if the rooms are directly connected.
	var same_room_cost := pow(2, len(target.owned_by.doors) * len(against.owned_by.doors))
	for door in target.owned_by.doors: if door.connected_to == against.connected_to:
		score += int(same_room_cost)
		same_room_cost *= 4
	
	return score

## CONNECTING DOORS

func find_connection_for(doorA:Room.Door, from:Array) -> Array[Room.Door]:	
	var _from:Array[Room.Door]
	
	# Parse the input into doors.
	for item in from:
		if item is Room.Door: _from.append(item)
		elif item is Room: _from.append_array(item.doors)
	
	# Find a door to connect to.
	for checking in range(len(_from)):
		var doorB:Room.Door = _from[checking]
		# Ignore self & doors in the same room.
		if doorB.owned_by == doorA.owned_by: continue 
		
		if doorA.link(doorB):
			_from.erase(doorA)
			_from.erase(doorB)
			return _from
	
	return []

## SAVING / LOADING
