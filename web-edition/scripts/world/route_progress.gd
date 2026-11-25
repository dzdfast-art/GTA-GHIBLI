extends RefCounted
class_name GhibliRouteProgress

const DEFAULT_ARRIVAL_RADIUS := 4.0
const DEFAULT_OFF_ROUTE_DISTANCE := 12.0


func evaluate(route: Dictionary, world_position: Vector3, arrival_radius: float = DEFAULT_ARRIVAL_RADIUS) -> Dictionary:
	var path: Array = route.get("path", [])
	if not bool(route.get("reachable", false)) or path.is_empty():
		return _empty_result("unreachable")
	if path.size() == 1:
		var direct_distance: float = world_position.distance_to(path[0])
		return {
			"valid": true,
			"arrived": direct_distance <= arrival_radius,
			"remaining_distance": direct_distance,
			"cross_track_distance": direct_distance,
			"nearest_segment": 0,
			"nearest_position": path[0]
		}

	var nearest_distance := INF
	var nearest_segment := 0
	var nearest_position: Vector3 = path[0]
	var distance_after_nearest := 0.0
	var cumulative_distance := 0.0
	for index in range(path.size() - 1):
		var start: Vector3 = path[index]
		var finish: Vector3 = path[index + 1]
		var segment := finish - start
		var segment_length_squared := segment.length_squared()
		var weight := 0.0
		if segment_length_squared > 0.0001:
			weight = clampf((world_position - start).dot(segment) / segment_length_squared, 0.0, 1.0)
		var projected := start + segment * weight
		var cross_track := world_position.distance_to(projected)
		if cross_track < nearest_distance:
			nearest_distance = cross_track
			nearest_segment = index
			nearest_position = projected
			distance_after_nearest = finish.distance_to(projected)
		cumulative_distance += start.distance_to(finish)

	var remaining := distance_after_nearest
	for index in range(nearest_segment + 1, path.size() - 1):
		remaining += path[index].distance_to(path[index + 1])
	var destination: Vector3 = path[path.size() - 1]
	var destination_distance: float = world_position.distance_to(destination)
	var arrived := destination_distance <= arrival_radius
	return {
		"valid": true,
		"arrived": arrived,
		"remaining_distance": 0.0 if arrived else remaining,
		"cross_track_distance": nearest_distance,
		"nearest_segment": nearest_segment,
		"nearest_position": nearest_position,
		"destination_distance": destination_distance,
		"route_length": cumulative_distance
	}


func is_off_route(progress: Dictionary, threshold: float = DEFAULT_OFF_ROUTE_DISTANCE) -> bool:
	return bool(progress.get("valid", false)) and float(progress.get("cross_track_distance", INF)) > threshold


func _empty_result(status: String) -> Dictionary:
	return {
		"valid": false,
		"status": status,
		"arrived": false,
		"remaining_distance": 0.0,
		"cross_track_distance": INF,
		"nearest_segment": -1,
		"nearest_position": Vector3.ZERO
	}
