extends Node
class_name PlayerCombatController

@export var light_damage: float = 28.0
@export var heavy_damage: float = 52.0
@export var light_range: float = 1.65
@export var heavy_range: float = 2.0
@export var attack_cooldown: float = 0.32
@export var dodge_speed: float = 8.5
@export var dodge_duration: float = 0.32
@export var combo_reset_time: float = 0.9

@onready var player: CharacterBody3D = get_parent() as CharacterBody3D
@onready var combat: CombatComponent = player.get_node_or_null("CombatComponent") as CombatComponent

var attack_timer: float = 0.0
var combo_timer: float = 0.0
var combo_step: int = 0
var dodge_direction := Vector3.ZERO
var sphere := SphereShape3D.new()

func _ready() -> void:
	sphere.radius = light_range

func _physics_process(delta: float) -> void:
	attack_timer = maxf(attack_timer - delta, 0.0)
	combo_timer = maxf(combo_timer - delta, 0.0)
	if combo_timer <= 0.0:
		combo_step = 0

	if player.is_dodging():
		return

	if Input.is_action_just_pressed("dodge"):
		_start_dodge()
		return

	if attack_timer <= 0.0:
		if Input.is_action_just_pressed("heavy_attack"):
			_perform_attack(true)
		elif Input.is_action_just_pressed("light_attack"):
			_perform_attack(false)

func _start_dodge() -> void:
	var input_vector := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := Vector3(input_vector.x, 0.0, input_vector.y)
	if direction.length_squared() < 0.01:
		direction = -player.global_transform.basis.z
	dodge_direction = direction.normalized()
	player.start_dodge(dodge_direction, dodge_speed, dodge_duration)
	attack_timer = maxf(attack_timer, dodge_duration)

func _perform_attack(heavy: bool) -> void:
	attack_timer = attack_cooldown
	var damage := heavy_damage if heavy else light_damage
	var reach := heavy_range if heavy else light_range
	sphere.radius = reach * 0.58

	var forward := -player.global_transform.basis.z
	var center := player.global_position + Vector3.UP * 1.0 + forward * (reach * 0.62)
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = sphere
	query.transform = Transform3D(Basis.IDENTITY, center)
	query.exclude = [player.get_rid()]
	query.collision_mask = 1
	query.collide_with_areas = false

	var hits := player.get_world_3d().direct_space_state.intersect_shape(query, 16)
	var hit_ids: Dictionary = {}
	for hit in hits:
		var collider := hit.get("collider") as Node
		var target_combat := _find_combat_component(collider)
		if target_combat == null or hit_ids.has(target_combat.get_instance_id()):
			continue
		hit_ids[target_combat.get_instance_id()] = true
		target_combat.apply_damage(damage, player)

	if not heavy:
		combo_step = (combo_step % 3) + 1
		combo_timer = combo_reset_time
	else:
		combo_step = 0
		combo_timer = 0.0

func _find_combat_component(node: Node) -> CombatComponent:
	var current := node
	while current != null:
		var component := current.get_node_or_null("CombatComponent") as CombatComponent
		if component:
			return component
		current = current.get_parent()
	return null
