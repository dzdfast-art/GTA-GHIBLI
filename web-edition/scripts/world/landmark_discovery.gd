extends RefCounted
class_name GhibliLandmarkDiscovery
var discovered: Dictionary = {}
func discover(landmark_id: String, player_position: Vector3, landmark_position: Vector3, radius: float) -> bool:
	if landmark_id.is_empty() or radius <= 0.0 or player_position.distance_to(landmark_position) > radius or discovered.has(landmark_id): return false
	discovered[landmark_id] = {"position": landmark_position, "discovered_at_distance": player_position.distance_to(landmark_position)}
	return true
func is_discovered(landmark_id: String) -> bool:
	return discovered.has(landmark_id)
func count_discovered() -> int:
	return discovered.size()