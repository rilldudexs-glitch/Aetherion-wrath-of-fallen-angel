extends CharacterBody3D
class_name DraevenController

## Movement foundation. Combat and animation are separate systems.
@export var move_speed: float = 5.0
@export var acceleration: float = 18.0
@export var turn_speed: float = 10.0
@export var gravity: float = 9.8
@export var camera_sensitivity: float = 0.003
@export var camera_pitch_min: float = -0.75
@export var camera_pitch_max: float = 0.35
@export var lock_on_range: float = 18.0
@export var lock_turn_speed: float = 13.0
@export var lock_camera_smooth: float = 7.0

@onready var camera_pivot: Node3D = $CameraPivot
@onready var visual: DraevenVisual = $VisualRoot

var camera_yaw: float = 0.0
var camera_pitch: float = -0.18
var dodge_time_left: float = 0.0
var dodge_direction: Vector3 = Vector3.ZERO
var dodge_speed: float = 8.5
var lock_target: Node3D = null
var lock_enabled: bool = false
@onready var combat_component: CombatComponent = get_node_or_null("CombatComponent") as CombatComponent

func _ready() -> void:
	camera_yaw = rotation.y
	camera_pivot.rotation.x = camera_pitch

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event is InputEventScreenDrag:
		camera_yaw -= event.relative.x * camera_sensitivity
		camera_pitch = clampf(camera_pitch - event.relative.y * camera_sensitivity, camera_pitch_min, camera_pitch_max)
	elif event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		camera_yaw -= event.relative.x * camera_sensitivity
		camera_pitch = clampf(camera_pitch - event.relative.y * camera_sensitivity, camera_pitch_min, camera_pitch_max)

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("lock_on"):
		_toggle_lock_on()
	_update_lock_target()
	if lock_enabled and is_instance_valid(lock_target):
		var aim_point := lock_target.global_position + Vector3.UP * 1.1
		var to_target := aim_point - camera_pivot.global_position
		if to_target.length_squared() > 0.01:
			var desired_yaw := atan2(to_target.x, to_target.z) + PI
			var desired_pitch := clampf(-atan2(to_target.y, Vector2(to_target.x, to_target.z).length()), camera_pitch_min, camera_pitch_max)
			camera_yaw = lerp_angle(camera_yaw, desired_yaw, lock_camera_smooth * delta)
			camera_pitch = lerpf(camera_pitch, desired_pitch, lock_camera_smooth * delta)
	camera_pivot.rotation.x = camera_pitch
	camera_pivot.rotation.y = wrapf(camera_yaw - rotation.y, -PI, PI)
	if dodge_time_left > 0.0:
		dodge_time_left = maxf(dodge_time_left - delta, 0.0)
		velocity.x = dodge_direction.x * dodge_speed
		velocity.z = dodge_direction.z * dodge_speed
		if not is_on_floor():
			velocity.y -= gravity * delta
		else:
			velocity.y = 0.0
		if dodge_time_left <= 0.0 and combat_component:
			combat_component.invulnerable = false
		move_and_slide()
		return

	var input_vector := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var basis := Basis(Vector3.UP, camera_yaw)
	var move_direction := (basis * Vector3(input_vector.x, 0.0, input_vector.y)).normalized()

	velocity.x = move_toward(velocity.x, move_direction.x * move_speed, acceleration * delta)
	velocity.z = move_toward(velocity.z, move_direction.z * move_speed, acceleration * delta)

	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	visual.play_move(move_direction.length_squared() > 0.001)

	if lock_enabled and is_instance_valid(lock_target):
		var to_enemy := lock_target.global_position - global_position
		if to_enemy.length_squared() > 0.01:
			var lock_angle := atan2(to_enemy.x, to_enemy.z)
			rotation.y = lerp_angle(rotation.y, lock_angle, lock_turn_speed * delta)
	elif move_direction.length_squared() > 0.001:
		var target_angle := atan2(move_direction.x, move_direction.z)
		rotation.y = lerp_angle(rotation.y, target_angle, turn_speed * delta)

	move_and_slide()

func start_dodge(direction: Vector3, speed: float, duration: float) -> void:
	dodge_direction = direction.normalized()
	dodge_speed = speed
	dodge_time_left = duration
	if combat_component:
		combat_component.invulnerable = true
	if visual:
		visual.play_dodge(direction)

func is_dodging() -> bool:
	return dodge_time_left > 0.0

func get_weapon_socket() -> Marker3D:
	return visual.get_weapon_socket()

func _toggle_lock_on() -> void:
	if lock_enabled and is_instance_valid(lock_target):
		lock_enabled = false
		lock_target = null
		return
	lock_target = _find_nearest_enemy()
	lock_enabled = is_instance_valid(lock_target)

func _update_lock_target() -> void:
	if not lock_enabled:
		return
	if not is_instance_valid(lock_target):
		lock_enabled = false
		lock_target = null
		return
	if lock_target.global_position.distance_to(global_position) > lock_on_range * 1.35:
		lock_enabled = false
		lock_target = null

func _find_nearest_enemy() -> Node3D:
	var nearest: Node3D = null
	var nearest_distance := lock_on_range
	for candidate in get_tree().get_nodes_in_group("enemies"):
		if not candidate is Node3D or candidate == self:
			continue
		var enemy := candidate as Node3D
		if enemy.is_queued_for_deletion():
			continue
		var health := _get_enemy_combat(enemy)
		if health and health.current_health <= 0.0:
			continue
		var distance := global_position.distance_to(enemy.global_position)
		if distance < nearest_distance:
			var direction := (enemy.global_position - global_position).normalized()
			if (-global_transform.basis.z).dot(direction) < -0.35:
				continue
			nearest = enemy
			nearest_distance = distance
	return nearest

func _get_enemy_combat(enemy: Node) -> CombatComponent:
	var current: Node = enemy
	while current != null:
		var component := current.get_node_or_null("CombatComponent") as CombatComponent
		if component:
			return component
		current = current.get_parent()
	return null

func get_lock_target() -> Node3D:
	return lock_target if lock_enabled and is_instance_valid(lock_target) else null
