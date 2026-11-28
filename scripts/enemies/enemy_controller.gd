extends CharacterBody3D
class_name EnemyController

signal state_changed(new_state: StringName)
signal attack_started
signal attack_landed
signal defeated

enum State { IDLE, CHASE, ATTACK, RECOVER, DEAD }

@export var max_health: float = 60.0
@export var move_speed: float = 2.8
@export var detection_range: float = 10.0
@export var attack_range: float = 1.8
@export var attack_damage: float = 12.0
@export var attack_cooldown: float = 1.6
@export var attack_windup: float = 0.65
@export var recovery_duration: float = 0.55
@export var target_path: NodePath

@onready var combat: CombatComponent = get_node_or_null("CombatComponent") as CombatComponent
@onready var attack_telegraph: MeshInstance3D = get_node_or_null("AttackTelegraph") as MeshInstance3D
var target: Node3D
var state: State = State.IDLE
var attack_timer: float = 0.0
var state_timer: float = 0.0
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	add_to_group("enemies")
	if not target_path.is_empty():
		target = get_node_or_null(target_path) as Node3D
	if combat:
		combat.max_health = max_health
		combat.reset_health()
		combat.defeated.connect(_on_defeated)

func set_target(new_target: Node3D) -> void:
	target = new_target

func _physics_process(delta: float) -> void:
	if state == State.DEAD:
		return

	attack_timer = maxf(attack_timer - delta, 0.0)
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	if state == State.ATTACK:
		state_timer -= delta
		_stop_horizontal(delta)
		if state_timer <= 0.0:
			_resolve_attack()
			_set_state(State.RECOVER)
			state_timer = recovery_duration
		move_and_slide()
		return

	if state == State.RECOVER:
		state_timer -= delta
		_stop_horizontal(delta)
		if state_timer <= 0.0:
			_set_state(State.IDLE)
		move_and_slide()
		return

	if not is_instance_valid(target):
		_set_state(State.IDLE)
		_stop_horizontal(delta)
		move_and_slide()
		return

	var offset := target.global_position - global_position
	var distance := offset.length()
	var direction := offset.normalized()
	direction.y = 0.0

	if distance > detection_range:
		_set_state(State.IDLE)
		_stop_horizontal(delta)
	elif distance > attack_range:
		_set_state(State.CHASE)
		velocity.x = direction.x * move_speed
		velocity.z = direction.z * move_speed
		_face_target(direction, delta)
	else:
		_stop_horizontal(delta)
		_face_target(direction, delta)
		if attack_timer <= 0.0:
			_begin_attack()
	move_and_slide()

func _begin_attack() -> void:
	_set_state(State.ATTACK)
	if attack_telegraph:
		attack_telegraph.visible = true
	attack_timer = attack_cooldown
	state_timer = attack_windup
	attack_started.emit()

func _resolve_attack() -> void:
	if attack_telegraph:
		attack_telegraph.visible = false
	if not is_instance_valid(target):
		return
	if global_position.distance_to(target.global_position) > attack_range * 1.2:
		return
	var target_combat := target.get_node_or_null("CombatComponent") as CombatComponent
	if target_combat:
		target_combat.apply_damage(get_attack_damage(), self)
		attack_landed.emit()

func get_attack_damage() -> float:
	return attack_damage

func _stop_horizontal(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, move_speed * delta * 4.0)
	velocity.z = move_toward(velocity.z, 0.0, move_speed * delta * 4.0)

func _face_target(direction: Vector3, delta: float) -> void:
	if direction.length_squared() > 0.001:
		rotation.y = lerp_angle(rotation.y, atan2(direction.x, direction.z), 8.0 * delta)

func _set_state(next_state: State) -> void:
	if state == next_state:
		return
	state = next_state
	state_changed.emit(StringName(State.keys()[state].to_lower()))

func _on_defeated() -> void:
	if state == State.DEAD:
		return
	_set_state(State.DEAD)
	if attack_telegraph:
		attack_telegraph.visible = false
	defeated.emit()
	queue_free()
