extends Area3D
class_name AetherionCheckpoint

## Interact with an altar to save the latest checkpoint.
const SAVE_PATH: String = "user://aetherion_checkpoint.cfg"

var nearby_player: DraevenController
var prompt: Label3D
var altar_light: OmniLight3D
var activated: bool = false

func _ready() -> void:
	collision_layer = 0
	collision_mask = 1
	monitoring = true
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_build_altar()
	_restore_checkpoint()

func _build_altar() -> void:
	var pillar := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.28
	mesh.bottom_radius = 0.42
	mesh.height = 1.15
	pillar.mesh = mesh
	pillar.position.y = 0.55
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.10, 0.16, 0.25)
	material.metallic = 0.72
	material.roughness = 0.3
	pillar.material_override = material
	add_child(pillar)

	var crystal := MeshInstance3D.new()
	var crystal_mesh := SphereMesh.new()
	crystal_mesh.radius = 0.24
	crystal_mesh.height = 0.52
	crystal.mesh = crystal_mesh
	crystal.position.y = 1.28
	var crystal_material := StandardMaterial3D.new()
	crystal_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	crystal_material.albedo_color = Color(0.25, 0.72, 1.0)
	crystal_material.emission_enabled = true
	crystal_material.emission = Color(0.18, 0.62, 1.0)
	crystal_material.emission_energy_multiplier = 1.8
	crystal.material_override = crystal_material
	add_child(crystal)

	altar_light = OmniLight3D.new()
	altar_light.position.y = 1.25
	altar_light.light_color = Color(0.22, 0.58, 1.0)
	altar_light.light_energy = 0.8
	altar_light.omni_range = 4.0
	add_child(altar_light)

	var shape_node := CollisionShape3D.new()
	var shape := SphereShape3D.new()
	shape.radius = 3.0
	shape_node.shape = shape
	add_child(shape_node)

	prompt = Label3D.new()
	prompt.text = "CHECKPOINT\n[G / USE]"
	prompt.font_size = 30
	prompt.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	prompt.position.y = 1.9
	prompt.visible = false
	add_child(prompt)

func _process(_delta: float) -> void:
	if not is_instance_valid(nearby_player):
		return
	if Input.is_action_just_pressed("interact"):
		_activate_checkpoint()

func _on_body_entered(body: Node3D) -> void:
	if body is DraevenController:
		nearby_player = body as DraevenController
		prompt.visible = true

func _on_body_exited(body: Node3D) -> void:
	if body == nearby_player:
		nearby_player = null
		prompt.visible = false

func _activate_checkpoint() -> void:
	if not is_instance_valid(nearby_player):
		return
	var config := ConfigFile.new()
	config.set_value("checkpoint", "scene", get_tree().current_scene.scene_file_path)
	config.set_value("checkpoint", "position", nearby_player.global_position)
	config.set_value("checkpoint", "activated", true)
	var combat := nearby_player.get_node_or_null("CombatComponent") as CombatComponent
	if combat:
		combat.reset_health()
		config.set_value("checkpoint", "health", combat.current_health)
	var result := config.save(SAVE_PATH)
	if result == OK:
		activated = true
		prompt.text = "PROGRESS SAVED"
		altar_light.light_energy = 1.6
	else:
		prompt.text = "SAVE FAILED"

func _restore_checkpoint() -> void:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return
	if not bool(config.get_value("checkpoint", "activated", false)):
		return
	if String(config.get_value("checkpoint", "scene", "")) != get_tree().current_scene.scene_file_path:
		return
	var saved_position: Variant = config.get_value("checkpoint", "position", Vector3.ZERO)
	if saved_position is Vector3:
		var player := get_tree().current_scene.get_node_or_null("Draeven") as DraevenController
		if player:
			player.global_position = saved_position
			var combat := player.get_node_or_null("CombatComponent") as CombatComponent
			if combat:
				combat.reset_health()
	activated = true
