class_name DoorBit extends Bit
## The basis for a room's doors.
## Needs to either be or to have a childed Area2D

@export var initial_state:DoorStateBit
var current_bit:DoorStateBit

func change_state(to:DoorStateBit):
	if current_bit != null: current_bit._on_inactive()
	
	current_bit = to
	
	if current_bit != null: current_bit._on_active()

@onready var states := get_states()
func get_states() -> Array[DoorStateBit]:
	var response:Array[DoorStateBit] 
	
	for child in get_children(): if child is DoorStateBit: 
		child.door = self
		response.append(child)
	for child in get_parent().get_children(): if child is DoorStateBit: 
		child.door = self
		response.append(child)
	
	return response

## Get the area and staticbody.

@onready var body:StaticBody2D = get_collider("StaticBody2D")
@onready var area:Area2D = get_collider("Area2D")
func get_collider(node_class:String) -> Node:
	
	# Check self
	if is_class(node_class): return self
	
	# Check children.
	for child in get_children(): if child.is_class(node_class): return child
	
	push_warning("Door at ", get_path(), " couldn't find a ", node_class, ".")
	return null
