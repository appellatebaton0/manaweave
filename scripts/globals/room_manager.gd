extends Node

const CONFIG_PATH = "res://assets/configs/" # Where the rooms' configs are stored.
const ROOM_PATH = "res://scenes/rooms/" # Where the rooms' scenes are stored

# A class version of a room's "world" config scene.
class Room:
	var doors:Array[Door]
	var room_filename:StringName
	
	func _init(from_file:StringName):
		var config = ConfigFile.new()
		
		var error := config.load(from_file)
		
		# Return preemptively if something went wrong.
		if error: 
			free()
			return
		
		# Set the doors and filename up.
		for connection in config.get_value("world", "door_connections"):
			doors.append(Door.new(connection, self))
		room_filename = config.get_value("world", "room_filename")
	
	class Door:
		
		var connected_to:Room # The room this door is connected to.
		var connection_path:StringName # The path of the room this door is connected to. The same as connected_to.room_filename.
		var owned_by:Room # The owner of the room
		
		func _init(connection:StringName, belongs_to:Room) -> void:
			connection_path = connection
			owned_by = belongs_to
		
		## Connect this door to another.
		func connect_to(door:Door, override_check:bool = false, connect_other:bool = true) -> bool:
			if (door.connected_to or connected_to) and not override_check: return false
			
			connected_to = door.owned_by
			connection_path = door.owned_by.room_filename
			
			if connect_other:
				door.connect_to(self, true, false)
			
			return true
		
		## The set of doors this door is a part of.
		func doorset() -> Array[Door]: return owned_by.doors

# An array of all the loaded rooms.
var rooms:Array[Room]

@onready var PARENT:Node = get_tree().get_first_node_in_group("RoomParent")
@onready var PLAYER:Node = get_tree().get_first_node_in_group("Player")

func _ready() -> void:
	
	# Load all the rooms.
	rooms = load_rooms()
	
	shuffle()
	
	# DEBUG.
	for room in rooms:
		print("- - -")
		print("Room ", room.room_filename)
		print("-")
		for door in room.doors:
			print("Door ", door)
			print("Connection: ", door.connection_path)
			print("-")

func load_rooms() -> Array[Room]:
	var response:Array[Room]
	var room_paths:Dictionary[StringName, Room]
	
	# Load all the level cfgs as rooms.
	var dir = DirAccess.open(CONFIG_PATH)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir(): # The current file *is* a file.
				var new := Room.new(CONFIG_PATH + file_name)
				# Make sure it exists (The filename was a cfg file.)
				if new: 
					response.append(new)
					room_paths[CONFIG_PATH + file_name] = new
			file_name = dir.get_next()
	else:
		print("[Level Editor]: An error occurred when trying to access the path.")
	
	# Resolve any existing connections.
	# After the doors pass off their connection_path from their room's config,
	# this updates their connected_to room if it exists.
	for room in response: for door in room.doors:
		if door.connection_path and room_paths.has(door.connection_path):
			door.connected_to = room_paths[door.connection_path]
	
	return response

# Shuffles the current room array.
func shuffle():
	
	## Loop (Assumes no 1-doors)
	for i in range(len(rooms)):
		# Connect every door to its next, and the last to the first.
		var doorA = rooms[i].doors[0]
		var doorB = rooms[0 if i == len(rooms) - 1 else i + 1].doors[1] # The ternary makes the last go to the first.
		
		doorA.connect_to(doorB)
	
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
		
		if doorA.connect_to(doorB):
			_from.erase(doorA)
			_from.erase(doorB)
			return _from
	
	return []
