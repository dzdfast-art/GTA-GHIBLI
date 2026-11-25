extends Control

## Lightweight, live top-down minimap for the mobile gameplay HUD.
## It follows the player and draws the local road grid, village buildings,
## trees and the player's facing direction without allocating textures.
@export_range(30.0, 180.0, 5.0) var visible_world_width: float = 120.0
@export_range(30.0, 140.0, 5.0) var visible_world_depth: float = 90.0

var _redraw_timer := 0.0


func _ready() -> void:
	custom_minimum_size = Vector2(168.0, 126.0)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process(true)
	queue_redraw()


func _process(delta: float) -> void:
	_redraw_timer += delta
	if _redraw_timer >= 0.14:
		_redraw_timer = 0.0
		queue_redraw()


func _draw() -> void:
	if size.x <= 0.0 or size.y <= 0.0:
		return
	var bounds := Rect2(Vector2.ZERO, size)
	draw_rect(bounds, Color(0.025, 0.035, 0.040, 0.90), true)
	draw_rect(bounds, Color(0.82, 0.72, 0.46, 0.92), false, 2.0)

	var player := get_tree().get_first_node_in_group("player") as Node3D
	var origin := player.global_position if player != null else Vector3.ZERO
	var scale_x := (size.x - 18.0) / visible_world_width
	var scale_y := (size.y - 18.0) / visible_world_depth
	var scale_value := minf(scale_x, scale_y)
	var center := size * 0.5

	# Willow Village streets and adjoining neighborhood grid.
	_draw_road(origin, Vector2(-64.0, 0.0), Vector2(64.0, 0.0), scale_value, center)
	_draw_road(origin, Vector2(0.0, -52.0), Vector2(0.0, 52.0), scale_value, center)
	_draw_road(origin, Vector2(-24.0, -15.0), Vector2(24.0, -15.0), scale_value, center)
	_draw_road(origin, Vector2(-24.0, 15.0), Vector2(24.0, 15.0), scale_value, center)
	_draw_road(origin, Vector2(-15.0, -30.0), Vector2(-15.0, 30.0), scale_value, center)
	_draw_road(origin, Vector2(15.0, -30.0), Vector2(15.0, 30.0), scale_value, center)

	# Buildings are positioned in world coordinates, so the map scrolls with the player.
	for house_position in [
		Vector2(-11.0, -10.0), Vector2(11.0, -10.0),
		Vector2(-11.0, 11.0), Vector2(11.0, 11.0)
	]:
		_draw_building(origin, house_position, scale_value, center)
	for tree_position in [
		Vector2(-23.0, -18.0), Vector2(23.0, -18.0),
		Vector2(-24.0, 5.0), Vector2(24.0, 5.0),
		Vector2(-19.0, 29.0), Vector2(19.0, 29.0)
	]:
		var tree_point := _screen_point(origin, tree_position, scale_value, center)
		draw_circle(tree_point, 2.4, Color(0.30, 0.58, 0.34, 0.96))

	# Village square and its center marker.
	var square_point := _screen_point(origin, Vector2.ZERO, scale_value, center)
	draw_rect(Rect2(square_point - Vector2(5.5, 5.5), Vector2(11.0, 11.0)),
		Color(0.47, 0.43, 0.34, 0.95), true)

	# The player marker remains centered and rotates with the character.
	var heading := 0.0
	if player != null:
		var forward := -player.global_basis.z
		heading = atan2(forward.x, -forward.z)
	draw_circle(center, 6.0, Color(0.02, 0.025, 0.03, 0.96))
	var marker := PackedVector2Array([
		center + Vector2(0.0, -8.0).rotated(heading),
		center + Vector2(6.0, 7.0).rotated(heading),
		center + Vector2(-6.0, 7.0).rotated(heading)
	])
	draw_colored_polygon(marker, Color(0.94, 0.92, 0.78, 1.0))
	draw_polyline(PackedVector2Array([
		Vector2(center.x, 6.0),
		Vector2(center.x, 15.0)
	]), Color(0.88, 0.86, 0.74, 0.8), 1.2, true)


func _draw_road(origin: Vector3, start: Vector2, finish: Vector2,
		scale_value: float, center: Vector2) -> void:
	var from_point := _screen_point(origin, start, scale_value, center)
	var to_point := _screen_point(origin, finish, scale_value, center)
	draw_line(from_point, to_point, Color(0.15, 0.17, 0.17, 1.0), 8.0, true)
	draw_line(from_point, to_point, Color(0.28, 0.30, 0.29, 1.0), 5.0, true)


func _draw_building(origin: Vector3, world_position: Vector2,
		scale_value: float, center: Vector2) -> void:
	var point := _screen_point(origin, world_position, scale_value, center)
	var footprint := Vector2(6.0 * scale_value, 5.0 * scale_value)
	draw_rect(Rect2(point - footprint * 0.5, footprint),
		Color(0.66, 0.55, 0.39, 0.98), true)
	draw_rect(Rect2(point - footprint * 0.5, footprint),
		Color(0.13, 0.12, 0.11, 0.95), false, 1.0)


func _screen_point(origin: Vector3, relative_world: Vector2,
		scale_value: float, center: Vector2) -> Vector2:
	var offset := relative_world - Vector2(origin.x, origin.z)
	return center + offset * scale_value
