extends SceneTree

const PLAYER_SCENE: PackedScene = preload("res://scenes/player/player.tscn")
const GRAPHICS_SCRIPT = preload("res://scripts/graphics/ghibli_environment_upgrade.gd")
const WALLET_SCRIPT = preload("res://scripts/systems/player_wallet.gd")
const STATUS_SCRIPT = preload("res://scripts/systems/player_status.gd")
const CLOCK_SCRIPT = preload("res://scripts/world/world_clock.gd")
const HUD_SCRIPT = preload("res://scripts/ui/reference_hud_overlay.gd")
const MOBILE_CONTROLS_SCRIPT = preload("res://scripts/ui/mobile_controls.gd")


func _initialize() -> void:
	call_deferred("_run_test")


func _run_test() -> void:
	# Use the real player scene and real HUD/gameplay systems, while providing
	# only the world anchors needed by the procedural graphics pass. This keeps
	# the graphics/UI regression independent from loading all distant districts.
	var world := Node3D.new()
	world.name = "ReferenceHudTestWorld"
	root.add_child(world)

	var floor_body := StaticBody3D.new()
	floor_body.name = "Ground"
	world.add_child(floor_body)
	var floor_collision := CollisionShape3D.new()
	var floor_shape := BoxShape3D.new()
	floor_shape.size = Vector3(80.0, 1.0, 80.0)
	floor_collision.shape = floor_shape
	floor_collision.position.y = -0.5
	floor_body.add_child(floor_collision)

	var player := PLAYER_SCENE.instantiate() as CharacterBody3D
	player.name = "Player"
	player.position = Vector3(0.0, 0.95, 0.0)
	player.rotation.y = PI
	player.add_to_group("player")
	world.add_child(player)

	var wallet := Node.new()
	wallet.name = "PlayerWallet"
	wallet.set_script(WALLET_SCRIPT)
	wallet.set("persistence_enabled", false)
	wallet.set("initial_balance", 250)
	player.add_child(wallet)

	var status := Node.new()
	status.name = "PlayerStatus"
	status.set_script(STATUS_SCRIPT)
	player.add_child(status)

	var clock := Node.new()
	clock.name = "WorldClock"
	clock.set_script(CLOCK_SCRIPT)
	world.add_child(clock)

	var regions := Node3D.new()
	regions.name = "OpenWorldRegions"
	world.add_child(regions)
	var harbor := Node3D.new()
	harbor.name = "HarborCity"
	regions.add_child(harbor)

	var village := Node3D.new()
	village.name = "WillowVillage"
	world.add_child(village)

	var graphics := Node3D.new()
	graphics.name = "GhibliVisualPass"
	graphics.set_script(GRAPHICS_SCRIPT)
	world.add_child(graphics)

	var controls := MOBILE_CONTROLS_SCRIPT.new() as CanvasLayer
	controls.name = "MobileControls"
	world.add_child(controls)

	var hud := HUD_SCRIPT.new() as CanvasLayer
	hud.name = "ReferenceHUD"
	world.add_child(hud)

	for _frame in range(5):
		await physics_frame

	# Check the real spring-arm camera position and view direction.
	var camera := player.get_node_or_null("CameraPivot/SpringArm3D/Camera3D") as Camera3D
	var spring_arm := player.get_node_or_null("CameraPivot/SpringArm3D") as SpringArm3D
	if camera == null or spring_arm == null:
		_fail("The over-the-shoulder camera is missing.")
		return
	if not is_equal_approx(spring_arm.spring_length, 2.75):
		_fail("The camera spring arm does not use the intended reference distance.")
		return
	var player_forward: Vector3 = -player.global_basis.z
	var camera_forward: Vector3 = -camera.global_basis.z
	var camera_offset: Vector3 = camera.global_position - player.global_position
	if camera_offset.dot(player_forward) >= -0.1:
		_fail("Camera behind-player check failed; offset dot forward = %.3f" % camera_offset.dot(player_forward))
		return
	if camera_forward.dot(player_forward) < 0.92:
		_fail("Camera forward check failed; direction dot player-forward = %.3f" % camera_forward.dot(player_forward))
		return
	if not is_equal_approx(camera.fov, 78.0):
		_fail("The camera FOV is not set for the reference-style wide composition.")
		return

	# The same graphics script wired into main.gd must generate the reference set.
	var composition := graphics.get_node_or_null("ReferenceStreetComposition") as Node3D
	if composition == null:
		_fail("The in-game reference street composition was not created.")
		return
	for node_path in [
		"OpeningBoulevard",
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

	# Confirm the HUD consumes live wallet, clock and status values.
	var hud_root := hud.get_node_or_null("ReferenceHUD") as Control
	if hud_root == null:
		_fail("The reference-style HUD overlay is missing.")
		return
	for node_path in [
		"CircularMinimap",
		"Money",
		"GameClock",
		"WantedStars/Star_0",
		"HealthBar",
		"ArmorBar",
		"WeaponPanel/WeaponStack/WeaponIcon",
		"WeaponPanel/WeaponStack/WeaponName",
		"WeaponPanel/WeaponStack/Ammo"
	]:
		if hud_root.get_node_or_null(node_path) == null:
			_fail("Missing reference HUD element: " + node_path)
			return
	var minimap := hud_root.get_node_or_null("CircularMinimap") as Control
	if minimap == null or minimap.size.x < 200.0 or minimap.size.y < 200.0:
		_fail("The circular minimap has not received its intended on-screen size.")
		return

	# Confirm the mobile button layout, including actions that actually drive movement.
	var controls_root := controls.get_node_or_null("HUD") as Control
	if controls_root == null:
		_fail("The mobile touch HUD is missing.")
		return
	for node_name in ["MovementJoystick", "Attack", "Jump", "Sprint", "ContextAction"]:
		if controls_root.get_node_or_null(node_name) == null:
			_fail("Missing mobile touch control: " + node_name)
			return
	if not InputMap.has_action("jump") or not InputMap.has_action("attack"):
		_fail("Jump and punch controls are not registered.")
		return

	# Test updates through the same live systems consumed by the HUD.
	wallet.set("balance", 250)
	status.call("set_armor", 20.0)
	status.call("apply_damage", 30.0)
	status.call("set_wanted_level", 3)
	status.call("set_weapon", "rifle", 30, 120)
	wallet.call("add_money", 25)
	clock.call("set_time", 18, 30)
	hud.call("_refresh_values")

	if float(status.get("health")) != 90.0 or float(status.get("armor")) != 0.0:
		_fail("Player health/armor state did not process incoming damage.")
		return
	if str(hud_root.get_node("Money").text) != "$00000275":
		_fail("The HUD money value did not update from PlayerWallet.")
		return
	if str(hud_root.get_node("GameClock").text) != "18:30":
		_fail("The HUD clock did not update from WorldClock.")
		return
	if str(hud_root.get_node("WeaponPanel/WeaponStack/WeaponName").text) != "RIFLE":
		_fail("The HUD weapon name did not update from PlayerStatus.")
		return
	if str(hud_root.get_node("WeaponPanel/WeaponStack/Ammo").text) != "30/120":
		_fail("The HUD weapon/ammunition display did not update from PlayerStatus.")
		return
	if not hud_root.get_node("WantedStars/Star_2").modulate.is_equal_approx(Color(1.0, 0.82, 0.22)):
		_fail("Wanted stars did not reflect the player's wanted level.")
		return
	if not is_equal_approx(float(hud_root.get_node("HealthBar").value), 90.0):
		_fail("The health bar did not reflect the live player status.")
		return

	# Exercise the actual mobile jump button signal, not a fake direct player call.
	if not player.is_on_floor():
		_fail("The player was not grounded at the opening spawn.")
		return
	var jump_button := controls_root.get_node("Jump") as Button
	jump_button.button_down.emit()
	await physics_frame
	jump_button.button_up.emit()
	if player.velocity.y <= 0.0:
		_fail("The on-screen jump button did not produce upward player movement.")
		return

	print("PASS: reference composition, trailing camera, circular minimap, live HUD data, mobile buttons and jump.")
	quit(0)


func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	quit(1)
