extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var m=load("res://scripts/world/police_search_grid.gd").new()
		assert(m.build(Vector3.ZERO,10.0,5.0))
		assert(m.get_cells().size()>1)
		assert(m.nearest_cell(Vector3(4,0,4))==Vector3(5,0,5))
		assert(not m.build(Vector3.ZERO,0.0,5.0))
	print("PASS: Police Search Area Planner.")
	quit(0)
