extends CanvasLayer
class_name GhibliWebHUD

var _objective_label: Label
var _location_label: Label
var _cash_label: Label
var _prompt_label: Label
var _dialogue_label: Label
var _notice_label: Label
var _vehicle_label: Label
var _map_panel: PanelContainer


func _ready() -> void:
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	var info_panel := _make_panel()
	info_panel.position = Vector2(22.0, 20.0)
	info_panel.custom_minimum_size = Vector2(370.0, 112.0)
	root.add_child(info_panel)
	var info_column := VBoxContainer.new()
	info_panel.add_child(info_column)
	_objective_label = _make_label("Mission 001 — تحدث إلى Claire Bennett", 19, Color(1.0, 0.91, 0.69))
	_location_label = _make_label("Harbor City", 15, Color(0.82, 0.88, 0.89))
	info_column.add_child(_objective_label)
	info_column.add_child(_location_label)

	var status_panel := _make_panel()
	status_panel.anchor_left = 1.0
	status_panel.anchor_right = 1.0
	status_panel.offset_left = -190.0
	status_panel.offset_right = -22.0
	status_panel.offset_top = 20.0
	status_panel.offset_bottom = 76.0
	root.add_child(status_panel)
	_cash_label = _make_label("$350", 22, Color(1.0, 0.87, 0.47))
	status_panel.add_child(_cash_label)

	_prompt_label = _make_label("WASD — Move   Shift — Run   Space — Jump   E — Interact", 17, Color(1.0, 1.0, 1.0))
	_prompt_label.anchor_left = 0.5
	_prompt_label.anchor_right = 0.5
	_prompt_label.anchor_top = 1.0
	_prompt_label.anchor_bottom = 1.0
	_prompt_label.offset_left = -360.0
	_prompt_label.offset_right = 360.0
	_prompt_label.offset_top = -64.0
	_prompt_label.offset_bottom = -28.0
	_prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(_prompt_label)

	_dialogue_label = _make_label("", 18, Color(1.0, 0.94, 0.78))
	_dialogue_label.anchor_left = 0.0
	_dialogue_label.anchor_right = 0.0
	_dialogue_label.anchor_top = 1.0
	_dialogue_label.anchor_bottom = 1.0
	_dialogue_label.offset_left = 22.0
	_dialogue_label.offset_right = 540.0
	_dialogue_label.offset_top = -145.0
	_dialogue_label.offset_bottom = -88.0
	_dialogue_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(_dialogue_label)

	_notice_label = _make_label("", 16, Color(0.83, 0.96, 0.83))
	_notice_label.anchor_left = 0.5
	_notice_label.anchor_right = 0.5
	_notice_label.anchor_top = 0.0
	_notice_label.anchor_bottom = 0.0
	_notice_label.offset_left = -260.0
	_notice_label.offset_right = 260.0
	_notice_label.offset_top = 108.0
	_notice_label.offset_bottom = 140.0
	_notice_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(_notice_label)

	_vehicle_label = _make_label("", 16, Color(0.90, 0.93, 0.98))
	_vehicle_label.anchor_left = 1.0
	_vehicle_label.anchor_right = 1.0
	_vehicle_label.anchor_top = 0.0
	_vehicle_label.anchor_bottom = 0.0
	_vehicle_label.offset_left = -250.0
	_vehicle_label.offset_right = -22.0
	_vehicle_label.offset_top = 88.0
	_vehicle_label.offset_bottom = 118.0
	_vehicle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	root.add_child(_vehicle_label)

	_map_panel = _make_panel()
	_map_panel.anchor_left = 0.5
	_map_panel.anchor_right = 0.5
	_map_panel.anchor_top = 0.5
	_map_panel.anchor_bottom = 0.5
	_map_panel.offset_left = -250.0
	_map_panel.offset_right = 250.0
	_map_panel.offset_top = -175.0
	_map_panel.offset_bottom = 175.0
	_map_panel.visible = false
	root.add_child(_map_panel)

	var map_column := VBoxContainer.new()
	_map_panel.add_child(map_column)
	map_column.add_child(_make_label("GTA GHIBLI — WORLD MAP", 22, Color(1.0, 0.86, 0.54)))
	map_column.add_child(_make_label("Harbor City  ───  Sapphire Coast", 18, Color(0.83, 0.90, 0.91)))
	map_column.add_child(_make_label("       │                         │", 18, Color(0.83, 0.90, 0.91)))
	map_column.add_child(_make_label("Pine Highlands ─── Amber Valley", 18, Color(0.83, 0.90, 0.91)))
	map_column.add_child(_make_label("Marsa Al-Noor: Harbor City (موقع أولي)", 15, Color(0.94, 0.84, 0.63)))
	map_column.add_child(_make_label("M — إغلاق الخريطة", 14, Color(0.78, 0.84, 0.86)))


func set_objective(text: String) -> void:
	_objective_label.text = text


func set_location(text: String) -> void:
	_location_label.text = "Location — " + text


func set_wallet(amount: int) -> void:
	_cash_label.text = "$" + str(amount)


func set_prompt(text: String) -> void:
	_prompt_label.text = text


func set_vehicle_state(is_driving: bool, vehicle_name: String) -> void:
	_vehicle_label.text = ("DRIVING — " + vehicle_name + "   W/S move  A/D steer  Ctrl brake  E exit") if is_driving else ""


func show_dialogue(speaker: String, line: String) -> void:
	_dialogue_label.text = speaker + ": " + line


func show_notification(text: String) -> void:
	_notice_label.text = text


func toggle_map() -> void:
	_map_panel.visible = not _map_panel.visible


func _make_label(text: String, size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label


func _make_panel() -> PanelContainer:
	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.018, 0.035, 0.047, 0.86)
	style.border_color = Color(0.73, 0.61, 0.38, 0.70)
	style.set_border_width_all(1)
	style.set_corner_radius_all(8)
	style.content_margin_left = 14.0
	style.content_margin_right = 14.0
	style.content_margin_top = 10.0
	style.content_margin_bottom = 10.0
	panel.add_theme_stylebox_override("panel", style)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return panel
