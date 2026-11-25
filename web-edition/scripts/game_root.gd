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
	"route_progress": preload("res://scripts/world/route_progress.gd"),
	"vehicle_damage_model": preload("res://scripts/vehicles/vehicle_damage_model.gd"),
	"vehicle_dynamics": preload("res://scripts/vehicles/vehicle_dynamics.gd"),
	"vehicle_profile": preload("res://scripts/vehicles/vehicle_profile.gd"),
	"traffic_signal_controller": preload("res://scripts/world/traffic_signal_controller.gd")
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
var _active_vehicle: Node3D
var _hud_elapsed: float = 0.0
var _runtime_save_elapsed: float = 0.0
var _world_clock_elapsed: float = 0.0


func _ready() -> void:
	_initialize_runtime_systems()
	_create_environment()
	_missions = MISSION_SCRIPT.new()
	_missions.name = "MissionManager"
	add_child(_missions)
	_world = WORLD_SCRIPT.new()
	_world.name = "World"
	add_child(_world)
	_world.call("build_world")
	_points_of_interest = _world.call("get_points_of_interest")
	_attach_vehicle_runtime_services()
	_register_world_runtime_data()
	_route_planner = ROUTE_PLANNER_SCRIPT.new()
	_route_progress = ROUTE_PROGRESS_SCRIPT.new()
	if not bool(_route_planner.call("configure", _world.call("get_road_graph"))):
		push_error("The starter road graph could not be configured.")
	_player = PLAYER_SCRIPT.new()
	_player.name = "Player"
	add_child(_player)
	_player.global_position = _world.get("spawn_position")
	_player.call(
		"configure_runtime_services",
		get_runtime_system("player_vitals"),
		get_runtime_system("camera_follow")
	)
	_restore_runtime_state()
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
	_record_runtime_acceptance()
	_save_runtime_state()


func _process(delta: float) -> void:
	_advance_runtime_services(delta)
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
	_hud_elapsed += delta
	if _hud_elapsed >= 0.10:
		_hud_elapsed = 0.0
		_sync_runtime_hud_state()


func _attach_vehicle_runtime_services() -> void:
	var vehicles := get_tree().get_nodes_in_group("drivable_vehicles")
	if vehicles.is_empty():
		push_warning("No drivable vehicle was found while attaching vehicle services.")
		return
	_active_vehicle = vehicles[0] as Node3D
	if _active_vehicle != null and _active_vehicle.has_method("configure_runtime_services"):
		var configured: bool = bool(_active_vehicle.call(
			"configure_runtime_services",
			get_runtime_system("vehicle_dynamics"),
			get_runtime_system("vehicle_damage_model"),
			get_runtime_system("vehicle_fuel")
		))
		if not configured:
			push_error("The starting vehicle rejected one or more runtime services.")


func _advance_runtime_services(delta: float) -> void:
	if delta <= 0.0 or _runtime_systems.is_empty():
		return
	get_runtime_system("traffic_signal_controller").call("advance", delta)
	_world_clock_elapsed += delta
	var minutes_to_advance := int(_world_clock_elapsed)
	if minutes_to_advance > 0:
		get_runtime_system("world_clock_weather").call("advance_minutes", minutes_to_advance)
		_world_clock_elapsed -= float(minutes_to_advance)

	var pursuit: RefCounted = get_runtime_system("police_pursuit")
	var pursuit_state := str(pursuit.get("state"))
	if pursuit_state == "pursuing" and _player != null:
		pursuit.set("target", _player.global_position)
	elif pursuit_state == "searching" and _player != null:
		pursuit.call("update_sighting", _player.global_position, false, delta)

	if str(pursuit.get("state")) == "lost":
		var level := update_wanted_cooldown(delta, true)
		if level == 0:
			pursuit.call("reset")

	_runtime_save_elapsed += delta
	if _runtime_save_elapsed >= 15.0:
		_runtime_save_elapsed = 0.0
		_save_runtime_state()


func _connect_gameplay_signals() -> void:
	_missions.objective_changed.connect(_hud.set_objective)
	_missions.objective_changed.connect(_on_mission_objective_changed)
	_missions.connect("notification_requested", Callable(_hud, "show_notification"))
	_missions.dialogue_changed.connect(_hud.show_dialogue)
	_missions.wallet_changed.connect(_hud.set_wallet)
	_missions.wallet_changed.connect(_on_wallet_changed)
	_player.prompt_changed.connect(_hud.set_prompt)
	_player.map_toggled.connect(_hud.toggle_map)
	_player.vehicle_state_changed.connect(_hud.set_vehicle_state)
	_player.vehicle_state_changed.connect(_on_vehicle_state_changed)
	_hud.connect("waypoint_selected", Callable(self, "_on_waypoint_selected"))
	for actor in get_tree().get_nodes_in_group("interactables"):
		if actor.has_signal("activated"):
			actor.connect("activated", Callable(_missions, "handle_interaction"))


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
	get_runtime_system("mission_prerequisites").call("define", "mission_001", prerequisites)
	get_runtime_system("mission_prerequisites").call("define", "mission_002", mission_one)
	get_runtime_system("mission_objectives").call("add_objective", "mission_001_claire_contact", 1)
	get_runtime_system("mission_objectives").call("add_objective", "mission_001_nora_meeting", 1)
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
	var wanted: RefCounted = get_runtime_system("wanted_level")
	var clock: RefCounted = get_runtime_system("world_clock_weather")
	hud_state.call("update_health", float(vitals.get("health")))
	hud_state.set("money", int(_missions.call("get_wallet")))
	hud_state.call("set_wanted", int(wanted.call("get_level")))
	var minute_of_day := int(clock.get("minute_of_day"))
	hud_state.call("set_clock", int(minute_of_day / 60), minute_of_day % 60)
	hud_state.set("vehicle_mode", _active_vehicle != null and bool(_active_vehicle.call("is_driven")))

	var fuel := -1.0
	var condition := -1.0
	if _active_vehicle != null and _active_vehicle.has_method("get_runtime_vehicle_status"):
		var vehicle_status: Dictionary = _active_vehicle.call("get_runtime_vehicle_status")
		fuel = float(vehicle_status.get("fuel", -1.0))
		condition = float(vehicle_status.get("condition", -1.0))
	if _hud != null and _hud.has_method("set_runtime_status"):
		_hud.call(
			"set_runtime_status",
			hud_state.call("snapshot"),
			float(vitals.get("stamina")),
			fuel,
			condition,
			str(get_runtime_system("police_pursuit").get("state"))
		)


func _restore_runtime_state() -> void:
	var saved: Dictionary = get_runtime_system("save_slot_manager").call("load_slot", "autosave")
	var payload: Dictionary = saved.get("payload", {})
	if payload.is_empty():
		return
	if payload.get("player_position") is Vector3 and _player != null:
		_player.global_position = payload["player_position"]
	if payload.get("player_rotation") is Vector3 and _player != null:
		_player.global_rotation = payload["player_rotation"]
	var vitals: RefCounted = get_runtime_system("player_vitals")
	vitals.set("health", clampf(float(payload.get("player_health", vitals.get("health"))), 0.0, 100.0))
	vitals.set("stamina", clampf(float(payload.get("player_stamina", vitals.get("stamina"))), 0.0, 100.0))
	if _active_vehicle != null:
		if payload.get("vehicle_position") is Vector3:
			_active_vehicle.global_position = payload["vehicle_position"]
		if payload.get("vehicle_rotation") is Vector3:
			_active_vehicle.global_rotation = payload["vehicle_rotation"]
		var fuel: RefCounted = get_runtime_system("vehicle_fuel")
		var damage: RefCounted = get_runtime_system("vehicle_damage_model")
		fuel.set("fuel", clampf(float(payload.get("vehicle_fuel", fuel.get("fuel"))), 0.0, float(fuel.get("capacity"))))
		damage.set("durability", clampf(float(payload.get("vehicle_durability", damage.get("durability"))), 0.0, float(damage.get("max_durability"))))
	var wanted: RefCounted = get_runtime_system("wanted_level")
	wanted.set("level", clampi(int(payload.get("wanted_level", wanted.get("level"))), 0, int(wanted.get("max_level"))))


func _save_runtime_state() -> bool:
	if _player == null or _missions == null:
		return false
	var vitals: RefCounted = get_runtime_system("player_vitals")
	var payload: Dictionary = {
		"schema_version": 1,
		"mission_stage": int(_missions.get("mission_stage")),
		"wallet": int(_missions.call("get_wallet")),
		"player_position": _player.global_position,
		"player_rotation": _player.global_rotation,
		"player_health": float(vitals.get("health")),
		"player_stamina": float(vitals.get("stamina")),
		"wanted_level": int(get_runtime_system("wanted_level").call("get_level"))
	}
	if _active_vehicle != null:
		payload["vehicle_position"] = _active_vehicle.global_position
		payload["vehicle_rotation"] = _active_vehicle.global_rotation
		payload["vehicle_fuel"] = float(get_runtime_system("vehicle_fuel").get("fuel"))
		payload["vehicle_durability"] = float(get_runtime_system("vehicle_damage_model").get("durability"))
	return bool(get_runtime_system("save_slot_manager").call(
		"save_slot", "autosave", payload, int(Time.get_unix_time_from_system())
	))


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
	return bool(get_runtime_system("settings_profile").call("set_value", "language", language))


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
	var pursuit: RefCounted = get_runtime_system("police_pursuit")
	var state := str(pursuit.call("update_sighting", _player.global_position, visible, delta))
	get_runtime_system("hud_state").call("set_wanted", int(get_runtime_system("wanted_level").call("get_level")))
	if state == "lost":
		_hud.call("show_notification", "Police lost visual contact; search is cooling down.")
	return state


func update_wanted_cooldown(delta: float, player_hidden: bool) -> int:
	var level: int = get_runtime_system("wanted_level").call("tick", delta, player_hidden)
	get_runtime_system("hud_state").call("set_wanted", level)
	if level == 0:
		get_runtime_system("police_pursuit").call("reset")
	return level


func try_reserve_traffic_vehicle() -> bool:
	return bool(get_runtime_system("traffic_spawn_budget").call("try_spawn"))


func release_traffic_vehicle(count: int = 1) -> int:
	return int(get_runtime_system("traffic_spawn_budget").call("despawn", count))


func _on_mission_objective_changed(text: String) -> void:
	if text.contains("قابل Nora") or text.contains("Marsa Al-Noor"):
		get_runtime_system("mission_objectives").call("add_progress", "mission_001_claire_contact", 1)
	elif text.contains("مكتملة"):
		get_runtime_system("mission_objectives").call("add_progress", "mission_001_nora_meeting", 1)
		get_runtime_system("mission_prerequisites").call("complete", "mission_001")
		get_runtime_system("mission_rewards").call("settle", "mission_001", 250, 1)


func _on_wallet_changed(amount: int) -> void:
	var hud_state: RefCounted = get_runtime_system("hud_state")
	hud_state.set("money", amount)
	_hud.call("set_wallet", amount)
	_save_runtime_state()


func _on_vehicle_state_changed(is_driving: bool, vehicle_name: String) -> void:
	var hud_state: RefCounted = get_runtime_system("hud_state")
	hud_state.set("vehicle_mode", is_driving)
	var interaction: RefCounted = get_runtime_system("vehicle_interaction")
	if is_driving:
		interaction.call("enter", vehicle_name, 0.0, 3.6, false)
	else:
		interaction.call("exit_vehicle")
	_sync_runtime_hud_state()
	_save_runtime_state()
