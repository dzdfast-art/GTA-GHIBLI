extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://main.tscn")


func _initialize() -> void:
	call_deferred("_run_test")


func _run_test() -> void:
	var main := MAIN_SCENE.instantiate() as Node3D
	root.add_child(main)
	for _frame in range(4):
		await physics_frame

	var player := main.get_node_or_null("Player") as CharacterBody3D
	if player == null:
		_fail("The main scene did not create the player.")
		return
	var camera := player.get_node_or_null("CameraPivot/SpringArm3D/Camera3D") as Camera3D
	var spring_arm := player.get_node_or_null("CameraPivot/SpringArm3D") as SpringArm3D
	if camera == null or spring_arm == null:
		_fail("The over-the-shoulder camera is missing.")
		return
	if not is_equal_approx(camera.rotation.y, PI) or not is_equal_approx(spring_arm.spring_length, 2.75):
		_fail("The camera does not use the intended behind-player framing.")
		return
	var player_forward: Vector3 = -player.global_basis.z
	var camera_forward: Vector3 = -camera.global_basis.z
	var camera_offset: Vector3 = camera.global_position - player.global_position
	if camera_offset.dot(player_forward) >= -0.1:
		_fail("The camera is not positioned behind the player's facing direction.")
		return
	if camera_forward.dot(player_forward) < 0.92:
		_fail("The camera is not looking forward along the player's facing direction.")
		return
	if not is_equal_approx(camera.fov, 78.0):
		_fail("The camera FOV is not set for the reference-style wide composition.")
		return

	var composition := main.get_node_or_null("GhibliVisualPass/ReferenceStreetComposition") as Node3D
	if composition == null:
		_fail("The in-game reference street composition was not created.")
		return
	for node_path in [
		"OpeningSkyline",
		"RedSuspensionBridge",
		"GreenGhibliHill",
		"GhibliStoryBillboard",
		"Harbor24HourShop",
		"ParkedBlackSedan",
		"ParkedStreetMotorcycle",
		"DistantAirplane",
		"DistantHelicopter"
	]:
		if composition.get_node_or_null(node_path) == null:
			_fail("Missing reference composition element: " + node_path)
			return

	var player_status := player.get_node_or_null("PlayerStatus")
	if player_status == null:
		_fail("PlayerStatus is not attached to the player.")
		return
	var wallet := player.get_node_or_null("PlayerWallet")
	if wallet != null:
		wallet.set("persistence_enabled", false)
		wallet.set("balance", 250)
	if wallet == null:
		_fail("PlayerWallet is not attached to the player.")
		return
	if main.get_node_or_null("WorldClock") == null:
		_fail("The world clock is missing.")
		return

	var hud := main.get_node_or_null("ReferenceHUD")
	if hud == null:
		_fail("The reference-style HUD overlay is missing.")
		return
	var hud_root := hud.get_node_or_null("ReferenceHUD") as Control
	if hud_root == null:
		_fail("The HUD root control is missing.")
		return
	for node_path in [
		"CircularMinimap",
		"Money",
		"GameClock",
		"WantedStars/Star_0",
		"HealthBar",
		"ArmorBar",
		"WeaponPanel"
	]:
		if hud_root.get_node_or_null(node_path) == null:
			_fail("Missing reference HUD element: " + node_path)
			return
	var minimap := hud_root.get_node_or_null("CircularMinimap") as Control
	if minimap == null or minimap.size.x < 200.0 or minimap.size.y < 200.0:
		_fail("The circular minimap has not received its intended on-screen size.")
		return

	var controls := main.get_node_or_null("MobileControls/HUD") as Control
	if controls == null:
		_fail("The mobile touch HUD is missing.")
		return
	for node_name in ["MovementJoystick", "Attack", "Jump", "Sprint", "ContextAction"]:
		if controls.get_node_or_null(node_name) == null:
			_fail("Missing mobile touch control: " + node_name)
			return
	if not InputMap.has_action("jump") or not InputMap.has_action("attack"):
		_fail("Jump and punch controls are not registered.")
		return

	# Verify that HUD values come from the live game systems, not fixed labels.
	player_status.call("set_armor", 20.0)
	player_status.call("apply_damage", 30.0)
	player_status.call("set_wanted_level", 3)
	player_status.call("set_weapon", "rifle", 30, 120)
	wallet.set("persistence_enabled", false)
	wallet.set("balance", 250)
	wallet.call("add_money", 25)
	main.get_node("WorldClock").call("set_time", 18, 30)
	hud.call("_refresh_values")

	if float(player_status.get("health")) != 90.0 or float(player_status.get("armor")) != 0.0:
		_fail("Player health/armor state did not process incoming damage.")
		return
	if str(hud_root.get_node("Money").text) != "$0000275":
		_fail("The HUD money value did not update from PlayerWallet.")
		return
	if str(hud_root.get_node("GameClock").text) != "18:30":
		_fail("The HUD clock did not update from WorldClock.")
		return
	if str(hud_root.get_node("WeaponPanel/VBoxContainer/WeaponName").text) != "RIFLE":
		_fail("The HUD weapon name did not update from PlayerStatus.")
		return
	if str(hud_root.get_node("WeaponPanel/VBoxContainer/Ammo").text) != "30/120":
		_fail("The HUD weapon/ammunition display did not update from PlayerStatus.")
		return
	if not hud_root.get_node("WantedStars/Star_2").modulate.is_equal_approx(Color(1.0, 0.82, 0.22)):
		_fail("Wanted stars did not reflect the player's wanted level.")
		return
	if not is_equal_approx(float(hud_root.get_node("HealthBar").value), 90.0):
		_fail("The health bar did not reflect the live player status.")
		return

	# Verify that the on-foot jump input changes real player vertical velocity.
	if not player.is_on_floor():
		_fail("The player was not grounded at the opening spawn.")
		return
	Input.action_press("jump")
	await physics_frame
	Input.action_release("jump")
	if player.velocity.y <= 0.0:
		_fail("The jump button did not produce upward player movement.")
		return

	print("PASS: reference composition, camera framing, minimap, live HUD data, touch controls and jump.")
	quit(0)


func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	quit(1)
