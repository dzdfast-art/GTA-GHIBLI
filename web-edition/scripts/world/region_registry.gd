extends RefCounted
class_name GhibliRegionRegistry
var regions: Dictionary = {}
func register_region(region_id: String, bounds: Rect2, label: String) -> bool:
	if region_id.is_empty() or label.is_empty() or bounds.size.x <= 0.0 or bounds.size.y <= 0.0 or regions.has(region_id): return false
	regions[region_id] = {"bounds": bounds, "label": label}
	return true
func find_region(position: Vector2) -> String:
	for key in regions:
		if regions[key].bounds.has_point(position): return str(key)
	return ""
func get_region(region_id: String) -> Dictionary:
	return regions.get(region_id, {}).duplicate(true)