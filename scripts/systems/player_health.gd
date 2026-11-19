extends Node

signal health_changed(current: float, maximum: float)
signal damaged(amount: float, remaining: float)
signal healed(amount: float, current: float)
signal died

@export_range(1.0, 1000.0, 1.0) var maximum_health := 100.0
var current_health := 100.0
var _is_dead := false


func _ready() -> void:
	maximum_health = maxf(1.0, maximum_health)
	current_health = clampf(current_health, 0.0, maximum_health)
	_emit_health()


func apply_damage(amount: float, _source_id: StringName = &"") -> bool:
	if _is_dead or amount <= 0.0:
		return false
	var previous := current_health
	current_health = maxf(0.0, current_health - amount)
	var applied := previous - current_health
	if applied <= 0.0:
		return false
	damaged.emit(applied, current_health)
	_emit_health()
	if current_health <= 0.0:
		_is_dead = true
		died.emit()
	return true


func heal(amount: float) -> bool:
	if _is_dead or amount <= 0.0:
		return false
	var previous := current_health
	current_health = minf(maximum_health, current_health + amount)
	var restored := current_health - previous
	if restored <= 0.0:
		return false
	healed.emit(restored, current_health)
	_emit_health()
	return true


func restore_full() -> void:
	_is_dead = false
	current_health = maximum_health
	_emit_health()


func get_health_ratio() -> float:
	return current_health / maximum_health if maximum_health > 0.0 else 0.0


func is_alive() -> bool:
	return not _is_dead and current_health > 0.0


func _emit_health() -> void:
	health_changed.emit(current_health, maximum_health)
