extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://main.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var game := MAIN_SCENE.instantiate()
	root.add_child(game)
	for _frame in range(8):
		await process_frame

	var player := game.get_node_or_null("Player") as Node3D
	if player == null:
		_fail("The main scene did not create the player.")
		return

	var health := player.get_node_or_null("PlayerHealth")
	if health == null:
		_fail("PlayerHealth is not attached to the live player.")
		return

	var hud := game.get_node_or_null("MobileControls/HUD/GameplayHUD") as Control
	if hud == null:
		_fail("The live GameplayHUD overlay is missing from MobileControls.")
		return
	if get_nodes_in_group("gameplay_hud").size() != 1:
		_fail("Expected exactly one gameplay HUD in the live scene.")
		return

	for node_path in ["LiveRadar", "PlayerStatus/WorldClock",
			"PlayerStatus/CashBalance", "PlayerStatus/HealthRow/PlayerHealthBar",
			"PlayerStatus/HealthRow/HealthValue", "PlayerStatus/UnarmedFistIcon"]:
		if hud.get_node_or_null(node_path) == null:
			_fail("Gameplay HUD is missing required node: " + node_path)
			return

	var cash_label := hud.get_node("PlayerStatus/CashBalance") as Label
	var health_bar := hud.get_node("PlayerStatus/HealthRow/PlayerHealthBar") as ProgressBar
	var clock_label := hud.get_node("PlayerStatus/WorldClock") as Label
	var wallet := player.get_node_or_null("PlayerWallet")
	if wallet == null or not wallet.has_method("get_balance"):
		_fail("Gameplay HUD has no existing PlayerWallet source.")
		return
	if clock_label.text.is_empty():
		_fail("Gameplay HUD did not show the existing world clock.")
		return
	if cash_label.text != "¤ %d" % int(wallet.call("get_balance")):
		_fail("Cash display does not match the live player wallet balance.")
		return
	if not is_equal_approx(health_bar.value, float(health.get("current_health"))):
		_fail("Health bar does not match the live PlayerHealth value.")
		return

	wallet.call("add_money", 25)
	health.call("apply_damage", 15.0)
	for _frame in range(16):
		await process_frame
	if cash_label.text != "¤ %d" % int(wallet.call("get_balance")):
		_fail("Cash display did not refresh after the wallet balance changed.")
		return
	if not is_equal_approx(health_bar.value, float(health.get("current_health"))):
		_fail("Health bar did not refresh after player damage.")
		return

	print("PASS: live radar, clock, wallet, health bar and single gameplay HUD.")
	game.queue_free()
	quit(0)


func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	quit(1)
