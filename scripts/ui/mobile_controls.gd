extends CanvasLayer

const JOYSTICK_SCRIPT = preload("res://scripts/ui/virtual_joystick.gd")
const MINIMAP_SCRIPT = preload("res://scripts/ui/minimap_widget.gd")
const JOYSTICK_SIZE := Vector2(176.0, 176.0)

var _active_actions: Array[StringName] = []
var _mode_label: Label
var _context_button: Button
var _brake_button: Button
var _pedal_button: Button
var _sprint_button: Button
var _steer_left_button: Button
var _steer_right_button: Button
var _joystick: Control
var _is_car_mode := false
var _is_bicycle_mode := false
var _bike_steering_mode := "analog"
var _flick_touch_index := -1
var _time_label: Label
var _money_label: Label
var _health_bar: ProgressBar
var _health_value_label: Label
var _weapon_label: Label


func _ready() -> void:
	add_to_group("mobile_controls")
	add_to_group("mobile_hud")
	_register_actions()
	_build_hud()


func _process(_delta: float) -> void:
	_update_status_hud()
	if _context_button == null or _is_car_mode or _is_bicycle_mode:
		return
	var player := get_tree().get_first_node_in_group("player") as Node3D
	if player == null:
		return
	var prompt := "USE"
	var nearest_distance := 4.0
	for bicycle in get_tree().get_nodes_in_group("bicycles"):
		if not bicycle is Node3D:
			continue
		var distance := player.global_position.distance_to((bicycle as Node3D).global_position)
		if distance < nearest_distance:
			nearest_distance = distance
			prompt = "RIDE"
	for vehicle in get_tree().get_nodes_in_group("vehicles"):
		if vehicle.is_in_group("bicycles") or not vehicle is Node3D:
			continue
		var distance := player.global_position.distance_to((vehicle as Node3D).global_position)
		if distance < nearest_distance:
			nearest_distance = distance
			prompt = "ENTER"
	for portal in get_tree().get_nodes_in_group("building_portals"):
		if not portal is Node3D:
			continue
		var portal_node := portal as Node3D
		var portal_position := portal_node.global_position
		if bool(portal.get("_is_inside")):
			portal_position += portal.get("room_offset") + Vector3(0.0, 0.9, 3.1)
			if player.global_position.distance_to(portal_position) < nearest_distance:
				nearest_distance = player.global_position.distance_to(portal_position)
				prompt = "EXIT HOUSE"
		elif player.global_position.distance_to(portal_position) < nearest_distance:
			nearest_distance = player.global_position.distance_to(portal_position)
			prompt = "ENTER HOUSE"
	if _context_button.text != prompt:
		_context_button.text = prompt


func _register_actions() -> void:
	var actions := ["vehicle_brake", "bike_pedal", "bike_brake",
		"bike_steer_left", "bike_steer_right", "sprint"]
	for action in actions:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
	_add_key_binding(&"bike_pedal", KEY_W)
	_add_key_binding(&"bike_brake", KEY_S)
	_add_key_binding(&"bike_steer_left", KEY_A)
	_add_key_binding(&"bike_steer_right", KEY_D)
	_add_key_binding(&"sprint", KEY_SHIFT)


func _add_key_binding(action: StringName, keycode: int) -> void:
	for event in InputMap.action_get_events(action):
		if event is InputEventKey and event.physical_keycode == keycode:
			return
	var key_event := InputEventKey.new()
	key_event.physical_keycode = keycode
	InputMap.action_add_event(action, key_event)


func _build_hud() -> void:
	var root := Control.new()
	root.name = "HUD"
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	var minimap := MINIMAP_SCRIPT.new() as Control
	minimap.name = "Minimap"
	minimap.position = Vector2(18.0, 18.0)
	minimap.custom_minimum_size = Vector2(168.0, 126.0)
	root.add_child(minimap)
	_build_status_hud(root)

	_mode_label = Label.new()
	_mode_label.name = "PlayerModeLabel"
	_mode_label.text = "ON FOOT"
	_mode_label.position = Vector2(22.0, 150.0)
	_mode_label.add_theme_font_size_override("font_size", 15)
	_mode_label.add_theme_color_override("font_color", Color(1.0, 0.96, 0.82, 0.92))
	root.add_child(_mode_label)

	_joystick = JOYSTICK_SCRIPT.new() as Control
	_joystick.name = "MovementJoystick"
	_joystick.anchor_left = 0.0
	_joystick.anchor_top = 1.0
	_joystick.anchor_right = 0.0
	_joystick.anchor_bottom = 1.0
	_joystick.offset_left = 22.0
	_joystick.offset_top = -JOYSTICK_SIZE.y - 22.0
	_joystick.offset_right = 22.0 + JOYSTICK_SIZE.x
	_joystick.offset_bottom = -22.0
	_joystick.vector_changed.connect(_on_joystick_vector_changed)
	root.add_child(_joystick)

	_context_button = _make_action_button("USE", Vector2(104.0, 104.0))
	_context_button.name = "ContextAction"
	_set_bottom_right(_context_button, -132.0, -132.0, -24.0, -24.0)
	_context_button.button_down.connect(_press_action.bind(&"interact"))
	_context_button.button_up.connect(_release_action.bind(&"interact"))
	_context_button.tree_exiting.connect(_release_action.bind(&"interact"))
	root.add_child(_context_button)

	_brake_button = _make_action_button("BRAKE", Vector2(88.0, 88.0))
	_brake_button.name = "VehicleBrake"
	_set_bottom_right(_brake_button, -236.0, -120.0, -144.0, -28.0)
	_brake_button.visible = false
	_brake_button.button_down.connect(_on_brake_down)
	_brake_button.button_up.connect(_on_brake_up)
	_brake_button.tree_exiting.connect(_on_brake_up)
	root.add_child(_brake_button)

	_pedal_button = _make_action_button("PEDAL", Vector2(88.0, 88.0))
	_pedal_button.name = "BikePedal"
	_set_bottom_right(_pedal_button, -236.0, -218.0, -144.0, -126.0)
	_pedal_button.visible = false
	_pedal_button.button_down.connect(_press_action.bind(&"bike_pedal"))
	_pedal_button.button_up.connect(_release_action.bind(&"bike_pedal"))
	_pedal_button.tree_exiting.connect(_release_action.bind(&"bike_pedal"))
	root.add_child(_pedal_button)

	_sprint_button = _make_action_button("RUN", Vector2(82.0, 82.0))
	_sprint_button.name = "Sprint"
	_set_bottom_right(_sprint_button, -236.0, -218.0, -150.0, -132.0)
	_sprint_button.button_down.connect(_press_action.bind(&"sprint"))
	_sprint_button.button_up.connect(_release_action.bind(&"sprint"))
	_sprint_button.tree_exiting.connect(_release_action.bind(&"sprint"))
	root.add_child(_sprint_button)

	_steer_left_button = _make_action_button("◀", Vector2(76.0, 76.0))
	_steer_left_button.name = "BikeSteerLeft"
	_set_bottom_left(_steer_left_button, 24.0, -104.0, 100.0, -28.0)
	_steer_left_button.visible = false
	_steer_left_button.button_down.connect(_press_action.bind(&"bike_steer_left"))
	_steer_left_button.button_up.connect(_release_action.bind(&"bike_steer_left"))
	_steer_left_button.tree_exiting.connect(_release_action.bind(&"bike_steer_left"))
	root.add_child(_steer_left_button)

	_steer_right_button = _make_action_button("▶", Vector2(76.0, 76.0))
	_steer_right_button.name = "BikeSteerRight"
	_set_bottom_left(_steer_right_button, 108.0, -104.0, 184.0, -28.0)
	_steer_right_button.visible = false
	_steer_right_button.button_down.connect(_press_action.bind(&"bike_steer_right"))
	_steer_right_button.button_up.connect(_release_action.bind(&"bike_steer_right"))
	_steer_right_button.tree_exiting.connect(_release_action.bind(&"bike_steer_right"))
	root.add_child(_steer_right_button)

	_refresh_controls()


func _build_status_hud(root: Control) -> void:
	var panel := PanelContainer.new()
	panel.name = "StatusPanel"
	panel.anchor_left = 1.0
	panel.anchor_right = 1.0
	panel.offset_left = -246.0
	panel.offset_top = 16.0
	panel.offset_right = -16.0
	panel.offset_bottom = 142.0
	panel.custom_minimum_size = Vector2(230.0, 126.0)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.018, 0.025, 0.032, 0.82)
	panel_style.border_color = Color(0.78, 0.66, 0.36, 0.9)
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(7)
	panel_style.content_margin_left = 10.0
	panel_style.content_margin_right = 10.0
	panel_style.content_margin_top = 7.0
	panel_style.content_margin_bottom = 7.0
	panel.add_theme_stylebox_override("panel", panel_style)
	root.add_child(panel)

	var stack := VBoxContainer.new()
	stack.name = "StatusStack"
	stack.add_theme_constant_override("separation", 4)
	panel.add_child(stack)

	var top_row := HBoxContainer.new()
	top_row.name = "TimeAndMoney"
	stack.add_child(top_row)
	_time_label = _make_status_label("05:00", 19, Color(0.98, 0.94, 0.81, 1.0))
	_time_label.name = "TimeLabel"
	top_row.add_child(_time_label)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_row.add_child(spacer)
	_money_label = _make_status_label("$250", 19, Color(0.70, 0.91, 0.59, 1.0))
	_money_label.name = "MoneyLabel"
	top_row.add_child(_money_label)

	var health_row := HBoxContainer.new()
	health_row.name = "HealthRow"
	stack.add_child(health_row)
	var health_caption := _make_status_label("HP", 13, Color(0.96, 0.92, 0.84, 1.0))
	health_row.add_child(health_caption)
	_health_bar = ProgressBar.new()
	_health_bar.name = "HealthBar"
	_health_bar.min_value = 0.0
	_health_bar.max_value = 100.0
	_health_bar.value = 100.0
	_health_bar.show_percentage = false
	_health_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_health_bar.custom_minimum_size = Vector2(110.0, 16.0)
	health_row.add_child(_health_bar)
	_health_value_label = _make_status_label("100", 13, Color(0.97, 0.91, 0.80, 1.0))
	_health_value_label.name = "HealthValue"
	health_row.add_child(_health_value_label)

	_weapon_label = _make_status_label("✊  FIST", 14, Color(0.91, 0.89, 0.80, 1.0))
	_weapon_label.name = "WeaponLabel"
	stack.add_child(_weapon_label)


func _make_status_label(caption: String, font_size: int, tint: Color) -> Label:
	var label := Label.new()
	label.text = caption
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", tint)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label


func _update_status_hud() -> void:
	if _time_label == null:
		return
	var clock := get_tree().get_first_node_in_group("world_clock")
	if clock != null and clock.has_method("get_clock_text"):
		_time_label.text = str(clock.call("get_clock_text"))
	var player := get_tree().get_first_node_in_group("player") as Node3D
	if player == null:
		return
	var wallet := player.get_node_or_null("PlayerWallet")
	if wallet != null and wallet.has_method("get_balance"):
		_money_label.text = "$%d" % int(wallet.call("get_balance"))
	var vitals := player.get_node_or_null("PlayerVitals")
	if vitals != null and vitals.has_method("get_health") and vitals.has_method("get_max_health"):
		var maximum := maxf(1.0, float(vitals.call("get_max_health")))
		var health := clampf(float(vitals.call("get_health")), 0.0, maximum)
		_health_bar.max_value = maximum
		_health_bar.value = health
		_health_value_label.text = "%d" % roundi(health)


func _set_bottom_right(button: Control, left: float, top: float,
		right: float, bottom: float) -> void:
	button.anchor_left = 1.0
	button.anchor_top = 1.0
	button.anchor_right = 1.0
	button.anchor_bottom = 1.0
	button.offset_left = left
	button.offset_top = top
	button.offset_right = right
	button.offset_bottom = bottom


func _set_bottom_left(button: Control, left: float, top: float,
		right: float, bottom: float) -> void:
	button.anchor_left = 0.0
	button.anchor_top = 1.0
	button.anchor_right = 0.0
	button.anchor_bottom = 1.0
	button.offset_left = left
	button.offset_top = top
	button.offset_right = right
	button.offset_bottom = bottom


func set_vehicle_mode(active: bool) -> void:
	_is_car_mode = active
	_is_bicycle_mode = false
	_release_bicycle_actions()
	_refresh_controls()


func set_bicycle_mode(active: bool) -> void:
	_is_bicycle_mode = active
	_is_car_mode = active
	_flick_touch_index = -1
	if not active:
		_release_bicycle_actions()
	_refresh_controls()


func set_bike_steering_mode(mode: String) -> void:
	if not ["analog", "buttons", "flick"].has(mode):
		mode = "analog"
	_bike_steering_mode = mode
	_refresh_controls()


func _refresh_controls() -> void:
	if _mode_label == null:
		return
	if _is_bicycle_mode:
		_mode_label.text = "CYCLING"
		_context_button.text = "EXIT BIKE"
		_brake_button.text = "BRAKE / REV"
		_joystick.visible = _bike_steering_mode == "analog"
		_steer_left_button.visible = _bike_steering_mode == "buttons"
		_steer_right_button.visible = _bike_steering_mode == "buttons"
		_pedal_button.visible = true
		_brake_button.visible = true
		_sprint_button.visible = false
	elif _is_car_mode:
		_mode_label.text = "DRIVING"
		_context_button.text = "EXIT"
		_brake_button.text = "BRAKE"
		_joystick.visible = true
		_steer_left_button.visible = false
		_steer_right_button.visible = false
		_pedal_button.visible = false
		_brake_button.visible = true
		_sprint_button.visible = false
	else:
		_mode_label.text = "ON FOOT"
		_context_button.text = "USE"
		_brake_button.text = "BRAKE"
		_joystick.visible = true
		_steer_left_button.visible = false
		_steer_right_button.visible = false
		_pedal_button.visible = false
		_brake_button.visible = false
		_sprint_button.visible = true
	if _joystick != null:
		_joystick.call("_reset_stick")


func _on_joystick_vector_changed(value: Vector2) -> void:
	if _is_bicycle_mode:
		_set_action(&"bike_steer_left", value.x < -0.12)
		_set_action(&"bike_steer_right", value.x > 0.12)
		return
	_set_action(&"ui_left", value.x < -0.12)
	_set_action(&"ui_right", value.x > 0.12)
	_set_action(&"ui_up", value.y < -0.12)
	_set_action(&"ui_down", value.y > 0.12)


func _on_brake_down() -> void:
	_press_action(&"bike_brake" if _is_bicycle_mode else &"vehicle_brake")


func _on_brake_up() -> void:
	_release_action(&"bike_brake" if _is_bicycle_mode else &"vehicle_brake")


func _input(event: InputEvent) -> void:
	if not _is_bicycle_mode or _bike_steering_mode != "flick":
		return
	var screen_width := get_viewport().get_visible_rect().size.x
	if event is InputEventScreenTouch:
		if event.pressed:
			if _flick_touch_index == -1 and event.position.x < screen_width * 0.60:
				_flick_touch_index = event.index
		elif event.index == _flick_touch_index:
			_flick_touch_index = -1
			_set_action(&"bike_steer_left", false)
			_set_action(&"bike_steer_right", false)
	elif event is InputEventScreenDrag and event.index == _flick_touch_index:
		if absf(event.relative.x) > 3.0:
			_set_action(&"bike_steer_left", event.relative.x < 0.0)
			_set_action(&"bike_steer_right", event.relative.x > 0.0)


func _release_bicycle_actions() -> void:
	for action in [&"bike_pedal", &"bike_brake", &"bike_steer_left", &"bike_steer_right"]:
		_set_action(action, false)


func _set_action(action: StringName, pressed: bool) -> void:
	if pressed:
		if not _active_actions.has(action):
			_active_actions.append(action)
			Input.action_press(action)
	elif _active_actions.has(action):
		_active_actions.erase(action)
		Input.action_release(action)


func _press_action(action: StringName) -> void:
	_set_action(action, true)


func _release_action(action: StringName) -> void:
	_set_action(action, false)


func _make_action_button(caption: String, button_size: Vector2) -> Button:
	var button := Button.new()
	button.text = caption
	button.custom_minimum_size = button_size
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", 17)
	button.add_theme_color_override("font_color", Color(0.10, 0.12, 0.11, 1.0))
	button.add_theme_color_override("font_hover_color", Color(0.05, 0.07, 0.06, 1.0))
	button.add_theme_stylebox_override("normal", _button_style(Color(0.94, 0.91, 0.80, 0.94)))
	button.add_theme_stylebox_override("hover", _button_style(Color(1.0, 0.97, 0.87, 1.0)))
	button.add_theme_stylebox_override("pressed", _button_style(Color(0.70, 0.76, 0.63, 1.0)))
	button.add_theme_stylebox_override("focus", _button_style(Color(0.94, 0.91, 0.80, 0.94)))
	return button


func _button_style(fill_color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill_color
	style.border_color = Color(0.06, 0.08, 0.07, 0.96)
	style.set_border_width_all(4)
	style.set_corner_radius_all(48)
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.35)
	style.shadow_size = 5
	return style


func _exit_tree() -> void:
	for action in _active_actions:
		Input.action_release(action)
	_active_actions.clear()


func set_controls_preferences(scale_value: float, opacity_value: float) -> void:
	var hud := get_node_or_null("HUD") as Control
	if hud == null:
		return
	hud.modulate.a = clampf(opacity_value, 0.35, 1.0)
	for node_name in ["MovementJoystick", "ContextAction", "VehicleBrake",
			"BikePedal", "Sprint", "BikeSteerLeft", "BikeSteerRight"]:
		var control := hud.get_node_or_null(node_name) as Control
		if control == null:
			continue
		control.pivot_offset = control.size * 0.5
		var safe_scale := clampf(scale_value, 0.75, 1.35)
		control.scale = Vector2(safe_scale, safe_scale)
