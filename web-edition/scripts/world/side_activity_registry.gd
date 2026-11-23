extends RefCounted
class_name GhibliSideActivityRegistry
var activities: Dictionary = {}
func register_activity(activity_id: String, title: String, reward: int, location: Vector3) -> bool:
	if activity_id.is_empty() or title.is_empty() or reward < 0 or activities.has(activity_id): return false
	activities[activity_id]={"title":title,"reward":reward,"location":location,"completed":false}
	return true
func complete_activity(activity_id: String) -> int:
	if not activities.has(activity_id) or activities[activity_id].completed: return -1
	activities[activity_id].completed=true
	return int(activities[activity_id].reward)
func get_activity(activity_id: String) -> Dictionary:
	return activities.get(activity_id,{}).duplicate(true)