class_name DoorBit extends Bit
## The basis for a room's doors.
## Needs to either be or to have a childed Area2D

@export var initial_state:DoorStateBit
var current_bit:DoorStateBit

func change_state(to:DoorStateBit):
	if not states.has(to): push_warning("Set a door's state to something it doesn't own; ", get_path(), " <- ", to.get_path())
	
	if current_bit != null: current_bit._on_inactive()
	
	current_bit = to
	
	if current_bit != null: current_bit._on_active()

func _ready() -> void:
	# Initialize the door's state.
	if initial_state: change_state(initial_state)
	elif len(states) > 0: change_state(states[0])
	
	# Connect area signals.
	if area != null:
		area.area_entered.connect(_on_object_entered)
		area.body_entered.connect(_on_object_entered)
		#-
		area.area_exited.connect(_on_object_exited)
		area.body_exited.connect(_on_object_exited)

var user:Bot # The bot trying to use the door.
var user_direction := 0
func _on_object_entered(obj_in): if obj_in is Bit:
	update_user_data(obj_in) # Update the user.
	
	current_bit._on_user_entered(user, user_direction)

func _on_object_exited(obj_out): if obj_out is Bit:
	update_user_data(obj_out) # Update the user.
	
	current_bit._on_user_exited(user, user_direction)

func update_user_data(bit:Bit):
	user = bit.bot
	if user.is_class("Node2D"):
		var dist:float = user.global_position.x - body.global_position.x
		user_direction = dist / abs(dist)
		print(user_direction)
	
## Get the available states for the door.
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
