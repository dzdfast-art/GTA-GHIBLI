extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var m=load("res://scripts/world/landmark_discovery.gd").new()
	assert(not m.discover("tower", Vector3.ZERO, Vector3(20,0,0), 5.0))
	assert(m.discover("tower", Vector3.ZERO, Vector3(2,0,0), 5.0))
	assert(m.is_discovered("tower") and m.count_discovered()==1)
	assert(not m.discover("tower", Vector3.ZERO, Vector3.ZERO, 5.0))
	
	print("PASS: Landmark Discovery.")
	quit(0)
