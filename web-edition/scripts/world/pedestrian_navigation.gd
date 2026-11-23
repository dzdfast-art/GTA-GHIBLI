extends RefCounted
class_name GhibliPedestrianNavigation
var waypoints: Array[Vector3] = []
var index: int = 0
func set_route(points: Array) -> bool:
	if points.size() < 2: return false
	waypoints.clear()
	for p in points:
		if not (p is Vector3): return false
		waypoints.append(p)
	index=1
	return true
func get_target() -> Vector3:
	return waypoints[index] if index < waypoints.size() else Vector3.ZERO
func advance_if_reached(position: Vector3, radius: float = 1.0) -> bool:
	if index >= waypoints.size() or radius <= 0.0 or position.distance_to(waypoints[index]) > radius: return false
	index += 1
	return true
func is_complete() -> bool:
	return not waypoints.is_empty() and index >= waypoints.size()