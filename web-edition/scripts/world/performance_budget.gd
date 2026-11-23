extends RefCounted
class_name GhibliPerformanceBudget
var limits: Dictionary={"npcs":40,"vehicles":24,"effects":30}
var active: Dictionary={"npcs":0,"vehicles":0,"effects":0}
func configure(category: String, limit: int) -> bool:
	if not limits.has(category) or limit<0: return false
	limits[category]=limit
	active[category]=mini(int(active.get(category,0)),limit)
	return true
func acquire(category: String, count: int=1) -> bool:
	if not limits.has(category) or count<=0 or int(active[category])+count>int(limits[category]): return false
	active[category]=int(active[category])+count
	return true
func release(category: String, count: int=1) -> int:
	if not active.has(category): return 0
	active[category]=maxi(0,int(active[category])-maxi(0,count))
	return active[category]
func available(category: String) -> int:
	return maxi(0,int(limits.get(category,0))-int(active.get(category,0)))