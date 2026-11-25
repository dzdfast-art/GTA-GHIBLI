extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var m=load("res://scripts/world/mission_objectives.gd").new()
	assert(m.add_objective("deliver",3))
	assert(m.add_progress("deliver",2) and not m.is_complete("deliver"))
	assert(m.add_progress("deliver",5) and m.is_complete("deliver"))
	assert(not m.add_progress("missing"))
	print("PASS: Mission Objective Tracker.")
	quit(0)
