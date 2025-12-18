extends Node

const ROOM_DATA_PATH = "res://assets/resources/room_data"

const REQUIRED_ROOM_PATH = "res://scenes/rooms/"
const FILLER_ROOM_PATH = "res://scenes/rooms/"

const TILE_SIZE := 128

@onready var PARENT:Node = get_tree().get_first_node_in_group("RoomParent")
@onready var PLAYER:Node = get_tree().get_first_node_in_group("Player")

func _ready() -> void: 
	#for room in Lib.mass_load(REQUIRED_ROOM_PATH):
		#print("Running check for ", room, "...")
		#
		#var new1:RoomBit = room.instantiate()
		#print("Check 1: ", new1.data.door_count)
		#print("Modifying...")
		#new1.data.door_count += 1
		#var new2:RoomBit = room.instantiate()
		#print("Check 2: ", new2.data.door_count)
	##print("Connecting")
	#for room in rooms:
		#print(room.data)
		#room.ready.connect(_on_room_readied)
	#for room in filler_rooms:
		#room.ready.connect(_on_room_readied)
	#print("connected")
	#
	#await rooms_readied
	
	shuffle()


func shuffle():
	
	for room in rooms:
		print("from ", room, " -> ", room.data)
		print(room.data["doors"])
	
	return 
	var required := rooms.duplicate()
	var filler := filler_rooms.duplicate()
	
	print("shuffling w/ ", required)
	
	# Place the crossroad
	var crossroad:RoomBit = required[0]
	## NOTE: ^?
	
	var placed:Array[RoomBit] = [crossroad]
	while len(required) != 0: # As long as there are still rooms to place.
		
		print("going")
		
		# Get all the doors that need connections
		var unconnected_doors:Array[DoorBit]
		for room in placed: 
			print("checking ", room, "'s ", room.doors)
			for door in room.doors: 
				print("checking ", room, "'s ", door)
				if door.room_path == null:
					print("found!")
					unconnected_doors.append(door) # Append any unconnected door from the placed rooms.
		
		for i in range(len(unconnected_doors)):
			for j in range(i):
				print(i, ", ", j)
		
		print("broke.")
		break
	
	
	
	pass

### Helper functions.
#
### Returns the given coordinates as room coordinates
#func world_to_room(p:Vector2) -> Vector2i:
	#return Vector2( floor(p.x / TILE_SIZE), floor(p.y / TILE_SIZE) )
### Returns the given room coordinates as regular coordinates
#func room_to_world(p:Vector2) -> Vector2i:
	#return p * TILE_SIZE
#
### Returns the given coordinates locked to the room grid.
#func grid_lock(p:Vector2) -> Vector2:
	#return room_to_world(world_to_room(p))

## Load all the rooms
@onready var rooms:Array[RoomBit] = array_to_rooms(Lib.mass_instantiate(REQUIRED_ROOM_PATH))
@onready var filler_rooms:Array[RoomBit] = array_to_rooms(Lib.mass_instantiate(FILLER_ROOM_PATH))

func array_to_rooms(array:Array) -> Array[RoomBit]:
	var response:Array[RoomBit]
	
	for item in array: if item is RoomBit: response.append(item)
	
	return response
