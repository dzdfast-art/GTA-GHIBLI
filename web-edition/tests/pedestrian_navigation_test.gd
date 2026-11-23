extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var m=load("res://scripts/world/pedestrian_navigation.gd").new()
	assert(m.set_route([Vector3.ZERO,Vector3(5,0,0),Vector3(10,0,0)]))
	assert(m.get_target()==Vector3(5,0,0))
	assert(not m.advance_if_reached(Vector3.ZERO,1.0))
	assert(m.advance_if_reached(Vector3(5,0,0),1.0))
	assert(m.advance_if_reached(Vector3(10,0,0),1.0) and m.is_complete())
	
	print("PASS: Pedestrian Navigation.")
	quit(0)
