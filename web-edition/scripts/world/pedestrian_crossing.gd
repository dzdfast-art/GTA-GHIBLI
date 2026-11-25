extends RefCounted
class_name GhibliPedestrianCrossing
var walk_enabled: bool = false
var waiting: int = 0
func set_signal_allows_walk(allowed: bool) -> void:
	walk_enabled=allowed
func register_waiting_pedestrian() -> int:
	waiting += 1
	return waiting
func release_pedestrians() -> int:
	if not walk_enabled: return 0
	var released=waiting
	waiting=0
	return released
func get_waiting_count() -> int:
	return waiting