extends Node

const ROOM_DATA_PATH = "res://assets/resources/room_data"

const REQUIRED_ROOM_PATH = "res://scenes/rooms/"
const FILLER_ROOM_PATH = "res://scenes/rooms/"

const TILE_SIZE := 128

@onready var PARENT:Node = get_tree().get_first_node_in_group("RoomParent")
@onready var PLAYER:Node = get_tree().get_first_node_in_group("Player")
