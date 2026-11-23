extends RefCounted
class_name GhibliVehicleGarage
var stored: Dictionary={}
func store(vehicle_id: String, profile: Dictionary) -> bool:
	if vehicle_id.is_empty() or profile.is_empty() or stored.has(vehicle_id): return false
	stored[vehicle_id]=profile.duplicate(true)
	return true
func retrieve(vehicle_id: String) -> Dictionary:
	return stored.get(vehicle_id,{}).duplicate(true)
func remove(vehicle_id: String) -> bool:
	return stored.erase(vehicle_id)
func count() -> int:
	return stored.size()