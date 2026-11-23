extends Node
class_name GhibliWorldClock

signal time_changed(time_text: String)

const SAVE_PATH := "user://gta_ghibli_world_clock.cfg"
const SAVE_SCHEMA_VERSION := 1
const REAL_SECONDS_PER_GAME_DAY := 1200.0
const SECONDS_PER_DAY := 86400.0
const DEFAULT_TIME_SECONDS := 8.0 * 3600.0
const AUTOSAVE_INTERVAL := 15.0

var _time_seconds: float = DEFAULT_TIME_SECONDS
var _environment: Environment
var _sun: DirectionalLight3D
var _broadcast_elapsed: float = 0.0
var _save_elapsed: float = 0.0


func _ready() -> void:
	_load_time()


func _process(delta: float) -> void:
	_time_seconds = fposmod(
		_time_seconds + delta * SECONDS_PER_DAY / REAL_SECONDS_PER_GAME_DAY,
		SECONDS_PER_DAY
	)
	_broadcast_elapsed += delta
	_save_elapsed += delta
	if _broadcast_elapsed >= 1.0:
		_broadcast_elapsed = 0.0
		time_changed.emit(get_time_text())
	if _save_elapsed >= AUTOSAVE_INTERVAL:
		_save_elapsed = 0.0
		_save_time()
	_apply_lighting()


func configure(environment: Environment, sun: DirectionalLight3D) -> void:
	_environment = environment
	_sun = sun
	_apply_lighting()
	time_changed.emit(get_time_text())


func set_time(hour: int, minute: int) -> void:
	var normalized_hour := posmod(hour, 24)
	var normalized_minute := posmod(minute, 60)
	_time_seconds = float(normalized_hour * 3600 + normalized_minute * 60)
	_apply_lighting()
	time_changed.emit(get_time_text())


func get_time_text() -> String:
	var total_minutes := int(floor(_time_seconds / 60.0)) % 1440
	var hour := int(total_minutes / 60)
	var minute := total_minutes % 60
	return "%02d:%02d" % [hour, minute]


func get_time_seconds() -> int:
	return int(floor(_time_seconds))


func _apply_lighting() -> void:
	if _environment == null or _sun == null:
		return
	var hour := _time_seconds / 3600.0
	var daylight := clampf(sin((hour - 6.0) / 12.0 * PI), 0.0, 1.0)
	var morning_warmth := _warmth_at(hour, 7.0)
	var evening_warmth := _warmth_at(hour, 18.0)
	var golden_hour := maxf(morning_warmth, evening_warmth)

	var night_sky := Color(0.018, 0.035, 0.085)
	var day_sky := Color(0.39, 0.57, 0.68)
	var warm_sky := Color(0.88, 0.39, 0.22)
	_environment.background_color = night_sky.lerp(day_sky, daylight).lerp(
		warm_sky, golden_hour * 0.38
	)
	_environment.ambient_light_color = Color(0.17, 0.20, 0.31).lerp(
		Color(0.78, 0.82, 0.78), daylight
	).lerp(Color(0.92, 0.57, 0.39), golden_hour * 0.18)
	_environment.ambient_light_energy = lerpf(0.16, 0.78, daylight)

	_sun.rotation = Vector3(
		deg_to_rad(-90.0 + hour * 15.0),
		deg_to_rad(-28.0),
		0.0
	)
	_sun.light_color = Color(1.0, 0.66, 0.43).lerp(
		Color(1.0, 0.91, 0.76), daylight
	)
	_sun.light_energy = lerpf(0.015, 1.25, daylight)
	_sun.shadow_enabled = daylight > 0.035


func _warmth_at(hour: float, center_hour: float) -> float:
	return clampf(1.0 - absf(hour - center_hour) / 1.7, 0.0, 1.0)


func _load_time() -> void:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return
	var schema_version := int(config.get_value("clock", "schema_version", 0))
	if schema_version != SAVE_SCHEMA_VERSION:
		return
	var saved_seconds := int(config.get_value("clock", "time_seconds", -1))
	if saved_seconds < 0 or saved_seconds >= int(SECONDS_PER_DAY):
		return
	_time_seconds = float(saved_seconds)


func _save_time() -> void:
	var config := ConfigFile.new()
	config.set_value("clock", "schema_version", SAVE_SCHEMA_VERSION)
	config.set_value("clock", "time_seconds", int(_time_seconds))
	var error := config.save(SAVE_PATH)
	if error != OK:
		push_warning("Could not save the Web world clock: %s" % error)
