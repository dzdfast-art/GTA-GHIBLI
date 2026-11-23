extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var m=load("res://scripts/world/collectible_tracker.gd").new()
		assert(m.configure_total(2))
		assert(m.collect("photo") and m.collect("token"))
		assert(not m.collect("token") and m.is_complete())
		assert(m.get_progress().ratio==1.0)
	print("PASS: Collectible Set Tracker.")
	quit(0)
