extends RefCounted
class_name GhibliGarageUpgradeProgression
var levels: Dictionary={}
func upgrade(vehicle_id: String, current_level: int, max_level: int, cost: int, wallet: int) -> Dictionary:
	if vehicle_id.is_empty() or current_level<0 or max_level<=current_level or cost<0 or wallet<cost: return {"ok":false,"wallet":wallet}
	levels[vehicle_id]=current_level+1
	return {"ok":true,"level":current_level+1,"wallet":wallet-cost}
func get_level(vehicle_id: String) -> int:
	return int(levels.get(vehicle_id,0))