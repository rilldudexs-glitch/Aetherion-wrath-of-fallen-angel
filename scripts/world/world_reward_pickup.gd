extends Area3D
class_name WorldRewardPickup

## Reusable world reward. Set reward_type to "soul_shards" or "element".
@export_enum("soul_shards", "element") var reward_type: String = "soul_shards"
@export_range(1, 999, 1) var shard_amount: int = 5
@export_enum("storm", "void", "life") var element_name: String = "storm"
@export var pickup_title: String = "Soul Shards"
@export var interaction_distance: float = 2.6

var nearby_player: Node3D
var prompt: Label3D

func _ready() -> void:
	collision_layer = 0
	collision_mask = 1
	monitoring = true
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_build_visuals()

func _build_visuals() -> void:
	var orb := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = 0.28
	mesh.height = 0.56
	orb.mesh = mesh
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color(0.25, 0.78, 1.0) if reward_type == "soul_shards" else Color(0.72, 0.38, 1.0)
	material.emission_enabled = true
	material.emission = material.albedo_color
	material.emission_energy_multiplier = 1.25
	orb.material_override = material
	add_child(orb)

	var shape_node := CollisionShape3D.new()
	var shape := SphereShape3D.new()
	shape.radius = interaction_distance
	shape_node.shape = shape
	add_child(shape_node)

	prompt = Label3D.new()
	prompt.text = "%s\n[G / USE]" % pickup_title
	prompt.font_size = 32
	prompt.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	prompt.position = Vector3(0, 0.85, 0)
	prompt.modulate = Color(0.85, 0.94, 1.0)
	prompt.visible = false
	add_child(prompt)

func _process(_delta: float) -> void:
	if not is_instance_valid(nearby_player):
		return
	if nearby_player.global_position.distance_to(global_position) > interaction_distance + 0.35:
		nearby_player = null
		prompt.visible = false
		return
	if Input.is_action_just_pressed("interact"):
		_collect()

func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		nearby_player = body
		prompt.visible = true

func _on_body_exited(body: Node3D) -> void:
	if body == nearby_player:
		nearby_player = null
		prompt.visible = false

func _collect() -> void:
	if not is_instance_valid(nearby_player):
		return
	var controller := nearby_player.find_child("PlayerCombatController", true, false) as PlayerCombatController
	if controller == null:
		push_warning("WorldRewardPickup: PlayerCombatController not found on player.")
		return
	var granted := false
	if reward_type == "soul_shards":
		controller.grant_soul_shards(shard_amount)
		granted = true
	elif reward_type == "element":
		granted = controller.unlock_element(element_name)
	if granted:
		queue_free()
	else:
		if prompt:
			prompt.text = "ALREADY CLAIMED"
