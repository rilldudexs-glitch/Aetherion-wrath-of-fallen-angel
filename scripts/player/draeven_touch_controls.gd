extends Control
class_name DraevenTouchControls

## Lightweight mobile HUD: left virtual stick, three combat buttons.
## Input is converted into the same actions used by keyboard/gamepad.
var move_finger: int = -1
var move_origin: Vector2 = Vector2.ZERO
var move_vector: Vector2 = Vector2.ZERO
var held_fingers: Dictionary = {}
var stick_radius: float = 74.0
var button_radius: float = 39.0

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = OS.has_feature("mobile") or DisplayServer.is_touchscreen_available()
	queue_redraw()

func _draw() -> void:
	if not visible:
		return
	var size := get_viewport_rect().size
	var stick_center := Vector2(112.0, size.y - 112.0)
	draw_circle(stick_center, stick_radius, Color(0.04, 0.06, 0.10, 0.28))
	draw_arc(stick_center, stick_radius, 0.0, TAU, 48, Color(0.72, 0.82, 1.0, 0.45), 3.0)
	var knob := stick_center + move_vector * stick_radius * 0.62
	draw_circle(knob, 31.0, Color(0.48, 0.62, 0.82, 0.48))
	var attack_center := Vector2(size.x - 100.0, size.y - 112.0)
	_draw_button(attack_center, "ATK", Color(0.18, 0.42, 0.72, 0.72))
	_draw_button(attack_center + Vector2(-4.0, -102.0), "LOCK", Color(0.30, 0.34, 0.52, 0.72))
	_draw_button(attack_center + Vector2(-4.0, -202.0), "FORM", Color(0.34, 0.25, 0.52, 0.72))
	_draw_button(attack_center + Vector2(-92.0, -66.0), "HEAVY", Color(0.48, 0.30, 0.16, 0.72))
	_draw_button(attack_center + Vector2(-92.0, 38.0), "DODGE", Color(0.20, 0.48, 0.36, 0.72))

func _draw_button(center: Vector2, label: String, tint: Color) -> void:
	draw_circle(center, button_radius, tint)
	draw_arc(center, button_radius, 0.0, TAU, 36, Color(0.85, 0.91, 1.0, 0.68), 2.0)
	draw_string(ThemeDB.fallback_font, center + Vector2(-ThemeDB.fallback_font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, 12).x * 0.5, 4.0), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.WHITE)

func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventScreenTouch:
		if event.pressed:
			_handle_press(event.index, event.position)
		else:
			_handle_release(event.index)
	elif event is InputEventScreenDrag:
		if event.index == move_finger:
			_update_stick(event.position)
			get_viewport().set_input_as_handled()

func _handle_press(index: int, pos: Vector2) -> void:
	var size := get_viewport_rect().size
	var stick_center := Vector2(112.0, size.y - 112.0)
	var attack_center := Vector2(size.x - 100.0, size.y - 112.0)
	if pos.x < size.x * 0.43 and pos.y > size.y * 0.48 and move_finger == -1:
		move_finger = index
		move_origin = stick_center
		_update_stick(pos)
		get_viewport().set_input_as_handled()
		return
	var action := ""
	if pos.distance_to(attack_center + Vector2(-4.0, -202.0)) <= button_radius + 12.0:
		action = "switch_weapon"
	elif pos.distance_to(attack_center + Vector2(-4.0, -102.0)) <= button_radius + 12.0:
		action = "lock_on"
	elif pos.distance_to(attack_center) <= button_radius + 12.0:
		action = "light_attack"
	elif pos.distance_to(attack_center + Vector2(-92.0, -66.0)) <= button_radius + 12.0:
		action = "heavy_attack"
	elif pos.distance_to(attack_center + Vector2(-92.0, 38.0)) <= button_radius + 12.0:
		action = "dodge"
	if action != "":
		held_fingers[index] = action
		Input.action_press(action)
		queue_redraw()
		get_viewport().set_input_as_handled()

func _handle_release(index: int) -> void:
	if index == move_finger:
		move_finger = -1
		move_vector = Vector2.ZERO
		_update_move_actions()
		queue_redraw()
		get_viewport().set_input_as_handled()
	if held_fingers.has(index):
		Input.action_release(String(held_fingers[index]))
		held_fingers.erase(index)
		get_viewport().set_input_as_handled()

func _update_stick(pos: Vector2) -> void:
	var size := get_viewport_rect().size
	var center := Vector2(112.0, size.y - 112.0)
	move_vector = (pos - center).limit_length(stick_radius) / stick_radius
	_update_move_actions()
	queue_redraw()
	get_viewport().set_input_as_handled()

func _update_move_actions() -> void:
	_set_axis_action("move_left", move_vector.x < -0.18, absf(move_vector.x))
	_set_axis_action("move_right", move_vector.x > 0.18, absf(move_vector.x))
	_set_axis_action("move_forward", move_vector.y < -0.18, absf(move_vector.y))
	_set_axis_action("move_back", move_vector.y > 0.18, absf(move_vector.y))

func _set_axis_action(action: String, active: bool, strength: float) -> void:
	if active:
		Input.action_press(action, clampf(strength, 0.0, 1.0))
	else:
		Input.action_release(action)
