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
	
	return response

## Returns if a collision mask hits a collision layer.
func layer_match(layer:int, mask:int) -> bool: 
	# A bitwise and. If any two bits are active, the value is over 0 and this returns true.
	# If they don't share any bits, it'll return false.
	return layer & mask > 0 

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

func _process(delta: float) -> void:
	
	var areas := area.get_overlapping_areas()
	var bodies := area.get_overlapping_bodies()
	
	for bit in bits:
		
		var o_areas = masked_areas(areas, bit.coll)
		var o_bodies


# What does this need to do?
# - Run AreaBit functions when applicable.
# - Know when 
#
#
