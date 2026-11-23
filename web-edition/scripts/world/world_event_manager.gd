extends RefCounted
class_name GhibliWorldEventManager
var events: Dictionary = {}
func schedule_event(event_id: String, start_time: float, duration: float, payload: Dictionary = {}) -> bool:
	if event_id.is_empty() or start_time < 0.0 or duration <= 0.0 or events.has(event_id): return false
	events[event_id]={"start":start_time,"end":start_time+duration,"payload":payload.duplicate(true)}
	return true
func get_active_events(time_now: float) -> Array[String]:
	var active: Array[String]=[]
	for key in events:
		if time_now>=events[key].start and time_now<events[key].end: active.append(str(key))
	active.sort()
	return active
func cancel_event(event_id: String) -> bool:
	return events.erase(event_id)