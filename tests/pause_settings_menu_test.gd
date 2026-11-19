extends SceneTree

const MENU_SCRIPT = preload("res://scripts/ui/pause_settings_menu.gd")
const HEALTH_SCRIPT = preload("res://scripts/systems/player_health.gd")
const WALLET_SCRIPT = preload("res://scripts/systems/player_wallet.gd")
const NEEDS_SCRIPT = preload("res://scripts/systems/player_needs.gd")
const CAMPAIGN_SCRIPT = preload("res://scripts/missions/campaign_progress.gd")

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

	var player := Node3D.new()
	player.name = "Player"
	player.add_to_group("player")
	var health: Node = HEALTH_SCRIPT.new()
	health.name = "PlayerHealth"
	player.add_child(health)
	health.set("current_health", 76.0)
	var wallet: Node = WALLET_SCRIPT.new()
	wallet.name = "PlayerWallet"
	wallet.set("persistence_enabled", false)
	wallet.set("initial_balance", 425)
	player.add_child(wallet)
	var needs: Node = NEEDS_SCRIPT.new()
	needs.name = "PlayerNeeds"
	needs.set("persistence_enabled", false)
	player.add_child(needs)
	needs.set("hunger", 62.0)
	needs.set("thirst", 48.0)
	needs.set("energy", 81.0)
	root.add_child(player)

	var campaign: Node = CAMPAIGN_SCRIPT.new()
	root.add_child(campaign)

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
	if int(menu.get("_selected_menu_index")) != 0:
		_fail("Pause menu must initially select RESUME, not another option.")
		return
	var menu_cursors: Array = menu.get("_menu_cursors")
	if menu_cursors.size() != 7 or not menu_cursors[0].visible:
		_fail("Pause menu selection cursor must be visible beside RESUME on open.")
		return
	var previous_selection := int(menu.get("_selected_menu_index"))
	menu.call("_unhandled_input", movement_event)
	if int(menu.get("_selected_menu_index")) != posmod(previous_selection - 1, 7):
		_fail("Visible pause menu did not move its selection for ui_up.")
		return
	menu.call("_close_menu")
	menu.call("_open_menu")
	if int(menu.get("_selected_menu_index")) != 0 or not menu_cursors[0].visible:
		_fail("Reopening pause menu must reset selection to RESUME.")
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
	if map_markers.size() != 5:
		_fail("The world map must include Willow Village and all four open-world districts.")
		return
	menu.call("_show_main_menu")
	if not (menu.get_node("PauseAndSettingsOverlay/PauseMenu") as Control).visible:
		_fail("Returning from the map did not restore the pause menu.")
		return
	menu.call("_show_settings")
	if not (menu.get_node("PauseAndSettingsOverlay/SettingsMenu") as Control).visible:
		_fail("Settings page did not open.")
		return
	menu.call("_show_info", "الإحصائيات")
	var overlay := menu.get_node("PauseAndSettingsOverlay") as Control
	var stats_dialog := overlay.get_node_or_null("PauseInfoDialog") as AcceptDialog
	if stats_dialog == null or not stats_dialog.visible:
		_fail("STATS did not open its information dialog.")
		return
	var stats_text := stats_dialog.dialog_text
	if not stats_text.contains("76 / 100") or not stats_text.contains("425") or not stats_text.contains("62 / 100"):
		_fail("STATS did not display live health, wallet and hunger values.")
		return

	stats_dialog.hide()
	menu.call("_show_info", "ملخص المهام")
	var brief_dialog := overlay.get_node_or_null("PauseInfoDialog") as AcceptDialog
	if brief_dialog == null or brief_dialog != stats_dialog or not brief_dialog.visible:
		_fail("BRIEF must reuse the existing information dialog instead of stacking another window.")
		return
	var brief_text := brief_dialog.dialog_text
	if not brief_text.contains("الفصل الأول: طريق العودة") or not brief_text.contains("صباح جديد في قرية الصفصاف") or brief_text.contains("سيتم ربط هذه الصفحة"):
		_fail("BRIEF did not display the real campaign and mission data.")
		return
	brief_dialog.hide()

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
