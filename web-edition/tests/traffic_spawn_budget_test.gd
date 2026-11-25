extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var script = load("res://scripts/world/traffic_spawn_budget.gd")
	if script == null:
		_fail("Traffic spawn budget implementation did not load.")
		return
	var model = script.new()
	assert(model.get_available_slots() == 24)
	assert(model.try_spawn())
	assert(model.try_spawn())
	assert(model.active_count == 2)
	assert(model.configure(2))
	assert(not model.try_spawn())
	assert(model.get_available_slots() == 0)
	assert(model.despawn(1) == 1)
	assert(model.try_spawn())
	assert(model.configure(0))
	assert(model.get_available_slots() == 0)
	assert(not model.configure(-1))
	print("PASS: Traffic spawn cap, slots, despawn and invalid limits.")
	quit(0)

func _fail(message: String) -> void:
	push_error(message)
	quit(1)
