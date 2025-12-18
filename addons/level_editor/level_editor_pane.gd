@tool
extends PanelContainer

var plugin:EditorPlugin

var current:RoomBit

@onready var selection_display:Label = $MarginContainer/VBoxContainer/Panel/ScrollContainer/VBoxContainer/CurrentNode

@onready var door_scene = preload("res://scenes/door.tscn")

func _update_node() -> bool:
	print("updating")
	if plugin == null: return false
	
	for node in plugin.get_editor_interface().get_selection().get_selected_nodes():
		if node is RoomBit:
			current = node
	
	print("updated to ", current)
	selection_display.text = str(current) if current != null else "None"
	
	return true


func recursive_own_children_to_scene(node):
	node.set_owner(current)
	for child in node.get_children():
		recursive_own_children_to_scene(child)


func _on_door_adder_pressed() -> void:
	if current == null: return
	
	var new = door_scene.instantiate()
	
	current.add_child(new)
	new.owner = current
	
	new.name = "DoorBit"
	
	recursive_own_children_to_scene(new)
	new.filename = ""

func _update_room_data() -> void:
	if current == null: return
	
	var undo_redo := UndoRedo.new()
	
	
	undo_redo.create_action("Move the node")
	undo_redo.add_do_method(_update_room_data_do)
	undo_redo.add_undo_method(_update_room_data_undo)
	# undo_redo.add_do_property(node, "position", Vector2(100, 100))
	# undo_redo.add_undo_property(node, "position", node.position)
	undo_redo.commit_action()
func _update_room_data_do() -> void:
	current.data = {
		"test": "e"
	}
	pass
func _update_room_data_undo() -> void:
	current.data = {}
	pass
