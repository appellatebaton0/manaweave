class_name RoomBit extends Bit
## The bit for a room. Manages everything pertaining to the room.

@export_storage var config_path := ""

@export_storage var doors:Array[DoorBit]

var config:ConfigFile
func _ready() -> void:
	
	config = ConfigFile.new()
	if config.load(config_path): push_warning("Failed to load the config file at path ", config_path)
	
