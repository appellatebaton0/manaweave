@tool
extends EditorPlugin

var dock

func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	dock = preload("level_editor.tscn").instantiate()
	print(dock, self)
	dock.plugin = self
	
	add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_UL, dock)

func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	
	remove_control_from_docks(dock)
	dock.free()
