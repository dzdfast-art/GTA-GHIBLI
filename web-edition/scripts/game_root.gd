extends Node3D

const WORLD_SCRIPT = preload("res://scripts/world/world_builder.gd")
const PLAYER_SCRIPT = preload("res://scripts/player/player_controller.gd")
const MISSION_SCRIPT = preload("res://scripts/systems/mission_manager.gd")
const CLOCK_SCRIPT = preload("res://scripts/systems/world_clock.gd")
const HUD_SCRIPT = preload("res://scripts/ui/game_hud.gd")

var _world: Node3D
var _player: CharacterBody3D
var _missions: Node
var _world_clock: Node
var _hud: CanvasLayer
var _environment_resource: Environment
var _sun_light: DirectionalLight3D
var _location_elapsed: float = 0.0
var _minimap_elapsed: float = 0.0


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

	_world_clock = CLOCK_SCRIPT.new()
	_world_clock.name = "WorldClock"
	add_child(_world_clock)
	_world_clock.call("configure", _environment_resource, _sun_light)

	_connect_gameplay_signals()
	_hud.call("set_objective", _missions.call("get_objective"))
	_hud.call("set_wallet", _missions.call("get_wallet"))
	_hud.call("set_location", _world.call("get_region_name_at", _player.global_position))
	_hud.call("update_minimap", _player.global_position, _player.global_rotation.y)
	_hud.call("set_clock", _world_clock.call("get_time_text"))


func _process(delta: float) -> void:
	_location_elapsed += delta
	_minimap_elapsed += delta
	if _location_elapsed >= 0.35 and _player != null and _world != null:
		_location_elapsed = 0.0
		_hud.call("set_location", _world.call("get_region_name_at", _player.global_position))
	if _minimap_elapsed >= 0.12 and _player != null and _hud != null:
		_minimap_elapsed = 0.0
		_hud.call("update_minimap", _player.global_position, _player.global_rotation.y)


func _connect_gameplay_signals() -> void:
	_missions.objective_changed.connect(_hud.set_objective)
	_missions.connect("notification_requested", Callable(_hud, "show_notification"))
	_missions.dialogue_changed.connect(_hud.show_dialogue)
	_missions.wallet_changed.connect(_hud.set_wallet)
	_world_clock.time_changed.connect(_hud.set_clock)
	_player.prompt_changed.connect(_hud.set_prompt)
	_player.map_toggled.connect(_hud.toggle_map)
	_player.vehicle_state_changed.connect(_hud.set_vehicle_state)

	for actor in get_tree().get_nodes_in_group("interactables"):
		if actor.has_signal("activated"):
			actor.connect("activated", Callable(_missions, "handle_interaction"))


func _create_environment() -> void:
	var world_environment := WorldEnvironment.new()
	_environment_resource = Environment.new()
	_environment_resource.background_mode = Environment.BG_COLOR
	_environment_resource.background_color = Color(0.39, 0.57, 0.68)
	_environment_resource.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	_environment_resource.ambient_light_color = Color(0.78, 0.82, 0.78)
	_environment_resource.ambient_light_energy = 0.72
	world_environment.environment = _environment_resource
	add_child(world_environment)

	_sun_light = DirectionalLight3D.new()
	_sun_light.name = "WorldSun"
	_sun_light.rotation_degrees = Vector3(-48.0, -28.0, 0.0)
	_sun_light.light_color = Color(1.0, 0.88, 0.70)
	_sun_light.light_energy = 1.25
	_sun_light.shadow_enabled = true
	add_child(_sun_light)
