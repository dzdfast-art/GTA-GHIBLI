extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var m=load("res://scripts/world/settings_profile.gd").new()
		assert(m.set_value("music_volume",2.0) and m.get_value("music_volume")==1.0)
		assert(m.set_value("language","ar") and not m.set_value("language","fr"))
		assert(not m.set_value("unknown",1))
	print("PASS: Player Settings Profile.")
	quit(0)
