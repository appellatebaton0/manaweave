@abstract class_name DoorStateBit extends Bit
## Defines the current state of the door.

#@warning_ignore("unused_signal") signal exited_range ## The user has left the range of the door.
#@warning_ignore("unused_signal") signal entered_range ## The user has entered the range of the door.
#@warning_ignore("unused_signal") signal interact ## The user has interacted w/ the door.

## States to switch to upon a given event.
@export var switches:Dictionary[StringName, DoorStateBit] = {
	"exited_range": null,
	"entered_range": null,
	"interact": null
}

@onready var door:DoorBit

## Action functions

func _on_active() -> void:   pass
func _on_inactive() -> void: pass

func _on_user_entered(_user:Bot) -> void: pass
func _on_user_exited(_user:Bot) -> void: pass

func _on_user_interact() -> void: pass

func _active(_delta:float) -> void: pass
func _inactive(_delta:float) -> void: pass

func _phys_active(_delta:float) -> void: pass
func _phys_inactive(_delta:float) -> void: pass
