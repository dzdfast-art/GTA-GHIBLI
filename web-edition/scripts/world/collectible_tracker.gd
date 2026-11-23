extends RefCounted
class_name GhibliCollectibleTracker
var found: Dictionary={}
var total: int=0
func configure_total(value: int) -> bool:
	if value<0 or not found.is_empty(): return false
	total=value
	return true
func collect(id: String) -> bool:
	if id.is_empty() or found.has(id) or found.size()>=total: return false
	found[id]=true
	return true
func get_progress() -> Dictionary:
	return {"found":found.size(),"total":total,"ratio":1.0 if total==0 else float(found.size())/float(total)}
func is_complete() -> bool:
	return found.size()>=total