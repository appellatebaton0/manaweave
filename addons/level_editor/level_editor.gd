@tool
extends EditorPlugin

var dock:Panel

var selection_display:Label
var entry_box:VBoxContainer
var door_counter:Label

var door_adder:Button
var updater:Button
var door_checker:Button

var selection:EditorSelection

var current_room:RoomBit
var door_entries:Array[Control]

@onready var door_scene = preload("res://scenes/door.tscn")
@onready var entry_scene = preload("door_entry.tscn")

## Sets all the variables for controls.
func update_controls() -> bool:
	if not dock: return false
	
	var children:Array[Control]
	
	var left := dock.get_children()
	while len(left):
		var this = left.pop_front()
		
		var subchildren = this.get_children()
		if len(subchildren): left.append_array(subchildren)
		
		match this.name:
			"Selection": selection_display = this
			"Entries": entry_box = this
			"DoorCounter": door_counter = this
			
			"DoorAdder": door_adder = this
			"Update": updater = this
			"DoorChecker": door_checker = this
	
	return true

func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	
	# Add the control to the bottom docks.
	dock = preload("level_editor.tscn").instantiate()
	#dock.plugin = self
	
	update_controls()
	
	# Load in the selection and wire it up.
	selection = get_editor_interface().get_selection()
	selection.selection_changed.connect(_on_selection_change)
	
	# Connect all the buttons to their respective functions.
	updater.pressed.connect(_update_room_data)
	door_adder.pressed.connect(_on_door_adder_pressed)
	door_checker.pressed.connect(_on_check_door_count)
	
	add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_UL, dock)

func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	
	# Remove the dock from the docks, and free it.
	remove_control_from_docks(dock)
	dock.free()

func _on_selection_change() -> void:
	# Update the current room.
	var changed := false
	for node in selection.get_selected_nodes(): 
		if node.owner is RoomBit: node = node.owner
		
		if node is RoomBit:
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

## Adds a door to the working level & the entries list.
func _on_door_adder_pressed() -> void:
	if current_room == null: return
	
	# Add the door to the current_room.
	
	var undo_redo := get_undo_redo()
	
	var new = door_scene.instantiate()
	
	# Use the global UndoRedo manager, EditorUndoRedoManager, to make it notice the change.
	undo_redo.create_action("Add New Door")
	
	undo_redo.add_do_method(current_room, "add_child", new)
	undo_redo.add_do_method(self, "localize", new)
	undo_redo.add_do_method(self, "add_door_entry", new)
	undo_redo.add_do_property(new, "name", "DoorBit")
	undo_redo.add_do_method(self, "_update_room_data")
	undo_redo.add_do_method(self, "_update_interface")
	
	#undo_redo.add_undo_method(self, "print", "!!!")
	undo_redo.add_undo_method(current_room, "remove_child", new) #...Leaves the door existent for redos...
	undo_redo.add_undo_method(self, "_update_room_data")
	undo_redo.add_undo_method(self, "_update_interface")
	
	undo_redo.commit_action()
	
	

## Updates the data of the room to be correct
func _update_room_data() -> void:
	if current_room == null: return
	print("[Level Editor]: Saving...")
	
	# Update the doors.
	#unre_action("Update Room Doors", current_room, "doors", get_current_room_doors(), current_room.doors)
	current_room.doors = get_current_room_doors()
	
	# Update the cfg file.
	var save_error = current_room.save_config()
	
	if save_error:
		push_error("[Level Editor]: Failed Config Save. Error Code: ", save_error)
	else:
		print("[Level Editor]: Room Config Saved to ", current_room.config_path)

## Turn a scene node into its local version. Similar to the "Make Local" button in the editor.
func localize(node:Node):
	node.set_owner(current_room)
	node.scene_file_path = ""
	for child in node.get_children():
		localize(child)

## Adds a door entry to the container.
func add_door_entry(door:DoorBit):
	var new_entry = entry_scene.instantiate()
	new_entry.undo_redo = get_undo_redo()
	new_entry.door = door
		
	entry_box.add_child(new_entry)
	
	new_entry.door = door
	
	door_entries.append(new_entry)

func get_current_room_doors() -> Array[Vector2]:
	var response:Array[Vector2]
	
	for child in current_room.get_children(): if child is DoorBit: response.append(child.position)
	
	return response


# Run a count of the doors across all saved doors, to make it easier to ensure there's an even amount.
func _on_check_door_count() -> void:
	
	print("[Level Editor]: Running Door Count Check...")
	
	var door_count := 0
	# Load... all the level cfgs.
	var filenames:Array[StringName]
	
	var dir = DirAccess.open("res://assets/configs")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				filenames.append(file_name)
			file_name = dir.get_next()
	else:
		print("[Level Editor]: An error occurred when trying to access the path.")
	
	for filename in filenames:
		var this = ConfigFile.new()
		this.load("res://assets/configs/" + filename)
		
		door_count += len(this.get_value("world", "door_connections"))
	
	print("[Level Editor]: Result: ", door_count, " Doors Globally.")
	
	update_door_count_label(door_count)

func update_door_count_label(to:int):
	# Update the label of the counter.
	var new_text = "Check Global Doors: "
	
	# Placeholder 0s
	for i in range(4 - get_places(to)):
		new_text += "0"
	new_text += str(to)
	
	# Mark for if it's even.
	new_text += " ✗" if to % 2 else " ✓"
	
	# Update.
	door_counter.text = new_text

func get_places(num):
	if num == 0: return 1

	var places = 0
	while abs(num) >= 1:
		num /= 10;
		places += 1;

	return places
