@tool
class_name RoomBit extends Bit
## The bit for a room. Manages everything pertaining to the room.

const CONFIG_SAVE_PATH := "res://assets/configs/"
const ROOM_SAVE_PATH := "res://scenes/rooms/"

@export_storage var config_path

@export_storage var doors:Array[DoorBit]

var config:ConfigFile
func _ready() -> void:
	if not Engine.is_editor_hint():
		config = ConfigFile.new()
		if config.load(config_path): push_warning("Failed to load the config file at path ", config_path)

func update_config() -> Error:
	var config = ConfigFile.new()
	
	# Make the config path if it doesn't already exist.
	if not config_path:
		var current_filename = str(scene_file_path.replace(ROOM_SAVE_PATH, "").replace(".tscn", ""))
		config_path = CONFIG_SAVE_PATH + current_filename + ".cfg"
	else:
		config.load(config_path)
	
	# Update the room filename
	config.set_value("world", "room_filename", scene_file_path)
	
	# Update (clear) the door_connections.
	var door_connections:Array[StringName]
	for door in get_doors(): door_connections.append(door.connected_to)
	
	config.set_value("world", "door_connections", door_connections)
	
	# Level Editor message
	if Engine.is_editor_hint(): print("[Room Config Updater]: Saved ", len(door_connections), " Door Connections")
	
	# Save the config.
	return config.save(config_path)

func get_doors() -> Array[DoorBit]:
	var response:Array[DoorBit]
	
	for child in get_children(): if child is DoorBit: response.append(child)
	
	return response
