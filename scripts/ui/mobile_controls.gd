extends CanvasLayer

const JOYSTICK_SCRIPT = preload("res://scripts/ui/virtual_joystick.gd")
const JOYSTICK_SIZE := Vector2(176.0, 176.0)

var _active_actions: Array[StringName] = []
var _mode_label: Label
var _context_button: Button
var _brake_button: Button

func _ready() -> void:
	if not InputMap.has_action("vehicle_brake"):
		InputMap.add_action("vehicle_brake")
	_build_hud()

func _build_hud() -> void:
	var root := Control.new()
	root.name = "HUD"
	root.add_to_group("mobile_hud")
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	_mode_label = Label.new()
	_mode_label.text = "ON FOOT"
	_mode_label.position = Vector2(22.0, 18.0)
	_mode_label.add_theme_font_size_override("font_size", 15)
	_mode_label.add_theme_color_override("font_color", Color(1.0, 0.96, 0.82, 0.92))
	root.add_child(_mode_label)
	var joystick := JOYSTICK_SCRIPT.new() as Control
	joystick.name = "MovementJoystick"
	joystick.anchor_left = 0.0
	joystick.anchor_top = 1.0
	joystick.anchor_right = 0.0
	joystick.anchor_bottom = 1.0
	joystick.offset_left = 22.0
	joystick.offset_top = -JOYSTICK_SIZE.y - 22.0
	joystick.offset_right = 22.0 + JOYSTICK_SIZE.x
	joystick.offset_bottom = -22.0
	joystick.vector_changed.connect(_on_joystick_vector_changed)
	root.add_child(joystick)
	_context_button = _make_action_button("USE", Vector2(104.0, 104.0))
	_context_button.name = "ContextAction"
	_context_button.anchor_left = 1.0
	_context_button.anchor_top = 1.0
	_context_button.anchor_right = 1.0
	_context_button.anchor_bottom = 1.0
	_context_button.offset_left = -132.0
	_context_button.offset_top = -132.0
	_context_button.offset_right = -24.0
	_context_button.offset_bottom = -24.0
	_context_button.button_down.connect(_press_action.bind(&"interact"))
	_context_button.button_up.connect(_release_action.bind(&"interact"))
	_context_button.tree_exiting.connect(_release_action.bind(&"interact"))
	root.add_child(_context_button)
	_brake_button = _make_action_button("BRAKE", Vector2(88.0, 88.0))
	_brake_button.name = "VehicleBrake"
	_brake_button.anchor_left = 1.0
	_brake_button.anchor_top = 1.0
	_brake_button.anchor_right = 1.0
	_brake_button.anchor_bottom = 1.0
	_brake_button.offset_left = -236.0
	_brake_button.offset_top = -120.0
	_brake_button.offset_right = -144.0
	_brake_button.offset_bottom = -28.0
	_brake_button.visible = false
	_brake_button.button_down.connect(_press_action.bind(&"vehicle_brake"))
	_brake_button.button_up.connect(_release_action.bind(&"vehicle_brake"))
	_brake_button.tree_exiting.connect(_release_action.bind(&"vehicle_brake"))
	root.add_child(_brake_button)

func set_vehicle_mode(active: bool) -> void:
	if _mode_label == null:
		return
	_mode_label.text = "DRIVING" if active else "ON FOOT"
	_context_button.text = "EXIT" if active else "USE"
	_brake_button.visible = active

func _on_joystick_vector_changed(value: Vector2) -> void:
	_set_action(&"ui_left", value.x < -0.12)
	_set_action(&"ui_right", value.x > 0.12)
	_set_action(&"ui_up", value.y < -0.12)
	_set_action(&"ui_down", value.y > 0.12)

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
