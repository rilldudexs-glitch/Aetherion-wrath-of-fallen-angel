extends SceneTree

var active_scene: Node

func _initialize() -> void:
	call_deferred("_run_smoke_test")

func _run_smoke_test() -> void:
	var main_scene_path := String(ProjectSettings.get_setting("application/run/main_scene", "res://scenes/main.tscn"))
	var packed_scene := ResourceLoader.load(main_scene_path, "PackedScene", ResourceLoader.CACHE_MODE_IGNORE_DEEP) as PackedScene
	if packed_scene == null:
		push_error("Runtime smoke test: configured main scene failed to load: " + main_scene_path)
		quit(1)
		return

	active_scene = packed_scene.instantiate()
	if active_scene == null:
		push_error("Runtime smoke test: main scene failed to instantiate.")
		quit(1)
		return

	root.add_child(active_scene)
	current_scene = active_scene
	packed_scene = null

	print("RUNTIME SMOKE TEST: configured main scene started: " + main_scene_path)
	await create_timer(3.0).timeout

	if is_instance_valid(active_scene):
		current_scene = null
		active_scene.free()
	active_scene = null
	await process_frame
	print("RUNTIME SMOKE TEST PASSED: scene ran for 3 seconds and shut down cleanly.")
	quit(0)
