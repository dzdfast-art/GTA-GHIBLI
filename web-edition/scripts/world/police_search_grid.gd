extends RefCounted
class_name GhibliPoliceSearchGrid
var cells: Array[Vector3]=[]
func build(center: Vector3, radius: float, spacing: float) -> bool:
	if radius<=0.0 or spacing<=0.0: return false
	cells.clear()
	var steps=int(ceil(radius/spacing))
	for x in range(-steps,steps+1):
		for z in range(-steps,steps+1):
			var p=center+Vector3(x*spacing,0,z*spacing)
			if Vector2(p.x-center.x,p.z-center.z).length()<=radius: cells.append(p)
	return not cells.is_empty()
func get_cells() -> Array[Vector3]:
	return cells.duplicate()
func nearest_cell(position: Vector3) -> Vector3:
	var best=Vector3.ZERO
	var distance=INF
	for p in cells:
		var d=position.distance_squared_to(p)
		if d<distance: distance=d; best=p
	return best