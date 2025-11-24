class_name RoomBit extends Bit
## The bit for a room. Manages everything pertaining to the room.
## What entrances are open, anything needed for shuffling, etc.

## Contains the states of every entrance.
@export var entrance_states:Dictionary[RoomManager.ENTRANCES, RoomManager.ENTRANCE_STATE]
