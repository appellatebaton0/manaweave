@tool
extends PanelContainer

signal delete(node:Node)

var door:DoorBit
@onready var label := $MarginContainer/HBoxContainer/Label

func _on_button_pressed() -> void: delete.emit(self)
