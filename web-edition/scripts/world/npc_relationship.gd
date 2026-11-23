extends RefCounted
class_name GhibliNpcRelationship
var scores: Dictionary = {}
func adjust(npc_id: String, delta: int) -> int:
	if npc_id.is_empty(): return 0
	scores[npc_id] = clampi(int(scores.get(npc_id,0))+delta,-100,100)
	return scores[npc_id]
func get_tier(npc_id: String) -> String:
	var v=int(scores.get(npc_id,0))
	if v >= 60: return "friend"
	if v <= -60: return "hostile"
	return "neutral"
func get_score(npc_id: String) -> int:
	return int(scores.get(npc_id,0))