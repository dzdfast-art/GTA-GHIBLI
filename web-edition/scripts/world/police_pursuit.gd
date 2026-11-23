extends RefCounted
class_name GhibliPolicePursuit

var state: String = "idle"
var target: Vector3 = Vector3.ZERO
var search_time: float = 0.0
var search_timeout: float = 20.0

func configure(timeout_seconds: float = 20.0) -> bool:
	if timeout_seconds <= 0.0:
		return false
	search_timeout = timeout_seconds
	return true

func start(player_position: Vector3) -> void:
	target = player_position
	state = "pursuing"
	search_time = 0.0

func update_sighting(player_position: Vector3, visible: bool, delta: float) -> String:
	if state == "idle" or state == "lost":
		return state
	if visible:
		target = player_position
		state = "pursuing"
		search_time = 0.0
	else:
		state = "searching"
		search_time += maxf(0.0, delta)
		if search_time >= search_timeout:
			state = "lost"
	return state

func reset() -> void:
	state = "idle"
	target = Vector3.ZERO
	search_time = 0.0
