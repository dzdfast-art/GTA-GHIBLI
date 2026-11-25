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

	var points_of_interest: Array[Dictionary] = world.call("get_points_of_interest")
	if points_of_interest.size() < 6:
		_fail("The world map is missing its expected point-of-interest registry.")
		return
	var point_ids := {}
	for point in points_of_interest:
		var point_id := str(point.get("id", ""))
		if point_id.is_empty() or point_ids.has(point_id):
			_fail("Point-of-interest IDs must be present and unique.")
			return
		point_ids[point_id] = true
		var point_position: Vector3 = point.get("position", Vector3.ZERO)
		if world.call("get_region_name_at", point_position) != str(point.get("region", "")):
			_fail("Point-of-interest region does not match its world coordinates.")
			return

	var world_map := hud.get_node_or_null(
		"HUDRoot/WorldMapPanel/MapColumn/WorldMapCanvas"
	) as Control
	if world_map == null:
		_fail("The interactive world-map canvas is missing.")
		return
	world_map.size = Vector2(740.0, 360.0)
	hud.call("set_points_of_interest", points_of_interest)
	var lighthouse_position: Vector3 = points_of_interest[0].get("position")
	var lighthouse_map_position: Vector2 = world_map.call("world_to_map", lighthouse_position)
	var selected_waypoint := {"id": ""}
	hud.connect(
		"waypoint_selected",
		func(point_id: String, _point_name: String, _world_position: Vector3) -> void:
			selected_waypoint["id"] = point_id
	)
	if not bool(world_map.call("select_nearest_point", lighthouse_map_position)):
		_fail("Clicking a known map marker did not select a waypoint.")
		return
	if str(selected_waypoint["id"]) != "marsa_al_noor":
		_fail("The world map selected the wrong point of interest.")
		return

	var route_planner = load("res://scripts/world/route_planner.gd").new()
	var road_graph: Dictionary = world.call("get_road_graph")
	if not bool(route_planner.call("configure", road_graph)):
		_fail("The connected starter-road graph could not be configured.")
		return
	if int(route_planner.call("get_node_count")) < points_of_interest.size() + 8:
		_fail("The road graph is missing expected road and point-of-interest nodes.")
		return
	if int(route_planner.call("get_edge_count")) < points_of_interest.size() + 7:
		_fail("The road graph is missing connecting road segments.")
		return
	if int(route_planner.call("get_node_count")) < 25 or int(route_planner.call("get_edge_count")) < 30:
		_fail("The expanded road graph is missing its connected street-grid intersections and segments.")
		return
	var cross_grid_route: Dictionary = route_planner.call(
		"find_route", Vector3(-96.0, 0.0, -24.0), Vector3(-32.0, 0.0, 24.0), 1.0
	)
	if not bool(cross_grid_route.get("reachable", false)):
		_fail("The new north-south and east-west streets are not connected into a drivable route network.")
		return
	if cross_grid_route.get("edge_ids", []).is_empty():
		_fail("The street-grid route did not return traversed road segment IDs.")
		return
	for point in points_of_interest:
		var destination: Vector3 = point["position"]
		var candidate_route: Dictionary = route_planner.call(
			"find_route", player.global_position, destination, 36.0
		)
		if not bool(candidate_route.get("reachable", false)):
			_fail("A registered point of interest has no connected road route: " + str(point["id"]))
			return
	var unreachable_route: Dictionary = route_planner.call(
		"find_route", Vector3(0.0, 0.0, 100.0), lighthouse_position, 4.0
	)
	if bool(unreachable_route.get("reachable", false)):
		_fail("The GPS planner accepted a start point outside the road snap limit.")
		return

	game.call("_on_waypoint_selected", "marsa_al_noor", "Marsa Al-Noor Lighthouse", lighthouse_position)
	game.call("_process", 0.5)
	var active_route: Dictionary = game.get("_active_route")
	if not bool(active_route.get("reachable", false)) or active_route.get("path", []).size() < 3:
		_fail("Selecting a waypoint did not produce a connected road route.")
		return
	var active_maneuvers: Array = active_route.get("maneuvers", [])
	if active_maneuvers.is_empty():
		_fail("The active GPS route did not produce a turn instruction.")
		return
	if str(active_maneuvers[0].get("instruction", "")) != "Turn right":
		_fail("The lighthouse access spur did not produce the expected right-turn instruction.")
		return
	var guidance_label := hud.get("_guidance_label") as Label
	if guidance_label == null or not guidance_label.text.contains("NEXT TURN — Turn right in"):
		_fail("The HUD did not display the next turn and its remaining distance.")
		return

	var turn_planner = load("res://scripts/world/route_planner.gd").new()
	var turn_graph := {
		"nodes": [
			{"id": "A", "position": Vector3(0.0, 0.0, 0.0)},
			{"id": "B", "position": Vector3(10.0, 0.0, 0.0)},
			{"id": "C", "position": Vector3(10.0, 0.0, 10.0)}
		],
		"edges": [
			{"id": "AB", "from": "A", "to": "B", "cost": 10.0},
			{"id": "BC", "from": "B", "to": "C", "cost": 10.0}
		]
	}
	if not bool(turn_planner.call("configure", turn_graph)):
		_fail("The isolated turn-guidance test graph could not be configured.")
		return
	var right_turn_route: Dictionary = turn_planner.call(
		"find_route", Vector3.ZERO, Vector3(10.0, 0.0, 10.0), 1.0
	)
	var left_turn_route: Dictionary = turn_planner.call(
		"find_route", Vector3(10.0, 0.0, 10.0), Vector3.ZERO, 1.0
	)
	if right_turn_route.get("maneuvers", []).size() != 1 or str(right_turn_route["maneuvers"][0]["kind"]) != "right":
		_fail("The route planner did not identify a right turn in the isolated test graph.")
		return
	if left_turn_route.get("maneuvers", []).size() != 1 or str(left_turn_route["maneuvers"][0]["kind"]) != "left":
		_fail("The route planner did not identify a left turn in the isolated test graph.")
		return

	var route_distance := float(active_route.get("distance", 0.0))
	var straight_line_distance: float = player.global_position.distance_to(lighthouse_position)
	if route_distance <= straight_line_distance:
		_fail("The route distance did not account for the road-access detour.")
		return
	if not str(hud.call("get_waypoint_status_text")).contains("(road)"):
		_fail("The HUD did not label the distance as a road route.")
		return
	if minimap.get("route_points").size() < 3:
		_fail("The minimap did not receive the planned road-route geometry.")
		return
	if world_map.get("_route_points").size() < 3:
		_fail("The full world map did not receive the planned road-route geometry.")
		return
	if not bool(minimap.get("has_waypoint")) or minimap.get("waypoint_world_position") != lighthouse_position:
		_fail("The minimap did not receive the selected waypoint marker.")
		return

	if not bool(game.call("set_road_edge_blocked", "road_segment_00", true)):
		_fail("The game root could not close a known road edge.")
		return
	if bool(game.get("_active_route").get("reachable", false)):
		_fail("The active route remained reachable after its only access segment was closed.")
		return
	if not str(hud.call("get_waypoint_status_text")).contains("no connected road route"):
		_fail("The HUD did not report an unreachable route after a road closure.")
		return
	if minimap.get("route_points").size() != 0 or world_map.get("_route_points").size() != 0:
		_fail("The map and minimap retained a stale route after the road closure.")
		return
	if not bool(game.call("set_road_edge_blocked", "road_segment_00", false)):
		_fail("The game root could not reopen the road edge.")
		return
	if not bool(game.get("_active_route").get("reachable", false)):
		_fail("The GPS route did not recover after reopening the road edge.")
		return

	var detour_planner = load("res://scripts/world/route_planner.gd").new()
	var detour_graph := {
		"nodes": [
			{"id": "A", "position": Vector3(0.0, 0.0, 0.0)},
			{"id": "B", "position": Vector3(10.0, 0.0, 0.0)},
			{"id": "C", "position": Vector3(0.0, 0.0, 15.0)},
			{"id": "D", "position": Vector3(10.0, 0.0, 10.0)}
		],
		"edges": [
			{"id": "AB", "from": "A", "to": "B", "cost": 10.0},
			{"id": "BD", "from": "B", "to": "D", "cost": 10.0},
			{"id": "AC", "from": "A", "to": "C", "cost": 15.0},
			{"id": "CD", "from": "C", "to": "D", "cost": 11.18}
		]
	}
	if not bool(detour_planner.call("configure", detour_graph)):
		_fail("The alternate-route test graph could not be configured.")
		return
	var original_detour_route: Dictionary = detour_planner.call(
		"find_route", Vector3.ZERO, Vector3(10.0, 0.0, 10.0), 1.0
	)
	if original_detour_route.get("edge_ids", []) != ["AB", "BD"]:
		_fail("The route planner did not choose the shortest open path before a closure.")
		return
	if not bool(detour_planner.call("set_edge_blocked", "BD", true)):
		_fail("The route planner could not block a known edge.")
		return
	var alternate_route: Dictionary = detour_planner.call(
		"find_route", Vector3.ZERO, Vector3(10.0, 0.0, 10.0), 1.0
	)
	if alternate_route.get("edge_ids", []) != ["AC", "CD"]:
		_fail("The route planner did not choose the alternate path after a closure.")
		return
	if not bool(detour_planner.call("set_edge_blocked", "CD", true)):
		_fail("The route planner could not block the alternate route edge.")
		return
	var no_detour_route: Dictionary = detour_planner.call(
		"find_route", Vector3.ZERO, Vector3(10.0, 0.0, 10.0), 1.0
	)
	if bool(no_detour_route.get("reachable", false)):
		_fail("The route planner did not report unreachable after all paths were closed.")
		return
	if bool(detour_planner.call("set_edge_blocked", "unknown_edge", false)):
		_fail("The route planner accepted an unknown edge ID.")
		return
	detour_planner.call("set_edge_blocked", "BD", false)
	if not bool(detour_planner.call("find_route", Vector3.ZERO, Vector3(10.0, 0.0, 10.0), 1.0).get("reachable", false)):
		_fail("The route planner did not recover after reopening an alternate edge.")
		return

	var one_way_planner = load("res://scripts/world/route_planner.gd").new()
	var one_way_graph := {
		"nodes": [
			{"id": "west", "position": Vector3(-5.0, 0.0, 0.0)},
			{"id": "east", "position": Vector3(5.0, 0.0, 0.0)}
		],
		"edges": [
			{"id": "one_way_eastbound", "from": "west", "to": "east", "direction": "forward", "cost": 10.0}
		]
	}
	if not bool(one_way_planner.call("configure", one_way_graph)):
		_fail("The one-way road test graph could not be configured.")
		return
	if not bool(one_way_planner.call("find_route", Vector3(-5.0, 0.0, 0.0), Vector3(5.0, 0.0, 0.0), 1.0).get("reachable", false)):
		_fail("The one-way road did not permit travel in its declared direction.")
		return
	if bool(one_way_planner.call("find_route", Vector3(5.0, 0.0, 0.0), Vector3(-5.0, 0.0, 0.0), 1.0).get("reachable", false)):
		_fail("The one-way road incorrectly permitted travel against its declared direction.")
		return

	var restriction_planner = load("res://scripts/world/route_planner.gd").new()
	var restricted_graph := {
		"nodes": [
			{"id": "A", "position": Vector3(0.0, 0.0, 0.0)},
			{"id": "B", "position": Vector3(10.0, 0.0, 0.0)},
			{"id": "C", "position": Vector3(10.0, 0.0, 10.0)},
			{"id": "D", "position": Vector3(20.0, 0.0, 0.0)}
		],
		"edges": [
			{"id": "AB", "from": "A", "to": "B", "cost": 10.0},
			{"id": "BC", "from": "B", "to": "C", "cost": 10.0},
			{"id": "CD", "from": "C", "to": "D", "cost": 14.14},
			{"id": "BD", "from": "B", "to": "D", "cost": 10.0}
		],
		"turn_restrictions": [
			{"via": "B", "from_edge": "AB", "to_edge": "BD", "type": "no"}
		]
	}
	if not bool(restriction_planner.call("configure", restricted_graph)):
		_fail("A valid no-turn restriction could not be configured.")
		return
	var no_turn_route: Dictionary = restriction_planner.call(
		"find_route", Vector3.ZERO, Vector3(20.0, 0.0, 0.0), 1.0
	)
	if no_turn_route.get("edge_ids", []) != ["AB", "BC", "CD"]:
		_fail("The planner ignored a prohibited turn or failed to find its legal detour.")
		return

	var only_turn_graph: Dictionary = restricted_graph.duplicate(true)
	only_turn_graph["turn_restrictions"] = [
		{"via": "B", "from_edge": "AB", "to_edge": "BC", "type": "only"}
	]
	if not bool(restriction_planner.call("configure", only_turn_graph)):
		_fail("A valid only-turn restriction could not be configured.")
		return
	var only_turn_route: Dictionary = restriction_planner.call(
		"find_route", Vector3.ZERO, Vector3(20.0, 0.0, 0.0), 1.0
	)
	if only_turn_route.get("edge_ids", []) != ["AB", "BC", "CD"]:
		_fail("The planner did not enforce an only-turn restriction at a junction.")
		return

	var invalid_turn_graph: Dictionary = restricted_graph.duplicate(true)
	invalid_turn_graph["turn_restrictions"] = [
		{"via": "B", "from_edge": "AB", "to_edge": "MISSING", "type": "no"}
	]
	if bool(restriction_planner.call("configure", invalid_turn_graph)):
		_fail("The planner accepted a turn restriction referencing an unknown road edge.")
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
	if player.collision_layer != 0 or player.collision_mask != 0:
		_fail("The on-foot player collision body remained active inside the sedan.")
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
	if player.collision_layer != 1 or player.collision_mask != 1:
		_fail("The on-foot player collision body was not restored after exiting the sedan.")
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

	var autosave_manager: RefCounted = load("res://scripts/world/save_slot_manager.gd").new()
	var autosave_record: Dictionary = autosave_manager.call("load_slot", "autosave")
	var autosave_payload: Dictionary = autosave_record.get("payload", {})
	var autosave_missions: Dictionary = autosave_payload.get("missions", {})
	if int(autosave_payload.get("schema_version", 0)) != 1 or int(autosave_missions.get("stage", -1)) != 2 or int(autosave_missions.get("wallet", -1)) != 600:
		_fail("The game root did not persist Mission 001 stage and wallet in its versioned live-game autosave slot.")
		return

	var pause_save_position: Vector3 = player.global_position + Vector3(1.25, 0.0, 0.75)
	player.global_position = pause_save_position
	game.call("_notification", Node.NOTIFICATION_APPLICATION_PAUSED)
	var pause_save_record: Dictionary = autosave_manager.call("load_slot", "autosave")
	var pause_save_payload: Dictionary = pause_save_record.get("payload", {})
	var pause_save_player: Dictionary = pause_save_payload.get("player", {})
	var pause_saved_position: Array = pause_save_player.get("position", [])
	if pause_saved_position.size() != 3:
		_fail("Application pause did not flush the live player position to the autosave slot.")
		return
	var restored_pause_position := Vector3(
		float(pause_saved_position[0]),
		float(pause_saved_position[1]),
		float(pause_saved_position[2])
	)
	if restored_pause_position.distance_to(pause_save_position) > 0.01:
		_fail("Application pause autosave stored a stale player position.")
		return
	autosave_manager.call("delete_slot", "autosave")

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
	print("PASS: world-map POIs have unique IDs and correct region coordinates.")
	print("PASS: the expanded north-south and cross-street grid connects across multiple regions.")
	print("PASS: all six points of interest are reachable through the connected road graph.")
	print("PASS: off-network starts are reported unreachable beyond the configured snap distance.")
	print("PASS: selecting a map marker produces a road-following route, distance and map/minimap polyline.")
	print("PASS: GPS derives the next-turn instruction and remaining distance for the HUD.")
	print("PASS: isolated route geometry correctly distinguishes left and right turns.")
	print("PASS: live road closures clear the active route and reopening restores it.")
	print("PASS: A* selects an alternate path when a road edge closes and reports unreachable when all paths close.")
	print("PASS: one-way road direction is enforced by the route planner.")
	print("PASS: prohibited and only-turn junction restrictions are enforced with legal detours.")
	print("PASS: malformed junction restrictions referencing unknown roads are rejected.")
	print("PASS: keyboard movement moves the player.")
	print("PASS: nearby E interaction enters the starter sedan; driving and E exit work.")
	print("PASS: Claire and Nora world interactions complete Mission 001 and grant $250 once.")
	print("PASS: Mission 001 stage and $600 wallet restore through a new manager instance.")
	print("PASS: game-root wallet changes persist the mission stage and balance in a durable autosave slot.")
	print("PASS: application-pause notification immediately flushes the latest player position.")
	print("NOTE: this is foundation regression coverage, not full-game acceptance.")
	restored_manager.queue_free()
	game.queue_free()
	await process_frame
	quit(0)


func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	quit(1)
