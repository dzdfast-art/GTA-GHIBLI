extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var script = load("res://scripts/world/police_pursuit.gd")
	if script == null:
		_fail("Police pursuit implementation did not load.")
		return
	var model = script.new()
	assert(model.state == "idle")
	model.start(Vector3(1.0, 0.0, 2.0))
	assert(model.state == "pursuing")
	assert(model.target == Vector3(1.0, 0.0, 2.0))
	assert(model.update_sighting(Vector3(3.0, 0.0, 4.0), true, 1.0) == "pursuing")
	assert(model.target == Vector3(3.0, 0.0, 4.0))
	assert(model.update_sighting(Vector3.ZERO, false, 10.0) == "searching")
	assert(model.update_sighting(Vector3.ZERO, false, 10.0) == "lost")
	assert(model.update_sighting(Vector3.ZERO, true, 1.0) == "lost")
	model.reset()
	assert(model.state == "idle" and model.search_time == 0.0)
	print("PASS: Police pursuit, sighting loss, timeout and reset.")
	quit(0)

func _fail(message: String) -> void:
	push_error(message)
	quit(1)
