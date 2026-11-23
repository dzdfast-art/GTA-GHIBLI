extends RefCounted
class_name GhibliWebAcceptanceGate
var required: Array[String]=["world","player","vehicle","gps","hud","save"]
var results: Dictionary={}
func record(name: String, passed: bool) -> bool:
	if not required.has(name): return false
	results[name]=passed
	return true
func missing() -> Array[String]:
	var result: Array[String]=[]
	for name in required:
		if not results.has(name): result.append(name)
	return result
func failures() -> Array[String]:
	var result: Array[String]=[]
	for name in results:
		if not results[name]: result.append(str(name))
	result.sort()
	return result
func can_release() -> bool:
	return missing().is_empty() and failures().is_empty()