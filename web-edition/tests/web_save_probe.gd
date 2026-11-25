extends Node

const GAME_SCENE: PackedScene = preload("res://scenes/main.tscn")
const SAVE_MANAGER_SCRIPT: Script = preload("res://scripts/world/save_slot_manager.gd")
const SLOT_ID: String = "autosave"
const SAVED_POSITION: Vector3 = Vector3(-96.0, 0.0, 0.0)


func _ready() -> void:
	call_deferred("_run_probe")


func _run_probe() -> void:
	var mode := str(JavaScriptBridge.eval("(new URLSearchParams(window.location.search)).get('save_probe') || ''"))
	if mode == "cleanup":
		var manager: RefCounted = SAVE_MANAGER_SCRIPT.new()
		manager.call("delete_slot", SLOT_ID)
		_publish("cleaned")
		return
	if mode != "write" and mode != "read":
		_fail("invalid_mode")
		return

	var game: Node = GAME_SCENE.instantiate()
	if game == null:
		_fail("scene_missing")
		return
	add_child(game)
	await get_tree().process_frame
	await get_tree().process_frame
	_publish_storage_persistence()
	if mode == "write":
		_write_live_game_state(game)
	else:
		_verify_live_game_state(game)


func _write_live_game_state(game: Node) -> void:
	var player := game.get_node_or_null("Player") as CharacterBody3D
	var missions := game.get_node_or_null("MissionManager")
	if player == null or missions == null:
		_fail("live_game_nodes_missing")
		return
	var vitals: RefCounted = game.call("get_runtime_system", "player_vitals")
	var clock: RefCounted = game.call("get_runtime_system", "world_clock_weather")
	var weapons: RefCounted = game.call("get_runtime_system", "weapon_inventory")
	var activities: RefCounted = game.call("get_runtime_system", "side_activity_registry")
	var landmarks: RefCounted = game.call("get_runtime_system", "landmark_discovery")
	var relationships: RefCounted = game.call("get_runtime_system", "npc_relationship")
	var wanted: RefCounted = game.call("get_runtime_system", "wanted_level")
	var objectives: RefCounted = game.call("get_runtime_system", "mission_objectives")
	var rewards: RefCounted = game.call("get_runtime_system", "mission_rewards")
	var vehicles: Array = get_tree().get_nodes_in_group("drivable_vehicles")
	if vehicles.size() != 1:
		_fail("starter_vehicle_missing")
		return

	missions.set("mission_stage", 1)
	missions.set("wallet", 825)
	player.global_position = SAVED_POSITION
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

	var vehicle := vehicles[0] as Node3D
	vehicle.global_position = SAVED_POSITION
	vehicle.global_rotation = Vector3(0.0, 0.4, 0.0)
	if vehicle is CharacterBody3D:
		(vehicle as CharacterBody3D).velocity = Vector3.ZERO
	if not bool(player.call("restore_vehicle_state", vehicle)):
		_fail("vehicle_entry_failed")
		return
	if not bool(game.call("set_language", "ar")):
		_fail("arabic_setting_failed")
		return
	if not bool(game.call("_save_game_state", true)):
		_fail("live_game_save_failed")
		return

	var manager: RefCounted = SAVE_MANAGER_SCRIPT.new()
	var record: Dictionary = manager.call("load_slot", SLOT_ID)
	var payload: Dictionary = record.get("payload", {})
	if int(payload.get("schema_version", 0)) != 1 or int(payload.get("missions", {}).get("wallet", 0)) != 825:
		_fail("saved_payload_verification_failed")
		return
	_publish("written")


func _verify_live_game_state(game: Node) -> void:
	var player := game.get_node_or_null("Player") as CharacterBody3D
	var missions := game.get_node_or_null("MissionManager")
	if player == null or missions == null:
		_fail("restored_game_nodes_missing")
		return
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
	var vehicles: Array = get_tree().get_nodes_in_group("drivable_vehicles")
	if vehicles.size() != 1:
		_fail("restored_vehicle_missing")
		return
	var vehicle := vehicles[0] as Node3D

	if player.global_position.distance_to(SAVED_POSITION) > 0.05 or absf(player.global_rotation.y - 0.72) > 0.01:
		_fail("player_transform_not_restored")
		return
	if int(missions.get("mission_stage")) != 1 or int(missions.call("get_wallet")) != 825:
		_fail("mission_progress_not_restored")
		return
	if absf(float(vitals.get("health")) - 73.5) > 0.001 or absf(float(vitals.get("stamina")) - 41.25) > 0.001:
		_fail("player_vitals_not_restored")
		return
	if int(clock.get("minute_of_day")) != 1275 or str(clock.get("weather")) != "rain":
		_fail("world_clock_weather_not_restored")
		return
	if int(weapons.call("ammo_count", "starter_pistol")) != 17 or str(weapons.get("selected")) != "starter_pistol":
		_fail("weapon_inventory_not_restored")
		return
	if not bool(activities.call("get_activity", "lighthouse_view").get("completed", false)):
		_fail("activity_not_restored")
		return
	if not bool(landmarks.call("is_discovered", "marsa_al_noor")):
		_fail("landmark_not_restored")
		return
	if int(relationships.call("get_score", "nora_blake")) != 25 or int(wanted.call("get_level")) != 2:
		_fail("npc_or_wanted_state_not_restored")
		return
	if not bool(objectives.call("is_complete", "mission_001_claire_contact")):
		_fail("mission_objective_not_restored")
		return
	if not bool(rewards.call("is_settled", "mission_001")):
		_fail("mission_reward_not_restored")
		return
	if str(settings.call("get_value", "language")) != "ar":
		_fail("language_setting_not_restored")
		return
	if vehicle.global_position.distance_to(SAVED_POSITION) > 0.05:
		_fail("vehicle_transform_not_restored")
		return
	if player.call("get_driven_vehicle") != vehicle or player.collision_layer != 0 or player.collision_mask != 0:
		_fail("active_vehicle_state_not_restored")
		return
	_publish("restored")


func _publish_storage_persistence() -> void:
	var persistent_literal := JSON.stringify(OS.is_userfs_persistent())
	JavaScriptBridge.eval("document.documentElement.setAttribute('data-ghibli-userfs-persistent', " + persistent_literal + ");")


func _publish(status: String) -> void:
	var status_literal := JSON.stringify(status)
	JavaScriptBridge.eval("document.documentElement.setAttribute('data-ghibli-save-probe', " + status_literal + ");")


func _fail(code: String) -> void:
	var detail_literal := JSON.stringify(code)
	JavaScriptBridge.eval(
		"document.documentElement.setAttribute('data-ghibli-save-probe', 'failed');" +
		"document.documentElement.setAttribute('data-ghibli-save-probe-detail', " + detail_literal + ");"
	)
