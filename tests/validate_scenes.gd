extends SceneTree

var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_validate_all_scenes")

func _validate_all_scenes() -> void:
	var scene_paths: Array[String] = []
	_collect_scenes("res://scenes", scene_paths)
	scene_paths.sort()
	for scene_path in scene_paths:
		var packed := ResourceLoader.load(scene_path) as PackedScene
		if packed == null:
			failures.append("Could not load: " + scene_path)
			continue
		var instance := packed.instantiate()
		if instance == null:
			failures.append("Could not instantiate: " + scene_path)
			continue
		instance.free()
		instance = null
		packed = null
	ResourceLoader.clear_cached_resources()
	await process_frame
	if failures.is_empty():
		print("SCENE VALIDATION PASSED: %d scenes loaded and instantiated." % scene_paths.size())
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)

func _collect_scenes(folder_path: String, output: Array[String]) -> void:
	var directory := DirAccess.open(folder_path)
	if directory == null:
		failures.append("Could not open directory: " + folder_path)
		return
	directory.list_dir_begin()
	var entry := directory.get_next()
	while entry != "":
		if directory.current_is_dir():
			if not entry.begins_with("."):
				_collect_scenes(folder_path.path_join(entry), output)
		elif entry.ends_with(".tscn"):
			output.append(folder_path.path_join(entry))
		entry = directory.get_next()
	directory.list_dir_end()
