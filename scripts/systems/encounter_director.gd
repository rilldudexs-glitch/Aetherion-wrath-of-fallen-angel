extends Node3D
class_name EncounterDirector

signal encounter_started
signal wave_started(wave_number: int)
signal wave_cleared(wave_number: int)
signal encounter_completed

@export var enemy_scenes: Array[PackedScene] = []
@export var spawn_points: Array[NodePath] = []
@export var waves: Array[int] = [3, 4, 1]

var current_wave: int = -1
var alive_enemies: int = 0
var active: bool = false

func start_encounter() -> void:
	if active or waves.is_empty() or enemy_scenes.is_empty() or spawn_points.is_empty():
		return
	active = true
	current_wave = -1
	encounter_started.emit()
	_start_next_wave()

func _start_next_wave() -> void:
	current_wave += 1
	if current_wave >= waves.size():
		active = false
		encounter_completed.emit()
		return
	alive_enemies = 0
	wave_started.emit(current_wave + 1)
	var amount: int = maxi(waves[current_wave], 0)
	for index in amount:
		var scene := enemy_scenes[index % enemy_scenes.size()]
		var spawn_node := get_node_or_null(spawn_points[index % spawn_points.size()]) as Node3D
		if scene == null or spawn_node == null:
			continue
		var enemy := scene.instantiate()
		get_tree().current_scene.add_child(enemy)
		if enemy is Node3D:
			enemy.global_position = spawn_node.global_position
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
	wave_cleared.emit(current_wave + 1)
	call_deferred("_start_next_wave")
