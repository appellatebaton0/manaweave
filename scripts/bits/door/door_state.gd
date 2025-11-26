@abstract class_name DoorStateBit extends Bit
## Defines the current state of the door.

@warning_ignore("unused_signal") signal exited_range_left ## The user has left the range of the door on the left side.
@warning_ignore("unused_signal") signal exited_range_right ## The user has left the range of the door on the right side.

@warning_ignore("unused_signal") signal entered_range_left ## The user has entered the range of the door from the left side.
@warning_ignore("unused_signal") signal entered_range_right ## The user has entered the range of the door from the right side.

@warning_ignore("unused_signal") signal interact_right ## The user has interacted w/ the door from the right.
@warning_ignore("unused_signal") signal interact_left ## The user has interacted w/ the door from the left.


## States to switch to upon a given event.
@export var switches:Dictionary[String, DoorStateBit] = {
	"exited_range_left": null,
	"exited_range_right": null,
	"entered_range_left": null,
	"entered_range_right": null,
	"interact_right": null,
	"interact_left": null,
}

@onready var door:DoorBit

## Action functions

func _on_active() -> void:   pass
func _on_inactive() -> void: pass

func _on_user_entered(_user:Bot, _user_direction:float) -> void: pass
func _on_user_exited(_user:Bot, _user_direction:float) -> void: pass

func _active(_delta:float) -> void: pass
func _inactive(_delta:float) -> void: pass
