class_name  extends MoveBit

## Ran during the master's _ready, after mover & master are defined.
func _on_ready() -> void:
	pass

## Ran when the state becomes active/inactive (signal)
func _on_active() -> void:
	pass
func _on_inactive() -> void:
	pass

## Ran while the state is active/inactive (_process)
func _active(_delta:float) -> void:
	pass
func _inactive(_delta:float) -> void:
	pass

## Ran while the state is active/inactive (_physics_process)
func _phys_active(_delta:float) -> void:
	pass
func _phys_inactive(_delta:float) -> void:
	pass
