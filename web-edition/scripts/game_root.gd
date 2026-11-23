extends Node3D

const WORLD_SCRIPT = preload("res://scripts/world/world_builder.gd")
const PLAYER_SCRIPT = preload("res://scripts/player/player_controller.gd")
const MISSION_SCRIPT = preload("res://scripts/systems/mission_manager.gd")
const HUD_SCRIPT = preload("res://scripts/ui/game_hud.gd")

var _world: Node3D
var _player: CharacterBody3D
var _missions: Node
var _hud: CanvasLayer
var _location_elapsed: float = 0.0
var _minimap_elapsed: float = 0.0
var _navigation_elapsed: float = 0.0


func _ready() -> void:
	_create_environment()

	_missions = MISSION_SCRIPT.new()
	_missions.name = "MissionManager"
	add_child(_missions)

	_world = WORLD_SCRIPT.new()
	_world.name = "World"
	add_child(_world)
	_world.call("build_world")

	_player = PLAYER_SCRIPT.new()
	_player.name = "Player"
	add_child(_player)
	_player.global_position = _world.get("spawn_position")

	_hud = HUD_SCRIPT.new()
	_hud.name = "GameplayHUD"
	add_child(_hud)

	_connect_gameplay_signals()
	_hud.call("set_objective", _missions.call("get_objective"))
	_hud.call("set_wallet", _missions.call("get_wallet"))
	_hud.call("set_location", _world.call("get_region_name_at", _player.global_position))
	_hud.call("update_minimap", _player.global_position, _player.global_rotation.y)
	_refresh_navigation()


func _process(delta: float) -> void:
	_location_elapsed += delta
	_minimap_elapsed += delta
	if _location_elapsed >= 0.35 and _player != null and _world != null:
		_location_elapsed = 0.0
		_hud.call("set_location", _world.call("get_region_name_at", _player.global_position))
	if _minimap_elapsed >= 0.12 and _player != null and _hud != null:
		_minimap_elapsed = 0.0
		_hud.call("update_minimap", _player.global_position, _player.global_rotation.y)

	_navigation_elapsed += delta
	if _navigation_elapsed >= 0.4 and _player != null and _world != null and _hud != null:
		_navigation_elapsed = 0.0
		_refresh_navigation()


func _refresh_navigation() -> void:
	if _world == null or _player == null or _missions == null or _hud == null:
		return

	var destination: Node3D
	var destination_name := ""
	match int(_missions.get("mission_stage")):
		0:
			destination = _world.get_node_or_null("ClaireBennett") as Node3D
			destination_name = "Claire Bennett"
		1:
			destination = _world.get_node_or_null("NoraBlake") as Node3D
			destination_name = "Nora Blake"
		_:
			_hud.call("clear_navigation_route")
			return

	if destination == null:
		_hud.call("clear_navigation_route")
		return

	var route: Dictionary = _world.call("find_road_route", _player.global_position, destination.global_position)
	if str(route.get("status", "")) != "ok":
		_hud.call("clear_navigation_route")
		return

	var route_points: PackedVector3Array = route.get("points", PackedVector3Array())
	_hud.call("set_navigation_route", route_points, destination_name, float(route.get("distance", 0.0)))


func _connect_gameplay_signals() -> void:
	_missions.objective_changed.connect(_hud.set_objective)
	_missions.connect("notification_requested", Callable(_hud, "show_notification"))
	_missions.dialogue_changed.connect(_hud.show_dialogue)
	_missions.wallet_changed.connect(_hud.set_wallet)
	_player.prompt_changed.connect(_hud.set_prompt)
	_player.map_toggled.connect(_hud.toggle_map)
	_player.vehicle_state_changed.connect(_hud.set_vehicle_state)

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
