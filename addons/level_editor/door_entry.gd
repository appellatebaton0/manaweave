@tool
extends PanelContainer

var undo_redo:EditorUndoRedoManager
var door:DoorBit

@onready var label := $MarginContainer/HBoxContainer/Label
@onready var selector := $MarginContainer/HBoxContainer/OptionButton

func _ready() -> void:
	
	# Make the options dropdown.
	var dict := DoorBit.ORI
	for item in dict.keys(): selector.add_item(item, dict[item])
	
	if door == null: return
	
	label.text = door.name
	selector.selected = door.orientation

# Make the options dropdown update the DoorBit.
func _on_orientation_selected(index: int) -> void:
	# Use the global UndoRedo manager, EditorUndoRedoManager, to make it notice the change.
	undo_redo.create_action("Update Room Data")
	
	undo_redo.add_do_property(door, "orientation", index)
	undo_redo.add_undo_property(door, "orientation", door.orientation)
	
	match index:
		DoorBit.ORI.NORTH: undo_redo.add_do_property(door, "rotation", deg_to_rad(90.0))
		DoorBit.ORI.EAST:  undo_redo.add_do_property(door, "rotation", deg_to_rad(180.0))
		DoorBit.ORI.SOUTH: undo_redo.add_do_property(door, "rotation", deg_to_rad(-90.0))
		DoorBit.ORI.WEST:  undo_redo.add_do_property(door, "rotation", deg_to_rad(0.0))
	undo_redo.add_undo_property(door, "rotation", door.rotation)
	
	
	undo_redo.commit_action()
