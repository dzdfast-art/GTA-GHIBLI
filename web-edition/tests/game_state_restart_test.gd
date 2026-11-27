extends SceneTree

const SLOT_ID: String = "autosave"
const SAVED_VEHICLE_POSITION: Vector3 = Vector3(-96.0, 0.0, 0.0)


func _initialize() -> void:
	call_deferred("_dispatch")


func _dispatch() -> void:
	var arguments: PackedStringArray = OS.get_cmdline_user_args()
	if arguments.has("--write"):
		await _run_writer_process()
		return
	if arguments.has("--read"):
		await _run_reader_process()
		return
	await _run_process_restart_test()


func _run_process_restart_test() -> void:
	var manager: RefCounted = load("res://scripts/world/save_slot_manager.gd").new()
	manager.call("delete_slot", SLOT_ID)
	if not bool(manager.call("save_slot", SLOT_ID, {"mission_stage": 1, "wallet": 725}, 1234567890)):
		_fail("The test could not create the previous-version autosave payload.")
		return

	var migration_game: Node = await _create_game()
	if migration_game == null:
		_fail("The migration test could not start the playable Web scene.")
		return
	var migrated_missions: Node = migration_game.get_node("MissionManager")
	if int(migrated_missions.get("mission_stage")) != 1 or int(migrated_missions.call("get_wallet")) != 725:
		_fail("The game root did not preserve the previous mission-stage and wallet autosave.")
		return
	var migrated_record: Dictionary = manager.call("load_slot", SLOT_ID)
	var migrated_payload: Dictionary = migrated_record.get("payload", {})
	if int(migrated_payload.get("schema_version", 0)) != 1:
		_fail("The previous autosave payload was not upgraded to the live-game schema.")
		return
	migration_game.queue_free()
	await process_frame
	manager.call("delete_slot", SLOT_ID)

	var executable: String = OS.get_executable_path()
	var project_path: String = ProjectSettings.globalize_path("res://")
	var writer_output: Array = []
	var writer_arguments := PackedStringArray([
		"--headless",
		"--path",
		project_path,
		"--script",
		"res://tests/game_state_restart_test.gd",
		"--",
		"--write"
	])
	var writer_status: int = OS.execute(executable, writer_arguments, writer_output, true)
	if writer_status != 0:
		_cleanup_save()
		_fail("The live-game save writer process failed: " + str(writer_output))
		return

	var reader_output: Array = []
	var reader_arguments := PackedStringArray([
		"--headless",
		"--path",
		project_path,
		"--script",
		"res://tests/game_state_restart_test.gd",
		"--",
		"--read"
	])
	var reader_status: int = OS.execute(executable, reader_arguments, reader_output, true)
	if reader_status != 0:
		_cleanup_save()
		_fail("The fresh live-game reader process failed: " + str(reader_output))
		return

	print("PASS: legacy autosave migration and live gameplay state survived a separate Godot process restart.")
	quit(0)


func _run_writer_process() -> void:
	var game: Node = await _create_game()
	if game == null:
		_fail("The writer process could not start the playable Web scene.")
		return

	var player: CharacterBody3D = game.get_node("Player") as CharacterBody3D
	var missions: Node = game.get_node("MissionManager")
	var vitals: RefCounted = game.call("get_runtime_system", "player_vitals")
	var clock: RefCounted = game.call("get_runtime_system", "world_clock_weather")
	var weapons: RefCounted = game.call("get_runtime_system", "weapon_inventory")
	var activities: RefCounted = game.call("get_runtime_system", "side_activity_registry")
	var landmarks: RefCounted = game.call("get_runtime_system", "landmark_discovery")
	var relationships: RefCounted = game.call("get_runtime_system", "npc_relationship")
	var wanted: RefCounted = game.call("get_runtime_system", "wanted_level")
	var objectives: RefCounted = game.call("get_runtime_system", "mission_objectives")
	var rewards: RefCounted = game.call("get_runtime_system", "mission_rewards")
	var shop: RefCounted = game.call("get_runtime_system", "shop_inventory")
	var vehicles: Array = get_nodes_in_group("drivable_vehicles")
	if vehicles.size() != 1:
		_fail("The writer process did not find the starter sedan.")
		return

	missions.set("mission_stage", 1)
	missions.set("wallet", 825)
	var shop_purchase: Dictionary = shop.call("purchase", "bottled_water", 825, 2)
	if not bool(shop_purchase.get("ok", false)) or not bool(missions.call("set_wallet_balance", int(shop_purchase.get("wallet", 0)), "restart_test")):
		_fail("The writer process could not create a transactional shop purchase.")
		return
	player.global_position = SAVED_VEHICLE_POSITION
	player.global_rotation = Vector3(0.0, 0.72, 0.0)
	player.velocity = Vector3.ZERO
	vitals.set("health", 73.5)
	vitals.set("stamina", 41.25)
	clock.set("minute_of_day", 1275)
	clock.call("set_weather", "rain")
	weapons.call("add_weapon", "starter_pistol", 17)
	weapons.call("select_weapon", "starter_pistol")
	activities.call("complete_activity", "lighthouse_view")
	landmarks.set("discovered", {
		"marsa_al_noor": {
			"position": Vector3(-79.0, 0.0, 17.0),
			"discovered_at_distance": 2.0
		}
	})
	relationships.call("adjust", "nora_blake", 25)
	wanted.call("add_crime", 2)
	objectives.call("add_progress", "mission_001_claire_contact", 1)
	rewards.set("settled", {"mission_001": {"cash": 250, "respect": 1}})
	if not bool(game.call("set_language", "ar")):
		_fail("The writer process could not select the Arabic settings profile.")
		return

	var vehicle: Node3D = vehicles[0] as Node3D
	vehicle.global_position = SAVED_VEHICLE_POSITION
	vehicle.global_rotation = Vector3(0.0, 0.4, 0.0)
	if vehicle is CharacterBody3D:
		(vehicle as CharacterBody3D).velocity = Vector3.ZERO
	if not bool(player.call("restore_vehicle_state", vehicle)):
		_fail("The writer process could not enter the starter sedan before saving.")
		return
	if not bool(game.call("_save_game_state", true)):
		_fail("The game root did not persist its live gameplay snapshot.")
		return
	print("PASS: writer process saved live player, mission, vehicle, inventory and world state.")
	quit(0)


func _run_reader_process() -> void:
	var game: Node = await _create_game()
	if game == null:
		_fail("The reader process could not start a fresh playable Web scene.")
		return

	var player: CharacterBody3D = game.get_node("Player") as CharacterBody3D
	var missions: Node = game.get_node("MissionManager")
	var vitals: RefCounted = game.call("get_runtime_system", "player_vitals")
	var clock: RefCounted = game.call("get_runtime_system", "world_clock_weather")
	var weapons: RefCounted = game.call("get_runtime_system", "weapon_inventory")
	var activities: RefCounted = game.call("get_runtime_system", "side_activity_registry")
	var landmarks: RefCounted = game.call("get_runtime_system", "landmark_discovery")
	var relationships: RefCounted = game.call("get_runtime_system", "npc_relationship")
	var wanted: RefCounted = game.call("get_runtime_system", "wanted_level")
	var objectives: RefCounted = game.call("get_runtime_system", "mission_objectives")
	var rewards: RefCounted = game.call("get_runtime_system", "mission_rewards")
	var settings: RefCounted = game.call("get_runtime_system", "settings_profile")
	var shop: RefCounted = game.call("get_runtime_system", "shop_inventory")
	var vehicles: Array = get_nodes_in_group("drivable_vehicles")
	if vehicles.size() != 1:
		_fail("The reader process did not find the starter sedan.")
		return
	var vehicle: Node3D = vehicles[0] as Node3D
	var diagnostic_manager: RefCounted = load("res://scripts/world/save_slot_manager.gd").new()
	var diagnostic_record: Dictionary = diagnostic_manager.call("load_slot", SLOT_ID)
	var diagnostic_payload: Dictionary = diagnostic_record.get("payload", {})
	var diagnostic_player: Dictionary = diagnostic_payload.get("player", {})
	var diagnostic_vehicles: Dictionary = diagnostic_payload.get("vehicles", {})
	print("RESTORE_DIAGNOSTIC=" + JSON.stringify({
		"saved_player_position": diagnostic_player.get("position", []),
		"saved_vehicle": diagnostic_vehicles.get("harbor_sedan", {}),
		"saved_active_vehicle_id": diagnostic_payload.get("active_vehicle_id", ""),
		"actual_player_position": [player.global_position.x, player.global_position.y, player.global_position.z],
		"actual_vehicle_position": [vehicle.global_position.x, vehicle.global_position.y, vehicle.global_position.z],
		"actual_active_vehicle": str(player.call("get_driven_vehicle"))
	}))
	var player_horizontal_delta := Vector2(
		player.global_position.x - SAVED_VEHICLE_POSITION.x,
		player.global_position.z - SAVED_VEHICLE_POSITION.z
	).length()
	if player_horizontal_delta > 0.05 or absf(player.global_position.y - SAVED_VEHICLE_POSITION.y) > 0.2:
		_fail("The fresh game did not restore the saved player position; expected=%s actual=%s" % [
			SAVED_VEHICLE_POSITION,
			player.global_position
		])
		return
	if player.global_position.distance_to(vehicle.global_position) > 0.01:
		_fail("The restored seated player is no longer synchronized with the active vehicle.")
		return
	if absf(player.global_rotation.y - 0.72) > 0.01:
		_fail("The fresh game did not restore the saved player rotation.")
		return
	if absf(float(vitals.get("health")) - 73.5) > 0.001 or absf(float(vitals.get("stamina")) - 41.25) > 0.001:
		_fail("The fresh game did not restore player health and stamina.")
		return
	if int(missions.get("mission_stage")) != 1 or int(missions.call("get_wallet")) != 801:
		_fail("The fresh game did not restore Mission 001 stage and the post-purchase wallet.")
		return
	if int(clock.get("minute_of_day")) != 1275 or str(clock.get("weather")) != "rain":
		_fail("The fresh game did not restore world time and weather.")
		return
	if int(weapons.call("ammo_count", "starter_pistol")) != 17 or str(weapons.get("selected")) != "starter_pistol":
		_fail("The fresh game did not restore weapon inventory and selection.")
		return
	var activity_state: Dictionary = activities.call("get_activity", "lighthouse_view")
	if not bool(activity_state.get("completed", false)):
		_fail("The fresh game did not restore completed side activities.")
		return
	if not bool(landmarks.call("is_discovered", "marsa_al_noor")):
		_fail("The fresh game did not restore discovered landmarks.")
		return
	if int(relationships.call("get_score", "nora_blake")) != 25 or int(wanted.call("get_level")) != 2:
		_fail("The fresh game did not restore NPC relationship and wanted level.")
		return
	if not bool(objectives.call("is_complete", "mission_001_claire_contact")):
		_fail("The fresh game did not restore mission objective progress.")
		return
	if not bool(rewards.call("is_settled", "mission_001")):
		_fail("The fresh game did not restore settled mission rewards.")
		return
	if str(settings.call("get_value", "language")) != "ar":
		_fail("The fresh game did not restore the selected Arabic language setting.")
		return
	if int(shop.call("get_quantity", "bottled_water")) != 2 or int(shop.get("stock").bottled_water.quantity) != 6:
		_fail("The fresh game did not restore purchased shop inventory and remaining market stock.")
		return
	if vehicle.global_position.distance_to(SAVED_VEHICLE_POSITION) > 0.05:
		_fail("The fresh game did not restore the parked vehicle transform.")
		return
	if player.call("get_driven_vehicle") != vehicle:
		_fail("The fresh game did not restore the active vehicle entry state.")
		return
	if player.collision_layer != 0 or player.collision_mask != 0:
		_fail("The restored seated player still participates in world collisions.")
		return

	_cleanup_save()
	print("PASS: fresh game restored player transform/vitals, mission progress/rewards, active vehicle, weapon inventory, shop inventory/stock, world time/weather, activity, landmark, relationship, wanted state and Arabic setting.")
	quit(0)


func _create_game() -> Node:
	var packed := load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		return null
	var game: Node = packed.instantiate()
	root.add_child(game)
	await process_frame
	await process_frame
	return game


func _cleanup_save() -> void:
	var manager: RefCounted = load("res://scripts/world/save_slot_manager.gd").new()
	manager.call("delete_slot", SLOT_ID)


func _fail(message: String) -> void:
	_cleanup_save()
	push_error("FAIL: " + message)
	quit(1)
