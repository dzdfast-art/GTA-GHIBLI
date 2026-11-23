extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var m=load("res://scripts/world/side_activity_registry.gd").new()
	assert(m.register_activity("race","Street Race",250,Vector3.ZERO))
	assert(m.complete_activity("race")==250)
	assert(m.complete_activity("race")==-1)
	print("PASS: Side Activity Registry.")
	quit(0)
