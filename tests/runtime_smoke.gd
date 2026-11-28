extends SceneTree

var active_scene: Node

func _initialize() -> void:
	call_deferred("_run_smoke_test")

func _run_smoke_test() -> void:
	var packed_scene := ResourceLoader.load("res://scenes/main.tscn") as PackedScene
	if packed_scene == null:
		push_error("Runtime smoke test: main scene failed to load.")
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

	print("RUNTIME SMOKE TEST: main scene started.")
	await create_timer(3.0).timeout

	if is_instance_valid(active_scene):
		current_scene = null
		active_scene.free()
	active_scene = null
	await process_frame
	print("RUNTIME SMOKE TEST PASSED: scene ran for 3 seconds and shut down cleanly.")
	quit(0)
