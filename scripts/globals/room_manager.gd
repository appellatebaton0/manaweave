extends Node

## An enum for the possible open entrances of a room, arranged clockwise from top left.
## Rooms have 8 entrances; (each X is an entrance)
## / X - X \
## X       X
## |       |
## X       X
## \ X - X /
enum ENTRANCES {
	TOP_LEFT,    TOP_RIGHT,    
	RIGHT_TOP,    RIGHT_BOTTOM,
	BOTTOM_RIGHT, BOTTOM_LEFT, 
	LEFT_BOTTOM,  LEFT_TOP     
}

## An enum for the possible states of an entrance.
enum ENTRANCE_STATE {
	OPEN,   ## The entrance is open, and can be walked through freely.
	CLOSED, ## The entrance is closed, and can't be walked through until next shuffle.
	LOCKED, ## The entrance is locked, and needs some sort of key to open.
	INVALID ## There is no supported entrance here.
}
