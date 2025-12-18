@tool
extends EditorPlugin


#var edi # for caching EditorInterface
#
#func _init():
	#var plugin = EditorPlugin.new()
	#edi = plugin.get_editor_interface() # now you always have the interface
	#plugin.queue_free()
#
## Then, in whatever context you want, you should be able to access it
#func _process():
	#if (self in edi.get_selection().get_selected_node()):
		## do stuff

func _enable_plugin() -> void:
	# Add autoloads here.
	pass


func _disable_plugin() -> void:
	# Remove autoloads here.
	pass

var dock

func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	dock = preload("level_editor.tscn").instantiate()
	dock.plugin = self
	
	add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_UL, dock)
	
	


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	
	remove_control_from_docks(dock)
	dock.free()
