extends Node
class_name CombatComponent

signal health_changed(current_health: float, max_health: float)
signal damaged(amount: float, source: Node)
signal defeated

@export var max_health: float = 100.0
@export var invulnerable: bool = false

var current_health: float

func _ready() -> void:
	current_health = max_health
	health_changed.emit(current_health, max_health)

func apply_damage(amount: float, source: Node = null) -> void:
	if invulnerable or current_health <= 0.0 or amount <= 0.0:
		return
	current_health = maxf(current_health - amount, 0.0)
	damaged.emit(amount, source)
	health_changed.emit(current_health, max_health)
	if current_health <= 0.0:
		defeated.emit()

func heal(amount: float) -> void:
	if amount <= 0.0 or current_health <= 0.0:
		return
	current_health = minf(current_health + amount, max_health)
	health_changed.emit(current_health, max_health)

func reset_health() -> void:
	current_health = max_health
	health_changed.emit(current_health, max_health)
