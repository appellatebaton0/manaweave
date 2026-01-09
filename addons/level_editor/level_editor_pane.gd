@tool
extends Panel

var plugin:EditorPlugin

var current:RoomBit

@onready var selection_display := $ScrollContainer/VBoxContainer/HBoxContainer/Selection
@onready var entry_box := $ScrollContainer/VBoxContainer/Entries

@onready var door_scene = preload("res://scenes/door.tscn")
@onready var entry_scene = preload("door_entry.tscn")

@onready var selection := plugin.get_editor_interface().get_selection()

var door_entries:Array[Control]

func _ready() -> void:
	selection.selection_changed.connect(_on_selection_change)

func _on_selection_change() -> void:
	if plugin == null: return
	
	var changed := false
	for node in selection.get_selected_nodes():
		if node is RoomBit:
			current = node
			changed = true
	if not changed: return
	
	selection_display.text = current.name if current != null else "None"
	
	# Update the door entries.
	
	for entry in door_entries: entry.queue_free()
	door_entries.clear()
	
	if current == null: return
	
	for door in get_current_doors(): add_door_entry(door)

func _on_door_adder_pressed() -> void:
	if current == null: return
	
	# Add the door to the current.
	
	var new = door_scene.instantiate()
	
	current.add_child(new)
	
	new.name = "DoorBit"
	
	localize(new)
	
	# Add a door_entry to the pane.
	add_door_entry(new)

## Updates the data of the room to be correct
func _update_room_data() -> void:
	if current == null: return
	
	current.doors = get_current_doors()
	
	var new_data:Dictionary = {
		"doors": []
	}
	
	# Append the data from doors
	for door in get_current_doors():
		new_data["doors"].append({
			"path": door.room_path,
			"orientation": door.orientation
		})
	
	# Append the data from the room itself
	new_data["position"] = current.global_position
	
	var undo_redo := plugin.get_undo_redo()
	
	# Use the global UndoRedo manager, EditorUndoRedoManager, to make it notice the change.
	undo_redo.create_action("Update Room Data")
	undo_redo.add_do_property(current, "data", new_data)
	undo_redo.commit_action()
	
	print("Updated ", current, "'s data to ", current.data)

# Lets a node keep all its children when .filename is set to nothing.
func localize(node):
	node.set_owner(current)
	for child in node.get_children():
		localize(child)

func add_door_entry(door:DoorBit):
	var new_entry = entry_scene.instantiate()
	new_entry.undo_redo = plugin.get_undo_redo()
	new_entry.door = door
		
	entry_box.add_child(new_entry)
	
	new_entry.door = door
	
	door_entries.append(new_entry)

func get_current_doors() -> Array[DoorBit]:
	var response:Array[DoorBit]
	
	for child in current.get_children(): if child is DoorBit: response.append(child)
	
	return response
