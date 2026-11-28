extends CanvasLayer
class_name DraevenPauseMenu

## God-of-War-style pause overlay. Runs while the scene tree is paused.
var player_combat: PlayerCombatController
var panel: PanelContainer
var content: VBoxContainer
var status_label: Label
var selected_tab: String = "equipment"

const FORM_NAMES: Array[String] = ["Origin Blade", "Chain Blades", "Twin Reapers", "Soul Swords"]
const ELEMENT_NAMES: Array[String] = ["flame", "frost", "storm", "void", "life"]

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	player_combat = get_parent().get_node_or_null("PlayerCombatController") as PlayerCombatController
	_build_menu()
	visible = false

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause_menu"):
		_toggle_pause()

func _toggle_pause() -> void:
	if visible:
		_close_menu()
	else:
		_open_menu()

func _open_menu() -> void:
	visible = true
	get_tree().paused = true
	_refresh_content()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _close_menu() -> void:
	visible = false
	get_tree().paused = false

func _build_menu() -> void:
	var shade := ColorRect.new()
	shade.color = Color(0.015, 0.02, 0.035, 0.88)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(shade)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.add_child(center)

	panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(560, 500)
	center.add_child(panel)

	var outer := VBoxContainer.new()
	outer.add_theme_constant_override("separation", 14)
	panel.add_child(outer)

	var heading := Label.new()
	heading.text = "AETHERION  /  PAUSED"
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_font_size_override("font_size", 26)
	outer.add_child(heading)

	var tabs := HBoxContainer.new()
	tabs.add_theme_constant_override("separation", 8)
	outer.add_child(tabs)
	_add_button(tabs, "EQUIPMENT", _show_equipment)
	_add_button(tabs, "ELEMENTS", _show_elements)
	_add_button(tabs, "SETTINGS", _show_settings)

	var separator := HSeparator.new()
	outer.add_child(separator)
	content = VBoxContainer.new()
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 10)
	outer.add_child(content)

	status_label = Label.new()
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	outer.add_child(status_label)

	var footer := HBoxContainer.new()
	footer.add_theme_constant_override("separation", 10)
	outer.add_child(footer)
	_add_button(footer, "RESUME", _close_menu)
	_add_button(footer, "QUIT TO TITLE", _quit_to_title)

func _add_button(parent: Container, caption: String, callback: Callable) -> void:
	var button := Button.new()
	button.text = caption
	button.custom_minimum_size = Vector2(0, 42)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.pressed.connect(callback)
	parent.add_child(button)

func _clear_content() -> void:
	for child in content.get_children():
		child.queue_free()

func _show_equipment() -> void:
	selected_tab = "equipment"
	_refresh_content()

func _show_elements() -> void:
	selected_tab = "elements"
	_refresh_content()

func _show_settings() -> void:
	selected_tab = "settings"
	_refresh_content()

func _refresh_content() -> void:
	if player_combat == null or content == null:
		return
	_clear_content()
	status_label.text = "SOUL SHARDS: %d" % player_combat.soul_shards
	match selected_tab:
		"equipment":
			_add_info("SOUL ARMS  |  UPGRADE")
			for i in range(FORM_NAMES.size()):
				var level := player_combat.weapon_levels[i]
				var cost := 0 if level >= PlayerCombatController.WEAPON_MAX_LEVEL else 3 + level * 2
				var row := HBoxContainer.new()
				content.add_child(row)
				var info := Label.new()
				info.text = "%s   Lv.%d" % [FORM_NAMES[i], level]
				info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				row.add_child(info)
				var upgrade := Button.new()
				upgrade.text = "MAX" if cost == 0 else "UPGRADE  (%d)" % cost
				upgrade.disabled = cost == 0 or player_combat.soul_shards < cost
				upgrade.pressed.connect(_upgrade_form.bind(i))
				row.add_child(upgrade)
		"elements":
			_add_info("DISCOVERED ELEMENTS")
			for element in ELEMENT_NAMES:
				var discovered := player_combat.unlocked_elements.has(element)
				var equipped := player_combat.equipped_elements.has(element)
				var row := HBoxContainer.new()
				content.add_child(row)
				var info := Label.new()
				info.text = "%s   %s" % [element.to_upper(), "EQUIPPED" if equipped else ("UNLOCKED" if discovered else "UNKNOWN")]
				info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				row.add_child(info)
				if discovered and not equipped:
					var equip := Button.new()
					equip.text = "EQUIP SLOT 1"
					equip.pressed.connect(_equip_element.bind(element))
					row.add_child(equip)
		"settings":
			_add_info("SETTINGS")
			_add_info("Audio, graphics and controller options will be added here.")
			_add_info("The pause menu is active; settings controls are not wired yet.")

func _add_info(value: String) -> void:
	var label := Label.new()
	label.text = value
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(label)

func _upgrade_form(form_index: int) -> void:
	if player_combat == null:
		return
	player_combat.weapon_form = form_index
	if player_combat.visual:
		player_combat.visual.set_weapon_form(form_index)
	if player_combat.upgrade_current_weapon():
		_refresh_content()

func _equip_element(element: String) -> void:
	if player_combat == null:
		return
	player_combat.equip_element(1, element)
	_refresh_content()

func _quit_to_title() -> void:
	get_tree().paused = false
	visible = false
	get_tree().reload_current_scene()
