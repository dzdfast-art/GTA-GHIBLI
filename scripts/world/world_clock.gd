extends Node

## Shared day/night clock for schedules, ambience and the village sun.
signal time_changed(hour: int, minute: int, day: int, phase: String)
signal hour_changed(hour: int, day: int)

@export_range(60.0, 7200.0, 30.0) var seconds_per_game_day := 900.0
@export_range(0, 23, 1) var start_hour := 5
@export_range(0, 59, 1) var start_minute := 0
@export var drive_sun_light := true

var elapsed_game_seconds := 0.0
var _last_total_minute := -1
var _sun: DirectionalLight3D

func _ready() -> void:
	add_to_group("world_clock")
	_sun = get_parent().get_node_or_null("Sun") as DirectionalLight3D if get_parent() != null else null
	_sync_clock(true)

func _process(delta: float) -> void:
	elapsed_game_seconds += maxf(0.0, delta)
	_sync_clock(false)

func get_game_hour() -> float:
	var start := float(start_hour) + float(start_minute) / 60.0
	return fposmod(start + elapsed_game_seconds / maxf(60.0, seconds_per_game_day) * 24.0, 24.0)

func get_hour() -> int:
	return int(floor(get_game_hour()))

func get_minute() -> int:
	var fractional := get_game_hour() - floor(get_game_hour())
	return int(floor(fractional * 60.0))

func get_day_number() -> int:
	var day_progress := elapsed_game_seconds / maxf(60.0, seconds_per_game_day)
	return 1 + int(floor(day_progress))

func get_phase() -> String:
	var hour := get_game_hour()
	if hour >= 5.0 and hour < 7.0:
		return "dawn"
	if hour >= 7.0 and hour < 17.0:
		return "day"
	if hour >= 17.0 and hour < 20.0:
		return "dusk"
	return "night"

func get_clock_text() -> String:
	return "%02d:%02d" % [get_hour(), get_minute()]

func set_time(hour: int, minute: int = 0) -> void:
	var bounded_hour := posmod(hour, 24)
	var bounded_minute := posmod(minute, 60)
	var start_total := start_hour * 60 + start_minute
	var target_total := bounded_hour * 60 + bounded_minute
	var difference := posmod(target_total - start_total, 1440)
	elapsed_game_seconds = float(difference) / 1440.0 * maxf(60.0, seconds_per_game_day)
	_last_total_minute = -1
	_sync_clock(true)

func _sync_clock(force: bool) -> void:
	var total_minutes := int(floor(elapsed_game_seconds / maxf(60.0, seconds_per_game_day) * 1440.0))
	if not force and total_minutes == _last_total_minute:
		return
	var previous_hour := -1
	if _last_total_minute >= 0:
		previous_hour = int(floor(_last_total_minute / 60.0)) % 24
	_last_total_minute = total_minutes
	var hour := get_hour()
	var minute := get_minute()
	var day := get_day_number()
	if drive_sun_light:
		_update_sun()
	_broadcast_time(hour, minute, day, force or previous_hour != hour)
	time_changed.emit(hour, minute, day, get_phase())

func _broadcast_time(hour: int, _minute: int, _day: int, hour_has_changed: bool) -> void:
	if not hour_has_changed:
		return
	hour_changed.emit(hour, get_day_number())
	for brain in get_tree().get_nodes_in_group("npc_brains"):
		if is_instance_valid(brain) and brain.has_method("set_world_hour"):
			brain.call("set_world_hour", hour)

func _update_sun() -> void:
	if _sun == null or not is_instance_valid(_sun):
		return
	var hour := get_game_hour()
	var daylight := sin(clampf((hour - 6.0) / 12.0, 0.0, 1.0) * PI)
	_sun.rotation_degrees.x = -90.0 + clampf((hour - 6.0) / 12.0, 0.0, 1.0) * 180.0
	_sun.light_energy = lerpf(0.035, 1.0, maxf(0.0, daylight))
	_sun.light_color = Color(1.0, 0.78, 0.58).lerp(Color(1.0, 0.97, 0.88), clampf(daylight * 1.8, 0.0, 1.0))
