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
	draw_set_transform(center, -heading, Vector2.ONE)

	# Park blocks and green spaces.
	var blocks := [
		Rect2(Vector2(-85.0, -76.0), Vector2(45.0, 27.0)),
		Rect2(Vector2(-28.0, -76.0), Vector2(52.0, 27.0)),
		Rect2(Vector2(34.0, -76.0), Vector2(48.0, 27.0)),
		Rect2(Vector2(-85.0, -28.0), Vector2(45.0, 36.0)),
		Rect2(Vector2(34.0, -28.0), Vector2(48.0, 36.0)),
		Rect2(Vector2(-85.0, 32.0), Vector2(45.0, 40.0)),
		Rect2(Vector2(-28.0, 32.0), Vector2(52.0, 40.0)),
		Rect2(Vector2(34.0, 32.0), Vector2(48.0, 40.0))
	]
	for index in range(blocks.size()):
		var green := Color(0.18, 0.34, 0.22, 0.96) if index % 3 == 0 else Color(0.30, 0.39, 0.29, 0.94)
		draw_rect(blocks[index], green)

	# Street grid, with a few diagonal connectors.
	var road_color := Color(0.70, 0.73, 0.65, 0.96)
	var road_edge := Color(0.13, 0.18, 0.16, 1.0)
	for x in [-58.0, 0.0, 58.0]:
		draw_line(Vector2(x, -112.0), Vector2(x, 112.0), road_edge, 15.0, true)
		draw_line(Vector2(x, -112.0), Vector2(x, 112.0), road_color, 9.0, true)
	for y in [-54.0, 4.0, 62.0]:
		draw_line(Vector2(-112.0, y), Vector2(112.0, y), road_edge, 15.0, true)
		draw_line(Vector2(-112.0, y), Vector2(112.0, y), road_color, 9.0, true)
	draw_line(Vector2(-100.0, 88.0), Vector2(92.0, -92.0), road_color, 5.0, true)
	draw_line(Vector2(-100.0, -92.0), Vector2(95.0, 84.0), road_color, 5.0, true)
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
