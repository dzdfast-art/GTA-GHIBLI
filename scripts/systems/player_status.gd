extends Node

## Shared player status contract for HUD, damage, recovery and future combat systems.
signal health_changed(current: float, maximum: float)
signal armor_changed(current: float, maximum: float)
signal wanted_level_changed(level: int)
signal weapon_changed(weapon_id: String, magazine: int, reserve: int)

@export_range(1.0, 500.0, 1.0) var max_health := 100.0
@export_range(0.0, 500.0, 1.0) var max_armor := 100.0

var health := 100.0
var armor := 0.0
var wanted_level := 0
var equipped_weapon_id := "fists"
var magazine_ammo := 0
var reserve_ammo := 0


func _ready() -> void:
	max_health = maxf(1.0, max_health)
	max_armor = maxf(0.0, max_armor)
	health = max_health
	armor = 0.0
	_emit_all()


func apply_damage(amount: float) -> float:
	if amount <= 0.0 or health <= 0.0:
		return 0.0
	var remaining := amount
	var absorbed := minf(armor, remaining)
	armor -= absorbed
	remaining -= absorbed
	var applied := minf(health, remaining)
	health -= applied
	armor_changed.emit(armor, max_armor)
	health_changed.emit(health, max_health)
	return applied


func restore_health(amount: float) -> float:
	if amount <= 0.0:
		return 0.0
	var before := health
	health = minf(max_health, health + amount)
	if not is_equal_approx(before, health):
		health_changed.emit(health, max_health)
	return health - before


func set_armor(value: float) -> void:
	var next_value := clampf(value, 0.0, max_armor)
	if is_equal_approx(next_value, armor):
		return
	armor = next_value
	armor_changed.emit(armor, max_armor)


func set_wanted_level(value: int) -> void:
	var next_value := clampi(value, 0, 5)
	if wanted_level == next_value:
		return
	wanted_level = next_value
	wanted_level_changed.emit(wanted_level)


func set_weapon(weapon_id: String, magazine: int = 0, reserve: int = 0) -> void:
	var safe_id := weapon_id.strip_edges().to_lower()
	if safe_id.is_empty():
		safe_id = "fists"
	equipped_weapon_id = safe_id
	magazine_ammo = maxi(0, magazine)
	reserve_ammo = maxi(0, reserve)
	weapon_changed.emit(equipped_weapon_id, magazine_ammo, reserve_ammo)


func consume_ammo(amount: int = 1) -> bool:
	if amount <= 0:
		return false
	if magazine_ammo < amount:
		return false
	magazine_ammo -= amount
	weapon_changed.emit(equipped_weapon_id, magazine_ammo, reserve_ammo)
	return true


func _emit_all() -> void:
	health_changed.emit(health, max_health)
	armor_changed.emit(armor, max_armor)
	wanted_level_changed.emit(wanted_level)
	weapon_changed.emit(equipped_weapon_id, magazine_ammo, reserve_ammo)
