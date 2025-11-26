@abstract class_name DoorStateBit extends Bit
## Defines the current state of the door.

@onready var door:DoorBit

func _on_active():   pass
func _on_inactive(): pass

func _on_user_entered(_user:Bot, _user_direction:float): pass
func _on_user_exited (_user:Bot, _user_direction:float): pass

func _active  (_delta:float): pass
func _inactive(_delta:float): pass
