extends RefCounted
class_name GhibliCheckpointSystem
var checkpoints: Array[Vector3]=[]
var current_index: int=0
func set_checkpoints(points: Array) -> bool:
	if points.is_empty(): return false
	checkpoints.clear()
	for p in points:
		if not (p is Vector3): return false
		checkpoints.append(p)
	current_index=0
	return true
func get_current() -> Vector3:
	return checkpoints[current_index] if current_index<checkpoints.size() else Vector3.ZERO
func reach(position: Vector3, radius: float=3.0) -> bool:
	if current_index>=checkpoints.size() or radius<=0.0 or position.distance_to(checkpoints[current_index])>radius: return false
	current_index+=1
	return true
func is_complete() -> bool:
	return not checkpoints.is_empty() and current_index>=checkpoints.size()