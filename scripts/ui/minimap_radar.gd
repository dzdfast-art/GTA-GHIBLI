extends Control

@export_range(20.0, 300.0, 5.0) var world_radius := 85.0
@export_range(45.0, 100.0, 1.0) var radar_radius := 82.0

var _player: Node3D
var _target_position := Vector3.ZERO
var _has_target := false
var _redraw_timer := 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(180.0, 180.0)
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
		_draw_world_roads(center, radius)
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



func _draw_world_roads(center: Vector2, radius: float) -> void:
	for candidate in get_tree().get_nodes_in_group("radar_roads"):
		var road := candidate as MeshInstance3D
		if road == null or not is_instance_valid(road):
			continue
		var box := road.mesh as BoxMesh
		if box == null:
			continue
		var local_axis: Vector3
		var road_length: float
		var road_width: float
		if box.size.x >= box.size.z:
			local_axis = road.global_basis.x
			road_length = box.size.x
			road_width = box.size.z
		else:
			local_axis = road.global_basis.z
			road_length = box.size.z
			road_width = box.size.x
		var half_length := local_axis.normalized() * road_length * 0.5
		var world_start := road.global_position - half_length
		var world_end := road.global_position + half_length
		var point_start := _world_to_radar(world_start, center, radius)
		var point_end := _world_to_radar(world_end, center, radius)
		var line_width := clampf(road_width * (radius - 12.0) / maxf(world_radius, 1.0), 1.5, 4.5)
		_draw_clipped_road(point_start, point_end, center, radius - 3.0, line_width)


func _draw_clipped_road(start: Vector2, finish: Vector2, center: Vector2,
		clip_radius: float, line_width: float) -> void:
	var delta := finish - start
	var relative_start := start - center
	var a := delta.dot(delta)
	if a <= 0.0001:
		return
	var b := 2.0 * relative_start.dot(delta)
	var c := relative_start.dot(relative_start) - clip_radius * clip_radius
	var discriminant := b * b - 4.0 * a * c
	if discriminant < 0.0:
		if relative_start.length() <= clip_radius and (finish - center).length() <= clip_radius:
			draw_line(start, finish, Color(0.72, 0.79, 0.79, 0.58), line_width, true)
		return
	var root := sqrt(discriminant)
	var entry := (-b - root) / (2.0 * a)
	var exit := (-b + root) / (2.0 * a)
	var from_t := maxf(0.0, entry)
	var to_t := minf(1.0, exit)
	if from_t > to_t:
		return
	draw_line(start + delta * from_t, start + delta * to_t,
		Color(0.72, 0.79, 0.79, 0.58), line_width, true)
