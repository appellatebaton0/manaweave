@tool
extends Panel

@onready var door:DoorBit

func _process(delta: float) -> void:
	$MarginContainer/HBoxContainer/Label.text = str(door)
