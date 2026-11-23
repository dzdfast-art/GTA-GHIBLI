extends Node3D

const WORLD_SCRIPT = preload("res://scripts/world/world_builder.gd")
const PLAYER_SCRIPT = preload("res://scripts/player/player_controller.gd")
const MISSION_SCRIPT = preload("res://scripts/systems/mission_manager.gd")
const HUD_SCRIPT = preload("res://scripts/ui/game_hud.gd")
const ROUTE_PLANNER_SCRIPT = preload("res://scripts/world/route_planner.gd")

var _world: Node3D
var _player: CharacterBody3D
var _missions: Node
var _hud: CanvasLayer
var _route_planner: RefCounted
var _active_route: Dictionary = {}
var _location_elapsed: float = 0.0
var _minimap_elapsed: float = 0.0
var _navigation_elapsed: float = 0.0
var _points_of_interest: Array[Dictionary] = []
var _active_waypoint_id: String = ""
var _active_waypoint_name: String = ""
var _active_waypoint_position: Vector3 = Vector3.ZERO


func _ready() -> void:
	_create_environment()

	_missions = MISSION_SCRIPT.new()
	_missions.name = "MissionManager"
	add_child(_missions)

	_world = WORLD_SCRIPT.new()
	_world.name = "World"
	add_child(_world)
	_world.call("build_world")
	_points_of_interest = _world.call("get_points_of_interest")
	_route_planner = ROUTE_PLANNER_SCRIPT.new()
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


func _process(delta: float) -> void:
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
	_missions.connect("notification_requested", Callable(_hud, "show_notification"))
	_missions.dialogue_changed.connect(_hud.show_dialogue)
	_missions.wallet_changed.connect(_hud.set_wallet)
	_player.prompt_changed.connect(_hud.set_prompt)
	_player.map_toggled.connect(_hud.toggle_map)
	_player.vehicle_state_changed.connect(_hud.set_vehicle_state)
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

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48.0, -28.0, 0.0)
	sun.light_color = Color(1.0, 0.88, 0.70)
	sun.light_energy = 1.25
	sun.shadow_enabled = true
	add_child(sun)


func _on_waypoint_selected(point_id: String, point_name: String, world_position: Vector3) -> void:
	_active_waypoint_id = point_id
	_active_waypoint_name = point_name
	_active_waypoint_position = world_position
	_update_navigation_route()
	_hud.call("show_notification", "Waypoint selected — " + point_name)


func _update_navigation_route() -> void:
	if _route_planner == null or _player == null or _hud == null:
		return
	_active_route = _route_planner.call(
		"find_route", _player.global_position, _active_waypoint_position, 36.0
	)
	_hud.call("set_navigation_route", _active_route)
	if bool(_active_route.get("reachable", false)):
		_hud.call("set_waypoint_status", _active_waypoint_name, float(_active_route.get("distance", 0.0)), true)
		_hud.call("set_navigation_guidance", _get_next_route_instruction(_active_route))
	else:
		_hud.call("set_waypoint_status", _active_waypoint_name, 0.0, false)
		_hud.call("set_navigation_guidance", "No connected road route")


func _get_next_route_instruction(route: Dictionary) -> String:
	for maneuver in route.get("maneuvers", []):
		var turn_position: Vector3 = maneuver.get("position", Vector3.ZERO)
		var distance_to_turn: float = _player.global_position.distance_to(turn_position)
		if distance_to_turn > 3.0:
			return "%s in %.0f m" % [str(maneuver.get("instruction", "Turn")), distance_to_turn]
	return "Continue to destination"
