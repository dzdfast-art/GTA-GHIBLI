extends RefCounted
class_name GhibliVehicleRouteFollower

const PROGRESS_SCRIPT = preload("res://scripts/world/route_progress.gd")
var arrival_radius: float = 4.0
var off_route_threshold: float = 12.0
var target_lookahead: float = 8.0

func configure(values: Dictionary) -> bool:
	var arrival := float(values.get("arrival_radius", arrival_radius))
	var off_route := float(values.get("off_route_threshold", off_route_threshold))
	var lookahead := float(values.get("target_lookahead", target_lookahead))
	if arrival <= 0.0 or off_route <= arrival or lookahead <= 0.0:
		return false
	arrival_radius = arrival
	off_route_threshold = off_route
	target_lookahead = lookahead
	return true

func evaluate_vehicle(route: Dictionary, vehicle_position: Vector3) -> Dictionary:
	var progress_model = PROGRESS_SCRIPT.new()
	var progress: Dictionary = progress_model.call("evaluate", route, vehicle_position, arrival_radius)
	if not bool(progress.get("valid", false)):
		return {"valid": false, "status": "unreachable", "reroute_required": false, "arrived": false, "target_position": vehicle_position, "progress": progress}
	var off_route := bool(progress_model.call("is_off_route", progress, off_route_threshold))
	var path: Array = route.get("path", [])
	var target: Vector3 = vehicle_position
	if not path.is_empty():
		target = path[path.size() - 1]
	if not path.is_empty():
		var nearest_index := int(progress.get("nearest_segment", 0))
		var target_index := mini(nearest_index + 1, path.size() - 1)
		var accumulated := 0.0
		while target_index < path.size() - 1 and accumulated < target_lookahead:
			accumulated += path[target_index].distance_to(path[target_index + 1])
			if accumulated < target_lookahead:
				target_index += 1
		target = path[target_index]
	var arrived := bool(progress.get("arrived", false))
	var status := "arrived" if arrived else ("off_route" if off_route else "following")
	return {
		"valid": true,
		"status": status,
		"reroute_required": off_route and not arrived,
		"arrived": arrived,
		"target_position": target,
		"remaining_distance": float(progress.get("remaining_distance", 0.0)),
		"cross_track_distance": float(progress.get("cross_track_distance", INF)),
		"progress": progress
	}
