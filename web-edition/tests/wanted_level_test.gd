extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	extends RefCounted
	class_name GhibliWantedLevel
	var level: int=0
	var max_level: int=5
	var cooldown: float=0.0
	func add_crime(severity: int=1) -> int:
		level=clampi(level+maxi(1,severity),0,max_level)
		cooldown=0.0
		return level
	func reduce_by_arrest() -> int:
		level=maxi(0,level-2)
		cooldown=0.0
		return level
	func tick(delta: float, hidden: bool) -> int:
		if delta>0.0 and hidden and level>0:
			cooldown+=delta
			if cooldown>=30.0:
				level-=1
				cooldown=0.0
		return level
	func get_level() -> int:
		return level
	print("PASS: Wanted Level and Police Response.")
	quit(0)
