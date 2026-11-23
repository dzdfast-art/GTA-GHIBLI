extends RefCounted
class_name GhibliTouchControlZones
var zones: Dictionary={}
func register_zone(id: String, rect: Rect2, action: String) -> bool:
	if id.is_empty() or action.is_empty() or rect.size.x<=0.0 or rect.size.y<=0.0 or zones.has(id): return false
	zones[id]={"rect":rect,"action":action}
	return true
func action_at(point: Vector2) -> String:
	for id in zones:
		if zones[id].rect.has_point(point): return str(zones[id].action)
	return ""
func remove_zone(id: String) -> bool:
	return zones.erase(id)