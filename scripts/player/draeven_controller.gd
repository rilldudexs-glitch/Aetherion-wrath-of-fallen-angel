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

@onready var camera_pivot: Node3D = $CameraPivot
@onready var weapon_socket: Marker3D = $VisualRoot/Skeleton3D/RightHandAttachment/WeaponSocket

var camera_yaw: float = 0.0
var camera_pitch: float = -0.18

func _ready() -> void:
	camera_yaw = rotation.y
	camera_pivot.rotation.x = camera_pitch

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		camera_yaw -= event.relative.x * camera_sensitivity
		camera_pitch = clampf(camera_pitch - event.relative.y * camera_sensitivity, camera_pitch_min, camera_pitch_max)
		camera_pivot.rotation.x = camera_pitch

func _physics_process(delta: float) -> void:
	var input_vector := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var basis := Basis(Vector3.UP, camera_yaw)
	var move_direction := (basis * Vector3(input_vector.x, 0.0, input_vector.y)).normalized()

	velocity.x = move_toward(velocity.x, move_direction.x * move_speed, acceleration * delta)
	velocity.z = move_toward(velocity.z, move_direction.z * move_speed, acceleration * delta)

	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	if move_direction.length_squared() > 0.001:
		var target_angle := atan2(move_direction.x, move_direction.z)
		rotation.y = lerp_angle(rotation.y, target_angle, turn_speed * delta)

	move_and_slide()

func get_weapon_socket() -> Marker3D:
	return weapon_socket
