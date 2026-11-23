extends RefCounted
class_name GhibliVehicleCustomization
var paint: Color=Color.WHITE
var wheel_style: String="standard"
var plate_text: String="GHIBLI"
func set_paint(value: Color) -> void:
	paint=value
func set_wheel_style(value: String) -> bool:
	if not ["standard","sport","offroad"].has(value): return false
	wheel_style=value
	return true
func set_plate(value: String) -> bool:
	var clean=value.strip_edges()
	if clean.is_empty() or clean.length()>10: return false
	plate_text=clean
	return true
func snapshot() -> Dictionary:
	return {"paint":paint,"wheel_style":wheel_style,"plate_text":plate_text}