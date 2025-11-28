class_name RunNJumpMoveBit extends ControlMoveBit

@export var gravity := 10.0 ## The coefficient of the applied gravity.

@export_group("Jump", "jump_")
@export var jump_curve:Curve ## The amount of upwards velocity applied on jump over time.
@export var jump_multiplier := 100.0 ## The amount to multiply any point on the curve by.

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

var current_acceleration
var current_friction
var current_max_speed
func _phys_active(delta:float) -> void:
	
	# Gravity
	if not mover.is_on_floor(): mover.velocity += mover.get_gravity() * delta * gravity
	
	# Jumpin'
	handle_jump(delta)
	
	# Runnin'
	handle_movement(delta)

var jumping := false
var jump_time := 0.0
func handle_jump(delta:float) -> void: 
	# Coyote Time
	coyote_time = move_toward(coyote_time, 0, delta)
	if mover.is_on_floor(): 
		jumping = false # If you're on the floor, you're not jumping.
		coyote_time = len_coyote_time
	
	# Jump Buffering
	jump_buffer = move_toward(jump_buffer, 0, delta)
	if Input.is_action_pressed("Jump"): jump_buffer = len_jump_buffer
	
	# Jumping
	if jump_buffer > 0:
		# Start jumping.
		if coyote_time > 0: 
			jumping = true
			coyote_time = 0 
		
		# Jumping
		if jumping:
			# Set the vel.y to the current sample, if it's not already moving faster.
			mover.velocity.y = min(mover.velocity.y, -jump_curve.sample(jump_time) * jump_multiplier)
			
			# Move to the next sample
			jump_time = move_toward(jump_time, jump_curve.max_domain, delta)
			
			# Stop jumping if you've reached the end of the curve.
			if jump_time >= jump_curve.max_domain: jumping = false
			
			# Disallow the leniency while already jumping.
			jump_buffer = 0 
	else: # Jump input NOT pressed.
		jumping = false
		jump_time = 0.0

func handle_movement(delta:float) -> void:
	# Set the current coefficients for movement.
	if mover.is_on_floor():
		current_acceleration = ground_acceleration
		current_friction = ground_friction
		current_max_speed = ground_max_speed
	else:
		current_acceleration = air_acceleration
		current_friction = air_friction
		current_max_speed = air_max_speed
	
	# Do the actual movement.
	var direction = Input.get_axis("Left", "Right")
	if direction: mover.velocity.x = move_toward(mover.velocity.x, current_max_speed * direction, current_acceleration * delta)
	else:         mover.velocity.x = move_toward(mover.velocity.x, 0,                             current_friction     * delta)
