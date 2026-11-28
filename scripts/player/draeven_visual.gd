extends Node3D
class_name DraevenVisual

@export var animation_blend_speed: float = 12.0
@export_file("*.glb") var skinned_model_path: String = "res://assets/characters/draeven/draeven_Apose.glb"

var body: Node3D
var chest: Node3D
var head: Node3D
var left_arm: Node3D
var right_arm: Node3D
var left_forearm: Node3D
var right_forearm: Node3D
var left_leg: Node3D
var right_leg: Node3D
var left_knee: Node3D
var right_knee: Node3D
var coat_left: Node3D
var coat_right: Node3D
var weapon_socket: Marker3D
var active_tween: Tween
var action_name: StringName = &"idle"
var action_time: float = 0.0
var walk_phase: float = 0.0
var attack_variant: int = 1
var weapon_form: int = 0
var weapon_switch_tween: Tween
var skinned_model: Node3D
var model_animation_player: AnimationPlayer
var using_skinned_model: bool = false

var mat_coat: StandardMaterial3D
var mat_coat_inner: StandardMaterial3D
var mat_silver: StandardMaterial3D
var mat_armor: StandardMaterial3D
var mat_skin: StandardMaterial3D
var mat_hair: StandardMaterial3D
var mat_boot: StandardMaterial3D
var mat_eye: StandardMaterial3D

func _ready() -> void:
	mat_coat = _material(Color(0.018, 0.035, 0.085), 0.72, 0.12)
	mat_coat_inner = _material(Color(0.006, 0.008, 0.016), 0.85, 0.05)
	mat_silver = _material(Color(0.58, 0.68, 0.78), 0.35, 0.45)
	mat_armor = _material(Color(0.09, 0.13, 0.19), 0.38, 0.32)
	mat_skin = _material(Color(0.72, 0.55, 0.43), 0.82, 0.0)
	mat_hair = _material(Color(0.78, 0.83, 0.9), 0.42, 0.3)
	mat_boot = _material(Color(0.025, 0.03, 0.045), 0.55, 0.12)
	mat_eye = _material(Color(0.12, 0.42, 0.72), 0.22, 0.8)
	if _try_load_skinned_model():
		return
	_build_character()

func _process(delta: float) -> void:
	if using_skinned_model:
		return
	action_time += delta
	if action_name == &"walk":
		walk_phase += delta * 10.0
		var swing := sin(walk_phase) * 0.48
		left_leg.rotation.x = lerpf(left_leg.rotation.x, swing, delta * animation_blend_speed)
		right_leg.rotation.x = lerpf(right_leg.rotation.x, -swing, delta * animation_blend_speed)
		left_arm.rotation.x = lerpf(left_arm.rotation.x, -swing * 0.62, delta * animation_blend_speed)
		right_arm.rotation.x = lerpf(right_arm.rotation.x, -swing * 0.62, delta * animation_blend_speed)
		left_forearm.rotation.x = lerpf(left_forearm.rotation.x, 0.12 + maxf(0.0, swing) * 0.18, delta * animation_blend_speed)
		right_forearm.rotation.x = lerpf(right_forearm.rotation.x, 0.12 + maxf(0.0, -swing) * 0.18, delta * animation_blend_speed)
		left_knee.rotation.x = lerpf(left_knee.rotation.x, maxf(0.0, swing) * 0.32, delta * animation_blend_speed)
		right_knee.rotation.x = lerpf(right_knee.rotation.x, maxf(0.0, -swing) * 0.32, delta * animation_blend_speed)
		coat_left.rotation.x = lerpf(coat_left.rotation.x, swing * 0.12, delta * 8.0)
		coat_right.rotation.x = lerpf(coat_right.rotation.x, -swing * 0.12, delta * 8.0)
	elif action_name == &"idle":
		var breath := sin(action_time * 2.1) * 0.018
		if chest:
			chest.position.y = 1.38 + breath
		if head:
			head.rotation.x = sin(action_time * 1.1) * 0.018
		if coat_left:
			coat_left.rotation.x = lerpf(coat_left.rotation.x, 0.0, delta * 5.0)
			coat_right.rotation.x = lerpf(coat_right.rotation.x, 0.0, delta * 5.0)
			left_forearm.rotation.x = lerpf(left_forearm.rotation.x, 0.0, delta * 5.0)
			right_forearm.rotation.x = lerpf(right_forearm.rotation.x, 0.0, delta * 5.0)
			left_knee.rotation.x = lerpf(left_knee.rotation.x, 0.0, delta * 5.0)
			right_knee.rotation.x = lerpf(right_knee.rotation.x, 0.0, delta * 5.0)
	elif action_name == &"dodge":
		body.rotation.z = lerpf(body.rotation.z, 0.24, delta * animation_blend_speed)
	elif action_name == &"attack":
		pass

func play_move(moving: bool) -> void:
	if using_skinned_model:
		if action_name in [&"attack", &"dodge"]:
			return
		var model_action: StringName = &"walk" if moving else &"idle"
		if action_name != model_action:
			action_name = model_action
			_play_model_animation("walk-loop" if moving else "idle-loop")
		return
	if action_name in [&"attack", &"dodge"]:
		return
	var next_action: StringName = &"walk" if moving else &"idle"
	if action_name == next_action:
		return
	action_name = next_action
	action_time = 0.0
	if not moving:
		_reset_limb_pose()

func play_attack(combo_index: int, heavy: bool, form: int = 0) -> void:
	if using_skinned_model:
		action_name = &"attack"
		var clip := "attack_heavy" if heavy else ("attack_light" if combo_index <= 1 else "combo")
		_play_model_animation(clip)
		return
	action_name = &"attack"
	action_time = 0.0
	attack_variant = combo_index
	if active_tween and active_tween.is_running():
		active_tween.kill()
	var duration := 0.34 if not heavy else 0.52
	active_tween = create_tween()
	active_tween.set_parallel(true)
	match form:
		1:
			active_tween.tween_property(right_arm, "rotation", Vector3(-1.75, 0.0, -0.65 if combo_index % 2 == 1 else 0.65), duration * 0.38)
			active_tween.tween_property(right_forearm, "rotation", Vector3(-0.45, 0.0, 0.0), duration * 0.38)
			active_tween.tween_property(chest, "rotation:y", -0.28 if combo_index % 2 == 1 else 0.28, duration * 0.38)
		2:
			active_tween.tween_property(right_arm, "rotation", Vector3(-1.9, 0.0, -0.9 if combo_index % 2 == 1 else 0.9), duration * 0.4)
			active_tween.tween_property(right_forearm, "rotation", Vector3(-0.55, 0.0, 0.0), duration * 0.4)
			active_tween.tween_property(chest, "rotation:y", 0.32 if combo_index % 2 == 1 else -0.32, duration * 0.4)
		3:
			active_tween.tween_property(right_arm, "rotation", Vector3(-1.65, 0.0, -0.45), duration * 0.4)
			active_tween.tween_property(left_arm, "rotation", Vector3(-1.25, 0.0, 0.5), duration * 0.4)
			active_tween.tween_property(chest, "rotation:x", -0.22, duration * 0.4)
		0:
			match combo_index:
				1:
					active_tween.tween_property(right_arm, "rotation", Vector3(-1.55, 0.0, -0.85), duration * 0.42)
					active_tween.tween_property(right_forearm, "rotation", Vector3(-0.25, 0.0, 0.3), duration * 0.42)
					active_tween.tween_property(chest, "rotation:y", -0.22, duration * 0.42)
				2:
					active_tween.tween_property(right_arm, "rotation", Vector3(-1.35, 0.0, 0.95), duration * 0.42)
					active_tween.tween_property(right_forearm, "rotation", Vector3(-0.35, 0.0, -0.28), duration * 0.42)
					active_tween.tween_property(chest, "rotation:y", 0.24, duration * 0.42)
				3:
					active_tween.tween_property(right_arm, "rotation", Vector3(-2.0, 0.0, -0.15), duration * 0.42)
					active_tween.tween_property(right_forearm, "rotation", Vector3(-0.6, 0.0, 0.12), duration * 0.42)
					active_tween.tween_property(chest, "rotation:x", -0.18, duration * 0.42)
				_:
					active_tween.tween_property(right_arm, "rotation", Vector3(-2.0, 0.0, -0.1), duration * 0.45)
					active_tween.tween_property(right_forearm, "rotation", Vector3(-0.5, 0.0, 0.0), duration * 0.45)
					active_tween.tween_property(chest, "rotation:x", -0.24, duration * 0.45)
	active_tween.chain().tween_property(right_arm, "rotation", Vector3.ZERO, duration * 0.58)
	active_tween.parallel().tween_property(right_forearm, "rotation", Vector3.ZERO, duration * 0.58)
	active_tween.parallel().tween_property(chest, "rotation", Vector3.ZERO, duration * 0.58)
	active_tween.tween_callback(_return_to_idle)

func play_dodge(direction: Vector3) -> void:
	if using_skinned_model:
		action_name = &"dodge"
		_play_model_animation("dodge")
		return
	action_name = &"dodge"
	action_time = 0.0
	if active_tween and active_tween.is_running():
		active_tween.kill()
	var side := signf(direction.dot(global_transform.basis.x))
	active_tween = create_tween()
	active_tween.set_parallel(true)
	active_tween.tween_property(body, "rotation:z", -0.28 if side == 0.0 else -0.38 * side, 0.12)
	active_tween.tween_property(chest, "rotation:x", 0.18, 0.12)
	active_tween.tween_property(right_arm, "rotation:z", -0.55, 0.12)
	active_tween.tween_property(left_arm, "rotation:z", 0.55, 0.12)
	active_tween.chain().tween_property(body, "rotation", Vector3.ZERO, 0.2)
	active_tween.parallel().tween_property(chest, "rotation", Vector3.ZERO, 0.2)
	active_tween.parallel().tween_property(right_arm, "rotation", Vector3.ZERO, 0.2)
	active_tween.parallel().tween_property(left_arm, "rotation", Vector3.ZERO, 0.2)
	active_tween.tween_callback(_return_to_idle)

func get_weapon_socket() -> Marker3D:
	return weapon_socket

func set_weapon_form(next_form: int) -> void:
	weapon_form = posmod(next_form, 4)
	if using_skinned_model:
		_play_model_animation("weapon_switch")
	if not is_instance_valid(weapon_socket):
		return
	if weapon_switch_tween and weapon_switch_tween.is_running():
		weapon_switch_tween.kill()
	weapon_switch_tween = create_tween()
	weapon_switch_tween.tween_property(weapon_socket, "scale", Vector3(0.05, 0.05, 0.05), 0.10).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	weapon_switch_tween.tween_callback(_rebuild_weapon)
	weapon_switch_tween.tween_property(weapon_socket, "scale", Vector3.ONE, 0.14).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _rebuild_weapon() -> void:
	for child in weapon_socket.get_children():
		child.queue_free()
	match weapon_form:
		0:
			_build_sword(weapon_socket)
		1:
			_build_chain_blades(weapon_socket)
		2:
			_build_twin_reapers(weapon_socket)
		3:
			_build_soul_swords(weapon_socket)

func _build_chain_blades(parent: Node3D) -> void:
	for side in [-1.0, 1.0]:
		var pivot := Node3D.new()
		pivot.position = Vector3(side * 0.11, -0.08, 0.0)
		parent.add_child(pivot)
		_add_box(pivot, "ChainGrip", Vector3(0.045, 0.18, 0.045), Vector3.ZERO, mat_boot)
		_add_box(pivot, "ChainGuard", Vector3(0.16, 0.035, 0.05), Vector3(0, -0.1, 0), mat_silver)
		_add_box(pivot, "ChainBlade", Vector3(0.07, 0.38, 0.025), Vector3(0, -0.31, 0), mat_silver)
		for link in range(4):
			_add_box(pivot, "ChainLink%d" % link, Vector3(0.025, 0.065, 0.025), Vector3(0, -0.52 - float(link) * 0.055, 0), mat_silver)

func _build_twin_reapers(parent: Node3D) -> void:
	for side in [-1.0, 1.0]:
		var pivot := Node3D.new()
		pivot.position = Vector3(side * 0.12, -0.12, 0.0)
		pivot.rotation.z = side * 0.18
		parent.add_child(pivot)
		_add_box(pivot, "ReaperHandle", Vector3(0.055, 0.48, 0.055), Vector3(0, -0.2, 0), mat_boot)
		_add_box(pivot, "ReaperCrossguard", Vector3(0.22, 0.045, 0.07), Vector3(0, -0.43, 0), mat_silver)
		_add_box(pivot, "ReaperBlade", Vector3(0.11, 0.46, 0.035), Vector3(side * 0.06, -0.68, 0), mat_silver).rotation.z = -side * 0.24
		_add_box(pivot, "ReaperEdge", Vector3(0.025, 0.38, 0.018), Vector3(side * 0.11, -0.68, -0.025), mat_eye).rotation.z = -side * 0.24

func _build_soul_swords(parent: Node3D) -> void:
	for side in [-1.0, 1.0]:
		var pivot := Node3D.new()
		pivot.position = Vector3(side * 0.105, -0.05, 0.0)
		pivot.rotation.z = side * 0.12
		parent.add_child(pivot)
		_add_box(pivot, "SoulSwordGrip", Vector3(0.045, 0.16, 0.045), Vector3(0, -0.08, 0), mat_boot)
		_add_box(pivot, "SoulSwordGuard", Vector3(0.19, 0.035, 0.055), Vector3(0, -0.17, 0), mat_silver)
		_add_box(pivot, "SoulSwordBlade", Vector3(0.075, 0.58, 0.028), Vector3(0, -0.47, 0), mat_silver)
		_add_box(pivot, "SoulSwordCore", Vector3(0.018, 0.52, 0.012), Vector3(0, -0.47, -0.022), mat_eye)

func _return_to_idle() -> void:
	action_name = &"idle"
	if using_skinned_model:
		_play_model_animation("idle-loop")
		return
	action_time = 0.0
	_reset_limb_pose()

func _reset_limb_pose() -> void:
	if not is_instance_valid(left_arm):
		return
	left_arm.rotation = Vector3.ZERO
	right_arm.rotation = Vector3.ZERO
	left_forearm.rotation = Vector3.ZERO
	right_forearm.rotation = Vector3.ZERO
	left_knee.rotation = Vector3.ZERO
	right_knee.rotation = Vector3.ZERO
	left_leg.rotation = Vector3.ZERO
	right_leg.rotation = Vector3.ZERO
	left_knee.rotation = Vector3.ZERO
	right_knee.rotation = Vector3.ZERO
	body.rotation = Vector3.ZERO
	chest.rotation = Vector3.ZERO


func _try_load_skinned_model() -> bool:
	if skinned_model_path.is_empty() or not ResourceLoader.exists(skinned_model_path):
		push_warning("Draeven skinned model is not installed at %s; using the procedural fallback." % skinned_model_path)
		return false
	var packed_model := load(skinned_model_path) as PackedScene
	if packed_model == null:
		push_warning("Draeven model could not be imported as a PackedScene: %s" % skinned_model_path)
		return false
	var instance := packed_model.instantiate()
	if not instance is Node3D:
		instance.queue_free()
		push_warning("Draeven GLB root is not Node3D; using procedural fallback.")
		return false
	skinned_model = instance as Node3D
	skinned_model.name = "SkinnedDraeven"
	add_child(skinned_model)
	model_animation_player = _find_first_animation_player(skinned_model)
	if model_animation_player == null:
		skinned_model.queue_free()
		skinned_model = null
		push_warning("Draeven GLB has no AnimationPlayer; using procedural fallback.")
		return false
	var skeleton := _find_first_skeleton(skinned_model)
	if skeleton == null:
		skinned_model.queue_free()
		skinned_model = null
		model_animation_player = null
		push_warning("Draeven GLB has no Skeleton3D; using procedural fallback.")
		return false
	var imported_sword := _find_named_node(skinned_model, "Katana")
	if imported_sword is GeometryInstance3D:
		(imported_sword as GeometryInstance3D).visible = false
	var hand_attachment := BoneAttachment3D.new()
	hand_attachment.name = "WeaponHandAttachment"
	hand_attachment.bone_name = "RightHand"
	skeleton.add_child(hand_attachment)
	weapon_socket = Marker3D.new()
	weapon_socket.name = "WeaponSocket"
	hand_attachment.add_child(weapon_socket)
	_build_sword(weapon_socket)
	model_animation_player.animation_finished.connect(_on_model_animation_finished)
	using_skinned_model = true
	action_name = &"idle"
	_play_model_animation("idle-loop")
	print("DRAEVEN MODEL: loaded skinned A-Pose with %d animations." % model_animation_player.get_animation_list().size())
	return true

func _play_model_animation(clip_name: String) -> void:
	if not is_instance_valid(model_animation_player):
		return
	if model_animation_player.has_animation(clip_name):
		model_animation_player.play(clip_name)
	elif model_animation_player.has_animation("idle-loop"):
		model_animation_player.play("idle-loop")

func _on_model_animation_finished(clip_name: StringName) -> void:
	if clip_name != &"idle-loop" and clip_name != &"walk-loop" and clip_name != &"run-loop":
		_return_to_idle()

func _find_first_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node as AnimationPlayer
	for child in node.get_children():
		var found := _find_first_animation_player(child)
		if found != null:
			return found
	return null

func _find_first_skeleton(node: Node) -> Skeleton3D:
	if node is Skeleton3D:
		return node as Skeleton3D
	for child in node.get_children():
		var found := _find_first_skeleton(child)
		if found != null:
			return found
	return null

func _find_named_node(node: Node, target_name: String) -> Node:
	if node.name == target_name:
		return node
	for child in node.get_children():
		var found := _find_named_node(child, target_name)
		if found != null:
			return found
	return null

func _build_character() -> void:
	body = Node3D.new()
	body.name = "BodyRig"
	add_child(body)
	_add_capsule(body, "Pelvis", 0.22, 0.34, Vector3(0, 0.91, 0), mat_armor)
	chest = Node3D.new()
	chest.name = "ChestPivot"
	chest.position = Vector3(0, 1.38, 0)
	body.add_child(chest)
	_add_capsule(chest, "Torso", 0.245, 0.62, Vector3.ZERO, mat_coat)
	_add_box(chest, "ChestArmor", Vector3(0.37, 0.23, 0.12), Vector3(0, 0.12, -0.13), mat_armor)
	_add_box(chest, "SilverChestTrim", Vector3(0.29, 0.03, 0.025), Vector3(0, 0.19, -0.205), mat_silver)
	_add_box(chest, "Belt", Vector3(0.37, 0.065, 0.29), Vector3(0, -0.27, 0), mat_boot)
	_add_box(chest, "BeltBuckle", Vector3(0.09, 0.09, 0.035), Vector3(0, -0.27, -0.18), mat_silver)
	_add_box(chest, "LeftCoatLapel", Vector3(0.105, 0.39, 0.045), Vector3(-0.105, 0.19, -0.18), mat_coat_inner).rotation.z = -0.16
	_add_box(chest, "RightCoatLapel", Vector3(0.105, 0.39, 0.045), Vector3(0.105, 0.19, -0.18), mat_coat_inner).rotation.z = 0.16
	_add_box(chest, "LapelSilverEdgeL", Vector3(0.018, 0.34, 0.018), Vector3(-0.16, 0.19, -0.207), mat_silver).rotation.z = -0.16
	_add_box(chest, "LapelSilverEdgeR", Vector3(0.018, 0.34, 0.018), Vector3(0.16, 0.19, -0.207), mat_silver).rotation.z = 0.16
	_add_box(chest, "WaistSilverLine", Vector3(0.34, 0.018, 0.018), Vector3(0, -0.22, -0.16), mat_silver)
	_add_box(chest, "LeftRibArmor", Vector3(0.055, 0.25, 0.055), Vector3(-0.205, -0.015, -0.105), mat_armor)
	_add_box(chest, "RightRibArmor", Vector3(0.055, 0.25, 0.055), Vector3(0.205, -0.015, -0.105), mat_armor)

	head = Node3D.new()
	head.name = "Head"
	head.position = Vector3(0, 1.86, 0)
	body.add_child(head)
	_add_sphere(head, "Face", Vector3(0.16, 0.22, 0.145), Vector3.ZERO, mat_skin)
	_add_sphere(head, "HairCap", Vector3(0.175, 0.14, 0.17), Vector3(0, 0.14, 0.025), mat_hair)
	# Soft downward fringe, with layered locks instead of swept-back spikes.
	_add_capsule(head, "FringeCenter", 0.052, 0.29, Vector3(-0.015, 0.015, -0.115), mat_hair).rotation.z = -0.10
	_add_capsule(head, "FringeLeft", 0.046, 0.25, Vector3(-0.085, 0.005, -0.105), mat_hair).rotation.z = 0.28
	_add_capsule(head, "FringeRight", 0.046, 0.27, Vector3(0.075, -0.005, -0.11), mat_hair).rotation.z = -0.25
	_add_capsule(head, "SideLockL", 0.045, 0.34, Vector3(-0.145, -0.105, 0.015), mat_hair).rotation.z = -0.08
	_add_capsule(head, "SideLockR", 0.045, 0.34, Vector3(0.145, -0.105, 0.015), mat_hair).rotation.z = 0.08
	_add_capsule(head, "BackHairL", 0.055, 0.32, Vector3(-0.105, -0.11, 0.105), mat_hair).rotation.z = -0.12
	_add_capsule(head, "BackHairR", 0.055, 0.32, Vector3(0.105, -0.11, 0.105), mat_hair).rotation.z = 0.12
	_add_box(head, "EyeL", Vector3(0.035, 0.018, 0.012), Vector3(-0.065, 0.015, -0.139), mat_eye)
	_add_box(head, "EyeR", Vector3(0.035, 0.018, 0.012), Vector3(0.065, 0.015, -0.139), mat_eye)

	left_arm = _make_arm("LeftArm", Vector3(-0.34, 1.59, 0), mat_coat, false)
	right_arm = _make_arm("RightArm", Vector3(0.34, 1.59, 0), mat_coat, true)
	body.add_child(left_arm)
	body.add_child(right_arm)
	left_leg = _make_leg("LeftLeg", Vector3(-0.13, 0.78, 0))
	right_leg = _make_leg("RightLeg", Vector3(0.13, 0.78, 0))
	body.add_child(left_leg)
	body.add_child(right_leg)

	coat_left = Node3D.new()
	coat_left.position = Vector3(-0.13, 1.03, 0.12)
	body.add_child(coat_left)
	_add_box(coat_left, "CoatTailL", Vector3(0.19, 0.7, 0.07), Vector3(0, -0.35, 0), mat_coat)
	_add_box(coat_left, "CoatTailTrimL", Vector3(0.025, 0.68, 0.018), Vector3(-0.07, -0.35, -0.042), mat_silver)
	coat_right = Node3D.new()
	coat_right.position = Vector3(0.13, 1.03, 0.12)
	body.add_child(coat_right)
	_add_box(coat_right, "CoatTailR", Vector3(0.19, 0.7, 0.07), Vector3(0, -0.35, 0), mat_coat)
	_add_box(coat_right, "CoatTailTrimR", Vector3(0.025, 0.68, 0.018), Vector3(0.07, -0.35, -0.042), mat_silver)
	_add_box(coat_left, "CoatTailInnerL", Vector3(0.13, 0.62, 0.025), Vector3(0.015, -0.35, -0.045), mat_coat_inner)
	_add_box(coat_right, "CoatTailInnerR", Vector3(0.13, 0.62, 0.025), Vector3(-0.015, -0.35, -0.045), mat_coat_inner)

func _make_arm(label: String, origin: Vector3, sleeve_material: Material, is_right: bool) -> Node3D:
	var pivot := Node3D.new()
	pivot.name = label
	pivot.position = origin
	_add_capsule(pivot, "UpperSleeve", 0.095, 0.38, Vector3(0, -0.16, 0), sleeve_material)
	_add_sphere(pivot, "ShoulderGuard", Vector3(0.125, 0.11, 0.13), Vector3(0, 0.015, 0), mat_armor)
	_add_box(pivot, "ShoulderSilverInlay", Vector3(0.105, 0.025, 0.14), Vector3(0, 0.075, -0.012), mat_silver)
	var forearm := Node3D.new()
	forearm.name = "ForearmPivot"
	forearm.position = Vector3(0, -0.34, 0)
	pivot.add_child(forearm)
	if is_right:
		right_forearm = forearm
	else:
		left_forearm = forearm
	_add_capsule(forearm, "Forearm", 0.072, 0.32, Vector3(0, -0.14, 0), mat_armor)
	_add_box(forearm, "Bracer", Vector3(0.19, 0.13, 0.12), Vector3(0, -0.19, -0.015), mat_silver)
	var hand := Node3D.new()
	hand.name = "Hand"
	hand.position = Vector3(0, -0.31, 0)
	forearm.add_child(hand)
	_add_sphere(hand, "Glove", Vector3(0.09, 0.09, 0.08), Vector3.ZERO, mat_boot)
	if is_right:
		weapon_socket = Marker3D.new()
		weapon_socket.name = "WeaponSocket"
		weapon_socket.position = Vector3(0, -0.04, -0.02)
		hand.add_child(weapon_socket)
		_build_sword(weapon_socket)
	else:
		_add_box(hand, "LeftGloveCuff", Vector3(0.14, 0.07, 0.12), Vector3(0, 0.025, 0), mat_silver)
	return pivot

func _make_leg(label: String, origin: Vector3) -> Node3D:
	var pivot := Node3D.new()
	pivot.name = label
	pivot.position = origin
	_add_capsule(pivot, "Thigh", 0.105, 0.42, Vector3(0, -0.2, 0), mat_boot)
	var knee := Node3D.new()
	knee.name = "KneePivot"
	knee.position = Vector3(0, -0.39, 0)
	pivot.add_child(knee)
	if label == "LeftLeg":
		left_knee = knee
	else:
		right_knee = knee
	_add_capsule(knee, "Shin", 0.09, 0.42, Vector3(0, -0.2, 0), mat_armor)
	_add_box(knee, "Boot", Vector3(0.2, 0.13, 0.32), Vector3(0, -0.4, -0.055), mat_boot)
	_add_box(knee, "KneeGuard", Vector3(0.15, 0.13, 0.055), Vector3(0, -0.035, -0.07), mat_armor)
	_add_box(knee, "KneeGuardEdge", Vector3(0.11, 0.018, 0.012), Vector3(0, -0.005, -0.102), mat_silver)
	return pivot

func _build_sword(parent: Node3D) -> void:
	var grip := _add_box(parent, "SwordGrip", Vector3(0.055, 0.2, 0.055), Vector3(0, -0.08, 0), mat_boot)
	_add_box(parent, "SwordGuard", Vector3(0.28, 0.045, 0.075), Vector3(0, -0.19, 0), mat_silver)
	_add_box(parent, "SwordBlade", Vector3(0.095, 0.72, 0.035), Vector3(0, -0.56, 0), mat_silver)
	_add_box(parent, "BladeCenter", Vector3(0.025, 0.66, 0.012), Vector3(0, -0.56, -0.024), mat_eye)
	_add_box(parent, "SwordPommel", Vector3(0.085, 0.075, 0.075), Vector3(0, 0.035, 0), mat_silver)

func _add_capsule(parent: Node3D, label: String, radius: float, height: float, position: Vector3, material: Material) -> MeshInstance3D:
	var mesh := CapsuleMesh.new()
	mesh.radius = radius
	mesh.height = height
	return _add_mesh(parent, label, mesh, position, material)

func _add_sphere(parent: Node3D, label: String, size: Vector3, position: Vector3, material: Material) -> MeshInstance3D:
	var mesh := SphereMesh.new()
	mesh.radius = 0.5
	mesh.height = 1.0
	var instance := _add_mesh(parent, label, mesh, position, material)
	instance.scale = size
	return instance

func _add_box(parent: Node3D, label: String, size: Vector3, position: Vector3, material: Material) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	return _add_mesh(parent, label, mesh, position, material)

func _add_mesh(parent: Node3D, label: String, mesh: Mesh, position: Vector3, material: Material) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.name = label
	instance.mesh = mesh
	instance.position = position
	instance.material_override = material
	parent.add_child(instance)
	return instance

func _material(color: Color, roughness: float, metallic: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	material.metallic = metallic
	return material
