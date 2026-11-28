extends DraevenVisual
class_name DraevenModelVisual

## Skinned-model replacement for the procedural Draeven placeholder.
## Uses the KayKit Rogue rig (CC0) with its built-in animation clips.
## If the model cannot be loaded, it falls back to the procedural visual from DraevenVisual.

const MODEL_PATH := "res://assets/characters/draeven/draeven_model.glb"
const BODY_TEXTURE_PATH := "res://assets/characters/draeven/draeven_body.png"
const HEAD_TEXTURE_PATH := "res://assets/characters/draeven/draeven_head.png"
const HEAD_MESH_NAME := "Rogue_Head"
const HIDDEN_PARTS: Array[String] = ["Knife", "Knife_Offhand", "1H_Crossbow", "2H_Crossbow", "Throwable"]
const LOOPING_CLIPS: Array[StringName] = [&"Idle", &"Walking_A", &"Walking_B", &"Running_A", &"Running_B"]

@export var model_scale: float = 1.1
## glTF models face +Z, Godot gameplay faces -Z. Adjust if Draeven walks backwards.
@export var model_yaw_degrees: float = 180.0
## Tune in-engine so the sword grip sits correctly in the right hand.
@export var weapon_socket_rotation_degrees: Vector3 = Vector3.ZERO
@export var idle_clip: StringName = &"Idle"
@export var move_clip: StringName = &"Running_A"
@export var clip_fade: float = 0.12

var use_model: bool = false
var model_root: Node3D
var skeleton: Skeleton3D
var anim_player: AnimationPlayer
var action_token: int = 0

func _ready() -> void:
	# Parent builds materials, the procedural body and the weapon socket/forms.
	super._ready()
	if not ResourceLoader.exists(MODEL_PATH):
		push_warning("DraevenModelVisual: %s missing, using procedural visual." % MODEL_PATH)
		return
	var packed := load(MODEL_PATH) as PackedScene
	if packed == null:
		push_warning("DraevenModelVisual: could not load model, using procedural visual.")
		return
	model_root = packed.instantiate() as Node3D
	if model_root == null:
		return
	model_root.name = "DraevenModel"
	model_root.scale = Vector3.ONE * model_scale
	model_root.rotation_degrees.y = model_yaw_degrees
	add_child(model_root)
	skeleton = model_root.find_child("Skeleton3D", true, false) as Skeleton3D
	anim_player = model_root.find_child("AnimationPlayer", true, false) as AnimationPlayer
	if skeleton == null or anim_player == null:
		push_warning("DraevenModelVisual: model has no skeleton or AnimationPlayer, using procedural visual.")
		model_root.queue_free()
		model_root = null
		return
	if not _attach_weapon_socket():
		push_warning("DraevenModelVisual: right hand bone not found, using procedural visual.")
		model_root.queue_free()
		model_root = null
		return
	_apply_materials()
	_setup_animations()
	# Remove the procedural placeholder body (weapon socket was moved out first).
	if is_instance_valid(body):
		body.queue_free()
	use_model = true
	_play_clip(idle_clip)

func _process(delta: float) -> void:
	if not use_model:
		super._process(delta)
		return
	action_time += delta

func play_move(moving: bool) -> void:
	if not use_model:
		super.play_move(moving)
		return
	if action_name in [&"attack", &"dodge"]:
		return
	var next_action: StringName = &"walk" if moving else &"idle"
	if action_name == next_action:
		return
	action_name = next_action
	action_time = 0.0
	_play_clip(move_clip if moving else idle_clip)

func play_attack(combo_index: int, heavy: bool, form: int = 0) -> void:
	if not use_model:
		super.play_attack(combo_index, heavy, form)
		return
	action_name = &"attack"
	action_time = 0.0
	attack_variant = combo_index
	# Same total timing as the procedural attack so combat timing stays aligned.
	var total := (0.34 if not heavy else 0.52) * 1.58
	_play_clip_fitted(_attack_clip(combo_index, heavy, form), total)
	_schedule_return_to_idle(total)

func play_dodge(direction: Vector3) -> void:
	if not use_model:
		super.play_dodge(direction)
		return
	action_name = &"dodge"
	action_time = 0.0
	var local_dir := global_transform.basis.inverse() * direction
	var clip: StringName = &"Dodge_Forward"
	if absf(local_dir.x) > absf(local_dir.z):
		clip = &"Dodge_Right" if local_dir.x > 0.0 else &"Dodge_Left"
	elif local_dir.z > 0.0:
		clip = &"Dodge_Backward"
	var total := 0.4
	_play_clip_fitted(clip, total)
	_schedule_return_to_idle(total)

func _return_to_idle() -> void:
	if not use_model:
		super._return_to_idle()
		return
	action_name = &"idle"
	action_time = 0.0
	_play_clip(idle_clip)

func _attack_clip(combo_index: int, heavy: bool, form: int) -> StringName:
	if form == 3:
		match combo_index:
			1:
				return &"Dualwield_Melee_Attack_Slice"
			2:
				return &"Dualwield_Melee_Attack_Chop"
			_:
				return &"Dualwield_Melee_Attack_Stab"
	if heavy:
		return &"2H_Melee_Attack_Chop"
	match combo_index:
		1:
			return &"1H_Melee_Attack_Slice_Horizontal"
		2:
			return &"1H_Melee_Attack_Slice_Diagonal"
		3:
			return &"1H_Melee_Attack_Chop"
		_:
			return &"1H_Melee_Attack_Stab"

func _play_clip(clip: StringName) -> void:
	if anim_player == null or not anim_player.has_animation(clip):
		push_warning("DraevenModelVisual: missing animation '%s'" % clip)
		return
	anim_player.play(clip, clip_fade)

func _play_clip_fitted(clip: StringName, total_time: float) -> void:
	if anim_player == null or not anim_player.has_animation(clip):
		push_warning("DraevenModelVisual: missing animation '%s'" % clip)
		return
	var length := anim_player.get_animation(clip).length
	var speed := clampf(length / maxf(total_time, 0.05), 0.6, 3.0)
	anim_player.play(clip, clip_fade * 0.5, speed)

func _schedule_return_to_idle(delay: float) -> void:
	action_token += 1
	var token := action_token
	await get_tree().create_timer(delay).timeout
	# A newer action replaced this one, so leave it alone.
	if token == action_token and use_model:
		_return_to_idle()

func _setup_animations() -> void:
	for clip in anim_player.get_animation_list():
		var animation := anim_player.get_animation(clip)
		animation.loop_mode = Animation.LOOP_LINEAR if StringName(clip) in LOOPING_CLIPS else Animation.LOOP_NONE

func _apply_materials() -> void:
	var body_material := _texture_material(BODY_TEXTURE_PATH)
	var head_material := _texture_material(HEAD_TEXTURE_PATH)
	for node in model_root.find_children("*", "MeshInstance3D", true, false):
		var mesh_node := node as MeshInstance3D
		if mesh_node.name in HIDDEN_PARTS:
			mesh_node.visible = false
		elif mesh_node.name == HEAD_MESH_NAME:
			mesh_node.material_override = head_material
		else:
			mesh_node.material_override = body_material

func _texture_material(path: String) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_texture = load(path) as Texture2D
	material.roughness = 0.85
	material.metallic = 0.0
	return material

func _attach_weapon_socket() -> bool:
	if not is_instance_valid(weapon_socket):
		return false
	var bone_name := _find_bone("handslot_r")
	if bone_name == "":
		bone_name = _find_bone("hand_r")
	if bone_name == "":
		return false
	var attachment := BoneAttachment3D.new()
	attachment.name = "RightHandAttachment"
	skeleton.add_child(attachment)
	attachment.bone_name = bone_name
	weapon_socket.reparent(attachment, false)
	weapon_socket.transform = Transform3D(Basis.from_euler(weapon_socket_rotation_degrees * (PI / 180.0)), Vector3.ZERO)
	return true

## Finds a bone whatever the importer did to "." in names (handslot.r -> handslot_r).
func _find_bone(normalized_name: String) -> String:
	for i in skeleton.get_bone_count():
		var bone := skeleton.get_bone_name(i)
		if bone.to_lower().replace(".", "_") == normalized_name:
			return bone
	return ""
