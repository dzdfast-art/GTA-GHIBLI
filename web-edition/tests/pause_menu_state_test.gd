extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var m=load("res://scripts/world/pause_menu_state.gd").new()
	assert(m.get_selected_item()=="RESUME")
	assert(m.move_selection(-1)==6 and m.get_selected_item()=="QUIT GAME")
	assert(m.select(2) and m.get_selected_item()=="MAP")
	assert(not m.select(99))
	print("PASS: Pause Menu State and Navigation.")
	quit(0)
