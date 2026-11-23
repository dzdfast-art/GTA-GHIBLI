extends RefCounted
class_name GhibliMissionRewards
var settled: Dictionary={}
func settle(mission_id: String, cash: int, respect: int) -> Dictionary:
	if mission_id.is_empty() or cash<0 or respect<0 or settled.has(mission_id): return {"ok":false}
	var result={"cash":cash,"respect":respect}
	settled[mission_id]=result
	return {"ok":true,"reward":result.duplicate(true)}
func is_settled(mission_id: String) -> bool:
	return settled.has(mission_id)
func get_reward(mission_id: String) -> Dictionary:
	return settled.get(mission_id,{}).duplicate(true)