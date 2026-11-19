extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://main.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var scene := MAIN_SCENE.instantiate()
	root.add_child(scene)
	for _frame in range(6):
		await process_frame

	var huds := get_nodes_in_group("gameplay_hud")
	if huds.size() != 1:
		push_error("Expected exactly one logical gameplay HUD, found %d." % huds.size())
		quit(1)
		return

	for group_name in [&"mission_hud_sources", &"side_activity_hud_sources"]:
		for source in get_nodes_in_group(group_name):
			var panel = source.get("_panel")
			if panel is Control and panel.visible:
				push_error("Legacy mission/activity panel should be hidden: " + source.name)
				quit(1)
				return
			if source.has_method("get_hud_snapshot"):
				var snapshot = source.call("get_hud_snapshot")
				if not snapshot is Dictionary:
					push_error("HUD source did not return a dictionary: " + source.name)
					quit(1)
					return

	print("PASS: one gameplay HUD and no stacked legacy mission/activity panels.")
	quit(0)
