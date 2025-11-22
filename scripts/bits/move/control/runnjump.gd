class_name RunNJumpMoveBit extends ControlMoveBit

@export var gravity := 5.0 ## The coefficient of the applied gravity.
@export var jump_velocity := 2000.0 ## The amount of upwards velocity applied on jump.

@export_group("Ground", "ground_")
@export var ground_max_speed := 900.0 ## How fast the bot can move while on the ground.
@export var ground_friction := 2000.0 ## How fast the bot slows to a stop while on the ground.
@export var ground_acceleration := 3000.0 ## How fast the bot gets up to top speed while on the ground.

@export_group("Air", "air_")
@export var air_max_speed := 900.0 ## How fast the bot can move while midair.
@export var air_friction := 2000.0 ## How fast the bot slows to a stop while midair.
@export var air_acceleration := 3000.0 ## How fast the bot gets up to top speed while midair.

var speed := 0.0

@export_group("Leniencies", "len_")
@export var len_coyote_time := 0.1 ## How long, in seconds, the bot can still jump after leaving the ground.
@export var len_jump_buffer := 0.1 ## How long, in seconds, the bot will keep track of a jump input while the bot's midair.
var coyote_time := 0.0
var jump_buffer := 0.0

func _phys_active(delta:float) -> void:
	var current_acceleration
	var current_friction
	var current_max_speed
	
	# Gravity
	if not mover.is_on_floor():
		mover.velocity += mover.get_gravity() * delta * gravity
		
		current_acceleration = air_acceleration
		current_friction = air_friction
		current_max_speed = air_max_speed
	
	# Leniencies
	
	coyote_time = move_toward(coyote_time, 0, delta)
	if mover.is_on_floor(): 
		coyote_time = len_coyote_time
		
		current_acceleration = ground_acceleration
		current_friction = ground_friction
		current_max_speed = ground_max_speed
	
	jump_buffer = move_toward(jump_buffer, 0, delta)
	if Input.is_action_just_pressed("Jump"): jump_buffer = len_jump_buffer
	
	# Jumping
	if coyote_time > 0 and jump_buffer > 0:
		mover.velocity.y -= jump_velocity
		
		coyote_time = 0 
		jump_buffer = 0
	
	# Runnin'
	
	var direction = Input.get_axis("Left", "Right")
	if direction: mover.velocity.x = move_toward(mover.velocity.x, current_max_speed * direction, current_acceleration * delta)
	else:         mover.velocity.x = move_toward(mover.velocity.x, 0,                             current_friction     * delta)
	
