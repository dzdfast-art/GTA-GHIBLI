extends RefCounted
class_name GhibliParkingRegistry
var spaces: Dictionary={}
func add_space(space_id: String, position: Vector3) -> bool:
	if space_id.is_empty() or spaces.has(space_id): return false
	spaces[space_id]={"position":position,"vehicle":""}
	return true
func reserve(space_id: String, vehicle_id: String) -> bool:
	if not spaces.has(space_id) or vehicle_id.is_empty() or spaces[space_id].vehicle!="": return false
	spaces[space_id].vehicle=vehicle_id
	return true
func release(space_id: String, vehicle_id: String) -> bool:
	if not spaces.has(space_id) or spaces[space_id].vehicle!=vehicle_id: return false
	spaces[space_id].vehicle=""
	return true
func available_count() -> int:
	var count=0
	for s in spaces.values():
		if s.vehicle=="": count+=1
	return count