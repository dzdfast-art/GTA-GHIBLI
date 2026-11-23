extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var m=load("res://scripts/world/accessibility_options.gd").new()
		assert(m.set_option("high_contrast",true))
		assert(m.set_option("reduced_camera_motion",true))
		assert(m.set_text_scale(1.5) and not m.set_text_scale(2.0))
		assert(m.snapshot().subtitles==true)
	print("PASS: Accessibility Options.")
	quit(0)
