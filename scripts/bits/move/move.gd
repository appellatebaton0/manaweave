@abstract class_name MoveBit extends Bit

@onready var master:MoveMasterBit
@onready var mover:CharacterBody2D

## MoveBits to make active when this bit is active.
@export var nexts:Array[MoveBit]

func pass_call(call_name:String, ...args):
	 # Make the call for this bit.
	if len(args) > 0:
		call(call_name, args[0])
	else:
		call(call_name)
	
	# Pass the call onto the nexts.
	for move_bit in nexts: move_bit.pass_call(call_name, args)

func _ready() -> void:
	for child in get_children():
		if child is MoveBit and not nexts.has(child):
			nexts.append(child)

## Ran during the master's _ready, after mover & master are defined.
func _on_ready() -> void:
	pass

## Ran when the state becomes active/inactive (signal)
func _on_active() -> void:
	pass
func _on_inactive() -> void:
	pass

## Ran while the state is active/inactive (_process)
func _active(_delta:float) -> void:
	pass
func _inactive(_delta:float) -> void:
	pass

## Ran while the state is active/inactive (_physics_process)
func _phys_active(_delta:float) -> void:
	pass
func _phys_inactive(_delta:float) -> void:
	pass
