extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var m=load("res://scripts/world/garage_upgrade_progression.gd").new()
		assert(m.upgrade("car",0,3,100,500).level==1)
		assert(m.get_level("car")==1)
		assert(not m.upgrade("car",3,3,100,500).ok)
		assert(not m.upgrade("car",1,3,100,20).ok)
	print("PASS: Garage Upgrade Progression.")
	quit(0)
