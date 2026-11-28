extends Node
class_name PlayerCombatController

@export var light_damage: float = 28.0
@export var heavy_damage: float = 52.0
@export var light_range: float = 1.65
@export var heavy_range: float = 2.0
@export var attack_cooldown: float = 0.32
@export var light_hit_delay: float = 0.13
@export var heavy_hit_delay: float = 0.22
@export var dodge_speed: float = 8.5
@export var dodge_duration: float = 0.32
@export var combo_reset_time: float = 0.9
@export var input_buffer_time: float = 0.24
@export var weapon_switch_cooldown: float = 0.42

@onready var player: DraevenController = get_parent() as DraevenController
@onready var combat: CombatComponent = player.get_node_or_null("CombatComponent") as CombatComponent
@onready var combo_vfx: ComboVFX = player.get_node_or_null("ComboVFX") as ComboVFX
@onready var visual: DraevenVisual = player.get_node_or_null("VisualRoot") as DraevenVisual

var attack_timer: float = 0.0
var combo_timer: float = 0.0
var combo_step: int = 0
var light_buffer_timer: float = 0.0
var pending_hit_timer: float = -1.0
var pending_damage: float = 0.0
var pending_reach: float = 0.0
var pending_combo_index: int = 0
var pending_heavy: bool = false
var weapon_form: int = 0
var weapon_switch_timer: float = 0.0
var sphere := SphereShape3D.new()

func _ready() -> void:
	sphere.radius = light_range

func _physics_process(delta: float) -> void:
	attack_timer = maxf(attack_timer - delta, 0.0)
	weapon_switch_timer = maxf(weapon_switch_timer - delta, 0.0)
	combo_timer = maxf(combo_timer - delta, 0.0)
	light_buffer_timer = maxf(light_buffer_timer - delta, 0.0)
	if pending_hit_timer >= 0.0:
		pending_hit_timer -= delta
		if pending_hit_timer <= 0.0:
			_resolve_pending_hit()
	if combo_timer <= 0.0:
		combo_step = 0

	if player.is_dodging():
		return
	if Input.is_action_just_pressed("switch_weapon") and weapon_switch_timer <= 0.0:
		_switch_weapon()

	if Input.is_action_just_pressed("dodge"):
		_start_dodge()
		return

	if Input.is_action_just_pressed("light_attack") and attack_timer > 0.0 and combo_step > 0:
		light_buffer_timer = input_buffer_time

	if attack_timer <= 0.0:
		if Input.is_action_just_pressed("heavy_attack"):
			_perform_attack(true)
		elif Input.is_action_just_pressed("light_attack") or light_buffer_timer > 0.0:
			light_buffer_timer = 0.0
			_perform_attack(false)

func _switch_weapon() -> void:
	weapon_form = (weapon_form + 1) % 4
	weapon_switch_timer = weapon_switch_cooldown
	if visual:
		visual.set_weapon_form(weapon_form)
	combo_step = 0
	combo_timer = 0.0
	light_buffer_timer = 0.0

func _start_dodge() -> void:
	var input_vector := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := Vector3(input_vector.x, 0.0, input_vector.y)
	if direction.length_squared() < 0.01:
		direction = -player.global_transform.basis.z
	player.start_dodge(direction.normalized(), dodge_speed, dodge_duration)
	attack_timer = maxf(attack_timer, dodge_duration)
	pending_hit_timer = -1.0
	light_buffer_timer = 0.0

func _perform_attack(heavy: bool) -> void:
	attack_timer = attack_cooldown
	pending_heavy = heavy
	var form_damage := [1.0, 0.92, 1.08, 1.0][weapon_form]
	var form_reach := [1.0, 1.12, 0.92, 1.0][weapon_form]
	pending_damage = (heavy_damage if heavy else light_damage) * form_damage
	pending_reach = (heavy_range if heavy else light_range) * form_reach
	pending_combo_index = 0 if heavy else (combo_step % 3) + 1
	pending_hit_timer = heavy_hit_delay if heavy else light_hit_delay

	if visual:
		visual.play_attack(pending_combo_index, heavy, weapon_form)

	if not heavy:
		combo_step = (combo_step % 3) + 1
		combo_timer = combo_reset_time
	else:
		combo_step = 0
		combo_timer = 0.0

func _resolve_pending_hit() -> void:
	pending_hit_timer = -1.0
	sphere.radius = pending_reach * 0.58
	var forward := -player.global_transform.basis.z
	var center := player.global_position + Vector3.UP * 1.0 + forward * (pending_reach * 0.62)
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = sphere
	query.transform = Transform3D(Basis.IDENTITY, center)
	query.exclude = [player.get_rid()]
	query.collision_mask = 1
	query.collide_with_areas = false

	var hits := player.get_world_3d().direct_space_state.intersect_shape(query, 16)
	var hit_ids: Dictionary = {}
	var hit_positions: Array[Vector3] = []
	for hit in hits:
		var collider := hit.get("collider") as Node3D
		if collider == null:
			continue
		var target_combat := _find_combat_component(collider)
		if target_combat == null or hit_ids.has(target_combat.get_instance_id()):
			continue
		hit_ids[target_combat.get_instance_id()] = true
		target_combat.apply_damage(pending_damage, player)
		hit_positions.append(collider.global_position)

	if combo_vfx:
		combo_vfx.play_attack(pending_combo_index, pending_heavy, -player.global_transform.basis.z, hit_positions, weapon_form)

func _find_combat_component(node: Node) -> CombatComponent:
	var current := node
	while current != null:
		var component := current.get_node_or_null("CombatComponent") as CombatComponent
		if component:
			return component
		current = current.get_parent()
	return null
