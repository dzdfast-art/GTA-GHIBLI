extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var script = load("res://scripts/world/wanted_level.gd")
	if script == null:
		_fail("Wanted level implementation did not load.")
		return
	var model = script.new()
	assert(model.get_level() == 0)
	assert(model.add_crime(2) == 2)
	assert(model.add_crime(99) == 5)
	assert(model.reduce_by_arrest() == 3)
	assert(model.tick(29.0, true) == 3)
	assert(model.tick(31.0, true) == 1)
	assert(model.tick(60.0, false) == 1)
	assert(model.configure(3))
	assert(model.add_crime(1) == 2)
	print("PASS: Wanted level escalation, arrest reduction and hidden cooldown.")
	quit(0)

func _fail(message: String) -> void:
	push_error(message)
	quit(1)
