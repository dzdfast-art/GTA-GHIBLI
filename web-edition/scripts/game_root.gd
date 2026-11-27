extends Node3D

const WORLD_SCRIPT = preload("res://scripts/world/world_builder.gd")
const PLAYER_SCRIPT = preload("res://scripts/player/player_controller.gd")
const MISSION_SCRIPT = preload("res://scripts/systems/mission_manager.gd")
const HUD_SCRIPT = preload("res://scripts/ui/game_hud.gd")
const ROUTE_PLANNER_SCRIPT = preload("res://scripts/world/route_planner.gd")
const ROUTE_PROGRESS_SCRIPT = preload("res://scripts/world/route_progress.gd")

const RUNTIME_SYSTEM_SCRIPTS := {
	"vehicle_route_follower": preload("res://scripts/vehicles/vehicle_route_follower.gd"),
	"region_registry": preload("res://scripts/world/region_registry.gd"),
	"landmark_discovery": preload("res://scripts/world/landmark_discovery.gd"),
	"npc_schedule": preload("res://scripts/world/npc_schedule.gd"),
	"npc_relationship": preload("res://scripts/world/npc_relationship.gd"),
	"pedestrian_navigation": preload("res://scripts/world/pedestrian_navigation.gd"),
	"pedestrian_crossing": preload("res://scripts/world/pedestrian_crossing.gd"),
	"side_activity_registry": preload("res://scripts/world/side_activity_registry.gd"),
	"shop_inventory": preload("res://scripts/world/shop_inventory.gd"),
	"mission_objectives": preload("res://scripts/world/mission_objectives.gd"),
	"world_event_manager": preload("res://scripts/world/world_event_manager.gd"),
	"save_slot_manager": preload("res://scripts/world/save_slot_manager.gd"),
	"checkpoint_system": preload("res://scripts/world/checkpoint_system.gd"),
	"wanted_level": preload("res://scripts/world/wanted_level.gd"),
	"police_pursuit": preload("res://scripts/world/police_pursuit.gd"),
	"traffic_spawn_budget": preload("res://scripts/world/traffic_spawn_budget.gd"),
	"vehicle_garage": preload("res://scripts/world/vehicle_garage.gd"),
	"vehicle_fuel": preload("res://scripts/world/vehicle_fuel.gd"),
	"vehicle_customization": preload("res://scripts/world/vehicle_customization.gd"),
	"vehicle_interaction": preload("res://scripts/world/vehicle_interaction.gd"),
	"parking_registry": preload("res://scripts/world/parking_registry.gd"),
	"weapon_inventory": preload("res://scripts/world/weapon_inventory.gd"),
	"player_vitals": preload("res://scripts/world/player_vitals.gd"),
	"world_pickup_registry": preload("res://scripts/world/world_pickup_registry.gd"),
	"world_clock_weather": preload("res://scripts/world/world_clock_weather.gd"),
	"ambient_audio_state": preload("res://scripts/world/ambient_audio_state.gd"),
	"map_marker_manager": preload("res://scripts/world/map_marker_manager.gd"),
	"fast_travel_registry": preload("res://scripts/world/fast_travel_registry.gd"),
	"dialogue_branching": preload("res://scripts/world/dialogue_branching.gd"),
	"localization_registry": preload("res://scripts/world/localization_registry.gd"),
	"contextual_input_map": preload("res://scripts/world/contextual_input_map.gd"),
	"camera_follow": preload("res://scripts/world/camera_follow.gd"),
	"camera_input_isolation": preload("res://scripts/world/camera_input_isolation.gd"),
	"touch_control_zones": preload("res://scripts/world/touch_control_zones.gd"),
	"hud_state": preload("res://scripts/world/hud_state.gd"),
	"pause_menu_state": preload("res://scripts/world/pause_menu_state.gd"),
	"settings_profile": preload("res://scripts/world/settings_profile.gd"),
	"mission_rewards": preload("res://scripts/world/mission_rewards.gd"),
	"mission_prerequisites": preload("res://scripts/world/mission_prerequisites.gd"),
	"crime_witness_memory": preload("res://scripts/world/crime_witness_memory.gd"),
	"police_search_grid": preload("res://scripts/world/police_search_grid.gd"),
	"economy_ledger": preload("res://scripts/world/economy_ledger.gd"),
	"faction_reputation": preload("res://scripts/world/faction_reputation.gd"),
	"collectible_tracker": preload("res://scripts/world/collectible_tracker.gd"),
	"safehouse_registry": preload("res://scripts/world/safehouse_registry.gd"),
	"garage_upgrade_progression": preload("res://scripts/world/garage_upgrade_progression.gd"),
	"performance_budget": preload("res://scripts/world/performance_budget.gd"),
	"region_streaming_state": preload("res://scripts/world/region_streaming_state.gd"),
	"accessibility_options": preload("res://scripts/world/accessibility_options.gd"),
	"integration_health": preload("res://scripts/world/integration_health.gd"),
	"web_acceptance_gate": preload("res://scripts/world/web_acceptance_gate.gd"),
	"route_progress": preload("res://scripts/world/route_progress.gd")
}

var _world: Node3D
var _player: CharacterBody3D
var _missions: Node
var _hud: CanvasLayer
var _route_planner: RefCounted
var _route_progress: RefCounted
var _runtime_systems: Dictionary = {}
var _landmark_check_elapsed: float = 0.0
var _world_context_elapsed: float = 0.0
var _sun: DirectionalLight3D
var _active_route: Dictionary = {}
var _location_elapsed: float = 0.0
var _minimap_elapsed: float = 0.0
var _navigation_elapsed: float = 0.0
var _points_of_interest: Array[Dictionary] = []
var _active_waypoint_id: String = ""
var _active_waypoint_name: String = ""
var _active_waypoint_position: Vector3 = Vector3.ZERO
var _arrival_notified: bool = false
var _autosave_elapsed: float = 0.0
var _last_autosave_payload_json: String = ""
var _is_restoring_game_state: bool = false


func _ready() -> void:
	_initialize_runtime_systems()
	_create_environment()
	_missions = MISSION_SCRIPT.new()
	_missions.name = "MissionManager"
	add_child(_missions)
	var initial_economy: RefCounted = get_runtime_system("economy_ledger")
	initial_economy.set("balance", int(_missions.call("get_wallet")))
	_world = WORLD_SCRIPT.new()
	_world.name = "World"
	add_child(_world)
	_world.call("build_world")
	_points_of_interest = _world.call("get_points_of_interest")
	_register_world_runtime_data()
	_route_planner = ROUTE_PLANNER_SCRIPT.new()
	_route_progress = ROUTE_PROGRESS_SCRIPT.new()
	if not bool(_route_planner.call("configure", _world.call("get_road_graph"))):
		push_error("The starter road graph could not be configured.")
	_player = PLAYER_SCRIPT.new()
	_player.name = "Player"
	add_child(_player)
	_player.global_position = _world.get("spawn_position")
	_hud = HUD_SCRIPT.new()
	_hud.name = "GameplayHUD"
	add_child(_hud)
	_hud.call("set_points_of_interest", _points_of_interest)
	_connect_gameplay_signals()
	_hud.call("set_objective", _missions.call("get_objective"))
	_hud.call("set_wallet", _missions.call("get_wallet"))
	_hud.call("set_location", _world.call("get_region_name_at", _player.global_position))
	_hud.call("update_minimap", _player.global_position, _player.global_rotation.y, _active_waypoint_position, false)
	_sync_runtime_hud_state()
	_restore_game_state()
	_synchronize_campaign_runtime_from_manager()
	_update_mission_waypoint()
	_sync_runtime_hud_state()
	_refresh_save_storage_status()
	_record_runtime_acceptance()


func _process(delta: float) -> void:
	_update_runtime_world_context(delta)
	_landmark_check_elapsed += delta
	if _landmark_check_elapsed >= 0.5:
		_landmark_check_elapsed = 0.0
		_discover_nearby_landmarks()
	_location_elapsed += delta
	_minimap_elapsed += delta
	if _location_elapsed >= 0.35 and _player != null and _world != null:
		_location_elapsed = 0.0
		_hud.call("set_location", _world.call("get_region_name_at", _player.global_position))
	if _minimap_elapsed >= 0.12 and _player != null and _hud != null:
		_minimap_elapsed = 0.0
		_hud.call("update_minimap", _player.global_position, _player.global_rotation.y, _active_waypoint_position, not _active_waypoint_id.is_empty())
	if not _active_waypoint_id.is_empty():
		_navigation_elapsed += delta
		if _navigation_elapsed >= 0.30:
			_navigation_elapsed = 0.0
			_update_navigation_route()
	_autosave_elapsed += delta
	if _autosave_elapsed >= 5.0:
		_autosave_elapsed = 0.0
		_save_game_state()


func _notification(what: int) -> void:
	if what != NOTIFICATION_APPLICATION_PAUSED and what != NOTIFICATION_WM_CLOSE_REQUEST:
		return
	if not is_instance_valid(_missions) or not is_instance_valid(_player):
		return
	_save_game_state(true)


func _connect_gameplay_signals() -> void:
	_missions.objective_changed.connect(_hud.set_objective)
	_missions.objective_changed.connect(_on_mission_objective_changed)
	_missions.mission_step_completed.connect(_on_mission_step_completed)
	_missions.mission_completed.connect(_on_mission_completed)
	_missions.progress_reset.connect(_on_mission_progress_reset)
	_missions.connect("notification_requested", Callable(_hud, "show_notification"))
	_missions.dialogue_changed.connect(_hud.show_dialogue)
	_missions.wallet_changed.connect(_hud.set_wallet)
	_missions.wallet_changed.connect(_on_wallet_changed)
	_player.prompt_changed.connect(_hud.set_prompt)
	_player.map_toggled.connect(_hud.toggle_map)
	_player.vehicle_state_changed.connect(_hud.set_vehicle_state)
	_player.vehicle_state_changed.connect(_on_vehicle_state_changed)
	_hud.connect("waypoint_selected", Callable(self, "_on_waypoint_selected"))
	_hud.connect("shop_purchase_requested", Callable(self, "_on_shop_purchase_requested"))
	_hud.connect("shop_sell_requested", Callable(self, "_on_shop_sell_requested"))
	for actor in get_tree().get_nodes_in_group("interactables"):
		if actor.has_signal("activated"):
			actor.connect("activated", Callable(self, "_on_world_interaction"))


func _on_world_interaction(action_id: String) -> void:
	match action_id:
		"market_enter":
			_enter_market_interior()
		"market_exit":
			_exit_market_interior()
		"market_shop":
			_open_market_shop()
		"claire":
			if int(_missions.get("mission_stage")) == 7:
				var shop: RefCounted = get_runtime_system("shop_inventory")
				if int(shop.call("get_quantity", "bottled_water")) < 1:
					_hud.call("show_notification", "أحضر زجاجة الماء من Harbor Market إلى Claire أولاً.")
					return
			_missions.call("handle_interaction", action_id)
		_:
			_missions.call("handle_interaction", action_id)


func _is_player_inside_market() -> bool:
	if _player == null:
		return false
	var position := _player.global_position
	return position.x >= -87.0 and position.x <= -75.0 and position.z >= 29.0 and position.z <= 43.0


func _enter_market_interior() -> void:
	if _player == null or _player.call("get_driven_vehicle") != null:
		_hud.call("show_notification", "اخرج من المركبة قبل دخول متجر Harbor Market.")
		return
	_player.global_position = Vector3(-81.0, 0.05, 31.2)
	_player.velocity = Vector3.ZERO
	_hud.call("show_notification", "دخلت متجر Harbor Market.")


func _exit_market_interior() -> void:
	if _player == null:
		return
	_hud.call("close_market_shop")
	_player.global_position = Vector3(-81.0, 0.05, 27.0)
	_player.velocity = Vector3.ZERO
	_hud.call("show_notification", "خرجت من متجر Harbor Market.")


func _open_market_shop() -> void:
	if not _is_player_inside_market():
		_hud.call("show_notification", "يجب دخول متجر Harbor Market أولاً.")
		return
	var shop: RefCounted = get_runtime_system("shop_inventory")
	_hud.call(
		"open_market_shop",
		shop.call("get_catalog"),
		shop.get("inventory"),
		int(_missions.call("get_wallet"))
	)


func _on_shop_purchase_requested(item_id: String) -> void:
	_purchase_market_item(item_id)


func _purchase_market_item(item_id: String) -> bool:
	if not _is_player_inside_market():
		_hud.call("set_market_shop_message", "Enter Harbor Market before buying.")
		return false
	var shop: RefCounted = get_runtime_system("shop_inventory")
	var previous_state: Dictionary = shop.call("snapshot")
	var wallet := int(_missions.call("get_wallet"))
	var result: Dictionary = shop.call("purchase", item_id, wallet, 1)
	if not bool(result.get("ok", false)):
		_hud.call("set_market_shop_message", _shop_transaction_error(str(result.get("reason", "invalid_item"))))
		return false
	var new_wallet := int(result.get("wallet", wallet))
	if not bool(_missions.call("set_wallet_balance", new_wallet, "market_purchase")):
		shop.call("restore", previous_state)
		_hud.call("set_market_shop_message", "Purchase could not be committed. No item was kept.")
		return false
	if item_id == "bottled_water" and int(_missions.get("mission_stage")) == 6:
		_missions.call("handle_interaction", "market_shop_purchase")
	_save_game_state(true)
	_hud.call("update_market_shop", shop.call("get_catalog"), shop.get("inventory"), new_wallet)
	_hud.call("set_market_shop_message", "Purchased %s for $%d." % [item_id.replace("_", " "), int(result.get("cost", 0))])
	_hud.call("show_notification", "Market purchase saved.")
	return true


func _on_shop_sell_requested(item_id: String) -> void:
	_sell_market_item(item_id)


func _sell_market_item(item_id: String) -> bool:
	if not _is_player_inside_market():
		_hud.call("set_market_shop_message", "Enter Harbor Market before selling.")
		return false
	if item_id == "bottled_water" and int(_missions.get("mission_stage")) == 7:
		_hud.call("set_market_shop_message", "Keep the mission water until you deliver it to Claire.")
		return false
	var shop: RefCounted = get_runtime_system("shop_inventory")
	var previous_state: Dictionary = shop.call("snapshot")
	var wallet := int(_missions.call("get_wallet"))
	var result: Dictionary = shop.call("sell", item_id, wallet, 1)
	if not bool(result.get("ok", false)):
		_hud.call("set_market_shop_message", _shop_transaction_error(str(result.get("reason", "invalid_item"))))
		return false
	var new_wallet := int(result.get("wallet", wallet))
	if not bool(_missions.call("set_wallet_balance", new_wallet, "market_sale")):
		shop.call("restore", previous_state)
		_hud.call("set_market_shop_message", "Sale could not be committed. No item was removed.")
		return false
	_save_game_state(true)
	_hud.call("update_market_shop", shop.call("get_catalog"), shop.get("inventory"), new_wallet)
	_hud.call("set_market_shop_message", "Sold %s for $%d." % [item_id.replace("_", " "), int(result.get("proceeds", 0))])
	_hud.call("show_notification", "Market sale saved.")
	return true


func _shop_transaction_error(reason: String) -> String:
	match reason:
		"out_of_stock":
			return "This item is out of stock."
		"insufficient_funds":
			return "Not enough money for this purchase."
		"not_owned":
			return "You do not have this item to sell."
		"stock_full":
			return "The shop cannot accept more of this item."
		"not_resellable":
			return "This item has no resale value."
		_:
			return "The requested trade is not available."


func _create_environment() -> void:
	var world_environment := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.39, 0.57, 0.68)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.78, 0.82, 0.78)
	environment.ambient_light_energy = 0.72
	world_environment.environment = environment
	add_child(world_environment)
	_sun = DirectionalLight3D.new()
	_sun.rotation_degrees = Vector3(-48.0, -28.0, 0.0)
	_sun.light_color = Color(1.0, 0.88, 0.70)
	_sun.light_energy = 1.25
	_sun.shadow_enabled = true
	add_child(_sun)


func _on_waypoint_selected(point_id: String, point_name: String, world_position: Vector3) -> void:
	_active_waypoint_id = point_id
	_active_waypoint_name = point_name
	_active_waypoint_position = world_position
	_arrival_notified = false
	_update_navigation_route()
	_hud.call("show_notification", "Waypoint selected — " + point_name)


func _update_navigation_route() -> void:
	if _route_planner == null or _route_progress == null or _player == null or _hud == null:
		return
	_active_route = _route_planner.call("find_route", _player.global_position, _active_waypoint_position, 36.0)
	_hud.call("set_navigation_route", _active_route)
	if not bool(_active_route.get("reachable", false)):
		_hud.call("set_waypoint_status", _active_waypoint_name, 0.0, false)
		_hud.call("set_navigation_guidance", "No connected road route")
		return
	var progress: Dictionary = _route_progress.call("evaluate", _active_route, _player.global_position)
	var remaining := float(progress.get("remaining_distance", _active_route.get("distance", 0.0)))
	_hud.call("set_waypoint_status", _active_waypoint_name, remaining, true)
	if bool(progress.get("arrived", false)):
		_hud.call("set_navigation_guidance", "You have arrived")
		if not _arrival_notified:
			_hud.call("show_notification", "Arrived at " + _active_waypoint_name)
			_arrival_notified = true
	else:
		_hud.call("set_navigation_guidance", _get_next_route_instruction(_active_route, progress))


func _get_next_route_instruction(route: Dictionary, progress: Dictionary) -> String:
	var nearest_position: Vector3 = progress.get("nearest_position", _player.global_position)
	for maneuver in route.get("maneuvers", []):
		var turn_position: Vector3 = maneuver.get("position", Vector3.ZERO)
		var distance_to_turn: float = nearest_position.distance_to(turn_position)
		if distance_to_turn > 3.0:
			return "%s in %.0f m" % [str(maneuver.get("instruction", "Turn")), distance_to_turn]
	return "Continue to destination"


func set_road_edge_blocked(edge_id: String, blocked: bool) -> bool:
	if _route_planner == null:
		return false
	var updated := bool(_route_planner.call("set_edge_blocked", edge_id, blocked))
	if updated and not _active_waypoint_id.is_empty():
		_update_navigation_route()
	return updated



func _initialize_runtime_systems() -> void:
	for system_id in RUNTIME_SYSTEM_SCRIPTS:
		var system_script: Script = RUNTIME_SYSTEM_SCRIPTS[system_id]
		var instance: Variant = system_script.new()
		if not (instance is RefCounted):
			push_error("Runtime system '%s' is not a RefCounted service." % system_id)
			continue
		_runtime_systems[system_id] = instance
	var prerequisites: Array[String] = []
	var mission_one: Array[String] = ["mission_001"]
	var mission_two: Array[String] = ["mission_002"]
	get_runtime_system("mission_prerequisites").call("define", "mission_001", prerequisites)
	get_runtime_system("mission_prerequisites").call("define", "mission_002", mission_one)
	get_runtime_system("mission_prerequisites").call("define", "mission_003", mission_two)
	get_runtime_system("mission_objectives").call("add_objective", "mission_001_claire_contact", 1)
	get_runtime_system("mission_objectives").call("add_objective", "mission_001_nora_meeting", 1)
	get_runtime_system("mission_objectives").call("add_objective", "mission_002_nora_start", 1)
	get_runtime_system("mission_objectives").call("add_objective", "mission_002_noticeboard", 1)
	get_runtime_system("mission_objectives").call("add_objective", "mission_002_return_to_nora", 1)
	get_runtime_system("mission_objectives").call("add_objective", "mission_003_nora_start", 1)
	get_runtime_system("mission_objectives").call("add_objective", "mission_003_buy_water", 1)
	get_runtime_system("mission_objectives").call("add_objective", "mission_003_return_to_claire", 1)
	var shop: RefCounted = get_runtime_system("shop_inventory")
	shop.call("add_item", "bottled_water", 12, 8)
	shop.call("add_item", "fruit_basket", 25, 5)
	shop.call("add_item", "first_aid_kit", 80, 3)
	get_runtime_system("checkpoint_system").call("set_checkpoints", [Vector3(-114.0, 0.0, 0.0), Vector3(-75.0, 0.0, 11.0)])
	get_runtime_system("traffic_spawn_budget").call("configure", 24)
	get_runtime_system("performance_budget").call("configure", "npcs", 40)
	get_runtime_system("performance_budget").call("configure", "vehicles", 24)
	get_runtime_system("performance_budget").call("configure", "effects", 30)


func _register_world_runtime_data() -> void:
	var region_registry: RefCounted = get_runtime_system("region_registry")
	var region_ids: Array[String] = ["harbor_city", "sapphire_coast", "pine_highlands", "amber_valley"]
	var region_labels: Array[String] = ["Harbor City", "Sapphire Coast", "Pine Highlands", "Amber Valley"]
	for index in range(region_ids.size()):
		var bounds := Rect2(Vector2(-128.0 + index * 64.0, -32.0), Vector2(64.0, 64.0))
		region_registry.call("register_region", region_ids[index], bounds, region_labels[index])
		var streaming: RefCounted = get_runtime_system("region_streaming_state")
		streaming.call("request_load", region_ids[index])
		streaming.call("mark_loaded", region_ids[index])
	for point in _points_of_interest:
		get_runtime_system("map_marker_manager").call("add_marker", str(point.id), point.position, str(point.category))
	get_runtime_system("fast_travel_registry").call("unlock", "harbor_city", Vector3(-114.0, 0.0, 0.0))
	get_runtime_system("parking_registry").call("add_space", "harbor_market_parking", Vector3(-81.0, 0.0, 25.0))
	get_runtime_system("safehouse_registry").call("register_house", "pine_cabin", Vector3(14.0, 0.0, -18.0), 2500)
	get_runtime_system("side_activity_registry").call("register_activity", "lighthouse_view", "Lighthouse Viewpoint", 100, Vector3(-79.0, 0.0, 17.0))
	get_runtime_system("world_event_manager").call("schedule_event", "harbor_market_opening", 8.0 * 60.0, 10.0 * 60.0, {"region": "harbor_city"})
	get_runtime_system("world_clock_weather").call("set_weather", "clear")
	_update_runtime_world_context(0.0)


func _update_runtime_world_context(delta: float) -> void:
	if _runtime_systems.is_empty() or _player == null or _world == null:
		return
	_world_context_elapsed += delta
	var clock: RefCounted = get_runtime_system("world_clock_weather")
	var audio_state: RefCounted = get_runtime_system("ambient_audio_state")
	var region_registry: RefCounted = get_runtime_system("region_registry")
	var region_id: String = region_registry.call("find_region", Vector2(_player.global_position.x, _player.global_position.z))
	var region: Dictionary = region_registry.call("get_region", region_id)
	var region_label := str(region.get("label", _world.call("get_region_name_at", _player.global_position)))
	audio_state.call("update_context", region_label, clock.call("get_period"), clock.get("weather"))
	if _world_context_elapsed >= 1.0:
		_world_context_elapsed = 0.0
		var period := str(clock.call("get_period"))
		if _sun != null:
			match period:
				"morning":
					_sun.light_energy = 0.95
					_sun.light_color = Color(1.0, 0.78, 0.57)
				"day":
					_sun.light_energy = 1.25
					_sun.light_color = Color(1.0, 0.91, 0.78)
				"evening":
					_sun.light_energy = 0.72
					_sun.light_color = Color(1.0, 0.58, 0.34)
				"night":
					_sun.light_energy = 0.22
					_sun.light_color = Color(0.40, 0.52, 0.80)


func _discover_nearby_landmarks() -> void:
	if _player == null or _hud == null:
		return
	var discovery: RefCounted = get_runtime_system("landmark_discovery")
	for point in _points_of_interest:
		if str(point.category) != "landmark":
			continue
		var was_discovered: bool = discovery.call("is_discovered", str(point.id))
		if not was_discovered and discovery.call("discover", str(point.id), _player.global_position, point.position, 7.0):
			_hud.call("show_notification", "Landmark discovered — " + str(point.name))


func _sync_runtime_hud_state() -> void:
	var hud_state: RefCounted = get_runtime_system("hud_state")
	var vitals: RefCounted = get_runtime_system("player_vitals")
	hud_state.call("update_health", float(vitals.get("health")))
	var wallet := int(_missions.call("get_wallet"))
	var money_difference := wallet - int(hud_state.get("money"))
	hud_state.call("add_money", money_difference)
	hud_state.set("vehicle_mode", _player.call("get_driven_vehicle") != null)


func _record_runtime_acceptance() -> void:
	var health: RefCounted = get_runtime_system("integration_health")
	var gate: RefCounted = get_runtime_system("web_acceptance_gate")
	for system_id in RUNTIME_SYSTEM_SCRIPTS:
		health.call("record_check", "service:" + system_id, _runtime_systems.has(system_id), "runtime service initialized")
	health.call("record_check", "world", _world != null, "world builder attached")
	health.call("record_check", "player", _player != null, "player controller attached")
	health.call("record_check", "gps", _route_planner != null, "road graph route planner initialized")
	health.call("record_check", "hud", _hud != null, "gameplay HUD attached")
	health.call("record_check", "save", _missions != null and _missions.has_method("get_wallet"), "mission save manager available")
	var has_vehicle := not get_tree().get_nodes_in_group("drivable_vehicles").is_empty()
	health.call("record_check", "vehicle", has_vehicle, "starting drivable vehicle present")
	gate.call("record", "world", _world != null)
	gate.call("record", "player", _player != null)
	gate.call("record", "vehicle", has_vehicle)
	gate.call("record", "gps", _route_planner != null)
	gate.call("record", "hud", _hud != null)
	gate.call("record", "save", _missions != null and _missions.has_method("get_wallet"))


func get_runtime_system(system_id: String) -> RefCounted:
	return _runtime_systems.get(system_id) as RefCounted


func get_runtime_system_ids() -> Array[String]:
	var result: Array[String] = []
	for system_id in _runtime_systems:
		result.append(str(system_id))
	result.sort()
	return result


func get_runtime_health_report() -> Dictionary:
	return get_runtime_system("integration_health").call("get_report")


func get_web_acceptance_status() -> Dictionary:
	var gate: RefCounted = get_runtime_system("web_acceptance_gate")
	return {"can_release": gate.call("can_release"), "missing": gate.call("missing"), "failures": gate.call("failures")}


func set_language(language: String) -> bool:
	if not bool(get_runtime_system("localization_registry").call("set_locale", language)):
		return false
	var updated := bool(get_runtime_system("settings_profile").call("set_value", "language", language))
	if updated and not _is_restoring_game_state:
		_save_game_state(true)
	return updated


func report_crime(severity: int = 1) -> int:
	var level: int = get_runtime_system("wanted_level").call("add_crime", severity)
	if level > 0:
		var pursuit: RefCounted = get_runtime_system("police_pursuit")
		if str(pursuit.get("state")) == "idle":
			pursuit.call("start", _player.global_position)
		get_runtime_system("hud_state").call("set_wanted", level)
		_hud.call("show_notification", "Wanted level — " + "★".repeat(level))
	return level


func update_police_sighting(visible: bool, delta: float) -> String:
	return str(get_runtime_system("police_pursuit").call("update_sighting", _player.global_position, visible, delta))


func update_wanted_cooldown(delta: float, player_hidden: bool) -> int:
	var level: int = get_runtime_system("wanted_level").call("tick", delta, player_hidden)
	get_runtime_system("hud_state").call("set_wanted", level)
	return level


func try_reserve_traffic_vehicle() -> bool:
	return bool(get_runtime_system("traffic_spawn_budget").call("try_spawn"))


func release_traffic_vehicle(count: int = 1) -> int:
	return int(get_runtime_system("traffic_spawn_budget").call("despawn", count))


func _on_mission_objective_changed(_text: String) -> void:
	_update_mission_waypoint()
	if not _is_restoring_game_state:
		_save_game_state(true)


func _on_mission_step_completed(mission_id: String, step_id: String) -> void:
	var objective_id := ""
	match mission_id:
		"mission_001":
			match step_id:
				"speak_to_claire":
					objective_id = "mission_001_claire_contact"
				"meet_nora":
					objective_id = "mission_001_nora_meeting"
		"mission_002":
			match step_id:
				"start_at_nora":
					objective_id = "mission_002_nora_start"
				"inspect_noticeboard":
					objective_id = "mission_002_noticeboard"
				"return_to_nora":
					objective_id = "mission_002_return_to_nora"
		"mission_003":
			match step_id:
				"start_at_nora":
					objective_id = "mission_003_nora_start"
				"enter_market":
					objective_id = "mission_003_enter_market"
				"buy_water":
					objective_id = "mission_003_buy_water"
				"return_to_claire":
					objective_id = "mission_003_return_to_claire"
	if objective_id.is_empty():
		return
	var objectives: RefCounted = get_runtime_system("mission_objectives")
	if not bool(objectives.call("add_progress", objective_id, 1)):
		push_warning("Could not record mission objective progress: %s" % objective_id)


func _on_mission_completed(mission_id: String) -> void:
	var reward_values: Dictionary = {
		"mission_001": {"cash": 250, "respect": 1},
		"mission_002": {"cash": 300, "respect": 2},
		"mission_003": {"cash": 150, "respect": 1}
	}
	if not reward_values.has(mission_id):
		return
	var prerequisites: RefCounted = get_runtime_system("mission_prerequisites")
	var completed: Dictionary = prerequisites.get("completed")
	if not completed.has(mission_id) and not bool(prerequisites.call("complete", mission_id)):
		push_warning("Mission prerequisite completion was rejected: %s" % mission_id)
	var rewards: RefCounted = get_runtime_system("mission_rewards")
	var reward: Dictionary = reward_values[mission_id]
	if not bool(rewards.call("is_settled", mission_id)):
		var settlement: Dictionary = rewards.call(
			"settle", mission_id, int(reward.cash), int(reward.respect)
		)
		if not bool(settlement.get("ok", false)):
			push_warning("Mission reward ledger rejected settlement: %s" % mission_id)


func _on_mission_progress_reset() -> void:
	var objectives: RefCounted = get_runtime_system("mission_objectives")
	var objective_records: Dictionary = objectives.get("objectives")
	for objective_id in objective_records:
		var record: Dictionary = objective_records[objective_id]
		record["progress"] = 0
	objectives.set("objectives", objective_records)
	get_runtime_system("mission_rewards").set("settled", {})
	get_runtime_system("mission_prerequisites").set("completed", {})
	get_runtime_system("shop_inventory").call("reset")


func _synchronize_campaign_runtime_from_manager() -> void:
	if _missions == null:
		return
	var stage := int(_missions.get("mission_stage"))
	var objectives: RefCounted = get_runtime_system("mission_objectives")
	var prerequisites: RefCounted = get_runtime_system("mission_prerequisites")
	var completed: Dictionary = prerequisites.get("completed")
	var rewards: RefCounted = get_runtime_system("mission_rewards")
	if stage >= 1:
		objectives.call("add_progress", "mission_001_claire_contact", 1)
	if stage >= 2:
		objectives.call("add_progress", "mission_001_nora_meeting", 1)
		if not completed.has("mission_001"):
			prerequisites.call("complete", "mission_001")
		if not bool(rewards.call("is_settled", "mission_001")):
			rewards.call("settle", "mission_001", 250, 1)
	if stage >= 3:
		objectives.call("add_progress", "mission_002_nora_start", 1)
	if stage >= 4:
		objectives.call("add_progress", "mission_002_noticeboard", 1)
	if stage >= 5:
		objectives.call("add_progress", "mission_002_return_to_nora", 1)
		completed = prerequisites.get("completed")
		if not completed.has("mission_002"):
			prerequisites.call("complete", "mission_002")
		if not bool(rewards.call("is_settled", "mission_002")):
			rewards.call("settle", "mission_002", 300, 2)
	if stage >= 6:
		objectives.call("add_progress", "mission_003_nora_start", 1)
	if stage >= 7:
		objectives.call("add_progress", "mission_003_enter_market", 1)
		objectives.call("add_progress", "mission_003_buy_water", 1)
	if stage >= 8:
		objectives.call("add_progress", "mission_003_return_to_claire", 1)
		completed = prerequisites.get("completed")
		if not completed.has("mission_003"):
			prerequisites.call("complete", "mission_003")
		if not bool(rewards.call("is_settled", "mission_003")):
			rewards.call("settle", "mission_003", 150, 1)


func _update_mission_waypoint() -> void:
	if _missions == null or _player == null or _hud == null:
		return
	var stage := int(_missions.get("mission_stage"))
	var target_id := ""
	if stage == 1 or stage == 2 or stage == 4:
		target_id = "nora_blake"
	elif stage == 3:
		target_id = "harbor_market_noticeboard"
	elif stage == 6:
		target_id = "harbor_market"
	elif stage == 7:
		target_id = "claire_bennett"
	if target_id.is_empty():
		if _active_waypoint_id in ["nora_blake", "harbor_market_noticeboard", "harbor_market", "claire_bennett"]:
			_active_waypoint_id = ""
			_active_waypoint_name = ""
			_active_waypoint_position = Vector3.ZERO
			_active_route = {}
			_hud.call("set_navigation_route", {})
			_hud.call("set_waypoint_status", "", 0.0, false)
			_hud.call("set_navigation_guidance", "Mission complete — explore the world")
		return
	if _active_waypoint_id == target_id:
		return
	for point in _points_of_interest:
		if str(point.get("id", "")) != target_id:
			continue
		_active_waypoint_id = target_id
		_active_waypoint_name = str(point.get("name", target_id))
		_active_waypoint_position = point.get("position", Vector3.ZERO)
		_arrival_notified = false
		_update_navigation_route()
		return


func _on_wallet_changed(amount: int) -> void:
	var hud_state: RefCounted = get_runtime_system("hud_state")
	var difference := amount - int(hud_state.get("money"))
	hud_state.call("add_money", difference)
	var economy: RefCounted = get_runtime_system("economy_ledger")
	var ledger_difference := amount - int(economy.get("balance"))
	if ledger_difference != 0 and not bool(economy.call("transact", ledger_difference, "wallet_change")):
		push_warning("The economy ledger rejected a wallet change.")
	if not _is_restoring_game_state:
		_save_game_state(true)



func _save_game_state(force: bool = false) -> bool:
	if _is_restoring_game_state or _missions == null or _player == null or _runtime_systems.is_empty():
		return false
	var payload: Dictionary = _capture_game_state()
	var payload_json: String = JSON.stringify(payload)
	if payload_json.is_empty():
		return false
	if not force and payload_json == _last_autosave_payload_json:
		return true
	var manager: RefCounted = get_runtime_system("save_slot_manager")
	var saved := bool(manager.call(
		"save_slot", "autosave", payload, int(Time.get_unix_time_from_system())
	))
	if saved:
		_last_autosave_payload_json = payload_json
	_refresh_save_storage_status(saved)
	return saved


func _refresh_save_storage_status(save_succeeded: bool = true) -> void:
	if _hud == null:
		return
	var manager: RefCounted = get_runtime_system("save_slot_manager")
	var settings: RefCounted = get_runtime_system("settings_profile")
	if manager == null:
		return
	var persistent := bool(manager.call("is_storage_persistent"))
	var language := str(settings.call("get_value", "language")) if settings != null else "en"
	var message := str(manager.call(
		"get_storage_status_message", persistent, OS.has_feature("web"), language, save_succeeded
	))
	_hud.call("set_save_storage_status", message, persistent, save_succeeded)


func _capture_game_state() -> Dictionary:
	var vitals: RefCounted = get_runtime_system("player_vitals")
	var clock: RefCounted = get_runtime_system("world_clock_weather")
	var weapon_inventory: RefCounted = get_runtime_system("weapon_inventory")
	var activity_system: RefCounted = get_runtime_system("side_activity_registry")
	var landmark_system: RefCounted = get_runtime_system("landmark_discovery")
	var pickup_system: RefCounted = get_runtime_system("world_pickup_registry")
	var objective_system: RefCounted = get_runtime_system("mission_objectives")
	var reward_system: RefCounted = get_runtime_system("mission_rewards")
	var prerequisite_system: RefCounted = get_runtime_system("mission_prerequisites")
	var relationship_system: RefCounted = get_runtime_system("npc_relationship")
	var wanted_system: RefCounted = get_runtime_system("wanted_level")
	var collectible_system: RefCounted = get_runtime_system("collectible_tracker")
	var faction_system: RefCounted = get_runtime_system("faction_reputation")
	var economy_system: RefCounted = get_runtime_system("economy_ledger")
	var settings_system: RefCounted = get_runtime_system("settings_profile")
	var checkpoint_system: RefCounted = get_runtime_system("checkpoint_system")
	var garage_upgrade_system: RefCounted = get_runtime_system("garage_upgrade_progression")
	var safehouse_system: RefCounted = get_runtime_system("safehouse_registry")
	var fuel_system: RefCounted = get_runtime_system("vehicle_fuel")
	var parking_system: RefCounted = get_runtime_system("parking_registry")
	var shop_system: RefCounted = get_runtime_system("shop_inventory")

	var activity_records: Dictionary = activity_system.get("activities")
	var completed_activities: Array[String] = []
	for activity_id in activity_records:
		if bool(activity_records[activity_id].get("completed", false)):
			completed_activities.append(str(activity_id))
	completed_activities.sort()

	var landmark_records: Dictionary = landmark_system.get("discovered")
	var discovered_landmarks: Array[String] = []
	for landmark_id in landmark_records:
		discovered_landmarks.append(str(landmark_id))
	discovered_landmarks.sort()

	var pickup_records: Dictionary = pickup_system.get("pickups")
	var collected_pickups: Array[String] = []
	for pickup_id in pickup_records:
		if bool(pickup_records[pickup_id].get("collected", false)):
			collected_pickups.append(str(pickup_id))
	collected_pickups.sort()

	var safehouse_records: Dictionary = safehouse_system.get("houses")
	var owned_safehouses: Array[String] = []
	for house_id in safehouse_records:
		if bool(safehouse_records[house_id].get("owned", false)):
			owned_safehouses.append(str(house_id))
	owned_safehouses.sort()

	var parking_records: Dictionary = parking_system.get("spaces")
	var parking_reservations: Dictionary = {}
	for space_id in parking_records:
		var reserved_vehicle := str(parking_records[space_id].get("vehicle", ""))
		if not reserved_vehicle.is_empty():
			parking_reservations[str(space_id)] = reserved_vehicle

	var vehicles: Dictionary = {}
	var active_vehicle_id := ""
	var active_vehicle: Node3D = _player.call("get_driven_vehicle")
	for candidate in get_tree().get_nodes_in_group("drivable_vehicles"):
		if not candidate is Node3D or not candidate.has_method("get_save_id"):
			continue
		var vehicle := candidate as Node3D
		var vehicle_id := str(vehicle.call("get_save_id"))
		if vehicle_id.is_empty():
			continue
		var vehicle_velocity := Vector3.ZERO
		if vehicle is CharacterBody3D:
			vehicle_velocity = (vehicle as CharacterBody3D).velocity
		vehicles[vehicle_id] = {
			"position": _vector3_to_array(vehicle.global_position),
			"rotation": _vector3_to_array(vehicle.global_rotation),
			"velocity": _vector3_to_array(vehicle_velocity)
		}
		if vehicle == active_vehicle:
			active_vehicle_id = vehicle_id

	var economy_entries: Array = economy_system.get("entries").duplicate(true)
	var settings_values: Dictionary = settings_system.get("values").duplicate(true)
	var collectible_found: Dictionary = collectible_system.get("found").duplicate(true)
	var faction_reputation: Dictionary = faction_system.get("reputation").duplicate(true)
	var garage_levels: Dictionary = garage_upgrade_system.get("levels").duplicate(true)
	var relationship_scores: Dictionary = relationship_system.get("scores").duplicate(true)
	var mission_objectives: Dictionary = objective_system.get("objectives").duplicate(true)
	var mission_rewards: Dictionary = reward_system.get("settled").duplicate(true)
	var mission_completed: Dictionary = prerequisite_system.get("completed").duplicate(true)
	var weapon_state: Dictionary = {
		"weapons": weapon_inventory.get("weapons").duplicate(true),
		"selected": str(weapon_inventory.get("selected"))
	}

	return {
		"schema_version": 1,
		"player": {
			"position": _vector3_to_array(_player.global_position),
			"rotation": _vector3_to_array(_player.global_rotation),
			"velocity": _vector3_to_array(_player.velocity)
		},
		"missions": {
			"stage": int(_missions.get("mission_stage")),
			"wallet": int(_missions.call("get_wallet"))
		},
		"vitals": {
			"health": float(vitals.get("health")),
			"stamina": float(vitals.get("stamina"))
		},
		"world": {
			"minute_of_day": int(clock.get("minute_of_day")),
			"weather": str(clock.get("weather"))
		},
		"weapons": weapon_state,
		"mission_objectives": mission_objectives,
		"mission_rewards": mission_rewards,
		"mission_completed": mission_completed,
		"landmarks_discovered": discovered_landmarks,
		"activities_completed": completed_activities,
		"pickups_collected": collected_pickups,
		"npc_relationships": relationship_scores,
		"wanted": {
			"level": int(wanted_system.get("level")),
			"cooldown": float(wanted_system.get("cooldown"))
		},
		"collectibles_found": collectible_found,
		"faction_reputation": faction_reputation,
		"economy": {
			"balance": int(economy_system.get("balance")),
			"entries": economy_entries
		},
		"settings": settings_values,
		"checkpoint_index": int(checkpoint_system.get("current_index")),
		"garage_upgrade_levels": garage_levels,
		"safehouses_owned": owned_safehouses,
		"vehicle_fuel": float(fuel_system.get("fuel")),
		"parking_reservations": parking_reservations,
		"shop": shop_system.call("snapshot"),
		"vehicles": vehicles,
		"active_vehicle_id": active_vehicle_id
	}


func _restore_game_state() -> bool:
	if _missions == null or _player == null or _runtime_systems.is_empty():
		return false
	_is_restoring_game_state = true
	var manager: RefCounted = get_runtime_system("save_slot_manager")
	var record: Dictionary = manager.call("load_slot", "autosave")
	var payload_value: Variant = record.get("payload", {})
	if record.is_empty() or not payload_value is Dictionary:
		_is_restoring_game_state = false
		return false
	var payload: Dictionary = payload_value
	var payload_version := int(payload.get("schema_version", 0))
	if payload_version == 0 and (payload.has("mission_stage") or payload.has("wallet")):
		_missions.set("mission_stage", clampi(int(payload.get("mission_stage", 0)), 0, 8))
		_missions.set("wallet", maxi(0, int(payload.get("wallet", 350))))
		_hud.call("set_objective", _missions.call("get_objective"))
		_hud.call("set_wallet", _missions.call("get_wallet"))
		_sync_runtime_hud_state()
		_is_restoring_game_state = false
		_save_game_state(true)
		return true
	if payload_version != 1:
		_is_restoring_game_state = false
		return false

	var player_state: Variant = payload.get("player", {})
	if player_state is Dictionary:
		var saved_position: Vector3 = _vector3_from_array(player_state.get("position", []), _player.global_position)
		if _is_safe_world_position(saved_position):
			_player.global_position = saved_position
		_player.global_rotation = _vector3_from_array(player_state.get("rotation", []), _player.global_rotation)
		_player.velocity = _vector3_from_array(player_state.get("velocity", []), Vector3.ZERO)

	var mission_state: Variant = payload.get("missions", {})
	if mission_state is Dictionary:
		_missions.set("mission_stage", clampi(int(mission_state.get("stage", 0)), 0, 8))
		_missions.set("wallet", maxi(0, int(mission_state.get("wallet", 350))))

	var vitals: RefCounted = get_runtime_system("player_vitals")
	var vitals_state: Variant = payload.get("vitals", {})
	if vitals_state is Dictionary:
		vitals.set("health", clampf(float(vitals_state.get("health", 100.0)), 0.0, float(vitals.get("max_health"))))
		vitals.set("stamina", clampf(float(vitals_state.get("stamina", 100.0)), 0.0, float(vitals.get("max_stamina"))))

	var clock: RefCounted = get_runtime_system("world_clock_weather")
	var world_state: Variant = payload.get("world", {})
	if world_state is Dictionary:
		clock.set("minute_of_day", clampi(int(world_state.get("minute_of_day", 8 * 60)), 0, 1439))
		clock.call("set_weather", str(world_state.get("weather", "clear")))

	var weapon_inventory: RefCounted = get_runtime_system("weapon_inventory")
	var weapon_state: Variant = payload.get("weapons", {})
	if weapon_state is Dictionary:
		var saved_weapons: Variant = weapon_state.get("weapons", {})
		if saved_weapons is Dictionary:
			var clean_weapons: Dictionary = {}
			for weapon_id in saved_weapons:
				var clean_id := str(weapon_id)
				if not clean_id.is_empty():
					clean_weapons[clean_id] = maxi(0, int(saved_weapons[weapon_id]))
			weapon_inventory.set("weapons", clean_weapons)
			var selected_weapon := str(weapon_state.get("selected", ""))
			if clean_weapons.has(selected_weapon):
				weapon_inventory.set("selected", selected_weapon)
			else:
				var weapon_ids: Array = clean_weapons.keys()
				weapon_ids.sort()
				weapon_inventory.set("selected", str(weapon_ids[0]) if not weapon_ids.is_empty() else "")

	var objective_system: RefCounted = get_runtime_system("mission_objectives")
	var saved_objectives: Variant = payload.get("mission_objectives", {})
	if saved_objectives is Dictionary:
		var current_objectives: Dictionary = objective_system.get("objectives")
		for objective_id in current_objectives:
			var saved_objective: Variant = saved_objectives.get(objective_id, {})
			if saved_objective is Dictionary:
				var current_entry: Dictionary = current_objectives[objective_id]
				var target := int(current_entry.get("target", 0))
				current_entry["progress"] = clampi(int(saved_objective.get("progress", 0)), 0, target)
		objective_system.set("objectives", current_objectives)

	var reward_system: RefCounted = get_runtime_system("mission_rewards")
	var saved_rewards: Variant = payload.get("mission_rewards", {})
	if saved_rewards is Dictionary:
		reward_system.set("settled", saved_rewards.duplicate(true))

	var prerequisite_system: RefCounted = get_runtime_system("mission_prerequisites")
	var saved_completed: Variant = payload.get("mission_completed", {})
	if saved_completed is Dictionary:
		prerequisite_system.set("completed", saved_completed.duplicate(true))

	var activity_system: RefCounted = get_runtime_system("side_activity_registry")
	var completed_activities: Variant = payload.get("activities_completed", [])
	if completed_activities is Array:
		var activity_records: Dictionary = activity_system.get("activities")
		for activity_id in activity_records:
			var activity_record: Dictionary = activity_records[activity_id]
			activity_record["completed"] = completed_activities.has(str(activity_id))

	var landmark_system: RefCounted = get_runtime_system("landmark_discovery")
	var saved_landmarks: Variant = payload.get("landmarks_discovered", [])
	if saved_landmarks is Array:
		var discovered_records: Dictionary = {}
		for landmark_id_value in saved_landmarks:
			var landmark_id := str(landmark_id_value)
			for point in _points_of_interest:
				if str(point.get("id", "")) == landmark_id and str(point.get("category", "")) == "landmark":
					discovered_records[landmark_id] = {
						"position": point.get("position", Vector3.ZERO),
						"discovered_at_distance": 0.0
					}
					break
		landmark_system.set("discovered", discovered_records)

	var pickup_system: RefCounted = get_runtime_system("world_pickup_registry")
	var saved_pickups: Variant = payload.get("pickups_collected", [])
	if saved_pickups is Array:
		var pickup_records: Dictionary = pickup_system.get("pickups")
		for pickup_id in pickup_records:
			var pickup_record: Dictionary = pickup_records[pickup_id]
			pickup_record["collected"] = saved_pickups.has(str(pickup_id))

	var relationship_system: RefCounted = get_runtime_system("npc_relationship")
	var saved_relationships: Variant = payload.get("npc_relationships", {})
	if saved_relationships is Dictionary:
		var clean_scores: Dictionary = {}
		for npc_id in saved_relationships:
			clean_scores[str(npc_id)] = clampi(int(saved_relationships[npc_id]), -100, 100)
		relationship_system.set("scores", clean_scores)

	var wanted_system: RefCounted = get_runtime_system("wanted_level")
	var wanted_state: Variant = payload.get("wanted", {})
	if wanted_state is Dictionary:
		wanted_system.set("level", clampi(int(wanted_state.get("level", 0)), 0, int(wanted_system.get("max_level"))))
		wanted_system.set("cooldown", clampf(float(wanted_state.get("cooldown", 0.0)), 0.0, 30.0))

	var collectible_system: RefCounted = get_runtime_system("collectible_tracker")
	var saved_collectibles: Variant = payload.get("collectibles_found", {})
	if saved_collectibles is Dictionary:
		var clean_collectibles: Dictionary = {}
		for collectible_id in saved_collectibles:
			if bool(saved_collectibles[collectible_id]):
				clean_collectibles[str(collectible_id)] = true
		collectible_system.set("found", clean_collectibles)

	var faction_system: RefCounted = get_runtime_system("faction_reputation")
	var saved_factions: Variant = payload.get("faction_reputation", {})
	if saved_factions is Dictionary:
		var clean_reputation: Dictionary = {}
		for faction_id in saved_factions:
			clean_reputation[str(faction_id)] = clampi(int(saved_factions[faction_id]), -100, 100)
		faction_system.set("reputation", clean_reputation)

	var economy_system: RefCounted = get_runtime_system("economy_ledger")
	var economy_state: Variant = payload.get("economy", {})
	if economy_state is Dictionary:
		economy_system.set("balance", maxi(0, int(economy_state.get("balance", 0))))
		var clean_entries: Array[Dictionary] = []
		var saved_entries: Variant = economy_state.get("entries", [])
		if saved_entries is Array:
			for entry in saved_entries:
				if entry is Dictionary:
					clean_entries.append(entry.duplicate(true))
		economy_system.set("entries", clean_entries)

	var shop_system: RefCounted = get_runtime_system("shop_inventory")
	var saved_shop: Variant = payload.get("shop", {})
	if saved_shop is Dictionary and not bool(shop_system.call("restore", saved_shop)):
		push_warning("The saved Harbor Market inventory was invalid; default stock was retained.")

	var settings_system: RefCounted = get_runtime_system("settings_profile")
	var saved_settings: Variant = payload.get("settings", {})
	if saved_settings is Dictionary:
		for setting_id in saved_settings:
			settings_system.call("set_value", str(setting_id), saved_settings[setting_id])
		var language := str(settings_system.call("get_value", "language"))
		get_runtime_system("localization_registry").call("set_locale", language)

	var checkpoint_system: RefCounted = get_runtime_system("checkpoint_system")
	var checkpoints: Array = checkpoint_system.get("checkpoints")
	checkpoint_system.set("current_index", clampi(int(payload.get("checkpoint_index", 0)), 0, checkpoints.size()))

	var garage_upgrade_system: RefCounted = get_runtime_system("garage_upgrade_progression")
	var saved_garage_levels: Variant = payload.get("garage_upgrade_levels", {})
	if saved_garage_levels is Dictionary:
		var clean_levels: Dictionary = {}
		for vehicle_id in saved_garage_levels:
			clean_levels[str(vehicle_id)] = maxi(0, int(saved_garage_levels[vehicle_id]))
		garage_upgrade_system.set("levels", clean_levels)

	var safehouse_system: RefCounted = get_runtime_system("safehouse_registry")
	var saved_safehouses: Variant = payload.get("safehouses_owned", [])
	if saved_safehouses is Array:
		var house_records: Dictionary = safehouse_system.get("houses")
		for house_id in house_records:
			var house_record: Dictionary = house_records[house_id]
			house_record["owned"] = saved_safehouses.has(str(house_id))

	var fuel_system: RefCounted = get_runtime_system("vehicle_fuel")
	fuel_system.set("fuel", clampf(float(payload.get("vehicle_fuel", fuel_system.get("capacity"))), 0.0, float(fuel_system.get("capacity"))))

	var parking_system: RefCounted = get_runtime_system("parking_registry")
	var saved_parking: Variant = payload.get("parking_reservations", {})
	if saved_parking is Dictionary:
		var parking_records: Dictionary = parking_system.get("spaces")
		for space_id in parking_records:
			var parking_record: Dictionary = parking_records[space_id]
			parking_record["vehicle"] = str(saved_parking.get(str(space_id), ""))

	var saved_vehicles: Variant = payload.get("vehicles", {})
	if saved_vehicles is Dictionary:
		for candidate in get_tree().get_nodes_in_group("drivable_vehicles"):
			if not candidate is Node3D or not candidate.has_method("get_save_id"):
				continue
			var vehicle := candidate as Node3D
			var vehicle_id := str(vehicle.call("get_save_id"))
			var saved_vehicle: Variant = saved_vehicles.get(vehicle_id, {})
			if saved_vehicle is Dictionary:
				var vehicle_position: Vector3 = _vector3_from_array(saved_vehicle.get("position", []), vehicle.global_position)
				if _is_safe_world_position(vehicle_position):
					vehicle.global_position = vehicle_position
				vehicle.global_rotation = _vector3_from_array(saved_vehicle.get("rotation", []), vehicle.global_rotation)
				if vehicle is CharacterBody3D:
					(vehicle as CharacterBody3D).velocity = _vector3_from_array(saved_vehicle.get("velocity", []), Vector3.ZERO)

	var active_vehicle_id := str(payload.get("active_vehicle_id", ""))
	if not active_vehicle_id.is_empty():
		for candidate in get_tree().get_nodes_in_group("drivable_vehicles"):
			if candidate is Node3D and candidate.has_method("get_save_id") and str(candidate.call("get_save_id")) == active_vehicle_id:
				_player.call("restore_vehicle_state", candidate)
				break

	_hud.call("set_objective", _missions.call("get_objective"))
	_hud.call("set_wallet", _missions.call("get_wallet"))
	_hud.call("set_location", _world.call("get_region_name_at", _player.global_position))
	_hud.call("update_minimap", _player.global_position, _player.global_rotation.y, _active_waypoint_position, not _active_waypoint_id.is_empty())
	_sync_runtime_hud_state()
	_last_autosave_payload_json = JSON.stringify(_capture_game_state())
	_autosave_elapsed = 0.0
	_is_restoring_game_state = false
	return true


func _vector3_to_array(value: Vector3) -> Array[float]:
	return [value.x, value.y, value.z]


func _vector3_from_array(value: Variant, fallback: Vector3) -> Vector3:
	if not value is Array or value.size() != 3:
		return fallback
	for component in value:
		if typeof(component) != TYPE_FLOAT and typeof(component) != TYPE_INT:
			return fallback
	return Vector3(float(value[0]), float(value[1]), float(value[2]))


func _is_safe_world_position(value: Vector3) -> bool:
	return absf(value.x) <= 256.0 and absf(value.y) <= 100.0 and absf(value.z) <= 128.0


func _on_vehicle_state_changed(is_driving: bool, vehicle_name: String) -> void:
	var hud_state: RefCounted = get_runtime_system("hud_state")
	hud_state.set("vehicle_mode", is_driving)
	var interaction: RefCounted = get_runtime_system("vehicle_interaction")
	if is_driving:
		interaction.call("enter", vehicle_name, 0.0, 3.6, false)
	else:
		interaction.call("exit_vehicle")
	if not _is_restoring_game_state:
		_save_game_state(true)
