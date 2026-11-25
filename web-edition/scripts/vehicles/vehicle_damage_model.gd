extends RefCounted
class_name GhibliVehicleDamageModel

var durability: float = 100.0
var max_durability: float = 100.0
var impact_threshold: float = 4.0
var damage_per_speed: float = 2.5

func configure(values: Dictionary) -> bool:
	var maximum := float(values.get("max_durability", max_durability))
	var threshold := float(values.get("impact_threshold", impact_threshold))
	var rate := float(values.get("damage_per_speed", damage_per_speed))
	if maximum <= 0.0 or threshold < 0.0 or rate < 0.0:
		return false
	max_durability = maximum
	durability = clampf(durability, 0.0, maximum)
	impact_threshold = threshold
	damage_per_speed = rate
	return true

func apply_impact(relative_speed: float, damage_multiplier: float = 1.0) -> Dictionary:
	if relative_speed < 0.0 or damage_multiplier < 0.0:
		return {"valid": false, "damage": 0.0, "durability": durability, "disabled": is_disabled()}
	var excess_speed := maxf(0.0, relative_speed - impact_threshold)
	var damage := minf(durability, excess_speed * damage_per_speed * damage_multiplier)
	durability = maxf(0.0, durability - damage)
	return {"valid": true, "damage": damage, "durability": durability, "disabled": is_disabled()}

func repair(amount: float) -> float:
	if amount <= 0.0:
		return 0.0
	var before := durability
	durability = minf(max_durability, durability + amount)
	return durability - before

func is_disabled() -> bool:
	return durability <= 0.0

func get_condition_ratio() -> float:
	return clampf(durability / max_durability, 0.0, 1.0)
