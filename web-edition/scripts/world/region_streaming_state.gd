extends RefCounted
class_name GhibliRegionStreamingState
var states: Dictionary={}
func request_load(region_id: String) -> bool:
	if region_id.is_empty() or states.get(region_id,"unloaded") in ["loading", "loaded"]: return false
	states[region_id]="loading"
	return true
func mark_loaded(region_id: String) -> bool:
	if states.get(region_id,"")!="loading": return false
	states[region_id]="loaded"
	return true
func unload(region_id: String) -> bool:
	if states.get(region_id,"")!="loaded": return false
	states[region_id]="unloaded"
	return true
func get_state(region_id: String) -> String:
	return str(states.get(region_id,"unloaded"))