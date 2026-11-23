extends RefCounted
class_name GhibliMissionObjectives
var objectives: Dictionary = {}
func add_objective(objective_id: String, target: int) -> bool:
	if objective_id.is_empty() or target <= 0 or objectives.has(objective_id): return false
	objectives[objective_id]={"target":target,"progress":0}
	return true
func add_progress(objective_id: String, amount: int = 1) -> bool:
	if amount <= 0 or not objectives.has(objective_id): return false
	var o=objectives[objective_id]
	o.progress=mini(int(o.target),int(o.progress)+amount)
	return true
func is_complete(objective_id: String) -> bool:
	return objectives.has(objective_id) and int(objectives[objective_id].progress)>=int(objectives[objective_id].target)