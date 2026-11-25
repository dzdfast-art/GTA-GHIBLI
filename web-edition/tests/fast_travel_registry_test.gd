extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var m=load("res://scripts/world/fast_travel_registry.gd").new()
	assert(m.unlock("station",Vector3(10,0,10)))
	assert(m.travel("station",100,25).wallet==75)
	assert(not m.travel("station",10,25).ok)
	assert(not m.is_unlocked("unknown"))
	print("PASS: Fast Travel Unlocks.")
	quit(0)
