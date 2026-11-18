extends Node3D

## Mobile-conscious global weather controller with lightweight rain particles.
signal weather_changed(weather_id: String)

@export var automatic_weather_enabled := true
@export_range(30.0, 1800.0, 10.0) var change_interval_seconds := 240.0

var weather_id := "clear"
var _weather_timer := 0.0
var _rain_particles: GPUParticles3D
var _player: Node3D
var _random := RandomNumberGenerator.new()

func _ready() -> void:
	_random.randomize()
	add_to_group("world_weather")
	_weather_timer = change_interval_seconds
	_build_rain_particles()
	_sync_ambience()
	set_weather("clear")

func _process(delta: float) -> void:
	_player = get_tree().get_first_node_in_group("player") as Node3D
	if _player != null and is_instance_valid(_player) and _rain_particles != null:
		_rain_particles.global_position = _player.global_position + Vector3(0.0, 7.0, 0.0)
	if not automatic_weather_enabled:
		return
	_weather_timer -= delta
	if _weather_timer <= 0.0:
		_weather_timer = change_interval_seconds
		_choose_next_weather()

func set_weather(next_weather: String) -> bool:
	if next_weather not in ["clear", "rain", "storm"]:
		return false
	if weather_id == next_weather:
		_apply_weather_visuals()
		_sync_ambience()
		return true
	weather_id = next_weather
	_apply_weather_visuals()
	_sync_ambience()
	weather_changed.emit(weather_id)
	return true

func get_weather() -> String:
	return weather_id

func set_automatic_weather(enabled: bool) -> void:
	automatic_weather_enabled = enabled
	_weather_timer = change_interval_seconds

func _choose_next_weather() -> void:
	var roll := _random.randf()
	if roll < 0.56:
		set_weather("clear")
	elif roll < 0.90:
		set_weather("rain")
	else:
		set_weather("storm")

func _build_rain_particles() -> void:
	_rain_particles = GPUParticles3D.new()
	_rain_particles.name = "WeatherRainParticles"
	_rain_particles.amount = 110
	_rain_particles.lifetime = 1.25
	_rain_particles.emitting = false
	_rain_particles.local_coords = false
	var rain_mesh := BoxMesh.new()
	rain_mesh.size = Vector3(0.025, 0.48, 0.025)
	var rain_material := StandardMaterial3D.new()
	rain_material.albedo_color = Color(0.62, 0.76, 0.86, 0.68)
	rain_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	rain_mesh.material = rain_material
	_rain_particles.draw_pass_1 = rain_mesh
	var process_material := ParticleProcessMaterial.new()
	process_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	process_material.emission_box_extents = Vector3(17.0, 7.0, 17.0)
	process_material.direction = Vector3(0.0, -1.0, 0.0)
	process_material.spread = 5.0
	process_material.initial_velocity_min = 13.0
	process_material.initial_velocity_max = 17.0
	process_material.gravity = Vector3(0.0, -1.5, 0.0)
	process_material.damping_min = 0.0
	process_material.damping_max = 0.0
	_rain_particles.process_material = process_material
	add_child(_rain_particles)

func _apply_weather_visuals() -> void:
	if _rain_particles == null:
		return
	match weather_id:
		"clear":
			_rain_particles.emitting = false
		"rain":
			_rain_particles.amount = 110
			_rain_particles.emitting = true
		"storm":
			_rain_particles.amount = 190
			_rain_particles.emitting = true

func _sync_ambience() -> void:
	if not is_inside_tree():
		return
	for ambience in get_tree().get_nodes_in_group("nature_ambience"):
		if is_instance_valid(ambience) and ambience.has_method("set_weather"):
			ambience.call("set_weather", weather_id)
