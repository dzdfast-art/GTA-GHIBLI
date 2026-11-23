extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var m=load("res://scripts/world/parking_registry.gd").new()
		assert(m.add_space("P1",Vector3.ZERO))
		assert(m.reserve("P1","car") and not m.reserve("P1","van"))
		assert(m.available_count()==0)
		assert(m.release("P1","car") and m.available_count()==1)
	print("PASS: Parking Space Reservation.")
	quit(0)
