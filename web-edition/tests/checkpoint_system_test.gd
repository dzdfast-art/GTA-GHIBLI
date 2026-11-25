extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var m=load("res://scripts/world/checkpoint_system.gd").new()
	assert(m.set_checkpoints([Vector3.ZERO,Vector3(5,0,0)]))
	assert(m.reach(Vector3.ZERO) and m.get_current()==Vector3(5,0,0))
	assert(m.reach(Vector3(5,0,0)) and m.is_complete())
	print("PASS: Mission Checkpoint System.")
	quit(0)
