extends SceneTree

const MENU_SCRIPT = preload("res://scripts/ui/pause_settings_menu.gd")
const WALLET_SCRIPT = preload("res://scripts/systems/player_wallet.gd")
const NEEDS_SCRIPT = preload("res://scripts/systems/player_needs.gd")

func _initialize() -> void:
	call_deferred("_run_test")

func _run_test() -> void:
	var world := WorldEnvironment.new()
	world.environment = Environment.new()
	world.add_to_group("quality_managed_world_environment")
	root.add_child(world)
	var sun := DirectionalLight3D.new()
	sun.add_to_group("quality_managed_sun")
	root.add_child(sun)

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

	var pause_options := menu.get_node("PauseAndSettingsOverlay/PauseMenu/ClassicPauseOptions")
	var expected_options := ["RESUME", "START NEW GAME", "MAP", "STATS", "BRIEF", "OPTIONS", "QUIT GAME"]
	for index in range(expected_options.size()):
		var option := pause_options.get_node("PauseOptionRow%d/PauseOption%d" % [index, index]) as Button
		if option == null or option.text != expected_options[index]:
			_fail("The pause menu options are not in the required order.")
			return

	var player := Node3D.new()
	player.name = "TestPlayer"
	player.add_to_group("player")
	root.add_child(player)
	var wallet: Node = WALLET_SCRIPT.new()
	wallet.set("persistence_enabled", false)
	wallet.set("initial_balance", 875)
	wallet.name = "PlayerWallet"
	player.add_child(wallet)
	var needs: Node = NEEDS_SCRIPT.new()
	needs.set("persistence_enabled", false)
	needs.name = "PlayerNeeds"
	player.add_child(needs)
	needs.set("hunger", 72.0)
	needs.set("thirst", 58.0)
	needs.set("energy", 84.0)
	var stats_report := str(menu.call("_build_stats_report"))
	if not stats_report.contains("875") or not stats_report.contains("72%") or not stats_report.contains("58%"):
		_fail("STATS did not report the live wallet and player needs.")
		return
	var brief_report := str(menu.call("_build_brief_report"))
	for mission_title in ["صباح جديد في قرية الصفصاف", "الطريق القديم: عملية الإنقاذ", "ظلال فوق الميناء", "القطار الأخير"]:
		if not brief_report.contains(mission_title):
			_fail("BRIEF is missing mission information: " + mission_title)
			return
	if brief_report.contains("سيتم ربط هذه الصفحة ببيانات اللعب لاحقاً"):
		_fail("BRIEF still contains placeholder text.")
		return

	menu.call("_on_quality_selected", 0)
	if world.environment.glow_enabled or sun.shadow_enabled or sun.directional_shadow_max_distance != 32.0:
		_fail("Low graphics preset did not disable glow/shadows and shorten shadow distance.")
		return
	menu.call("_on_quality_selected", 2)
	if not world.environment.glow_enabled or not sun.shadow_enabled or sun.directional_shadow_max_distance != 55.0:
		_fail("High graphics preset did not enable glow/shadows and restore shadow distance.")
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
	menu.call("_show_map")
	var map_page := menu.get_node_or_null("PauseAndSettingsOverlay/MapMenu") as Control
	if map_page == null or not map_page.visible:
		_fail("Selecting MAP did not open the world map page.")
		return
	var map_canvas := map_page.get_node_or_null("MapFrame/MapCanvas")
	if map_canvas == null or not map_canvas.has_method("get_region_markers"):
		_fail("The MAP page does not contain the interactive world map canvas.")
		return
	var map_markers: Array = map_canvas.call("get_region_markers")
	if map_markers.size() != 6:
		_fail("The world map must include Willow Village, all four districts, and Marsa Al-Noor.")
		return
	var has_marsa := false
	for marker in map_markers:
		if str(marker.get("id", "")) == "marsa_al_noor":
			has_marsa = true
	if not has_marsa:
		_fail("The world map does not show the Marsa Al-Noor location.")
		return
	menu.call("_show_main_menu")
	if not (menu.get_node("PauseAndSettingsOverlay/PauseMenu") as Control).visible:
		_fail("Returning from the map did not restore the pause menu.")
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
