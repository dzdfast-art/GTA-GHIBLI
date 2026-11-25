extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var script = load("res://scripts/vehicles/vehicle_dynamics.gd")
	if script == null:
		_fail("Vehicle dynamics module did not load.")
		return
	var model = script.new()
	if not model.call("configure", {"max_forward_speed": 20.0, "max_reverse_speed": 6.0, "acceleration": 10.0, "braking": 20.0, "rolling_resistance": 2.0}):
		_fail("Valid vehicle dynamics profile was rejected.")
		return
	var accelerated := float(model.call("step_speed", 0.0, 1.0, false, 0.5))
	if absf(accelerated - 5.0) > 0.01:
		_fail("Throttle did not apply the configured acceleration.")
		return
	var braked := float(model.call("step_speed", accelerated, 1.0, true, 0.1))
	if absf(braked - 3.0) > 0.01:
		_fail("Brake did not decelerate toward zero.")
		return
	var reverse := float(model.call("step_speed", 0.0, -1.0, false, 2.0))
	if reverse > 0.0 or reverse < -6.0:
		_fail("Reverse speed exceeded its configured limit.")
		return
	if model.call("configure", {"max_forward_speed": -1.0}):
		_fail("Invalid negative speed limit was accepted.")
		return
	print("PASS: vehicle acceleration, braking, reverse cap and profile validation.")
	quit(0)

func _fail(message: String) -> void:
	push_error(message)
	quit(1)
