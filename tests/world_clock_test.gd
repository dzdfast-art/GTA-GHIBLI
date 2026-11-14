extends SceneTree

const CLOCK_SCRIPT = preload("res://scripts/world/world_clock.gd")

func _initialize() -> void:
	call_deferred("_run_test")

func _run_test() -> void:
	var world := Node3D.new()
	root.add_child(world)
	var sun := DirectionalLight3D.new()
	sun.name = "Sun"
	world.add_child(sun)
	var clock := Node.new()
	clock.set_script(CLOCK_SCRIPT)
	clock.set("seconds_per_game_day", 1440.0)
	world.add_child(clock)
	clock.call("set_time", 6, 30)
	if int(clock.call("get_hour")) != 6 or int(clock.call("get_minute")) != 30:
		_fail("Clock did not set the requested time.")
		return
	if str(clock.call("get_phase")) != "dawn":
		_fail("Dawn phase was not identified.")
		return
	clock.call("set_time", 12, 0)
	if str(clock.call("get_phase")) != "day":
		_fail("Day phase was not identified.")
		return
	clock.call("set_time", 18, 0)
	if str(clock.call("get_phase")) != "dusk":
		_fail("Dusk phase was not identified.")
		return
	clock.call("set_time", 23, 0)
	if str(clock.call("get_phase")) != "night":
		_fail("Night phase was not identified.")
		return
	if float(sun.light_energy) <= 0.0:
		_fail("Sunlight was not updated.")
		return
	print("PASS: Shared world clock, day phases and sun updates.")
	quit(0)

func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	quit(1)
