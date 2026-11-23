extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var m=load("res://scripts/world/world_event_manager.gd").new()
	assert(m.schedule_event("market",10.0,5.0,{"type":"market"}))
	assert(m.get_active_events(12.0).has("market"))
	assert(m.get_active_events(16.0).is_empty())
	assert(m.cancel_event("market"))
	print("PASS: World Event Manager.")
	quit(0)
