extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var m=load("res://scripts/world/vehicle_interaction.gd").new()
		assert(not m.enter("car",5.0,3.0,false))
		assert(m.enter("car",2.0,3.0,false) and m.is_in_vehicle())
		assert(not m.enter("van",1.0,3.0,false))
		assert(m.exit_vehicle()=="car" and not m.is_in_vehicle())
	print("PASS: Vehicle Entry and Exit Rules.")
	quit(0)
