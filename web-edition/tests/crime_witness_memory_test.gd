extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var m=load("res://scripts/world/crime_witness_memory.gd").new()
		assert(m.record("npc1","theft",Vector3.ZERO,0.7))
		assert(m.record("npc2","theft",Vector3.ONE,0.9))
		assert(m.get_witness_count("theft")==2)
		assert(absf(m.get_best_confidence("theft")-0.9)<0.001)
		assert(not m.record("npc3","theft",Vector3.ZERO,2.0))
	print("PASS: Crime Witness Memory.")
	quit(0)
