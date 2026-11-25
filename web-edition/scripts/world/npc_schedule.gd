extends RefCounted
class_name GhibliNpcSchedule
var entries: Array[Dictionary] = []
func add_entry(start_minute: int, end_minute: int, activity: String, location: String) -> bool:
	if start_minute < 0 or end_minute > 1440 or start_minute >= end_minute or activity.is_empty() or location.is_empty(): return false
	for e in entries:
		if start_minute < int(e.end) and end_minute > int(e.start): return false
	entries.append({"start":start_minute,"end":end_minute,"activity":activity,"location":location})
	entries.sort_custom(func(a,b): return int(a.start)<int(b.start))
	return true
func get_activity(minute_of_day: int) -> Dictionary:
	for e in entries:
		if minute_of_day >= int(e.start) and minute_of_day < int(e.end): return e.duplicate(true)
	return {"activity":"idle","location":"current"}