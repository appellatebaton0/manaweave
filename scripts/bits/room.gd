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

# Updates the config for this room to reflect its state.
func save_config() -> Error:
	var cfg = ConfigFile.new()
	
	# Make the config path if it doesn't already exist.
	if not config_path:
		var current_filename = str(scene_file_path.replace(ROOM_SAVE_PATH, "").replace(".tscn", ""))
		config_path = CONFIG_SAVE_PATH + current_filename + ".cfg"
	# If it does, load the existing data from it.
	else: cfg.load(config_path)
	
	# Update the room filename
	cfg.set_value("world", "room_filename", scene_file_path)
	
	# Update (clear) the door_connections.
	var door_connections:Array[Dictionary]
	for door in get_doors(): door_connections.append({"connected_path": door.connected_path, "connected_index": door.connected_index})
	
	cfg.set_value("world", "door_connections", door_connections)
	
	# Level Editor message
	if Engine.is_editor_hint(): 
		print("[Room Config Updater]: Saved ", len(door_connections), " Door Connections")
	
	# Save all the info from the children. NOTE: Only when not an editor update.
	else: deferred_config_save(cfg)
	
	# Save the config.
	return cfg.save(config_path)
func load_config() -> Error:
	var cfg = ConfigFile.new()
	
	# Parse the doors' data from the config.
	
	return 0 as Error
	

func get_doors() -> Array[DoorBit]:
	var response:Array[DoorBit]
	
	for child in get_children(): if child is DoorBit: response.append(child)
	
	return response

# Save and load data for the config file via its children. NOTE: Unimplemented as I don't have any of those bits yet.
func deferred_config_save(_file:ConfigFile): pass
func deferred_config_load(_file:ConfigFile): pass
