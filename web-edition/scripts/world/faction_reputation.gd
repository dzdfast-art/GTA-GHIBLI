extends RefCounted
class_name GhibliFactionReputation
var reputation: Dictionary={}
func adjust(faction: String, delta: int) -> int:
	if faction.is_empty(): return 0
	reputation[faction]=clampi(int(reputation.get(faction,0))+delta,-100,100)
	return reputation[faction]
func get_standing(faction: String) -> String:
	var v=int(reputation.get(faction,0))
	if v>=50: return "ally"
	if v<=-50: return "enemy"
	return "neutral"
func get_score(faction: String) -> int:
	return int(reputation.get(faction,0))