class_name DoorBit extends Bit
## The basis for a room's doors.

## Live getters for the door's world data. Good for making sure they're in-date.
func get_connected_path() -> StringName:
	var parent = get_parent()
	if parent is RoomBit: if parent.config: 
		return parent.config.get_value("world", "door_connections")[parent.get_doors().find(self)]["connected_path"]
	return &""
func get_connected_index():
	var parent = get_parent()
	if parent is RoomBit: if parent.config: 
		return parent.config.get_value("world", "door_connections")[parent.get_doors().find(self)]["connected_index"]
	return 0

## Everything relating to the current state of the door.
@export var initial_state:DoorStateBit
var current_state:DoorStateBit

@onready var states := get_states()
func get_states() -> Array[DoorStateBit]:
	var response:Array[DoorStateBit]
	
	for child in get_children(): if child is DoorStateBit: 
		response.append(child)
		child.door = self
	
	return response

@onready var area := get_area()
func get_area() -> Area2D:
	var me = self
	return me

func _ready() -> void:
	# Set up the current state.
	if initial_state: change_state(initial_state) # Initial state if it exists.
	else: change_state(states[0] if len(states) > 0 else null) # Otherwise first state found, otherwise null.
	
	# Connect the body signals.
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)

## Call appropriate active functions for process & physics_process.
func _process(delta: float) -> void:
	for state in states:
		if state == current_state: state._active(delta)
		else: state._inactive(delta)
	
	# Call the appropriate interaction method if necessary.
	# This is here rather than in each door's "_active" to make it easier to change later.
	if Input.is_action_just_pressed("Interact") and area.get_overlapping_bodies(): 
		current_state._on_user_interact()
		try_switch("interact")
func _physics_process(delta: float) -> void:
	for state in states:
		if state == current_state: state._phys_active(delta)
		else: state._phys_inactive(delta)

## Call appropriate functions when the user enteres the door's range.
func _on_body_entered(body: Node2D) -> void:_on_body(body, "_on_user_entered", "entered_range")
func _on_body_exited(body: Node2D) -> void: _on_body(body, "_on_user_exited",  "exited_range")
func _on_body(user, method:StringName, switch_call:StringName):
	if user is Bit: user = user.bot
	if user is Bot: 
		current_state.call(method, user)
		try_switch(switch_call)

## Tries to switch the state to the current state's designation for a specific action.
## IE, action = "interact" will try to switch the state to what the current state says
## it should when the user interacts.
func try_switch(action:StringName) -> bool:
	var next_state = current_state.switches[action]
	if next_state: 
		change_state(next_state)
		return true
	return false

## Changes the state to a new state, and runs the appropriate functions.
func change_state(to:DoorStateBit):
	if current_state: current_state._on_inactive()
	
	current_state = to
	
	if current_state: current_state._on_active()

## Switch rooms to this door's room.
func pass_through() -> void:
	# Make the new room.
	var new:RoomBit = load(get_connected_path()).instantiate()
	
	# Add it to the tree.
	get_tree().get_first_node_in_group("RoomParent").add_child(new)
	
	# Transform it so the doors line up.
	new.global_position = self.global_position - new.doors[get_index()]
	
	# Delete this room. NOTE: Should make a lazier unloader / loader? at some point.
	get_parent().queue_free()
