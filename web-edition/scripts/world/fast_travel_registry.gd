extends RefCounted
class_name GhibliFastTravelRegistry
var destinations: Dictionary={}
func unlock(id: String, position: Vector3) -> bool:
	if id.is_empty() or destinations.has(id): return false
	destinations[id]=position
	return true
func is_unlocked(id: String) -> bool:
	return destinations.has(id)
func travel(id: String, wallet: int, fee: int) -> Dictionary:
	if not destinations.has(id) or fee<0 or wallet<fee: return {"ok":false,"wallet":wallet}
	return {"ok":true,"wallet":wallet-fee,"position":destinations[id]}
func list_destinations() -> Array[String]:
	var result: Array[String]=[]
	for id in destinations: result.append(str(id))
	result.sort()
	return result