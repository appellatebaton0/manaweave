class_name DoorBit extends Bit
## The basis for a room's doors.
## Needs to either be or to have a childed Area2D

signal exited_range_left ## The user has left the range of the door on the left side.
signal exited_range_right ## The user has left the range of the door on the right side.

signal entered_range_left ## The user has entered the range of the door from the left side.
signal entered_range_right ## The user has entered the range of the door from the right side.

signal interact_right ## The user has interacted w/ the door from the right.
signal interact_left ## The user has interacted w/ the door from the left.

@export var initial_state:DoorStateBit
var current_state:DoorStateBit

func change_state(to:DoorStateBit):
	if to == null: return
	if not states.has(to): push_warning("Set a door's state to something it doesn't own; ", get_path(), " <- ", to.get_path())
	
	if current_state != null: current_state._on_inactive()
	
	current_state = to
	
	if current_state != null: current_state._on_active()

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

func _process(delta: float) -> void:
	# Call active for the current bit, and inactive for all else.
	for bit in states: bit.call("_active" if bit == current_state else "_inactive", delta)
	
	# User is interacting w/ the door.
	if user_in_range and Input.is_action_just_pressed("Interact"):
		match user_direction:
			1:
				interact_right.emit()
				pass
			-1:
				interact_left.emit()
				pass

var user:Bot # The bot trying to use the door.
var user_direction := 0
var user_in_range := false
func _on_object_entered(obj_in): if obj_in is Bit:
	update_user_data(obj_in) # Update the user.
	
	user_in_range = true
	
	# Notify the current bit.
	current_state._on_user_entered(user, user_direction)
	
	# Fire off the relevant signal.
	directional_emit(entered_range_left, entered_range_right)

func _on_object_exited(obj_out): if obj_out is Bit:
	update_user_data(obj_out) # Update the user.
	
	user_in_range = false
	
	# Notify the current bit.
	current_state._on_user_exited(user, user_direction)
	
	# Fire off the relevant signal.
	directional_emit(exited_range_left, exited_range_right)

func update_user_data(bit:Bit):
	user = bit.bot
	if user.is_class("Node2D"):
		# Get the distance between the user and the door.
		var dist:float = user.global_position.x - body.global_position.x
		# Round it to either 1 or -1, by dividing it by abs(itself). ex: 4 / -4 -> -1, 4 / 4 -> 1
		user_direction = dist / abs(dist)

## _-_
## Helper functions

## Emits left_signal if the user is on the left, right_signal if they're on the right.
func directional_emit(left_signal:Signal, right_signal:Signal):
	if user_direction == -1: left_signal.emit()
	elif user_direction == 1: right_signal.emit()

## Everything to do to a state when it's assigned to this door.
func init_state(state:DoorStateBit):
	state.door = self

## Passes the signal from the door to its state, and changes the state if necessary.
func emit_as_state_pass(signal_name:String):
	emit_signal(signal_name)
	
	if current_state != null:
		current_state.emit_signal(signal_name)
	

## _-_
## Initializing all the variables.

## Get the available states for the door.
@onready var states := get_states()
func get_states() -> Array[DoorStateBit]:
	var response:Array[DoorStateBit] 
	
	for child in get_children(): if child is DoorStateBit: 
		init_state(child)
		response.append(child)
	for child in get_parent().get_children(): if child is DoorStateBit: 
		init_state(child)
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
