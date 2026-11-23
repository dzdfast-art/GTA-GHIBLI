extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var m=load("res://scripts/world/pedestrian_crossing.gd").new()
		assert(m.register_waiting_pedestrian()==1)
		assert(m.release_pedestrians()==0)
		m.set_signal_allows_walk(true)
		assert(m.release_pedestrians()==1 and m.get_waiting_count()==0)
	print("PASS: Pedestrian Crossing Controller.")
	quit(0)
