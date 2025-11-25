@abstract class_name Bit extends Bot
## Provides extended functionality to a Bot.

## Whether or not the chain of functionality inheritance stops at this bot.
@export var isolated := false

@onready var bot:Bot = get_bot()
func get_bot(depth := 5, with:Node = self) -> Bot:
	if depth == 0 or with == null:
		return null
	
	if isolated:
		return self
	
	var parent = with.get_parent()
	
	if parent is Bit: return parent.get_bot(depth - 1) ## IF the parent's a bit, return its bot.
	elif parent is Bot: return parent ## IF it is a bot but not a bit, it's the target.
	return get_bot(depth - 1, parent) ## ELSE search from the parent.
