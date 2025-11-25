@abstract class_name AreaBit extends Bit
## Provides functionality to and from an Area2D, through extension functions.
## NOTE: MUST BE A CHILD OF AN AreaMasterBit.

@export_flags_2d_physics var collision_mask := 1

## Ran when an area / body enters the Area2D.
func _on_area_entered(_area:Area2D): pass
func _on_body_entered(_body:Node2D): pass

## Ran when an area / body exits the Area2D
func _on_area_exited(_area:Area2D): pass
func _on_body_exited(_body:Node2D): pass

## Ran while there are areas / bodies overlapping with the Area2d.
func _while_overlapping_areas (_areas :Array[Area2D], _delta:float): pass
func _while_overlapping_bodies(_bodies:Array[Node2D], _delta:float): pass
