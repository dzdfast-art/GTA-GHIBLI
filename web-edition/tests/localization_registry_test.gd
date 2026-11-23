extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var m=load("res://scripts/world/localization_registry.gd").new()
		assert(m.register("play","en","Play"))
		assert(m.register("play","ar","العب"))
		assert(m.set_locale("ar") and m.translate("play")=="العب" and m.is_rtl())
		assert(not m.set_locale("fr"))
	print("PASS: Arabic and English Localization.")
	quit(0)
