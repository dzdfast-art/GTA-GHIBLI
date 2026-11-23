extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var m=load("res://scripts/world/world_pickup_registry.gd").new()
		assert(m.add_pickup("cash",Vector3.ZERO,100))
		assert(m.collect_near("cash",Vector3(20,0,0),2.0)==-1)
		assert(m.collect_near("cash",Vector3.ONE,2.0)==100)
		assert(m.collect_near("cash",Vector3.ZERO,2.0)==-1)
		assert(m.remaining_count()==0)
	print("PASS: World Pickup Collection.")
	quit(0)
