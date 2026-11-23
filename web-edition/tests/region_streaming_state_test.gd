extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var m=load("res://scripts/world/region_streaming_state.gd").new()
		assert(m.request_load("harbor"))
		assert(not m.request_load("harbor"))
		assert(m.mark_loaded("harbor") and m.get_state("harbor")=="loaded")
		assert(m.unload("harbor") and m.get_state("harbor")=="unloaded")
	print("PASS: World Region Streaming State.")
	quit(0)
