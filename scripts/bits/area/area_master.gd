class_name AreaMasterBit extends Bit
## Provides a wrapper for Area2D functionality through AreaBits.

## The Area2D this master extends.
@onready var area := get_area()
func get_area(with:Node = self, depth := 4) -> Area2D: ## Look for the Area2D.
	# Fail condition.
	if depth <= 0 or with == null:
		push_warning("An AreaMaster has been unable to find its Area2D! Trace: ", get_path())
		return null
	
	# Check self.
	if with is Area2D: return with
	# Check children.
	for child in with.get_children(): if child is Area2D: return child
	# Move onto parent.
	return get_area(with.get_parent(), depth - 1)

@onready var bits := get_area_bits()
func get_area_bits() -> Array[AreaBit]:
	var response:Array[AreaBit]
	
	# Append any children that are AreaBits.
	for child in get_children(): if child is AreaBit:
		response.append(child)
	
	# Append any siblings  that are AreaBits.
	for child in get_parent().get_children(): if child is AreaBit:
		response.append(child)
	
	return response

## Returns if a collision mask hits a collision layer.
func layer_match(layer:int, mask:int) -> bool: 
	# A bitwise and. If any two bits are active, the value is over 0 and this returns true.
	# If they don't share any bits, it'll return false.
	return layer & mask > 0 

## Return their given arrays masked to the given int.
func masked_areas(areas:Array[Area2D], mask:int) -> Array[Area2D]:
	var response:Array[Area2D]
	
	# Append any matching areas back into the response.
	for a in areas: if layer_match(a.collision_layer, mask): 
		response.append(a)
	
	return response
func masked_bodies(bodies:Array[Node2D], mask:int) -> Array[Node2D]:
	var response:Array[Node2D]
	
	for b in bodies:
		if b is PhysicsBody2D: # Everything but tilemaps.
			if layer_match(b.collision_layer,mask): response.append(b)
		elif b is TileMapLayer: # Tilemaps NOTE: only masks the first physics layer.
			if layer_match(b.tile_set.get_physics_layer_collision_layer(0), mask): response.append(b)
	
	return response

func _ready() -> void:
	if area != null: # Connect all the signals.
		area.area_entered.connect(_on_area_entered)
		area.body_entered.connect(_on_body_entered)
		
		area.area_exited.connect(_on_area_exited)
		area.body_exited.connect(_on_body_exited)

func _process(delta: float) -> void:
	
	var areas := area.get_overlapping_areas()
	var bodies := area.get_overlapping_bodies()
	
	# Run the overlap functions for all the AreaBits.
	for bit in bits:
		# The overlapping areas and bodies for this bit.
		# NOTE: this is inefficient, it could only update these when 
		# the overlaps change.
		var o_areas  = masked_areas (areas,  bit.collision_mask)
		var o_bodies = masked_bodies(bodies, bit.collision_mask)
		
		if len(o_areas)  > 0: bit._while_overlapping_areas (o_areas,  delta)
		if len(o_bodies) > 0: bit._while_overlapping_bodies(o_bodies, delta)

func _on_area_entered(area_in:Area2D):
	# Run the function for any with the matching layer.
	for bit in bits: if layer_match(area_in.collision_layer, bit.collision_mask):
		bit._on_area_entered(area_in)
func _on_body_entered(body_in:Node2D):
	for bit in bits:
		if body_in is PhysicsBody2D:
			if layer_match(body_in.collision_layer, bit.collision_mask):
				bit._on_body_entered(body_in)
		elif body_in is TileMapLayer:
			if layer_match(body_in.tile_set.get_physics_layer_collision_layer(0), bit.collision_mask):
				bit._on_body_entered(body_in)

func _on_area_exited(area_out:Area2D):
	# Run the function for any with the matching layer.
	for bit in bits: if layer_match(area_out.collision_layer, bit.collision_mask):
		bit._on_area_exited(area_out)
func _on_body_exited(body_out:Node2D):
	for bit in bits:
		if body_out is PhysicsBody2D:
			if layer_match(body_out.collision_layer, bit.collision_mask):
				bit._on_body_exited(body_out)
		elif body_out is TileMapLayer:
			if layer_match(body_out.tile_set.get_physics_layer_collision_layer(0), bit.collision_mask):
				bit._on_body_exited(body_out)
