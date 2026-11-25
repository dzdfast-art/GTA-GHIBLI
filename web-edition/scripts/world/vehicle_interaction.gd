extends RefCounted
class_name GhibliVehicleInteraction
var occupied_vehicle: String=""
func can_enter(vehicle_id: String, distance: float, max_distance: float, locked: bool) -> bool:
	return vehicle_id!="" and occupied_vehicle=="" and distance>=0.0 and distance<=max_distance and not locked
func enter(vehicle_id: String, distance: float, max_distance: float, locked: bool) -> bool:
	if not can_enter(vehicle_id,distance,max_distance,locked): return false
	occupied_vehicle=vehicle_id
	return true
func exit_vehicle() -> String:
	var previous=occupied_vehicle
	occupied_vehicle=""
	return previous
func is_in_vehicle() -> bool:
	return occupied_vehicle!=""