extends Control

@export_range(20.0, 300.0, 5.0) var world_radius := 85.0
@export_range(45.0, 100.0, 1.0) var radar_radius := 68.0

var _player: Node3D
var _target_position := Vector3.ZERO
var _has_target := false
var _redraw_timer := 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(156.0, 156.0)
	queue_redraw()


func set_player(player: Node3D) -> void:
	_player = player
	queue_redraw()


func set_target_position(position: Vector3, active: bool) -> void:
	_target_position = position
	_has_target = active
	queue_redraw()


func _process(delta: float) -> void:
	_redraw_timer += delta
	if _redraw_timer >= 0.15:
		_redraw_timer = 0.0
		queue_redraw()


func _draw() -> void:
	var center := size * 0.5
	var radius := minf(minf(size.x, size.y) * 0.5 - 5.0, radar_radius)
	if radius <= 8.0:
		return
	draw_circle(center, radius, Color(0.018, 0.026, 0.029, 0.90))
	draw_arc(center, radius, 0.0, TAU, 72, Color(0.89, 0.84, 0.68, 0.95), 2.4, true)
	draw_arc(center, radius * 0.62, 0.0, TAU, 64, Color(0.64, 0.72, 0.69, 0.20), 1.0, true)
	draw_arc(center, radius * 0.30, 0.0, TAU, 64, Color(0.64, 0.72, 0.69, 0.16), 1.0, true)
	draw_line(center + Vector2(-radius * 0.82, 0.0), center + Vector2(radius * 0.82, 0.0), Color(0.72, 0.78, 0.72, 0.24), 1.0)
	draw_line(center + Vector2(0.0, -radius * 0.82), center + Vector2(0.0, radius * 0.82), Color(0.72, 0.78, 0.72, 0.24), 1.0)
	if _player != null and is_instance_valid(_player):
		_draw_world_markers(center, radius)
		if _has_target:
			_draw_target(center, radius)
	_draw_player_arrow(center)


func _draw_world_markers(center: Vector2, radius: float) -> void:
	for group_name in [&"vehicles", &"bicycles", &"world_landmarks", &"building_portals"]:
		for node in get_tree().get_nodes_in_group(group_name):
			var marker := node as Node3D
			if marker == null or not is_instance_valid(marker):
				continue
			if group_name == &"vehicles" and marker.is_in_group("bicycles"):
				continue
			var point := _world_to_radar(marker.global_position, center, radius)
			if point.distance_to(center) <= radius - 5.0:
				var tint := Color(0.90, 0.88, 0.72, 0.95)
				if group_name == &"vehicles":
					tint = Color(0.37, 0.78, 0.96, 0.95)
				elif group_name == &"bicycles":
					tint = Color(0.45, 0.92, 0.57, 0.95)
				draw_circle(point, 3.0, tint)


func _draw_target(center: Vector2, radius: float) -> void:
	var point := _world_to_radar(_target_position, center, radius)
	if point.distance_to(center) > radius - 7.0:
		point = center + (point - center).normalized() * (radius - 9.0)
	draw_circle(point, 6.0, Color(1.0, 0.72, 0.20, 1.0))
	draw_arc(point, 9.0, 0.0, TAU, 36, Color(1.0, 0.86, 0.50, 0.95), 1.6, true)


func _world_to_radar(world_position: Vector3, center: Vector2, radius: float) -> Vector2:
	var offset := world_position - _player.global_position
	var local_offset := _player.global_transform.basis.inverse() * offset
	var scale_value := (radius - 12.0) / maxf(world_radius, 1.0)
	return center + Vector2(local_offset.x, -local_offset.z) * scale_value


func _draw_player_arrow(center: Vector2) -> void:
	var arrow := PackedVector2Array([
		center + Vector2(0.0, -10.0),
		center + Vector2(7.0, 7.0),
		center + Vector2(0.0, 4.0),
		center + Vector2(-7.0, 7.0)
	])
	draw_colored_polygon(arrow, Color(0.98, 0.97, 0.88, 1.0))
	draw_polyline(PackedVector2Array([arrow[0], arrow[1], arrow[2], arrow[3], arrow[0]]), Color(0.06, 0.09, 0.08, 1.0), 1.5, true)
