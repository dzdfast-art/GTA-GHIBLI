extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var script = load("res://scripts/vehicles/vehicle_profile.gd")
	if script == null:
		_fail("Vehicle profile module did not load.")
		return
	var classes: Array = script.get_available_classes()
	for required in ["sedan", "sports", "van", "bike"]:
		if not classes.has(required):
			_fail("Missing vehicle class profile: " + required)
			return
	var sedan: Dictionary = script.get_profile("sedan")
	var sports: Dictionary = script.get_profile("sports")
	if float(sports.get("max_forward_speed", 0.0)) <= float(sedan.get("max_forward_speed", 0.0)):
		_fail("Sports class should have a higher configured top speed than sedan.")
		return
	if script.is_valid_control_scheme("flick") != true or script.is_valid_control_scheme("mouse") != false:
		_fail("Control scheme validation accepted or rejected the wrong scheme.")
		return
	var changed: Dictionary = script.apply_control_override(sedan, "buttons")
	if str(changed.get("control_scheme", "")) != "buttons" or str(sedan.get("control_scheme", "")) != "analog":
		_fail("Control override did not preserve the original profile.")
		return
	if not script.apply_control_override(sedan, "invalid").is_empty():
		_fail("Invalid control override was accepted.")
		return
	print("PASS: sedan, sports, van and bicycle profiles plus analog/buttons/flick controls.")
	quit(0)

func _fail(message: String) -> void:
	push_error(message)
	quit(1)
