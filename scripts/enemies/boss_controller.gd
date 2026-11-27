extends EnemyController
class_name BossController

signal phase_changed(phase: int)

@export var phase_two_ratio: float = 0.66
@export var phase_three_ratio: float = 0.33
@export var phase_two_speed_multiplier: float = 1.15
@export var phase_three_speed_multiplier: float = 1.3

var current_phase: int = 1
var base_speed: float

func _ready() -> void:
	super._ready()
	base_speed = move_speed
	if combat:
		combat.health_changed.connect(_on_health_changed)

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
