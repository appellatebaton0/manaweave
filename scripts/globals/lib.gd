extends Node

# Returns an array of instantiated Nodes from a folder.
func mass_instantiate(path) -> Array[Node]:
	var nodes:Array[Node]
	
	for resource in mass_load(path):
		if resource is PackedScene: nodes.append(resource.instantiate())
	
	return nodes

# Returns an array of Resources from a folder.
func mass_load(path) -> Array[Resource]:
	var resources:Array[Resource]
	
	for filename in get_file_paths_at(path):
		resources.append(load(filename))
	
	return resources

# Returns a string of paths to all the files within a folder.
func get_file_paths_at(path) -> Array[String]:
	
	var paths:Array[String] = []
	
	var dir = DirAccess.open(path)
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			## Add any files from subfolders.
			if dir.current_is_dir(): paths.append_array(get_file_paths_at(path + file_name + "/"))
			## Add any files in the given folder.
			else: paths.append(path + file_name)
			
			file_name = dir.get_next()
	else:
		push_error("An error occurred when trying to access the path: ", path)
	
	if len(paths) <= 0: push_error("Found no files to load when attempting path ", path)
	
	return paths
