extends CanvasLayer
class_name GhibliWebHUD

signal waypoint_selected(point_id: String, point_name: String, world_position: Vector3)
signal shop_purchase_requested(item_id: String)
signal shop_sell_requested(item_id: String)

const WORLD_MAP_SCRIPT = preload("res://scripts/ui/world_map.gd")

class MinimapCanvas extends Control:
	var player_world_position := Vector3(-114.0, 0.0, 0.0)
	var player_heading: float = 0.0
	var waypoint_world_position := Vector3.ZERO
	var has_waypoint: bool = false
	var route_points: Array[Vector3] = []
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

	func set_waypoint(world_position: Vector3, active: bool) -> void:
		waypoint_world_position = world_position
		has_waypoint = active
		queue_redraw()

	func set_navigation_route(route: Dictionary) -> void:
		route_points.clear()
		if bool(route.get("reachable", false)):
			for position in route.get("path", []):
				if position is Vector3:
					route_points.append(position)
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

		var player_point := world_to_map(player_world_position, size)
		var heading_vector := Vector2(sin(player_heading), -cos(player_heading))
		draw_line(player_point, player_point + heading_vector * 11.0, Color(0.98, 0.98, 0.94), 2.0)
		draw_circle(player_point, 5.0, Color(0.20, 0.82, 1.0))
		draw_arc(player_point, 7.0, 0.0, TAU, 20, Color(0.97, 0.98, 0.92), 1.3)
		if has_waypoint:
			if route_points.size() > 1:
				var route_line := PackedVector2Array()
				for route_position in route_points:
					route_line.append(world_to_map(route_position, size))
				draw_polyline(route_line, Color(1.0, 0.73, 0.22, 0.96), 2.4, true)
			var waypoint_point := world_to_map(waypoint_world_position, size)
			draw_circle(waypoint_point, 4.0, Color(1.0, 0.78, 0.26))
			draw_arc(waypoint_point, 7.0, 0.0, TAU, 20, Color(1.0, 0.90, 0.58), 1.2)


var _objective_label: Label
var _location_label: Label
var _waypoint_label: Label
var _guidance_label: Label
var _cash_label: Label
var _save_status_label: Label
var _prompt_label: Label
var _dialogue_label: Label
var _notice_label: Label
var _vehicle_label: Label
var _map_panel: PanelContainer
var _minimap: MinimapCanvas
var _map_canvas: Node
var _shop_panel: PanelContainer
var _shop_items_column: VBoxContainer
var _shop_message_label: Label
var _shop_catalog: Array[Dictionary] = []
var _shop_inventory: Dictionary = {}
var _shop_wallet: int = 0


func _ready() -> void:
	var root := Control.new()
	root.name = "HUDRoot"
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	var info_panel := _make_panel()
	info_panel.position = Vector2(22.0, 20.0)
	info_panel.custom_minimum_size = Vector2(390.0, 164.0)
	root.add_child(info_panel)
	var info_column := VBoxContainer.new()
	info_panel.add_child(info_column)
	_objective_label = _make_label("Mission 001 — تحدث إلى Claire Bennett", 19, Color(1.0, 0.91, 0.69))
	_location_label = _make_label("Harbor City", 15, Color(0.82, 0.88, 0.89))
	_waypoint_label = _make_label("", 14, Color(1.0, 0.82, 0.43))
	_guidance_label = _make_label("", 14, Color(0.72, 0.91, 1.0))
	info_column.add_child(_objective_label)
	info_column.add_child(_location_label)
	info_column.add_child(_waypoint_label)
	info_column.add_child(_guidance_label)

	var status_panel := _make_panel()
	status_panel.anchor_left = 1.0
	status_panel.anchor_right = 1.0
	status_panel.offset_left = -190.0
	status_panel.offset_right = -22.0
	status_panel.offset_top = 20.0
	status_panel.offset_bottom = 96.0
	root.add_child(status_panel)
	var status_column := VBoxContainer.new()
	status_column.add_theme_constant_override("separation", 2)
	status_panel.add_child(status_column)
	_cash_label = _make_label("$350", 22, Color(1.0, 0.87, 0.47))
	_save_status_label = _make_label("Checking save storage…", 10, Color(0.78, 0.88, 0.82))
	_save_status_label.custom_minimum_size = Vector2(160.0, 20.0)
	_save_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_column.add_child(_cash_label)
	status_column.add_child(_save_status_label)

	_vehicle_label = _make_label("", 16, Color(0.90, 0.93, 0.98))
	_vehicle_label.anchor_left = 1.0
	_vehicle_label.anchor_right = 1.0
	_vehicle_label.anchor_top = 0.0
	_vehicle_label.anchor_bottom = 0.0
	_vehicle_label.offset_left = -250.0
	_vehicle_label.offset_right = -22.0
	_vehicle_label.offset_top = 102.0
	_vehicle_label.offset_bottom = 132.0
	_vehicle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	root.add_child(_vehicle_label)

	var minimap_panel := _make_panel()
	minimap_panel.name = "MinimapPanel"
	minimap_panel.anchor_left = 1.0
	minimap_panel.anchor_right = 1.0
	minimap_panel.offset_left = -218.0
	minimap_panel.offset_right = -22.0
	minimap_panel.offset_top = 144.0
	minimap_panel.offset_bottom = 298.0
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
	_map_panel.name = "WorldMapPanel"
	_map_panel.anchor_left = 0.5
	_map_panel.anchor_right = 0.5
	_map_panel.anchor_top = 0.5
	_map_panel.anchor_bottom = 0.5
	_map_panel.offset_left = -390.0
	_map_panel.offset_right = 390.0
	_map_panel.offset_top = -250.0
	_map_panel.offset_bottom = 250.0
	_map_panel.visible = false
	root.add_child(_map_panel)

	var map_column := VBoxContainer.new()
	map_column.name = "MapColumn"
	_map_panel.add_child(map_column)
	map_column.add_child(_make_label("GTA GHIBLI — WORLD MAP", 22, Color(1.0, 0.86, 0.54)))
	_map_canvas = WORLD_MAP_SCRIPT.new()
	_map_canvas.name = "WorldMapCanvas"
	_map_canvas.set("custom_minimum_size", Vector2(740.0, 360.0))
	map_column.add_child(_map_canvas)
	_map_canvas.connect("waypoint_selected", Callable(self, "_forward_waypoint_selection"))
	map_column.add_child(_make_label("Click a marker to set a waypoint • Wheel: zoom • Right-drag: pan • M: close", 14, Color(0.78, 0.84, 0.86)))
	map_column.add_child(_make_label("Gold route follows the current connected starter-road graph.", 12, Color(0.70, 0.76, 0.77)))

	_shop_panel = _make_panel()
	_shop_panel.name = "MarketShopPanel"
	_shop_panel.anchor_left = 0.5
	_shop_panel.anchor_right = 0.5
	_shop_panel.anchor_top = 0.5
	_shop_panel.anchor_bottom = 0.5
	_shop_panel.offset_left = -285.0
	_shop_panel.offset_right = 285.0
	_shop_panel.offset_top = -205.0
	_shop_panel.offset_bottom = 205.0
	_shop_panel.visible = false
	_shop_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	root.add_child(_shop_panel)

	var shop_column := VBoxContainer.new()
	shop_column.add_theme_constant_override("separation", 8)
	_shop_panel.add_child(shop_column)
	shop_column.add_child(_make_label("HARBOR MARKET — BUY & SELL", 22, Color(1.0, 0.86, 0.54)))
	shop_column.add_child(_make_label("Local goods • purchases and sales are saved with your game.", 13, Color(0.78, 0.84, 0.86)))
	_shop_items_column = VBoxContainer.new()
	_shop_items_column.add_theme_constant_override("separation", 6)
	shop_column.add_child(_shop_items_column)
	_shop_message_label = _make_label("Choose an item to trade.", 14, Color(0.88, 0.92, 0.82))
	_shop_message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	shop_column.add_child(_shop_message_label)
	var close_button := Button.new()
	close_button.text = "Close shop"
	close_button.pressed.connect(close_market_shop)
	shop_column.add_child(close_button)


func set_objective(text: String) -> void:
	_objective_label.text = text


func set_location(text: String) -> void:
	_location_label.text = "Location — " + text


func set_wallet(amount: int) -> void:
	_cash_label.text = "$" + str(amount)


func set_save_storage_status(message: String, persistent: bool, save_succeeded: bool) -> void:
	if _save_status_label == null:
		return
	_save_status_label.text = message
	var color := Color(0.78, 0.88, 0.82)
	if not save_succeeded or not persistent:
		color = Color(1.0, 0.72, 0.42)
	_save_status_label.add_theme_color_override("font_color", color)


func get_save_storage_status_text() -> String:
	return _save_status_label.text if _save_status_label != null else ""


func set_prompt(text: String) -> void:
	_prompt_label.text = text


func set_vehicle_state(is_driving: bool, vehicle_name: String) -> void:
	_vehicle_label.text = ("DRIVING — " + vehicle_name + "   W/S move  A/D steer  Ctrl brake  E exit") if is_driving else ""


func set_points_of_interest(points: Array[Dictionary]) -> void:
	_map_canvas.call("set_points_of_interest", points)


func update_minimap(
	world_position: Vector3,
	heading: float,
	waypoint_position: Vector3 = Vector3.ZERO,
	has_waypoint: bool = false
) -> void:
	_minimap.set_player_state(world_position, heading)
	_minimap.set_waypoint(waypoint_position, has_waypoint)
	_map_canvas.call("set_player_state", world_position, heading)


func set_waypoint_status(point_name: String, distance: float, route_reachable: bool = true) -> void:
	if point_name.is_empty():
		_waypoint_label.text = ""
		return
	if not route_reachable:
		_waypoint_label.text = "GPS — no connected road route to " + point_name
		return
	_waypoint_label.text = "GPS ROUTE — %s · %.0f m (road)" % [point_name, distance]


func set_navigation_route(route: Dictionary) -> void:
	_minimap.set_navigation_route(route)
	_map_canvas.call("set_navigation_route", route)


func set_navigation_guidance(instruction: String) -> void:
	_guidance_label.text = ("NEXT TURN — " + instruction) if not instruction.is_empty() else ""


func get_waypoint_status_text() -> String:
	return _waypoint_label.text


func _forward_waypoint_selection(
	point_id: String,
	point_name: String,
	world_position: Vector3
) -> void:
	waypoint_selected.emit(point_id, point_name, world_position)


func show_dialogue(speaker: String, line: String) -> void:
	_dialogue_label.text = speaker + ": " + line


func show_notification(text: String) -> void:
	_notice_label.text = text


func toggle_map() -> void:
	_map_panel.visible = not _map_panel.visible


func open_market_shop(catalog: Array[Dictionary], inventory: Dictionary, wallet: int) -> void:
	_shop_catalog = catalog.duplicate(true)
	_shop_inventory = inventory.duplicate(true)
	_shop_wallet = wallet
	_shop_panel.visible = true
	_shop_message_label.text = "Wallet: $%d — choose an item to trade." % wallet
	_rebuild_market_shop()


func update_market_shop(catalog: Array[Dictionary], inventory: Dictionary, wallet: int) -> void:
	_shop_catalog = catalog.duplicate(true)
	_shop_inventory = inventory.duplicate(true)
	_shop_wallet = wallet
	if _shop_panel.visible:
		_rebuild_market_shop()


func set_market_shop_message(message: String) -> void:
	if _shop_message_label != null:
		_shop_message_label.text = message


func close_market_shop() -> void:
	if _shop_panel != null:
		_shop_panel.visible = false


func is_market_shop_open() -> bool:
	return _shop_panel != null and _shop_panel.visible


func _rebuild_market_shop() -> void:
	for child in _shop_items_column.get_children():
		child.queue_free()
	for item in _shop_catalog:
		var item_id := str(item.get("id", ""))
		var price := int(item.get("price", 0))
		var stock := int(item.get("quantity", 0))
		var owned := int(_shop_inventory.get(item_id, 0))
		var row := HBoxContainer.new()
		var description := _make_label(
			"%s — $%d | Stock %d | Owned %d" % [_shop_item_name(item_id), price, stock, owned],
			14,
			Color(0.94, 0.91, 0.82)
		)
		description.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(description)

		var buy_button := Button.new()
		buy_button.text = "Buy ×1"
		buy_button.disabled = stock <= 0 or _shop_wallet < price
		buy_button.pressed.connect(_emit_shop_purchase.bind(item_id))
		row.add_child(buy_button)

		var sell_button := Button.new()
		sell_button.text = "Sell ×1"
		sell_button.disabled = owned <= 0
		sell_button.pressed.connect(_emit_shop_sell.bind(item_id))
		row.add_child(sell_button)
		_shop_items_column.add_child(row)


func _shop_item_name(item_id: String) -> String:
	match item_id:
		"bottled_water":
			return "Bottled water / ماء معبأ"
		"fruit_basket":
			return "Fruit basket / سلة فواكه"
		"first_aid_kit":
			return "First-aid kit / حقيبة إسعاف"
		_:
			return item_id


func _emit_shop_purchase(item_id: String) -> void:
	shop_purchase_requested.emit(item_id)


func _emit_shop_sell(item_id: String) -> void:
	shop_sell_requested.emit(item_id)


func _make_label(text: String, size: int, color: Color)
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
