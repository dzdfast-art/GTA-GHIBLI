extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var m=load("res://scripts/world/ambient_audio_state.gd").new()
	assert(m.update_context("harbor","night","rain"))
	m.set_intensity(2.0)
	assert(m.get_mix_profile().intensity==1.0)
	assert(not m.update_context("","invalid","snow"))
	print("PASS: Dynamic Ambient Audio State.")
	quit(0)
