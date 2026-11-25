extends RefCounted
class_name GhibliWantedLevel

var level: int = 0
var max_level: int = 5
var cooldown: float = 0.0

func configure(maximum_level: int = 5) -> bool:
	if maximum_level < 1:
		return false
	max_level = maximum_level
	level = clampi(level, 0, max_level)
	return true

func add_crime(severity: int = 1) -> int:
	level = clampi(level + maxi(1, severity), 0, max_level)
	cooldown = 0.0
	return level

func reduce_by_arrest() -> int:
	level = maxi(0, level - 2)
	cooldown = 0.0
	return level

func tick(delta: float, hidden: bool) -> int:
	if delta <= 0.0 or not hidden or level <= 0:
		return level
	cooldown += delta
	while cooldown >= 30.0 and level > 0:
		cooldown -= 30.0
		level -= 1
	if level == 0:
		cooldown = 0.0
	return level

func get_level() -> int:
	return level
