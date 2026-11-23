extends CanvasLayer
class_name GhibliWebHUD

class MinimapCanvas extends Control:
	var player_world_position := Vector3(-114.0, 0.0, 0.0)
	var player_heading: float = 0.0
	var route_points := PackedVector3Array()
	var route_destination := ""
	var route_distance: float = 0.0
	const WORLD_MIN := Vector2(-128.0, -32.0)
	const WORLD_SIZE := Vector2(256.0, 64.0)
	const REGION_COLORS := [
		Color(0.20, 0.31, 0.34),
		Color(0.37, 0.34, 0.24),
		Color(0.18, 0.29, 0.22),
		Color(0.34, 0.27, 0.18)
	]
	const REGION_NAMES := ["H", "S", "P", "A"]

	func set_player_state(world_position: Vector3, heading: float) -> void:
		player_world_position = world_position
		player_heading = heading
		queue_redraw()

	func set_route(points: PackedVector3Array, destination_name: String, distance: float) -> void:
		route_points = points.duplicate()
		route_destination = destination_name
		route_distance = distance
		queue_redraw()

	func clear_route() -> void:
		route_points.clear()
		route_destination = ""
		route_distance = 0.0
		queue_redraw()

	func world_to_map(world_position: Vector3, map_size: Vector2 = Vector2(180.0, 132.0)) -> Vector2:
		var normalized := Vector2(
			(world_position.x - WORLD_MIN.x) / WORLD_SIZE.x,
			(world_position.z - WORLD_MIN.y) / WORLD_SIZE.y
		)
		return Vector2(clampf(normalized.x, 0.0, 1.0), clampf(normalized.y, 0.0, 1.0)) * map_size

	func _draw() -> void:
		var map_rect := Rect2(Vector2.ZERO, size)
		draw_rect(map_rect, Color(0.035, 0.055, 0.062, 0.98), true)
		var band_width := size.x / 4.0
		for index in range(4):
			var band := Rect2(Vector2(index * band_width, 0.0), Vector2(band_width, size.y))
			draw_rect(band, REGION_COLORS[index], true)
			draw_string(get_theme_default_font(), Vector2(index * band_width + 7.0, 15.0), REGION_NAMES[index], HORIZONTAL_ALIGNMENT_LEFT, -1.0, 10, Color(0.93, 0.91, 0.82))
			if index > 0:
				var divider_x := index * band_width
				draw_line(Vector2(divider_x, 0.0), Vector2(divider_x, size.y), Color(0.78, 0.75, 0.63, 0.45), 1.0)

		var road_y := world_to_map(Vector3(0.0, 0.0, 0.0), size).y
		draw_line(Vector2(0.0, road_y), Vector2(size.x, road_y), Color(0.13, 0.14, 0.14), 8.0)
		draw_line(Vector2(0.0, road_y), Vector2(size.x, road_y), Color(0.86, 0.78, 0.55, 0.85), 1.2)

		var lighthouse := world_to_map(Vector3(-79.0, 0.0, 17.0), size)
		draw_circle(lighthouse, 4.0, Color(1.0, 0.82, 0.35))
		draw_circle(lighthouse, 1.5, Color(0.12, 0.10, 0.07))

		if route_points.size() >= 2:
			var route_map_points := PackedVector2Array()
			for route_point in route_points:
				route_map_points.append(world_to_map(route_point, size))
			draw_polyline(route_map_points, Color(1.0, 0.64, 0.22, 0.96), 3.2, true)
			draw_circle(route_map_points[route_map_points.size() - 1], 4.8, Color(1.0, 0.76, 0.30))
			draw_arc(route_map_points[route_map_points.size() - 1], 7.0, 0.0, TAU, 20, Color(0.10, 0.08, 0.05), 1.2)

		var player_point := world_to_map(player_world_position, size)
		var heading_vector := Vector2(sin(player_heading), -cos(player_heading))
		draw_line(player_point, player_point + heading_vector * 11.0, Color(0.98, 0.98, 0.94), 2.0)
		draw_circle(player_point, 5.0, Color(0.20, 0.82, 1.0))
		draw_arc(player_point, 7.0, 0.0, TAU, 20, Color(0.97, 0.98, 0.92), 1.3)


var _objective_label: Label
var _location_label: Label
var _cash_label: Label
var _prompt_label: Label
var _dialogue_label: Label
var _notice_label: Label
var _vehicle_label: Label
var _map_panel: PanelContainer
var _minimap: MinimapCanvas
var _route_label: Label


func _ready() -> void:
	var root := Control.new()
	root.name = "HUDRoot"
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

	var minimap_panel := _make_panel()
	minimap_panel.name = "MinimapPanel"
	minimap_panel.anchor_left = 1.0
	minimap_panel.anchor_right = 1.0
	minimap_panel.offset_left = -218.0
	minimap_panel.offset_right = -22.0
	minimap_panel.offset_top = 132.0
	minimap_panel.offset_bottom = 286.0
	root.add_child(minimap_panel)
	_minimap = MinimapCanvas.new()
	_minimap.name = "WorldMinimap"
	_minimap.custom_minimum_size = Vector2(180.0, 132.0)
	_minimap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_minimap.size_flags_vertical = Control.SIZE_EXPAND_FILL
	minimap_panel.add_child(_minimap)

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
	_route_label = _make_label("GPS — no active destination", 15, Color(1.0, 0.72, 0.34))
	map_column.add_child(_route_label)
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


func update_minimap(world_position: Vector3, heading: float) -> void:
	_minimap.set_player_state(world_position, heading)


func set_navigation_route(points: PackedVector3Array, destination_name: String, distance: float) -> void:
	_minimap.set_route(points, destination_name, distance)
	_route_label.text = "GPS — " + destination_name + " · " + str(roundi(distance)) + " m"


func clear_navigation_route() -> void:
	_minimap.clear_route()
	_route_label.text = "GPS — no active destination"


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
	style.content_margin_left = 8.0
	style.content_margin_right = 8.0
	style.content_margin_top = 8.0
	style.content_margin_bottom = 8.0
	panel.add_theme_stylebox_override("panel", style)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return panel
