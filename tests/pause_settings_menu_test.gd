extends SceneTree

const MENU_SCRIPT = preload("res://scripts/ui/pause_settings_menu.gd")

func _initialize() -> void:
	call_deferred("_run_test")

func _run_test() -> void:
	var menu: CanvasLayer = MENU_SCRIPT.new() as CanvasLayer
	root.add_child(menu)
	await process_frame
	if menu.get_node_or_null("PauseAndSettingsOverlay") == null:
		_fail("Pause overlay was not created.")
		return
	if menu.get_node_or_null("PauseTouchButton") == null:
		_fail("Android pause touch button was not created.")
		return
	if menu.get_node_or_null("PauseAndSettingsOverlay/PauseMenu") == null:
		_fail("Pause menu page was not created.")
		return
	if menu.get_node_or_null("PauseAndSettingsOverlay/SettingsMenu") == null:
		_fail("Settings page was not created.")
		return
	var current_settings: Dictionary = menu.get("_settings")
	if str(current_settings.get("bike_steering", "")) != "analog":
		_fail("Bike steering should default to Analog.")
		return
	menu.call("_on_bike_steering_selected", 2)
	current_settings = menu.get("_settings")
	if str(current_settings.get("bike_steering", "")) != "flick":
		_fail("Bike steering selection did not update the saved setting.")
		return
	menu.call("toggle_pause")
	if not get_root().get_tree().paused:
		_fail("Opening pause did not pause the game.")
		return
	menu.call("_show_settings")
	if not (menu.get_node("PauseAndSettingsOverlay/SettingsMenu") as Control).visible:
		_fail("Settings page did not open.")
		return
	menu.call("_save_settings")
	menu.call("_close_menu")
	if get_root().get_tree().paused:
		_fail("Closing pause did not resume the game.")
		return
	print("PASS: pause menu, settings page, pause/resume and save.")
	quit(0)

func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	quit(1)
