extends RefCounted
class_name GhibliVehicleProfile

const PROFILES := {
	"sedan": {"label": "Harbor Sedan", "max_forward_speed": 22.0, "max_reverse_speed": 7.0, "acceleration": 12.0, "braking": 24.0, "steering_rate": 1.8, "mass": 1450.0, "control_scheme": "analog"},
	"sports": {"label": "Coast Sport", "max_forward_speed": 34.0, "max_reverse_speed": 9.0, "acceleration": 18.0, "braking": 30.0, "steering_rate": 1.55, "mass": 1180.0, "control_scheme": "analog"},
	"van": {"label": "Market Van", "max_forward_speed": 18.0, "max_reverse_speed": 6.0, "acceleration": 8.0, "braking": 22.0, "steering_rate": 1.35, "mass": 2200.0, "control_scheme": "buttons"},
	"bike": {"label": "City Bicycle", "max_forward_speed": 12.0, "max_reverse_speed": 2.0, "acceleration": 5.0, "braking": 14.0, "steering_rate": 2.4, "mass": 18.0, "control_scheme": "analog"}
}
const CONTROL_SCHEMES := ["analog", "buttons", "flick"]

static func get_profile(vehicle_class: String) -> Dictionary:
	if not PROFILES.has(vehicle_class):
		return {}
	return PROFILES[vehicle_class].duplicate(true)

static func get_available_classes() -> Array[String]:
	var result: Array[String] = []
	for key in PROFILES:
		result.append(str(key))
	result.sort()
	return result

static func is_valid_control_scheme(scheme: String) -> bool:
	return CONTROL_SCHEMES.has(scheme)

static func apply_control_override(profile: Dictionary, scheme: String) -> Dictionary:
	if profile.is_empty() or not is_valid_control_scheme(scheme):
		return {}
	var result := profile.duplicate(true)
	result["control_scheme"] = scheme
	return result
