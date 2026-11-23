extends RefCounted
class_name GhibliTrafficSpawnBudget

var active_count: int = 0
var maximum: int = 24

func configure(limit: int) -> bool:
	if limit < 0:
		return false
	maximum = limit
	active_count = mini(active_count, maximum)
	return true

func try_spawn() -> bool:
	if active_count >= maximum:
		return false
	active_count += 1
	return true

func despawn(count: int = 1) -> int:
	active_count = maxi(0, active_count - maxi(0, count))
	return active_count

func get_available_slots() -> int:
	return maxi(0, maximum - active_count)
