extends SceneTree


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var packed := load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		_fail("Main scene could not be loaded.")
		return

	var game := packed.instantiate()
	root.add_child(game)
	await process_frame
	await process_frame

	var player := game.get_node_or_null("Player")
	var world := game.get_node_or_null("World")
	var missions := game.get_node_or_null("MissionManager")
	var world_clock := game.get_node_or_null("WorldClock")
	var world_sun := game.get_node_or_null("WorldSun") as DirectionalLight3D
	var hud := game.get_node_or_null("GameplayHUD")
	if player == null or world == null or missions == null or hud == null:
		_fail("Player, World, MissionManager, or HUD is missing from the new project.")
		return
	if world_clock == null or world_sun == null:
		_fail("The world clock or its directional sun is missing.")
		return

	var interactables := get_nodes_in_group("interactables")
	if interactables.size() < 3:
		_fail("Expected Claire, Mia, and Nora interactive actors.")
		return

	var claire := world.get_node_or_null("ClaireBennett")
	var nora := world.get_node_or_null("NoraBlake")
	if claire == null or nora == null:
		_fail("Claire or Nora is missing from the built world.")
		return

	var vehicles := get_nodes_in_group("drivable_vehicles")
	if vehicles.size() != 1:
		_fail("Expected one functional starter sedan in the foundation milestone.")
		return

	world_clock.call("set_time", 6, 0)
	var dawn_energy := float(world_sun.get("light_energy"))
	world_clock.call("set_time", 12, 0)
	var midday_energy := float(world_sun.get("light_energy"))
	if midday_energy <= dawn_energy:
		_fail("Daylight did not brighten the sun between sunrise and noon.")
		return
	world_clock.call("set_time", 12, 34)
	if str(world_clock.call("get_time_text")) != "12:34":
		_fail("The world clock did not format the requested game time.")
		return

	var clock_label := hud.get_node_or_null(
		"HUDRoot/StatusPanel/StatusColumn/WorldClockLabel"
	) as Label
	if clock_label == null or clock_label.text != "TIME 12:34":
		_fail("The HUD did not display the live world clock.")
		return

	world_clock.call("_save_time")
	var restored_clock: Node = load("res://scripts/systems/world_clock.gd").new()
	root.add_child(restored_clock)
	await process_frame
	if str(restored_clock.call("get_time_text")) != "12:34":
		_fail("The world clock did not restore its saved time.")
		return

	var expected_regions := [
		[Vector3(-96.0, 0.0, 0.0), "Harbor City"],
		[Vector3(-32.0, 0.0, 0.0), "Sapphire Coast"],
		[Vector3(32.0, 0.0, 0.0), "Pine Highlands"],
		[Vector3(96.0, 0.0, 0.0), "Amber Valley"]
	]
	for entry in expected_regions:
		if world.call("get_region_name_at", entry[0]) != entry[1]:
			_fail("Region coordinate mapping failed for " + entry[1])
			return

	var minimap := hud.get_node_or_null("HUDRoot/MinimapPanel/WorldMinimap")
	if minimap == null:
		_fail("Live minimap control is missing from the HUD.")
		return
	var map_origin: Vector2 = minimap.call("world_to_map", Vector3(-128.0, 0.0, -32.0))
	var map_far_corner: Vector2 = minimap.call("world_to_map", Vector3(128.0, 0.0, 32.0))
	if map_origin.distance_to(Vector2.ZERO) > 0.01 or map_far_corner.distance_to(Vector2(180.0, 132.0)) > 0.01:
		_fail("Minimap world-to-map coordinate conversion is incorrect.")
		return
	hud.call("update_minimap", player.global_position, 0.5)
	if minimap.get("player_world_position") != player.global_position:
		_fail("Minimap did not receive the live player world position.")
		return

	var start_position: Vector3 = player.global_position
	Input.action_press("move_forward")
	for _frame in range(24):
		await physics_frame
	Input.action_release("move_forward")
	if player.global_position.distance_to(start_position) < 0.35:
		_fail("WASD forward input did not move the player.")
		return

	var vehicle := vehicles[0] as Node3D
	player.velocity = Vector3.ZERO
	player.global_position = vehicle.global_position + Vector3(3.0, 0.0, 0.0)
	await physics_frame
	player.call("_try_interact")
	if player.get("_driven_vehicle") != vehicle:
		_fail("E interaction did not enter the nearby starter sedan.")
		return

	var vehicle_start: Vector3 = vehicle.global_position
	Input.action_press("move_forward")
	for _frame in range(24):
		await physics_frame
	Input.action_release("move_forward")
	if vehicle.global_position.distance_to(vehicle_start) < 0.25:
		_fail("The starter sedan did not move under driving input.")
		return

	player.call("_try_interact")
	if player.get("_driven_vehicle") != null:
		_fail("E interaction did not exit the starter sedan.")
		return

	missions.call("reset_progress")
	claire.call("activate")
	if int(missions.get("mission_stage")) != 1:
		_fail("Activating Claire did not start Mission 001 through the world signal.")
		return

	nora.call("activate")
	if int(missions.get("mission_stage")) != 2:
		_fail("Activating Nora did not complete Mission 001 through the world signal.")
		return
	if int(missions.call("get_wallet")) != 600:
		_fail("Mission 001 reward was not added.")
		return

	nora.call("activate")
	if int(missions.call("get_wallet")) != 600:
		_fail("Mission 001 reward was not idempotent.")
		return

	var restored_manager: Node = load("res://scripts/systems/mission_manager.gd").new()
	root.add_child(restored_manager)
	await process_frame
	if int(restored_manager.get("mission_stage")) != 2:
		_fail("Mission 001 progress was not restored by a new manager instance.")
		return
	if int(restored_manager.call("get_wallet")) != 600:
		_fail("The wallet balance was not restored by a new manager instance.")
		return

	print("PASS: fresh Web project main scene starts.")
	print("PASS: four named region coordinates and three named interactive characters exist.")
	print("PASS: world clock formats time, updates the sun/daylight and is saved/restored.")
	print("PASS: HUD displays the live in-game clock.")
	print("PASS: minimap maps world bounds correctly and receives the live player position.")
	print("PASS: keyboard movement moves the player.")
	print("PASS: nearby E interaction enters the starter sedan; driving and E exit work.")
	print("PASS: Claire and Nora world interactions complete Mission 001 and grant $250 once.")
	print("PASS: Mission 001 stage and $600 wallet restore through a new manager instance.")
	print("NOTE: this is foundation regression coverage, not full-game acceptance.")
	restored_manager.queue_free()
	restored_clock.queue_free()
	game.queue_free()
	await process_frame
	quit(0)


func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	quit(1)
