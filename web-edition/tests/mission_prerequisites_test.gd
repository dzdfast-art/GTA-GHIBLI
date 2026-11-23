extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var m=load("res://scripts/world/mission_prerequisites.gd").new()
	assert(m.define("a",[]))
	assert(m.define("b",["a"]))
	assert(not m.is_available("b"))
	assert(m.complete("a") and m.is_available("b"))
	assert(m.complete("b") and not m.is_available("b"))
	print("PASS: Mission Prerequisite Graph.")
	quit(0)
