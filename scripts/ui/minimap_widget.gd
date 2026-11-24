extends Control

## Lightweight circular minimap: stylized roads, district blocks and player heading.
var _player: Node3D


func _ready() -> void:
	clip_contents = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(208.0, 208.0)
	queue_redraw()


func set_player(player: Node3D) -> void:
	_player = player
	queue_redraw()


func _process(_delta: float) -> void:
	if is_instance_valid(_player):
		queue_redraw()


func _draw() -> void:
	var center := size * 0.5
	var radius := minf(size.x, size.y) * 0.47
	draw_circle(center, radius, Color(0.055, 0.10, 0.085, 0.96))

	var heading := 0.0
	if is_instance_valid(_player):
		heading = _player.global_rotation.y
	var map_origin := center
	if is_instance_valid(_player):
		map_origin -= Vector2(_player.global_position.x, _player.global_position.z) * 0.28
	draw_set_transform(map_origin, -heading, Vector2.ONE)

	# Compact district blocks stay inside the circular map boundary.
	var blocks := [
		Rect2(Vector2(-66.0, -58.0), Vector2(28.0, 18.0)),
		Rect2(Vector2(-18.0, -58.0), Vector2(30.0, 18.0)),
		Rect2(Vector2(34.0, -55.0), Vector2(22.0, 18.0)),
		Rect2(Vector2(-66.0, 8.0), Vector2(28.0, 23.0)),
		Rect2(Vector2(35.0, 10.0), Vector2(22.0, 22.0)),
		Rect2(Vector2(-18.0, 48.0), Vector2(30.0, 18.0))
	]
	for index in range(blocks.size()):
		var green := Color(0.18, 0.34, 0.22, 0.96) if index % 3 == 0 else Color(0.30, 0.39, 0.29, 0.94)
		draw_rect(blocks[index], green)

	# Street grid is clipped mathematically to the circle, not a square viewport.
	var road_color := Color(0.70, 0.73, 0.65, 0.96)
	var road_edge := Color(0.13, 0.18, 0.16, 1.0)
	var safe_radius := radius - 10.0
	for x in [-50.0, 0.0, 50.0]:
		var vertical_extent := sqrt(maxf(0.0, safe_radius * safe_radius - x * x))
		draw_line(Vector2(x, -vertical_extent), Vector2(x, vertical_extent), road_edge, 14.0, true)
		draw_line(Vector2(x, -vertical_extent), Vector2(x, vertical_extent), road_color, 8.0, true)
	for y in [-50.0, 0.0, 50.0]:
		var horizontal_extent := sqrt(maxf(0.0, safe_radius * safe_radius - y * y))
		draw_line(Vector2(-horizontal_extent, y), Vector2(horizontal_extent, y), road_edge, 14.0, true)
		draw_line(Vector2(-horizontal_extent, y), Vector2(horizontal_extent, y), road_color, 8.0, true)
	draw_line(Vector2(-54.0, 22.0), Vector2(23.0, -54.0), road_color, 4.5, true)
	draw_line(Vector2(-50.0, -32.0), Vector2(43.0, 50.0), road_color, 4.5, true)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	# Player position arrow and map compass.
	var arrow := PackedVector2Array([
		center + Vector2(0.0, -14.0),
		center + Vector2(-10.0, 10.0),
		center + Vector2(0.0, 5.0),
		center + Vector2(10.0, 10.0)
	])
	draw_colored_polygon(arrow, Color(1.0, 0.96, 0.82))
	draw_arc(center, radius, 0.0, TAU, 96, Color(0.035, 0.045, 0.05, 1.0), 5.0, true)
	draw_arc(center, radius - 5.0, 0.0, TAU, 96, Color(0.88, 0.85, 0.72, 0.78), 1.8, true)
