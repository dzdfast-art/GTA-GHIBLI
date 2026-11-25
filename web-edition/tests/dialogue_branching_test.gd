extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var m=load("res://scripts/world/dialogue_branching.gd").new()
	var choices: Array[String] = ["help", "leave"]
	assert(m.add_node("start","Hello",choices))
	assert(m.choose("start",0)=="help")
	assert(m.choose("start",5)=="")
	assert(m.get_node("start").text=="Hello")
	print("PASS: Branching Dialogue State.")
	quit(0)
