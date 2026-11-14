extends SceneTree

const WEATHER_SCRIPT = preload("res://scripts/world/world_weather.gd")

func _initialize() -> void:
	call_deferred("_run_test")

func _run_test() -> void:
	var world := Node3D.new()
	root.add_child(world)
	var weather := Node3D.new()
	weather.set_script(WEATHER_SCRIPT)
	world.add_child(weather)
	if str(weather.call("get_weather")) != "clear":
		_fail("Weather did not begin in clear state.")
		return
	if not weather.call("set_weather", "rain"):
		_fail("Rain weather was rejected.")
		return
	if str(weather.call("get_weather")) != "rain":
		_fail("Rain weather state was not applied.")
		return
	var particles := weather.get_node("WeatherRainParticles") as GPUParticles3D
	if not particles.emitting or particles.amount != 110:
		_fail("Rain particle effect did not activate at the mobile preset.")
		return
	weather.call("set_weather", "storm")
	if particles.amount != 190 or not particles.emitting:
		_fail("Storm particle intensity was not increased.")
		return
	weather.call("set_weather", "clear")
	if particles.emitting:
		_fail("Rain particles continued after weather cleared.")
		return
	if weather.call("set_weather", "snow"):
		_fail("Unsupported weather value was accepted.")
		return
	print("PASS: Clear, rain and storm transitions with bounded particle counts.")
	quit(0)

func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	quit(1)
