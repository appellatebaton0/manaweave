@tool
extends PanelContainer

var undo_redo:EditorUndoRedoManager
var door:DoorBit

@onready var label := $MarginContainer/HBoxContainer/Label

func _ready() -> void:
	if door == null: return
	
	label.text = door.name
