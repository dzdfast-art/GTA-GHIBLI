extends SceneTree


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var manager_script := load("res://scripts/systems/mission_manager.gd")
	if manager_script == null:
		_fail("Mission manager script could not be loaded.")
		return
	var manager: Node = manager_script.new()
	root.add_child(manager)
	await process_frame
	manager.call("reset_progress")

	var completed_steps: Array[String] = []
	manager.mission_step_completed.connect(
		func(mission_id: String, objective_id: String) -> void:
			completed_steps.append("%s:%s" % [mission_id, objective_id])
	)

	manager.call("handle_interaction", "nora")
	if int(manager.get("mission_stage")) != 0:
		_fail("Nora incorrectly bypassed the Claire prerequisite for Mission 001.")
		return
	manager.call("handle_interaction", "claire")
	if int(manager.get("mission_stage")) != 1:
		_fail("Claire did not advance Mission 001 to its second stage.")
		return
	manager.call("handle_interaction", "nora")
	if int(manager.get("mission_stage")) != 2 or int(manager.call("get_wallet")) != 600:
		_fail("Mission 001 did not complete with the expected $250 reward.")
		return
	manager.call("handle_interaction", "nora")
	if int(manager.get("mission_stage")) != 3:
		_fail("Nora did not activate Mission 002 after Mission 001.")
		return
	manager.call("handle_interaction", "market_notice")
	if int(manager.get("mission_stage")) != 4:
		_fail("The market noticeboard did not advance Mission 002.")
		return
	manager.call("handle_interaction", "nora")
	if int(manager.get("mission_stage")) != 5 or int(manager.call("get_wallet")) != 900:
		_fail("Mission 002 did not complete with the expected $300 reward.")
		return
	manager.call("handle_interaction", "nora")
	if int(manager.get("mission_stage")) != 6:
		_fail("Nora did not unlock Mission 003 after Mission 002.")
		return
	var shop: RefCounted = load("res://scripts/world/shop_inventory.gd").new()
	if not bool(shop.call("add_item", "bottled_water", 12, 8)):
		_fail("The Mission 003 test shop could not create its bottled-water stock.")
		return
	manager.call("handle_interaction", "market_enter")
	manager.call("handle_interaction", "market_shop_purchase")
	if int(manager.get("mission_stage")) != 6:
		_fail("A direct purchase interaction bypassed the real shop transaction.")
		return
	if bool(manager.call("record_market_purchase", "bottled_water", 0)):
		_fail("Mission 003 accepted a purchase without owned bottled water.")
		return
	var purchase: Dictionary = shop.call("purchase", "bottled_water", int(manager.call("get_wallet")), 1)
	if not bool(purchase.get("ok", false)):
		_fail("The real shop transaction could not buy the mission water.")
		return
	if not bool(manager.call("set_wallet_balance", int(purchase.get("wallet", -1)), "test_shop_purchase")):
		_fail("The real shop purchase could not update the wallet.")
		return
	if not bool(manager.call("record_market_purchase", "bottled_water", int(shop.call("get_quantity", "bottled_water")))):
		_fail("Mission 003 did not accept the purchased water inventory.")
		return
	if int(manager.get("mission_stage")) != 7:
		_fail("The verified Mission 003 purchase step did not advance the campaign.")
		return
	if not bool(shop.call("consume", "bottled_water", 1)) or int(shop.call("get_quantity", "bottled_water")) != 0:
		_fail("Delivering the mission water did not consume the carried item.")
		return
	manager.call("handle_interaction", "claire")
	if int(manager.get("mission_stage")) != 8 or int(manager.call("get_wallet")) != 1038:
		_fail("Mission 003 did not complete with the expected $150 reward.")
		return
	manager.call("handle_interaction", "claire")
	manager.call("handle_interaction", "nora")
	if int(manager.call("get_wallet")) != 1038:
		_fail("A repeated post-completion interaction duplicated a campaign reward.")
		return

	var expected_steps: Array[String] = [
		"mission_001:speak_to_claire",
		"mission_001:meet_nora",
		"mission_002:start_at_nora",
		"mission_002:inspect_noticeboard",
		"mission_002:return_to_nora",
		"mission_003:start_at_nora",
		"mission_003:enter_market",
		"mission_003:buy_water",
		"mission_003:return_to_claire"
	]
	if completed_steps != expected_steps:
		_fail("Mission step completion signals were incomplete or out of order: " + str(completed_steps))
		return

	var restored: Node = manager_script.new()
	root.add_child(restored)
	await process_frame
	if int(restored.get("mission_stage")) != 8 or int(restored.call("get_wallet")) != 1038:
		_fail("The complete three-mission campaign did not restore from the local save.")
		return

	manager.call("reset_progress")
	restored.queue_free()
	manager.queue_free()
	await process_frame
	print("PASS: the original three-mission campaign enforces stage order, emits objective steps, saves and pays each reward once.")
	quit(0)


func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	quit(1)
