@tool
extends PanelContainer

var plugin:EditorPlugin

var current:RoomBit

@onready var selection_display:Label = $MarginContainer/VBoxContainer/Panel/ScrollContainer/VBoxContainer/CurrentNode

@onready var door_scene = preload("res://scenes/door.tscn")

func update_node() -> bool:
	if plugin == null: return false
	
	for node in plugin.get_editor_interface().get_selection().get_selected_nodes():
		if node is RoomBit:
			current = node
	
	selection_display.text = str(current) if current != null else "None"
	
	return true


func _on_door_adder_pressed() -> void:
	if current == null: return
	
	print("attempted add.")
	
	var new = door_scene.instantiate()
	
	current.add_child(new)
	new.owner = current
	
	new.name = "DoorBit"
	
	#var new_pack = PackedScene.new().pack(current)
	
	
	
