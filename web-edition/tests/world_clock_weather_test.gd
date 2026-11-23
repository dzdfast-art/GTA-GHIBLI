extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var m=load("res://scripts/world/world_clock_weather.gd").new()
		assert(m.get_time_string()=="08:00" and m.get_period()=="morning")
		m.advance_minutes(900)
		assert(m.get_period()=="evening")
		assert(m.set_weather("rain") and not m.set_weather("snow"))
	print("PASS: World Clock and Weather State.")
	quit(0)
