extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var script = load("res://scripts/vehicles/vehicle_damage_model.gd")
	if script == null:
		_fail("Vehicle damage model did not load.")
		return
	var model = script.new()
	if model.call("apply_impact", 3.0).get("damage", -1.0) != 0.0:
		_fail("Sub-threshold impact incorrectly caused damage.")
		return
	var impact: Dictionary = model.call("apply_impact", 10.0)
	if absf(float(impact.get("damage", 0.0)) - 15.0) > 0.01:
		_fail("Impact damage did not use excess speed and configured rate.")
		return
	if absf(float(model.call("repair", 5.0)) - 5.0) > 0.01:
		_fail("Vehicle repair did not restore durability.")
		return
	model.call("apply_impact", 100.0)
	if not bool(model.call("is_disabled")) or float(model.call("get_condition_ratio")) != 0.0:
		_fail("Severe impact did not disable the vehicle at zero durability.")
		return
	model.call("repair", 25.0)
	if bool(model.call("is_disabled")):
		_fail("Repair did not restore a disabled vehicle.")
		return
	if bool(model.call("apply_impact", -1.0).get("valid", true)):
		_fail("Negative impact speed was accepted.")
		return
	print("PASS: collision threshold, damage scaling, repair and disabled state.")
	quit(0)

func _fail(message: String) -> void:
	push_error(message)
	quit(1)
