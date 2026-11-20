extends CanvasLayer

const JOYSTICK_SCRIPT = preload("res://scripts/ui/virtual_joystick.gd")
const GAME_HUD_SCRIPT = preload("res://scripts/ui/game_hud.gd")
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
var _game_hud: Control
var _is_car_mode := false
var _is_bicycle_mode := false
var _bike_steering_mode := "analog"
var _flick_touch_index := -1


func _ready() -> void:
	add_to_group("mobile_controls")
	add_to_group("mobile_hud")
	_register_actions()
	_build_hud()


func _process(_delta: float) -> void:
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
	if _context_button.tooltip_text != prompt:
		_context_button.tooltip_text = prompt
		var icon_path := "res://assets/ui/hud/interact.svg"
		match prompt:
			"RIDE":
				icon_path = "res://assets/ui/hud/bicycle.svg"
			"ENTER":
				icon_path = "res://assets/ui/hud/car.svg"
			"EXIT HOUSE", "ENTER HOUSE":
				icon_path = "res://assets/ui/hud/interact.svg"
		_set_button_icon(_context_button, icon_path)


func bind_player(player: Node3D) -> void:
	if _game_hud != null and _game_hud.has_method("bind_player"):
		_game_hud.call("bind_player", player)


func set_gameplay_visible(value: bool) -> void:
	if _game_hud != null and _game_hud.has_method("set_gameplay_visible"):
		_game_hud.call("set_gameplay_visible", value)


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

	_game_hud = GAME_HUD_SCRIPT.new() as Control
	_game_hud.name = "GameplayHUD"
	add_child(_game_hud)

	_mode_label = Label.new()
	_mode_label.text = "ON FOOT"
	_mode_label.position = Vector2(22.0, 178.0)
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
	_set_button_icon(_context_button, "res://assets/ui/hud/bicycle.svg")
	_set_bottom_right(_context_button, -132.0, -132.0, -24.0, -24.0)
	_context_button.button_down.connect(_press_action.bind(&"interact"))
	_context_button.button_up.connect(_release_action.bind(&"interact"))
	_context_button.tree_exiting.connect(_release_action.bind(&"interact"))
	root.add_child(_context_button)

	_brake_button = _make_action_button("BRAKE", Vector2(88.0, 88.0))
	_brake_button.name = "VehicleBrake"
	_set_button_icon(_brake_button, "res://assets/ui/hud/brake.svg")
	_set_bottom_right(_brake_button, -236.0, -120.0, -144.0, -28.0)
	_brake_button.visible = false
	_brake_button.button_down.connect(_on_brake_down)
	_brake_button.button_up.connect(_on_brake_up)
	_brake_button.tree_exiting.connect(_on_brake_up)
	root.add_child(_brake_button)

	_pedal_button = _make_action_button("PEDAL", Vector2(88.0, 88.0))
	_pedal_button.name = "BikePedal"
	_set_button_icon(_pedal_button, "res://assets/ui/hud/pedal.svg")
	_set_bottom_right(_pedal_button, -236.0, -218.0, -144.0, -126.0)
	_pedal_button.visible = false
	_pedal_button.button_down.connect(_press_action.bind(&"bike_pedal"))
	_pedal_button.button_up.connect(_release_action.bind(&"bike_pedal"))
	_pedal_button.tree_exiting.connect(_release_action.bind(&"bike_pedal"))
	root.add_child(_pedal_button)

	_sprint_button = _make_action_button("RUN", Vector2(82.0, 82.0))
	_sprint_button.name = "Sprint"
	_set_button_icon(_sprint_button, "res://assets/ui/hud/run.svg")
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
		_context_button.tooltip_text = "EXIT BIKE"
		_set_button_icon(_context_button, "res://assets/ui/hud/exit.svg")
		_brake_button.tooltip_text = "BRAKE / REV"
		_joystick.visible = _bike_steering_mode == "analog"
		_steer_left_button.visible = _bike_steering_mode == "buttons"
		_steer_right_button.visible = _bike_steering_mode == "buttons"
		_pedal_button.visible = true
		_brake_button.visible = true
		_sprint_button.visible = false
	elif _is_car_mode:
		_mode_label.text = "DRIVING"
		_context_button.tooltip_text = "EXIT"
		_set_button_icon(_context_button, "res://assets/ui/hud/exit.svg")
		_brake_button.tooltip_text = "BRAKE"
		_joystick.visible = true
		_steer_left_button.visible = false
		_steer_right_button.visible = false
		_pedal_button.visible = false
		_brake_button.visible = true
		_sprint_button.visible = false
	else:
		_mode_label.text = "ON FOOT"
		_context_button.tooltip_text = "USE"
		_set_button_icon(_context_button, "res://assets/ui/hud/bicycle.svg")
		_brake_button.tooltip_text = "BRAKE"
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


func _set_button_icon(button: Button, icon_path: String) -> void:
	if not ResourceLoader.exists(icon_path):
		push_warning("HUD control icon is missing: " + icon_path)
		return
	button.icon = load(icon_path) as Texture2D
	button.text = ""
	button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.tooltip_text = button.tooltip_text if not button.tooltip_text.is_empty() else "Action"


func _make_action_button(caption: String, button_size: Vector2) -> Button:
	var button := Button.new()
	button.text = caption
	button.custom_minimum_size = button_size
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", 17)
	button.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
	button.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0, 1.0))
	button.add_theme_stylebox_override("normal", _button_style(Color(0.025, 0.035, 0.038, 0.66)))
	button.add_theme_stylebox_override("hover", _button_style(Color(0.11, 0.13, 0.13, 0.84)))
	button.add_theme_stylebox_override("pressed", _button_style(Color(0.30, 0.33, 0.31, 0.92)))
	button.add_theme_stylebox_override("focus", _button_style(Color(0.05, 0.07, 0.07, 0.72)))
	return button


func _button_style(fill_color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill_color
	style.border_color = Color(0.94, 0.94, 0.88, 0.94)
	style.set_border_width_all(3)
	style.set_corner_radius_all(48)
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.50)
	style.shadow_size = 3
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
