class_name DoorBit extends Bit
## The basis for a room's doors.

## The path of the room the door is connected to.
@export_storage var connected_path:String
@export_storage var connected_index:int

## Everything relating to the current state of the door.
@export var initial_state:DoorStateBit
var current_state:DoorStateBit

@onready var states := get_states()
func get_states() -> Array[DoorStateBit]:
	var response:Array[DoorStateBit]
	
	for child in get_children(): if child is DoorStateBit: response.append(child)
	
	return response

# Changes the state to a new state, and runs the appropriate functions.
func change_state(to:DoorStateBit):
	if current_state: current_state._on_inactive()
	
	current_state = to
	
	if current_state: current_state._on_active()

func _ready() -> void:
	# Set up the current state.
	if initial_state: change_state(initial_state) # Initial state if it exists.
	else: change_state(states[0] if len(states) > 0 else null) # Otherwise first state found, otherwise null.
	
	# Connect the body signals.
	var area = self
	if area is Area2D:
		area.body_entered.connect(_on_body_entered)
		area.body_exited.connect(_on_body_exited)
	
## Call appropriate active functions for process & physics_process.
func _process(delta: float) -> void:
	for state in states:
		if state == current_state: state._active(delta)
		else: state._inactive(delta)
func _physics_process(delta: float) -> void:
	for state in states:
		if state == current_state: state._phys_active(delta)
		else: state._phys_inactive(delta)

## Call appropriate functions when the user enteres the door's range.
func _on_body_entered(body: Node2D) -> void:_on_body(body, "_on_user_entered")
func _on_body_exited(body: Node2D) -> void: _on_body(body, "_on_user_exited")
func _on_body(user, method:StringName):
	if user is Bit: user = user.bot
	if user is Bot: current_state.call(method, user)
