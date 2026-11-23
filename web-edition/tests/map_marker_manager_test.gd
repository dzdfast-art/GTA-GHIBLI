extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var m=load("res://scripts/world/map_marker_manager.gd").new()
		assert(m.add_marker("shop",Vector3.ZERO,"service"))
		assert(m.add_marker("home",Vector3.ONE,"safehouse"))
		assert(m.get_markers("service").size()==1)
		assert(m.remove_marker("shop") and m.get_markers().size()==1)
	print("PASS: Map Marker Manager.")
	quit(0)
