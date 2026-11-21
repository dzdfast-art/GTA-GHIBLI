extends SceneTree

const CAR_SCRIPT = preload("res://scripts/vehicles/driveable_car.gd")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var car := CAR_SCRIPT.new() as CharacterBody3D
	root.add_child(car)
	await process_frame

	if not car.is_vehicle_operational():
		_fail("A new vehicle should be operational.")
		return
	if car.get_node_or_null("FrontLeftWheel") == null or car.get_node_or_null("RearRightWheel") == null:
		_fail("The vehicle must create all four wheel visuals.")
		return
	if car.get_node_or_null("LeftBrakeLight") == null or car.get_node_or_null("RightBrakeLight") == null:
		_fail("The vehicle must create paired brake lights.")
		return
	if car._wheel_nodes.size() != 4:
		_fail("All four wheel meshes must be registered for rotation.")
		return

	if not car.apply_damage(35.0, &"regression_test"):
		_fail("Positive damage should reduce vehicle condition.")
		return
	if not is_equal_approx(car.get_vehicle_health_ratio(), 0.65):
		_fail("Vehicle health ratio should reflect received damage.")
		return
	if not car.repair_vehicle(20.0):
		_fail("A damaged vehicle should accept partial repairs.")
		return
	if not is_equal_approx(car.get_vehicle_health_ratio(), 0.85):
		_fail("Partial repairs should restore the correct condition.")
		return
	if not car.repair_vehicle():
		_fail("A damaged vehicle should accept a full repair.")
		return
	if not is_equal_approx(car.get_vehicle_health_ratio(), 1.0):
		_fail("Full repair should restore the vehicle to maximum health.")
		return

	if not car.apply_damage(150.0, &"regression_test"):
		_fail("Fatal damage should disable the vehicle.")
		return
	if car.is_vehicle_operational():
		_fail("A vehicle at zero condition must not be drivable.")
		return
	if car.repair_vehicle() == false or not car.is_vehicle_operational():
		_fail("A fully disabled vehicle should become operational after repair.")
		return

	var snapshot: Dictionary = car.get_vehicle_save_snapshot()
	car.apply_damage(20.0)
	if not car.apply_vehicle_save_snapshot(snapshot):
		_fail("Vehicle condition snapshot should restore.")
		return
	if not is_equal_approx(car.get_vehicle_health_ratio(), 1.0):
		_fail("Restoring a vehicle snapshot should restore condition.")
		return

	print("PASS: vehicle health, collision-damage API, repair, disabled state, wheels, brake lights and condition snapshot.")
	car.queue_free()
	quit(0)


func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	quit(1)
