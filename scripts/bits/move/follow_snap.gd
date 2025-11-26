class_name FollowSnapMove extends MoveBit
## Meant for the camera, makes it follow the player's position. 
## The snapping can come later, but it'll be something like stopping at the edges of rooms....
## Maybe just add collision the camera can hit around the current room, actually.

@export var target:NodeValue

@export_range(0.1, 10.0, 0.1) var lerp_amount := 3.0

func get_next_velocity():
	
	if target == null: return Vector2.ZERO
	var node = target.value()
	if node is not Node2D: return Vector2.ZERO
	
	var a = mover.global_position
	var b = node .global_position
	
	return Vector2(b.x - a.x, b.y - a.y) * lerp_amount

func _on_ready() -> void:
	if target == null: for child in get_children(): if child is NodeValue: 
		target = child
		break

func _phys_active(delta:float) -> void:
	
	mover.velocity = get_next_velocity() * (60 * delta)
