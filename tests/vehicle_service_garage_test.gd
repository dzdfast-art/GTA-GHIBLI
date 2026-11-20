extends SceneTree

const GARAGE_SCENE = preload("res://scenes/world/vehicle_service_garage.tscn")
const CAR_SCRIPT = preload("res://scripts/vehicles/driveable_car.gd")
const WALLET_SCRIPT = preload("res://scripts/systems/player_wallet.gd")


func _initialize() -> void:
	call_deferred("_run_test")


func _run_test() -> void:
	var player := CharacterBody3D.new()
	player.name = "GarageTestPlayer"
	player.add_to_group("player")
	var wallet := Node.new()
	wallet.name = "PlayerWallet"
	wallet.set_script(WALLET_SCRIPT)
	wallet.set("persistence_enabled", false)
	wallet.set("initial_balance", 200)
	player.add_child(wallet)
	root.add_child(player)

	var garage := GARAGE_SCENE.instantiate()
	root.add_child(garage)
	var car := CAR_SCRIPT.new() as CharacterBody3D
	car.name = "GarageTestCar"
	car.position = Vector3(2.0, 0.0, 0.0)
	root.add_child(car)
	await process_frame

	var visual := garage.get_node_or_null("GarageVisual") as MeshInstance3D
	if visual == null or visual.mesh == null or visual.mesh.get_surface_count() < 6:
		_fail("The original workshop model must import all six material surfaces.")
		return
	var area := garage.get_node_or_null("InteractionArea") as Area3D
	if area == null or not area.is_in_group("interaction_areas"):
		_fail("The workshop must register with the shared interaction-area group.")
		return

	garage.set("_player_nearby", true)
	var repairs: Array = []
	garage.repair_completed.connect(func(name: String, restored: float, balance: int): repairs.append([name, restored, balance]))

	car.apply_damage(40.0, &"garage_test")
	if not bool(garage.call("_perform_repair")):
		_fail("A nearby damaged car could not be repaired.")
		return
	if not is_equal_approx(float(car.get("vehicle_health")), 100.0):
		_fail("The full service did not restore vehicle health to 100.")
		return
	if int(wallet.call("get_balance")) != 140:
		_fail("The wallet did not deduct the exact 60-coin repair quote.")
		return
	if repairs.size() != 1 or not is_equal_approx(float(repairs[0][1]), 40.0):
		_fail("The repair-completed signal did not report the restored condition.")
		return

	car.apply_damage(150.0, &"garage_test")
	if bool(garage.call("_perform_repair")):
		_fail("A repair costing more than the player's balance was accepted.")
		return
	if not is_equal_approx(float(car.get("vehicle_health")), 0.0) or int(wallet.call("get_balance")) != 140:
		_fail("An unaffordable service changed the vehicle or wallet.")
		return
	wallet.call("add_money", 10)
	if not bool(garage.call("_perform_repair")) or not car.is_vehicle_operational():
		_fail("A disabled vehicle could not be restored after the player obtained enough cash.")
		return
	if int(wallet.call("get_balance")) != 0:
		_fail("The full-repair quote for a disabled car was not charged accurately.")
		return

	wallet.call("add_money", 50)
	car.apply_damage(20.0, &"garage_test")
	car.set("driver", player)
	car.set("_speed", 2.0)
	if bool(garage.call("_perform_repair")):
		_fail("The garage repaired a vehicle while it was moving.")
		return
	if not is_equal_approx(float(car.get("vehicle_health")), 80.0) or int(wallet.call("get_balance")) != 50:
		_fail("A moving-vehicle rejection changed condition or money.")
		return
	car.set("_speed", 0.0)
	if not bool(garage.call("_perform_repair")):
		_fail("The parked vehicle was not accepted after it stopped.")
		return
	if not is_equal_approx(float(car.get("vehicle_health")), 100.0) or int(wallet.call("get_balance")) != 20:
		_fail("The parked vehicle repair did not restore health and charge the quote.")
		return

	car.apply_damage(10.0, &"garage_test")
	garage.set("_player_nearby", false)
	if bool(garage.call("_perform_repair")):
		_fail("The garage repaired a car when the player was outside the interaction area.")
		return
	if not is_equal_approx(float(car.get("vehicle_health")), 90.0):
		_fail("An out-of-range repair changed vehicle health.")
		return

	print("PASS: workshop import, interaction, vehicle matching, accurate quote, wallet charge, disabled recovery and parked-only safety.")
	quit(0)


func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	quit(1)
