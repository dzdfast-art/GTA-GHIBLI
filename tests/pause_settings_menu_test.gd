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

	var movement_event := InputEventAction.new()
	movement_event.action = &"ui_up"
	movement_event.pressed = true
	menu.call("_unhandled_input", movement_event)
	if bool(menu.call("_can_capture_menu_navigation")):
		_fail("Hidden pause menu incorrectly captures player movement navigation.")
		return

	menu.call("toggle_pause")
	if not bool(menu.call("_can_capture_menu_navigation")):
		_fail("Visible main pause menu does not accept navigation.")
		return
	var previous_selection := int(menu.get("_selected_menu_index"))
	menu.call("_unhandled_input", movement_event)
	if int(menu.get("_selected_menu_index")) != posmod(previous_selection - 1, 7):
		_fail("Visible pause menu did not move its selection for ui_up.")
		return
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
