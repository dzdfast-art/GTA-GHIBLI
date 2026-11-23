extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var script = load("res://scripts/world/localization_registry.gd")
	if script == null:
		_fail("Localization registry did not load.")
		return
	var model = script.new()
	assert(model.register("play", "en", "Play"))
	assert(model.register("play", "ar", "العب"))
	assert(model.set_locale("ar"))
	assert(model.translate("play") == "العب")
	assert(model.is_rtl())
	assert(model.set_locale("en"))
	assert(model.translate("play") == "Play")
	assert(not model.set_locale("fr"))
	assert(model.translate("missing") == "missing")
	print("PASS: Arabic and English localization, fallback and RTL state.")
	quit(0)

func _fail(message: String) -> void:
	push_error(message)
	quit(1)
