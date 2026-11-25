extends Control
class_name GhibliWorldMap

signal waypoint_selected(point_id: String, point_name: String, world_position: Vector3)

const WORLD_MIN := Vector2(-128.0, -32.0)
const WORLD_SIZE := Vector2(256.0, 64.0)
const REGION_NAMES := ["Harbor City", "Sapphire Coast", "Pine Highlands", "Amber Valley"]
const REGION_COLORS := [
	Color(0.17, 0.29, 0.33),
	Color(0.36, 0.34, 0.24),
	Color(0.17, 0.29, 0.22),
	Color(0.34, 0.26, 0.18)
]

var _points: Array[Dictionary] = []
var _player_position := Vector3(-114.0, 0.0, 0.0)
var _player_heading: float = 0.0
var _waypoint_id: String = ""
var _waypoint_position := Vector3.ZERO
var _route_points: Array[Vector3] = []
var _zoom: float = 1.0
var _pan := Vector2.ZERO
var _dragging: bool = false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	clip_contents = true
	queue_redraw()


func set_points_of_interest(points: Array[Dictionary]) -> void:
	_points.clear()
	for point in points:
		if point.has("id") and point.has("name") and point.has("position"):
			_points.append(point.duplicate(true))
	queue_redraw()


func set_player_state(world_position: Vector3, heading: float) -> void:
	_player_position = world_position
	_player_heading = heading
	queue_redraw()


func set_waypoint(point_id: String, world_position: Vector3) -> void:
	_waypoint_id = point_id
	_waypoint_position = world_position
	queue_redraw()


func clear_waypoint() -> void:
	_waypoint_id = ""
	_waypoint_position = Vector3.ZERO
	_route_points.clear()
	queue_redraw()


func set_navigation_route(route: Dictionary) -> void:
	_route_points.clear()
	if bool(route.get("reachable", false)):
		for position in route.get("path", []):
			if position is Vector3:
				_route_points.append(position)
	queue_redraw()


func world_to_map(world_position: Vector3) -> Vector2:
	var normalized := Vector2(
		(world_position.x - WORLD_MIN.x) / WORLD_SIZE.x,
		(world_position.z - WORLD_MIN.y) / WORLD_SIZE.y
	)
	var base_position := normalized * size
	return (base_position - size * 0.5) * _zoom + size * 0.5 + _pan


func select_nearest_point(local_position: Vector2) -> bool:
	var nearest_id := ""
	var nearest_name := ""
	var nearest_position := Vector3.ZERO
	var nearest_distance := 22.0

	for point in _points:
		var world_position: Vector3 = point.get("position", Vector3.ZERO)
		var marker_position := world_to_map(world_position)
		var distance := marker_position.distance_to(local_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_id = str(point.get("id", ""))
			nearest_name = str(point.get("name", ""))
			nearest_position = world_position

	if nearest_id.is_empty():
		return false

	set_waypoint(nearest_id, nearest_position)
	waypoint_selected.emit(nearest_id, nearest_name, nearest_position)
	return true


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var button := event as InputEventMouseButton
		if button.button_index == MOUSE_BUTTON_RIGHT:
			_dragging = button.pressed
			accept_event()
		elif button.pressed and button.button_index == MOUSE_BUTTON_LEFT:
			if select_nearest_point(button.position):
				accept_event()
		elif button.pressed and button.button_index == MOUSE_BUTTON_WHEEL_UP:
			_zoom = minf(_zoom * 1.15, 2.4)
			queue_redraw()
			accept_event()
		elif button.pressed and button.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_zoom = maxf(_zoom / 1.15, 1.0)
			if is_equal_approx(_zoom, 1.0):
				_pan = Vector2.ZERO
			queue_redraw()
			accept_event()
	elif event is InputEventMouseMotion and _dragging:
		var motion := event as InputEventMouseMotion
		_pan += motion.relative
		var pan_limit := size * ((_zoom - 1.0) * 0.5)
		_pan.x = clampf(_pan.x, -pan_limit.x, pan_limit.x)
		_pan.y = clampf(_pan.y, -pan_limit.y, pan_limit.y)
		queue_redraw()
		accept_event()


func _draw() -> void:
	if size.x <= 0.0 or size.y <= 0.0:
		return

	draw_rect(Rect2(Vector2.ZERO, size), Color(0.035, 0.052, 0.058), true)
	var band_width := WORLD_SIZE.x / 4.0
	for index in range(REGION_NAMES.size()):
		var region_left := world_to_map(Vector3(WORLD_MIN.x + band_width * index, 0.0, 0.0)).x
		var region_right := world_to_map(Vector3(WORLD_MIN.x + band_width * (index + 1), 0.0, 0.0)).x
		var region_rect := Rect2(
			Vector2(region_left, 0.0),
			Vector2(region_right - region_left, size.y)
		)
		draw_rect(region_rect, REGION_COLORS[index], true)
		draw_string(
			get_theme_default_font(),
			Vector2(region_left + 10.0, 24.0),
			REGION_NAMES[index],
			HORIZONTAL_ALIGNMENT_LEFT,
			-1.0,
			14,
			Color(0.94, 0.91, 0.82)
		)

	var road_start := world_to_map(Vector3(-128.0, 0.0, 0.0))
	var road_end := world_to_map(Vector3(128.0, 0.0, 0.0))
	draw_line(road_start, road_end, Color(0.10, 0.12, 0.13), 14.0)
	draw_line(road_start, road_end, Color(0.78, 0.70, 0.50), 1.6)
	# Keep the map topology in sync with the connected in-world street grid.
	for street_x in [-96.0, -32.0, 32.0, 96.0]:
		var vertical_start := world_to_map(Vector3(street_x, 0.0, -27.0))
		var vertical_end := world_to_map(Vector3(street_x, 0.0, 27.0))
		draw_line(vertical_start, vertical_end, Color(0.10, 0.12, 0.13), 5.0 * _zoom)
		draw_line(vertical_start, vertical_end, Color(0.68, 0.64, 0.52), 0.7 * _zoom)
	for street_z in [-24.0, 24.0]:
		var horizontal_start := world_to_map(Vector3(-99.0, 0.0, street_z))
		var horizontal_end := world_to_map(Vector3(99.0, 0.0, street_z))
		draw_line(horizontal_start, horizontal_end, Color(0.10, 0.12, 0.13), 5.0 * _zoom)
		draw_line(horizontal_start, horizontal_end, Color(0.68, 0.64, 0.52), 0.7 * _zoom)

	if _route_points.size() > 1:
		var route_line := PackedVector2Array()
		for route_position in _route_points:
			route_line.append(world_to_map(route_position))
		draw_polyline(route_line, Color(1.0, 0.72, 0.20, 0.98), 4.0, true)

	for point in _points:
		var point_position: Vector3 = point.get("position", Vector3.ZERO)
		var marker_position := world_to_map(point_position)
		var point_id := str(point.get("id", ""))
		var marker_color := _category_color(str(point.get("category", "")))
		draw_circle(marker_position, 5.0, marker_color)
		draw_arc(marker_position, 8.0, 0.0, TAU, 20, Color(0.96, 0.94, 0.84), 1.2)
		if point_id == _waypoint_id:
			draw_arc(marker_position, 13.0, 0.0, TAU, 24, Color(1.0, 0.84, 0.34), 2.0)
		draw_string(
			get_theme_default_font(),
			marker_position + Vector2(10.0, -7.0),
			str(point.get("name", "Point")),
			HORIZONTAL_ALIGNMENT_LEFT,
			-1.0,
			12,
			Color(0.98, 0.96, 0.87)
		)

	var player_point := world_to_map(_player_position)
	var heading_vector := Vector2(sin(_player_heading), -cos(_player_heading))
	draw_line(player_point, player_point + heading_vector * 15.0, Color(0.98, 0.98, 0.94), 2.4)
	draw_circle(player_point, 6.0, Color(0.16, 0.82, 1.0))
	draw_arc(player_point, 9.0, 0.0, TAU, 24, Color(0.97, 0.98, 0.92), 1.4)


func _category_color(category: String) -> Color:
	match category:
		"mission":
			return Color(1.0, 0.78, 0.24)
		"shop":
			return Color(0.40, 0.90, 0.65)
		"service":
			return Color(0.37, 0.76, 1.0)
		"rest":
			return Color(0.73, 0.85, 0.52)
		"farm":
			return Color(0.88, 0.68, 0.38)
		_:
			return Color(1.0, 0.88, 0.48)
