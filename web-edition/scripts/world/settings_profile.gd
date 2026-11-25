extends RefCounted
class_name GhibliSettingsProfile
var values: Dictionary={"camera_sensitivity":1.0,"music_volume":0.8,"sfx_volume":0.8,"language":"en"}
func set_value(key: String, value: Variant) -> bool:
	if not values.has(key): return false
	if key in ["camera_sensitivity","music_volume","sfx_volume"]:
		if not (value is float or value is int): return false
		values[key]=clampf(float(value),0.0,2.0 if key=="camera_sensitivity" else 1.0)
	elif key=="language":
		if not ["en","ar"].has(str(value)): return false
		values[key]=str(value)
	return true
func get_value(key: String) -> Variant:
	return values.get(key)
func snapshot() -> Dictionary:
	return values.duplicate(true)