extends RefCounted
class_name GhibliWorldPickupRegistry
var pickups: Dictionary={}
func add_pickup(id: String, position: Vector3, value: int) -> bool:
	if id.is_empty() or value<0 or pickups.has(id): return false
	pickups[id]={"position":position,"value":value,"collected":false}
	return true
func collect_near(id: String, player: Vector3, radius: float) -> int:
	if not pickups.has(id) or pickups[id].collected or radius<=0.0: return -1
	if player.distance_to(pickups[id].position)>radius: return -1
	pickups[id].collected=true
	return int(pickups[id].value)
func remaining_count() -> int:
	var n=0
	for p in pickups.values():
		if not p.collected: n+=1
	return n