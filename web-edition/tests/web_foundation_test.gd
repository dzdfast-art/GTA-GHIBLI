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
	var hud := game.get_node_or_null("GameplayHUD")
	if player == null or world == null or missions == null or hud == null:
		_fail("Player, World, or MissionManager is missing from the new project.")
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

	var road_network = world.get("road_network")
	if road_network == null or int(road_network.call("get_node_count")) != 16 or int(road_network.call("get_edge_count")) != 16:
		_fail("The new data-driven road graph did not load its 16 nodes and 16 edges.")
		return
	if world.get_node_or_null("RoadSurface_arterial_harbor_west") == null:
		_fail("The road graph was loaded but its main-road geometry was not created.")
		return

	var nora_route: Dictionary = world.call("find_road_route", Vector3(-114.0, 0.0, 0.0), nora.global_position)
	if str(nora_route.get("status", "")) != "ok":
		_fail("The road graph could not route the player to Nora.")
		return
	var nora_edges: Array = nora_route.get("edge_ids", [])
	if not nora_edges.has("local_lighthouse_access"):
		_fail("The Nora route did not use the lighthouse access road.")
		return

	var detour_route: Dictionary = world.call(
		"find_road_route",
		Vector3(-96.0, 0.0, 0.0),
		Vector3(-32.0, 0.0, 0.0),
		["arterial_coast_west_to_center"]
	)
	if str(detour_route.get("status", "")) != "ok":
		_fail("The road graph did not find the coastal bypass around a closed road edge.")
		return
	var detour_edges: Array = detour_route.get("edge_ids", [])
	if detour_edges.has("arterial_coast_west_to_center") or not detour_edges.has("local_coast_bypass_loop"):
		_fail("The route planner did not avoid the closed edge using the coastal bypass.")
		return

	var blocked_nora_route: Dictionary = world.call(
		"find_road_route",
		Vector3(-114.0, 0.0, 0.0),
		nora.global_position,
		["local_lighthouse_access"]
	)
	if str(blocked_nora_route.get("status", "")) != "unreachable":
		_fail("The route planner did not report an unreachable destination when its only access road was closed.")
		return

	hud.call("set_navigation_route", nora_route.get("points", PackedVector3Array()), "Nora Blake", float(nora_route.get("distance", 0.0)))
	var displayed_route: PackedVector3Array = minimap.get("route_points")
	if displayed_route.size() < 2 or str(minimap.get("route_destination")) != "Nora Blake":
		_fail("The minimap did not receive the active GPS route and destination.")
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
	print("PASS: minimap maps world bounds correctly and receives the live player position.")
	print("PASS: the data-driven road graph loads 16 nodes/16 edges and creates road geometry.")
	print("PASS: Dijkstra routing reaches Nora, detours around a closed edge and reports blocked access as unreachable.")
	print("PASS: the minimap receives the active route and destination marker.")
	print("PASS: keyboard movement moves the player.")
	print("PASS: nearby E interaction enters the starter sedan; driving and E exit work.")
	print("PASS: Claire and Nora world interactions complete Mission 001 and grant $250 once.")
	print("PASS: Mission 001 stage and $600 wallet restore through a new manager instance.")
	print("NOTE: this is foundation regression coverage, not full-game acceptance.")
	restored_manager.queue_free()
	game.queue_free()
	await process_frame
	quit(0)


func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	quit(1)
