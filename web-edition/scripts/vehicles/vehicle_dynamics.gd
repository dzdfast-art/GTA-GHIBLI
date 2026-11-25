extends RefCounted
class_name GhibliVehicleDynamics

var max_forward_speed: float = 22.0
var max_reverse_speed: float = 7.0
var acceleration: float = 12.0
var braking: float = 24.0
var rolling_resistance: float = 2.2

func configure(values: Dictionary) -> bool:
	var forward := float(values.get("max_forward_speed", max_forward_speed))
	var reverse := float(values.get("max_reverse_speed", max_reverse_speed))
	var accel := float(values.get("acceleration", acceleration))
	var brake := float(values.get("braking", braking))
	var resistance := float(values.get("rolling_resistance", rolling_resistance))
	if forward <= 0.0 or reverse <= 0.0 or accel <= 0.0 or brake <= 0.0 or resistance < 0.0:
		return false
	max_forward_speed = forward
	max_reverse_speed = reverse
	acceleration = accel
	braking = brake
	rolling_resistance = resistance
	return true

func step_speed(current_speed: float, throttle: float, brake_pressed: bool, delta: float) -> float:
	if delta <= 0.0:
		return current_speed
	var input := clampf(throttle, -1.0, 1.0)
	var target := max_forward_speed * input if input >= 0.0 else max_reverse_speed * input
	if brake_pressed:
		return move_toward(current_speed, 0.0, braking * delta)
	if absf(input) < 0.001:
		return move_toward(current_speed, 0.0, rolling_resistance * delta)
	return clampf(move_toward(current_speed, target, acceleration * delta), -max_reverse_speed, max_forward_speed)

func get_speed_ratio(current_speed: float) -> float:
	var limit := max_forward_speed if current_speed >= 0.0 else max_reverse_speed
	return clampf(absf(current_speed) / limit, 0.0, 1.0)
