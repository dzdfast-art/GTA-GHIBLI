extends RefCounted
class_name GhibliMapMarkerManager
var markers: Dictionary={}
func add_marker(id: String, position: Vector3, category: String) -> bool:
	if id.is_empty() or category.is_empty() or markers.has(id): return false
	markers[id]={"position":position,"category":category}
	return true
func remove_marker(id: String) -> bool:
	return markers.erase(id)
func get_markers(category: String="") -> Array[Dictionary]:
	var result: Array[Dictionary]=[]
	for id in markers:
		if category=="" or markers[id].category==category:
			result.append({"id":id,"position":markers[id].position,"category":markers[id].category})
	return result