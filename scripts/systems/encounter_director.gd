extends Node3D
class_name EncounterDirector

signal encounter_started
signal wave_started(wave_number: int)
signal wave_cleared(wave_number: int)
signal encounter_completed
signal arena_locked
signal arena_unlocked
signal inter_wave_break(next_wave: int)

@export var auto_start: bool = false
@export var enemy_scenes: Array[PackedScene] = []
@export var boss_scene: PackedScene
@export var boss_on_final_wave: bool = true
@export var spawn_points: Array[NodePath] = []
@export var player_path: NodePath
@export var waves: Array[int] = [3, 4, 1]
@export_range(0.0, 10.0, 0.25) var inter_wave_delay: float = 2.5
@export var arena_gate_paths: Array[NodePath] = []
@export_range(0, 100, 1) var shards_per_wave: int = 3
@export_range(0, 500, 1) var final_encounter_shards: int = 12

var current_wave: int = -1
var alive_enemies: int = 0
var active: bool = false
var player: Node3D
var transitioning: bool = false

func _ready() -> void:
	if not player_path.is_empty():
		player = get_node_or_null(player_path) as Node3D
	if auto_start:
		call_deferred("start_encounter")

func start_encounter() -> void:
	if active or waves.is_empty() or enemy_scenes.is_empty() or spawn_points.is_empty():
		return
	if not is_instance_valid(player):
		push_warning("EncounterDirector: assign a valid player_path before starting.")
		return
	active = true
	current_wave = -1
	encounter_started.emit()
	_start_next_wave()

func _start_next_wave() -> void:
	transitioning = false
	current_wave += 1
	if current_wave >= waves.size():
		active = false
		arena_unlocked.emit()
		encounter_completed.emit()
		return
	alive_enemies = 0
	arena_locked.emit()
	wave_started.emit(current_wave + 1)
	var amount: int = maxi(waves[current_wave], 0)
	for index in amount:
		var is_boss_wave := boss_on_final_wave and current_wave == waves.size() - 1 and boss_scene != null
		var scene: PackedScene = boss_scene if is_boss_wave else enemy_scenes[index % enemy_scenes.size()]
		var spawn_index := spawn_points.size() - 1 if is_boss_wave else index % spawn_points.size()
		var spawn_node := get_node_or_null(spawn_points[spawn_index]) as Node3D
		if scene == null or spawn_node == null:
			continue
		var enemy := scene.instantiate()
		get_tree().current_scene.add_child(enemy)
		if enemy is Node3D:
			enemy.global_position = spawn_node.global_position
		if enemy.has_method("set_target"):
			enemy.set_target(player)
		if enemy.has_signal("defeated"):
			enemy.defeated.connect(_on_enemy_defeated)
		alive_enemies += 1
	if alive_enemies == 0:
		_on_wave_empty()

func _on_enemy_defeated() -> void:
	alive_enemies = maxi(alive_enemies - 1, 0)
	if alive_enemies == 0:
		_on_wave_empty()

func _on_wave_empty() -> void:
	if transitioning or not active:
		return
	transitioning = true
	_grant_encounter_reward()
	wave_cleared.emit(current_wave + 1)
	if current_wave >= waves.size() - 1:
		call_deferred("_start_next_wave")
		return
	inter_wave_break.emit(current_wave + 2)
	await get_tree().create_timer(inter_wave_delay).timeout
	if is_inside_tree() and active:
		_start_next_wave()

func _grant_encounter_reward() -> void:
	if not is_instance_valid(player):
		return
	var controller := player.find_child("PlayerCombatController", true, false) as PlayerCombatController
	if controller == null:
		return
	var reward := shards_per_wave
	if current_wave == waves.size() - 1:
		reward += final_encounter_shards
	controller.grant_soul_shards(reward)
