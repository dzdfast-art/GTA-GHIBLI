extends RefCounted
class_name GhibliTrafficSignalController

const PHASE_GREEN := "green"
const PHASE_AMBER := "amber"
const PHASE_RED := "red"

var green_duration: float = 18.0
var amber_duration: float = 3.0
var red_duration: float = 18.0
var elapsed_in_phase: float = 0.0
var phase: String = PHASE_GREEN

func configure(values: Dictionary) -> bool:
	var green := float(values.get("green_duration", green_duration))
	var amber := float(values.get("amber_duration", amber_duration))
	var red := float(values.get("red_duration", red_duration))
	if green <= 0.0 or amber <= 0.0 or red <= 0.0:
		return false
	green_duration = green
	amber_duration = amber
	red_duration = red
	elapsed_in_phase = 0.0
	phase = PHASE_GREEN
	return true

func advance(delta: float) -> void:
	if delta <= 0.0:
		return
	elapsed_in_phase += delta
	var guard := 0
	while elapsed_in_phase >= _duration_for_phase(phase) and guard < 1000:
		elapsed_in_phase -= _duration_for_phase(phase)
		phase = _next_phase(phase)
		guard += 1

func get_phase() -> String:
	return phase

func get_remaining_seconds() -> float:
	return maxf(0.0, _duration_for_phase(phase) - elapsed_in_phase)

func can_enter_intersection() -> bool:
	return phase == PHASE_GREEN

func _duration_for_phase(value: String) -> float:
	match value:
		PHASE_GREEN:
			return green_duration
		PHASE_AMBER:
			return amber_duration
		PHASE_RED:
			return red_duration
	return green_duration

func _next_phase(value: String) -> String:
	match value:
		PHASE_GREEN:
			return PHASE_AMBER
		PHASE_AMBER:
			return PHASE_RED
		PHASE_RED:
			return PHASE_GREEN
	return PHASE_GREEN
