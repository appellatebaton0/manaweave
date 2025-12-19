@tool
extends Panel

var plugin:EditorPlugin

var current:RoomBit

@onready var selection_display := $ScrollContainer/VBoxContainer/Selection
@onready var entry_box := $ScrollContainer/VBoxContainer/Entries

@onready var door_scene = preload("res://scenes/door.tscn")
@onready var entry_scene = preload("door_entry.tscn")

@onready var selection := plugin.get_editor_interface().get_selection()

var door_entries:Array[Panel]

func _ready() -> void:
	selection.selection_changed.connect(_on_selection_change)

func _on_selection_change() -> void:
	if plugin == null: return
	
	for node in selection.get_selected_nodes():
		if node is RoomBit:
			current = node
			return
	
	selection_display.text = str(current) if current != null else "None"
	
	# Update the door entries.
	
	for entry in door_entries: entry.queue_free()
	door_entries.clear()
	
	if current == null: return
	
	for door in current.get_doors(): add_door_entry(door)

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
	
	var undo_redo := plugin.get_undo_redo()
	
	# Use the global UndoRedo manager, EditorUndoRedoManager, to make it notice the change.
	undo_redo.create_action("Update Room Data")
	undo_redo.add_do_property(current, "data", {
		"doors": ["Success! x2"]
	})
	undo_redo.commit_action()

# Lets a node keep all its children when .filename is set to nothing.
func localize(node):
	node.set_owner(current)
	for child in node.get_children():
		localize(child)

func add_door_entry(door:DoorBit):
	var new_entry = entry_scene.instantiate()
		
	entry_box.add_child(new_entry)
	
	print("set ", new_entry, ".", new_entry.door, " to ", door)
	new_entry.door = door
