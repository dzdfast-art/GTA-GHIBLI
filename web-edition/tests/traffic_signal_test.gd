extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var script = load("res://scripts/world/traffic_signal_controller.gd")
	if script == null:
		_fail("Traffic controller controller did not load.")
		return
	var controller = script.new()
	if not controller.call("configure", {"green_duration": 5.0, "amber_duration": 2.0, "red_duration": 4.0}):
		_fail("Valid controller timings were rejected.")
		return
	if str(controller.call("get_phase")) != "green" or not bool(controller.call("can_enter_intersection")):
		_fail("Signal did not start with a permissive green phase.")
		return
	controller.call("advance", 5.0)
	if str(controller.call("get_phase")) != "amber" or bool(controller.call("can_enter_intersection")):
		_fail("Green-to-amber transition or amber stop rule failed.")
		return
	controller.call("advance", 2.0)
	if str(controller.call("get_phase")) != "red" or bool(controller.call("can_enter_intersection")):
		_fail("Amber-to-red transition or red stop rule failed.")
		return
	controller.call("advance", 4.0)
	if str(controller.call("get_phase")) != "green" or not bool(controller.call("can_enter_intersection")):
		_fail("Red-to-green transition failed.")
		return
	if controller.call("configure", {"green_duration": 0.0}):
		_fail("Zero-duration controller phase was accepted.")
		return
	print("PASS: green/amber/red timing cycle and intersection entry gating.")
	quit(0)

func _fail(message: String) -> void:
	push_error(message)
	quit(1)
