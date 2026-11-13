extends Node

## Lightweight procedural ambience for the mobile prototype.
## Synthesizes bird-like dawn calls, wind, night insects and occasional owl-like calls.
## Production audio should layer in original or properly licensed field recordings.

const SAMPLE_RATE := 22050.0
const DAY_LENGTH_SECONDS := 900.0
var elapsed_game_seconds := 0.0
var biome := "village"
var weather := "clear"
var master_gain := 0.22
var _player: AudioStreamPlayer
var _playback: AudioStreamGeneratorPlayback
var _sample_clock := 0.0
var _wind_state := 0.0
var _bird_timer := 1.0
var _bird_remaining := 0.0
var _bird_duration := 0.22
var _bird_frequency := 2100.0
var _bird_pan := 0.0
var _bird_kind := "bird"
var _random := RandomNumberGenerator.new()
var _target_wind := 0.0
var _target_birds := 0.0
var _target_insects := 0.0
var _target_owl := 0.0
var _target_rain := 0.0
var _wind_level := 0.0
var _bird_level := 0.0
var _insect_level := 0.0
var _owl_level := 0.0
var _rain_level := 0.0

func _ready() -> void:
	_random.randomize()
	_player = AudioStreamPlayer.new()
	_player.name = "ProceduralNatureAudio"
	_player.volume_db = -3.0
	var generator := AudioStreamGenerator.new()
	generator.mix_rate = SAMPLE_RATE
	generator.buffer_length = 0.5
	_player.stream = generator
	add_child(_player)
	_player.play()
	_playback = _player.get_stream_playback() as AudioStreamGeneratorPlayback
	_update_targets()

func _process(delta: float) -> void:
	elapsed_game_seconds += delta
	_update_targets()
	var blend := 1.0 - exp(-delta * 0.7)
	_wind_level = lerpf(_wind_level, _target_wind, blend)
	_bird_level = lerpf(_bird_level, _target_birds, blend)
	_insect_level = lerpf(_insect_level, _target_insects, blend)
	_owl_level = lerpf(_owl_level, _target_owl, blend)
	_rain_level = lerpf(_rain_level, _target_rain, blend)
	_fill_audio_buffer()

func _update_targets() -> void:
	var hour := get_game_hour()
	var dawn := _smooth_band(hour, 4.5, 6.5, 8.5, 10.0)
	var daytime := _smooth_band(hour, 6.0, 8.0, 16.5, 19.0)
	var dusk := _smooth_band(hour, 16.0, 18.0, 19.0, 20.5)
	var night := 1.0 - daytime
	var biome_wind := 0.72 if biome == "coast" else (0.48 if biome == "highlands" else 0.34)
	_target_wind = biome_wind * (0.75 + 0.25 * dusk)
	_target_birds = clampf(dawn * 0.95 + daytime * 0.58 + dusk * 0.24, 0.0, 1.0)
	_target_insects = night * (0.82 if biome != "coast" else 0.42)
	_target_owl = night * 0.38
	_target_rain = 0.72 if weather == "rain" else (0.18 if weather == "storm" else 0.0)
	if weather == "storm":
		_target_wind = minf(1.0, _target_wind + 0.5)
		_target_birds *= 0.18
		_target_insects *= 0.35

func _fill_audio_buffer() -> void:
	if _playback == null:
		return
	var frames := _playback.get_frames_available()
	for index in range(frames):
		var wind_noise := _random.randf_range(-1.0, 1.0)
		_wind_state = lerpf(_wind_state, wind_noise, 0.012)
		var wind := _wind_state * _wind_level * 0.105
		var rain_noise := _random.randf_range(-1.0, 1.0)
		var rain := rain_noise * _rain_level * 0.055
		var insect_gate := 0.5 + 0.5 * sin(_sample_clock * TAU * 4.2)
		var insect_carrier := sin(_sample_clock * TAU * 4150.0)
		var insects := insect_carrier * insect_gate * _insect_level * 0.018
		var bird := _bird_sample()
		var owl := _owl_sample()
		var water := _water_sample()
		var sample := clampf((wind + rain + insects + bird + owl + water) * master_gain, -0.8, 0.8)
		_playback.push_frame(Vector2(sample * (1.0 - maxf(0.0, _bird_pan) * 0.12),
			sample * (1.0 + minf(0.0, _bird_pan) * 0.12)))
		_sample_clock += 1.0 / SAMPLE_RATE

func _bird_sample() -> float:
	if _bird_remaining <= 0.0:
		_bird_timer -= 1.0 / SAMPLE_RATE
		if _bird_timer <= 0.0 and _bird_level > 0.08:
			_bird_kind = "bird"
			_bird_duration = _random.randf_range(0.12, 0.30)
			_bird_frequency = _random.randf_range(1750.0, 3150.0)
			_bird_pan = _random.randf_range(-1.0, 1.0)
			_bird_remaining = _bird_duration
			_bird_timer = _random.randf_range(1.3, 4.8) / maxf(0.25, _bird_level)
		return 0.0
	if _bird_kind != "bird":
		return 0.0
	var progress := 1.0 - (_bird_remaining / _bird_duration)
	var envelope := sin(progress * PI)
	var frequency := _bird_frequency * (1.0 + 0.12 * sin(progress * PI))
	var tone := sin(_sample_clock * TAU * frequency)
	_bird_remaining -= 1.0 / SAMPLE_RATE
	return tone * envelope * _bird_level * 0.10

func _owl_sample() -> float:
	if _bird_remaining <= 0.0 and _owl_level > 0.1 and _random.randf() < 0.000012:
		_bird_kind = "owl"
		_bird_duration = 0.62
		_bird_frequency = 520.0
		_bird_remaining = _bird_duration
	if _bird_kind != "owl" or _bird_remaining <= 0.0:
		return 0.0
	var progress := 1.0 - (_bird_remaining / _bird_duration)
	var envelope := sin(progress * PI)
	_bird_remaining -= 1.0 / SAMPLE_RATE
	return sin(_sample_clock * TAU * _bird_frequency) * envelope * _owl_level * 0.025

func _water_sample() -> float:
	if biome != "coast" and biome != "river":
		return 0.0
	return _random.randf_range(-1.0, 1.0) * (0.012 if biome == "river" else 0.018)

func _smooth_band(value: float, rise_start: float, rise_end: float,
		fall_start: float, fall_end: float) -> float:
	var rising := smoothstep(rise_start, rise_end, value)
	var falling := 1.0 - smoothstep(fall_start, fall_end, value)
	return clampf(rising * falling, 0.0, 1.0)

func get_game_hour() -> float:
	return fposmod(5.0 + (elapsed_game_seconds / DAY_LENGTH_SECONDS) * 24.0, 24.0)

func set_biome(value: String) -> void:
	if value in ["village", "forest", "fields", "river", "coast", "highlands"]:
		biome = value

func set_weather(value: String) -> void:
	if value in ["clear", "rain", "storm"]:
		weather = value

func set_master_gain(value: float) -> void:
	master_gain = clampf(value, 0.0, 0.6)
