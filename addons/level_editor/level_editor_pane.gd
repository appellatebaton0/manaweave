@tool
extends Panel

var plugin:EditorPlugin

var current_room:RoomBit

@onready var selection_display := $ScrollContainer/VBoxContainer/HBoxContainer/Selection
@onready var entry_box := $ScrollContainer/VBoxContainer/Entries

@onready var door_scene = preload("res://scenes/door.tscn")
@onready var entry_scene = preload("door_entry.tscn")

@onready var selection := plugin.get_editor_interface().get_selection()

var door_entries:Array[Control]

func _ready() -> void: selection.selection_changed.connect(_on_selection_change)

func _on_selection_change() -> void:
	if plugin == null: return
	
	# Update the current room.
	var changed := false
	for node in selection.get_selected_nodes(): if node is RoomBit:
		current_room = node
		changed = true
		break
	
	# Update the panel if something's changed.
	if changed: _update_interface()
	
func _update_interface():
	
	# Remove the door entries
	for entry in door_entries: entry.queue_free()
	door_entries.clear()
	
	# If there's no longer a current room.
	if current_room == null:
		# Update the selection text.
		selection_display.text = "None"
	
	# If there's a new current room.
	else:
		# Update the selection text.
		selection_display.text = current_room.name
		
		# Add the new door entries.
		for door in current_room.get_doors(): add_door_entry(door)

func _on_door_adder_pressed() -> void:
	if current_room == null: return
	
	# Add the door to the current_room.
	
	var new = door_scene.instantiate()
	
	current_room.add_child(new)
	
	new.name = "DoorBit"
	
	localize(new)
	
	# Add a door_entry to the pane.
	add_door_entry(new)
	
	_update_room_data()

## Updates the data of the room to be correct
func _update_room_data() -> void:
	if current_room == null: return
	print("[Level Editor]: Saving...")
	
	# Update the doors.
	unre_action("Update Room Doors", current_room, "doors", get_current_room_doors(), current_room.doors)
	
	# Update the cfg file.
	var save_error = current_room.update_config()
	
	if save_error:
		push_error("[Level Editor]: Failed Config Save. Error Code: ", save_error)
	else:
		print("[Level Editor]: Room Config Saved to ", current_room.config_path)

# Lets a node keep all its children when .filename is set to nothing.
func localize(node):
	node.set_owner(current_room)
	for child in node.get_children():
		localize(child)

# Adds a door entry to the container.
func add_door_entry(door:DoorBit):
	var new_entry = entry_scene.instantiate()
	new_entry.undo_redo = plugin.get_undo_redo()
	new_entry.door = door
		
	entry_box.add_child(new_entry)
	
	new_entry.door = door
	
	door_entries.append(new_entry)

func get_current_room_doors() -> Array[DoorBit]:
	var response:Array[DoorBit]
	
	for child in current_room.get_children(): if child is DoorBit: response.append(child)
	
	return response

# Perform a change via the EditorUndoRedoManager
func unre_action(action_name:String, target:Object, property:StringName, new_value:Variant, old_value:Variant):
	var undo_redo := plugin.get_undo_redo()
	
	# Use the global UndoRedo manager, EditorUndoRedoManager, to make it notice the change.
	undo_redo.create_action(action_name)
	undo_redo.add_do_property(target, property, new_value)
	undo_redo.add_undo_property(target, property, old_value)
	undo_redo.commit_action()

func unre_method(action_name:String, target:Object, method:StringName, ...args:Array):
	var undo_redo := plugin.get_undo_redo()
	
	# Use the global UndoRedo manager, EditorUndoRedoManager, to make it notice the change.
	undo_redo.create_action(action_name)
	undo_redo.add_do_method(target, method, args)
	undo_redo.commit_action()
	
	pass
