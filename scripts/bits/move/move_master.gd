class_name MoveMasterBit extends Bit

@onready var mover := get_mover()
func get_mover(depth := 5, with:Node = self) -> CharacterBody2D:
	# Fail condition :(
	if depth <= 0: return null
	# If this is a CharacterBody, use it.
	if with is CharacterBody2D: return with
	# Otherwise, try with the parent.
	return get_mover(depth - 1, with.get_parent())

@onready var move_bits := get_move_bits()
func get_move_bits() -> Array[MoveBit]:
	var response:Array[MoveBit]
	
	# Append any movebits in the children
	for child in get_children(): if child is MoveBit: 
		response.append(child)
	
	return response

var current_bit:MoveBit
@export var initial_bit:MoveBit

## Change the current bit to a new bit.
func change_to(bit:MoveBit):
	if current_bit != null:
		current_bit.pass_call("_on_inactive")
	
	current_bit = bit
	
	if current_bit != null:
		current_bit.pass_call("_on_active")

func _ready() -> void:
	if initial_bit != null:  change_to(initial_bit)
	elif len(move_bits) > 0: change_to(move_bits[0])
	
	# Initialize the movebits.
	if mover != null: for bit in move_bits:
		bit.master = self 
		bit.mover = mover
		bit.pass_call("_on_ready")
		

func _process(delta: float) -> void:
	if mover != null: for bit in move_bits: # Call every movebit's active/inactive function.
		if bit == current_bit: bit.pass_call("_active", delta)
		else:                  bit.pass_call("_inactive", delta)

func _physics_process(delta: float) -> void:
	if mover != null:
		for bit in move_bits: # Call every movebit's active/inactive function.
			if bit == current_bit: bit.pass_call("_phys_active", delta)
			else:                  bit.pass_call("_phys_inactive", delta)
		
		## Pass any outstanding velocity to the mover, and position to the bot.
		mover.move_and_slide()
		
		if bot.is_class("Node2D"):
			bot.global_position += mover.position
		
		mover.position = Vector2.ZERO # Reset the CB2D's local position.
		
