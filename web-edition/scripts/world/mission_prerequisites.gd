extends RefCounted
class_name GhibliMissionPrerequisites
var requirements: Dictionary={}
var completed: Dictionary={}
func define(mission_id: String, prerequisites: Array[String]) -> bool:
	if mission_id.is_empty() or requirements.has(mission_id) or prerequisites.has(mission_id): return false
	requirements[mission_id]=prerequisites.duplicate()
	return true
func complete(mission_id: String) -> bool:
	if not requirements.has(mission_id): return false
	for dependency in requirements[mission_id]:
		if not completed.has(dependency): return false
	completed[mission_id]=true
	return true
func is_available(mission_id: String) -> bool:
	if not requirements.has(mission_id) or completed.has(mission_id): return false
	for dependency in requirements[mission_id]:
		if not completed.has(dependency): return false
	return true