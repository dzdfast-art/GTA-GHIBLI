extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var m=load("res://scripts/world/contextual_input_map.gd").new()
		assert(m.bind_action("on_foot","jump","space"))
		assert(m.bind_action("vehicle","accelerate","w"))
		assert(m.resolve("vehicle","w")=="accelerate")
		assert(m.get_binding("on_foot","jump")=="space")
		assert(m.clear_context("vehicle") and m.resolve("vehicle","w")=="")
	print("PASS: Contextual Input Mapping.")
	quit(0)
