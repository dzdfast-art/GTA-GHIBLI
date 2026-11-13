extends CanvasLayer

## On-screen directional pad. Buttons simulate the same input actions
## used by the keyboard, so gameplay does not need a separate touch code path.

const BUTTON_SIZE := Vector2(68.0, 68.0)
const BUTTON_GAP := 8


func _ready() -> void:
	_build_hud()


func _build_hud() -> void:
	var root := Control.new()
	root.name = "HUD"
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	var title := Label.new()
	title.text = "GTA GHIBLI  |  PROTOTYPE"
	title.position = Vector2(18.0, 16.0)
	title.add_theme_font_size_override("font_size", 20)
	root.add_child(title)

	var hint := Label.new()
	hint.text = "LEFT: MOVE     RIGHT: LOOK"
	hint.position = Vector2(18.0, 46.0)
	hint.add_theme_font_size_override("font_size", 13)
	root.add_child(hint)

	var pad := VBoxContainer.new()
	pad.name = "MovementPad"
	pad.anchor_left = 0.0
	pad.anchor_top = 1.0
	pad.anchor_right = 0.0
	pad.anchor_bottom = 1.0
	pad.offset_left = 24.0
	pad.offset_top = -176.0
	pad.offset_right = 244.0
	pad.offset_bottom = -18.0
	pad.add_theme_constant_override("separation", BUTTON_GAP)
	root.add_child(pad)

	var talk_button := _make_button("TALK", "interact")
	talk_button.anchor_left = 1.0
	talk_button.anchor_top = 1.0
	talk_button.anchor_right = 1.0
	talk_button.anchor_bottom = 1.0
	talk_button.offset_left = -150.0
	talk_button.offset_top = -104.0
	talk_button.offset_right = -24.0
	talk_button.offset_bottom = -24.0
	root.add_child(talk_button)

	var up_button := _make_button("UP", "ui_up")
	pad.add_child(up_button)

	var direction_row := HBoxContainer.new()
	direction_row.add_theme_constant_override("separation", BUTTON_GAP)
	pad.add_child(direction_row)
	direction_row.add_child(_make_button("LEFT", "ui_left"))
	direction_row.add_child(_make_button("DOWN", "ui_down"))
	direction_row.add_child(_make_button("RIGHT", "ui_right"))


func _make_button(caption: String, action: StringName) -> Button:
	var button := Button.new()
	button.text = caption
	button.custom_minimum_size = BUTTON_SIZE
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", 13)
	button.button_down.connect(func() -> void:
		Input.action_press(action)
	)
	button.button_up.connect(func() -> void:
		Input.action_release(action)
	)
	button.tree_exiting.connect(func() -> void:
		Input.action_release(action)
	)
	return button
