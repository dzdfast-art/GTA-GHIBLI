extends Node

## Runtime health state for the player. Damage/healing is centralized here so
## missions, hazards, vehicles and the HUD can share one authoritative value.
signal health_changed(current_health: float, maximum_health: float)
signal player_died

@export_range(1.0, 1000.0, 1.0) var maximum_health: float = 100.0
@export var reset_to_full_on_ready: bool = true

var current_health: float = 100.0
var _death_emitted := false


func _ready() -> void:
	maximum_health = maxf(1.0, maximum_health)
	if reset_to_full_on_ready:
		current_health = maximum_health
	else:
		current_health = clampf(current_health, 0.0, maximum_health)
	_emit_health()


func take_damage(amount: float) -> bool:
	if amount <= 0.0 or is_dead():
		return false
	var previous := current_health
	current_health = maxf(0.0, current_health - amount)
	if not is_equal_approx(previous, current_health):
		_emit_health()
		if is_dead() and not _death_emitted:
			_death_emitted = true
			player_died.emit()
		return true
	return false


func heal(amount: float) -> bool:
	if amount <= 0.0 or is_dead():
		return false
	var previous := current_health
	current_health = minf(maximum_health, current_health + amount)
	if not is_equal_approx(previous, current_health):
		_emit_health()
		return true
	return false


func set_health(value: float) -> void:
	var previous := current_health
	current_health = clampf(value, 0.0, maximum_health)
	if not is_equal_approx(previous, current_health):
		_emit_health()
		if is_dead() and not _death_emitted:
			_death_emitted = true
			player_died.emit()
		elif not is_dead():
			_death_emitted = false


func reset() -> void:
	_death_emitted = false
	current_health = maximum_health
	_emit_health()


func get_health() -> float:
	return current_health


func get_max_health() -> float:
	return maximum_health


func is_dead() -> bool:
	return current_health <= 0.0


func _emit_health() -> void:
	health_changed.emit(current_health, maximum_health)
