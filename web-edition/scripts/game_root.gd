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
var _simulation_ticks: int = 0
var _runtime_status_elapsed: float = 0.0
var _runtime_autosave_elapsed: float = 0.0


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
	_register_world_runtime_data()
	_route_planner = ROUTE_PLANNER_SCRIPT.new()
	_route_progress = ROUTE_PROGRESS_SCRIPT.new()
	if not bool(_route_planner.call("configure", _world.call("get_road_graph"))):
		push_error("The starter road graph could not be configured.")
	_player = PLAYER_SCRIPT.new()
	_player.name = "Player"
	add_child(_player)
	_player.global_position = _world.get("spawn_position")
	_bind_player_runtime_services()
	_bind_vehicle_runtime_services()
	_restore_runtime_autosave()
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


func _process(delta: float) -> void:
	advance_simulation(delta)
	_runtime_status_elapsed += delta
	if _runtime_status_elapsed >= 0.20:
		_runtime_status_elapsed = 0.0
		_update_runtime_hud()
	_runtime_autosave_elapsed += delta
	if _runtime_autosave_elapsed >= 30.0:
		_runtime_autosave_elapsed = 0.0
		_save_runtime_autosave()
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
	hud_state.call("update_health", float(vitals.get("health")))
	hud_state.set("money", int(_missions.call("get_wallet")))
	hud_state.call("set_wanted", int(wanted.call("get_level")))
	hud_state.set("vehicle_mode", false)
	_update_runtime_hud()


func _bind_player_runtime_services() -> void:
	var vitals: RefCounted = get_runtime_system("player_vitals")
	var camera_follow: RefCounted = get_runtime_system("camera_follow")
	camera_follow.call("configure", 10.0, Vector3(0.0, 1.55, 0.0))
	_player.call("set_runtime_services", vitals, camera_follow)


func _bind_vehicle_runtime_services() -> void:
	var vehicle := _get_runtime_vehicle()
	if vehicle == null:
		push_warning("Runtime vehicle services could not bind: no drivable vehicle is present.")
		return
	var profile_service: RefCounted = get_runtime_system("vehicle_profile")
	var profile: Dictionary = profile_service.call("get_profile", "sedan")
	var dynamics: RefCounted = get_runtime_system("vehicle_dynamics")
	var fuel: RefCounted = get_runtime_system("vehicle_fuel")
	var damage: RefCounted = get_runtime_system("vehicle_damage_model")
	dynamics.call("configure", profile)
	fuel.call("configure", 60.0, 0.12)
	damage.call("configure", {})
	vehicle.call("configure_runtime", profile, dynamics, fuel, damage)


func _get_runtime_vehicle() -> Node3D:
	for candidate in get_tree().get_nodes_in_group("drivable_vehicles"):
		if candidate is Node3D and is_instance_valid(candidate):
			return candidate as Node3D
	return null


func advance_simulation(delta: float) -> int:
	if delta <= 0.0 or _runtime_systems.is_empty():
		return _simulation_ticks
	var step := minf(delta, 0.25)
	var signals: RefCounted = get_runtime_system("traffic_signal_controller")
	signals.call("advance", step)
	var wanted: RefCounted = get_runtime_system("wanted_level")
	var pursuit: RefCounted = get_runtime_system("police_pursuit")
	var wanted_level := int(wanted.call("get_level"))
	if wanted_level > 0 and _player != null:
		var pursuit_state := str(pursuit.get("state"))
		if pursuit_state != "lost":
			pursuit_state = str(pursuit.call(
				"update_sighting",
				_player.global_position,
				_is_player_visible_to_police(),
				step
			))
		if pursuit_state == "lost":
			wanted_level = int(wanted.call("tick", step, true))
		get_runtime_system("hud_state").call("set_wanted", wanted_level)
	elif wanted_level == 0 and str(pursuit.get("state")) != "idle":
		pursuit.call("reset")
	_simulation_ticks += 1
	return _simulation_ticks


func _is_player_visible_to_police() -> bool:
	if _player == null:
		return false
	for officer in get_tree().get_nodes_in_group("police_units"):
		if officer is Node3D and is_instance_valid(officer):
			if (officer as Node3D).global_position.distance_to(_player.global_position) <= 45.0:
				return true
	return false


func _update_runtime_hud() -> void:
	if _hud == null or _player == null or _missions == null:
		return
	var vitals: RefCounted = get_runtime_system("player_vitals")
	var hud_state: RefCounted = get_runtime_system("hud_state")
	var clock: RefCounted = get_runtime_system("world_clock_weather")
	var wanted: RefCounted = get_runtime_system("wanted_level")
	var pursuit: RefCounted = get_runtime_system("police_pursuit")
	var minutes := int(clock.get("minute_of_day"))
	hud_state.call("update_health", float(vitals.get("health")))
	hud_state.call("set_wanted", int(wanted.call("get_level")))
	hud_state.call("set_clock", int(minutes / 60), minutes % 60)
	hud_state.set("vehicle_mode", bool(_player.call("is_driving")))
	var vehicle := _get_runtime_vehicle()
	var fuel_level := -1.0
	if vehicle != null and vehicle.has_method("get_fuel_remaining"):
		fuel_level = float(vehicle.call("get_fuel_remaining"))
	_hud.call(
		"show_runtime_status",
		hud_state.call("snapshot"),
		float(vitals.get("stamina")),
		fuel_level,
		str(pursuit.get("state")),
		str(get_runtime_system("traffic_signal_controller").call("get_phase"))
	)


func _save_runtime_autosave() -> bool:
	if _player == null or _missions == null:
		return false
	var payload := {
		"mission_stage": int(_missions.get("mission_stage")),
		"wallet": int(_missions.call("get_wallet")),
		"player_position": _player.global_position,
		"player_health": float(get_runtime_system("player_vitals").get("health")),
		"player_stamina": float(get_runtime_system("player_vitals").get("stamina")),
		"wanted_level": int(get_runtime_system("wanted_level").call("get_level"))
	}
	var vehicle := _get_runtime_vehicle()
	if vehicle != null:
		payload["vehicle_position"] = vehicle.global_position
		payload["vehicle_fuel"] = float(vehicle.call("get_fuel_remaining"))
		payload["vehicle_durability"] = float(vehicle.call("get_durability"))
	return bool(get_runtime_system("save_slot_manager").call(
		"save_slot", "autosave", payload, int(Time.get_unix_time_from_system())
	))


func _restore_runtime_autosave() -> void:
	var slot: Dictionary = get_runtime_system("save_slot_manager").call("load_slot", "autosave")
	var payload: Dictionary = slot.get("payload", {})
	if payload.is_empty():
		return
	var saved_position: Variant = payload.get("player_position", null)
	if saved_position is Vector3:
		_player.global_position = saved_position
	var vitals: RefCounted = get_runtime_system("player_vitals")
	vitals.set("health", clampf(float(payload.get("player_health", vitals.get("health"))), 0.0, float(vitals.get("max_health"))))
	vitals.set("stamina", clampf(float(payload.get("player_stamina", vitals.get("stamina"))), 0.0, float(vitals.get("max_stamina"))))
	var wanted: RefCounted = get_runtime_system("wanted_level")
	wanted.set("level", clampi(int(payload.get("wanted_level", 0)), 0, int(wanted.get("max_level"))))
	var vehicle := _get_runtime_vehicle()
	if vehicle != null:
		var vehicle_position: Variant = payload.get("vehicle_position", null)
		if vehicle_position is Vector3:
			vehicle.global_position = vehicle_position
		if payload.has("vehicle_fuel"):
			get_runtime_system("vehicle_fuel").set("fuel", clampf(float(payload.vehicle_fuel), 0.0, float(get_runtime_system("vehicle_fuel").get("capacity"))))
		if payload.has("vehicle_durability"):
			get_runtime_system("vehicle_damage_model").set("durability", clampf(float(payload.vehicle_durability), 0.0, float(get_runtime_system("vehicle_damage_model").get("max_durability"))))


func get_simulation_ticks() -> int:
	return _simulation_ticks


func save_runtime_checkpoint() -> bool:
	return _save_runtime_autosave()


func get_runtime_status_report() -> Dictionary:
	return {
		"simulation_ticks": _simulation_ticks,
		"health": float(get_runtime_system("player_vitals").get("health")),
		"stamina": float(get_runtime_system("player_vitals").get("stamina")),
		"wanted_level": int(get_runtime_system("wanted_level").call("get_level")),
		"pursuit_state": str(get_runtime_system("police_pursuit").get("state")),
		"traffic_signal_phase": str(get_runtime_system("traffic_signal_controller").call("get_phase")),
		"vehicle_bound": _get_runtime_vehicle() != null
	}


func _record_runtime_acceptance() -> void:
	var health: RefCounted = get_runtime_system("integration_health")
	var gate: RefCounted = get_runtime_system("web_acceptance_gate")
	for system_id in RUNTIME_SYSTEM_SCRIPTS:
		health.call("record_check", "service:" + system_id, _runtime_systems.has(system_id), "runtime service initialized")
	health.call("record_check", "world", _world != null, "world builder attached")
	health.call("record_check", "player", _player != null, "player controller attached")
	health.call("record_check", "gps", _route_planner != null, "road graph route planner initialized")
	health.call("record_check", "hud", _hud != null, "gameplay HUD attached")
	health.call("record_check", "save", get_runtime_system("save_slot_manager") != null and get_runtime_system("save_slot_manager").has_method("save_slot"), "persistent runtime save manager available")
	var has_vehicle := not get_tree().get_nodes_in_group("drivable_vehicles").is_empty()
	health.call("record_check", "vehicle", has_vehicle, "starting drivable vehicle present")
	gate.call("record", "world", _world != null)
	gate.call("record", "player", _player != null)
	gate.call("record", "vehicle", has_vehicle)
	gate.call("record", "gps", _route_planner != null)
	gate.call("record", "hud", _hud != null)
	gate.call("record", "save", get_runtime_system("save_slot_manager") != null and get_runtime_system("save_slot_manager").has_method("save_slot"))


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
	return str(get_runtime_system("police_pursuit").call("update_sighting", _player.global_position, visible, delta))


func update_wanted_cooldown(delta: float, player_hidden: bool) -> int:
	var level: int = get_runtime_system("wanted_level").call("tick", delta, player_hidden)
	get_runtime_system("hud_state").call("set_wanted", level)
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
	_save_runtime_autosave()


func _on_wallet_changed(amount: int) -> void:
	var hud_state: RefCounted = get_runtime_system("hud_state")
	var difference := amount - int(hud_state.get("money"))
	hud_state.call("add_money", difference)
	_save_runtime_autosave()


func _on_vehicle_state_changed(is_driving: bool, vehicle_name: String) -> void:
	var hud_state: RefCounted = get_runtime_system("hud_state")
	hud_state.set("vehicle_mode", is_driving)
	var interaction: RefCounted = get_runtime_system("vehicle_interaction")
	if is_driving:
		interaction.call("enter", vehicle_name, 0.0, 3.6, false)
	else:
		interaction.call("exit_vehicle")
	_update_runtime_hud()
