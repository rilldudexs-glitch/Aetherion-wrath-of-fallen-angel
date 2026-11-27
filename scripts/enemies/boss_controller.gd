extends EnemyController
class_name BossController

signal phase_changed(phase: int)

@export var phase_two_ratio: float = 0.66
@export var phase_three_ratio: float = 0.33
@export var phase_two_speed_multiplier: float = 1.15
@export var phase_three_speed_multiplier: float = 1.3
@export var phase_two_damage_multiplier: float = 1.2
@export var phase_three_damage_multiplier: float = 1.4
@export var phase_two_windup_multiplier: float = 0.9
@export var phase_three_windup_multiplier: float = 0.78
@export var phase_two_cooldown_multiplier: float = 0.9
@export var phase_three_cooldown_multiplier: float = 0.78

var current_phase: int = 1
var base_speed: float
var base_damage: float
var base_windup: float
var base_cooldown: float

func _ready() -> void:
	super._ready()
	base_speed = move_speed
	base_damage = attack_damage
	base_windup = attack_windup
	base_cooldown = attack_cooldown
	if combat:
		combat.health_changed.connect(_on_health_changed)

func _begin_attack() -> void:
	var windup_multiplier := 1.0
	var cooldown_multiplier := 1.0
	match current_phase:
		2:
			windup_multiplier = phase_two_windup_multiplier
			cooldown_multiplier = phase_two_cooldown_multiplier
		3:
			windup_multiplier = phase_three_windup_multiplier
			cooldown_multiplier = phase_three_cooldown_multiplier
	attack_cooldown = base_cooldown * cooldown_multiplier
	attack_windup = base_windup * windup_multiplier
	super._begin_attack()

func get_attack_damage() -> float:
	match current_phase:
		2:
			return base_damage * phase_two_damage_multiplier
		3:
			return base_damage * phase_three_damage_multiplier
	return base_damage

func _on_health_changed(current: float, maximum: float) -> void:
	if maximum <= 0.0:
		return
	var ratio := current / maximum
	var next_phase := 1
	if ratio <= phase_three_ratio:
		next_phase = 3
	elif ratio <= phase_two_ratio:
		next_phase = 2
	if next_phase == current_phase:
		return
	current_phase = next_phase
	match current_phase:
		2:
			move_speed = base_speed * phase_two_speed_multiplier
		3:
			move_speed = base_speed * phase_three_speed_multiplier
	phase_changed.emit(current_phase)
