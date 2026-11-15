extends CanvasLayer

const SETTINGS_PATH := "user://gta_ghibli_settings.cfg"
const PANEL_COLOR := Color(0.055, 0.075, 0.075, 0.97)
const ACCENT := Color(0.83, 0.72, 0.43, 1.0)
const TEXT_COLOR := Color(0.94, 0.93, 0.86, 1.0)

var _overlay: Control
var _main_panel: PanelContainer
var _settings_panel: PanelContainer
var _pause_touch_button: Button
var _menu_buttons: Array[Button] = []
var _menu_cursors: Array[Label] = []
var _selected_menu_index := 2
var _settings := {
	"master_volume": 0.85, "music_volume": 0.65, "effects_volume": 0.85,
	"dialogue_volume": 1.0, "look_sensitivity": 1.0, "graphics_quality": 2,
	"target_fps": 60, "touch_scale": 1.0, "touch_opacity": 0.9, "bike_steering": "analog", "show_subtitles": true, "language": "ar"
}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_load_settings()
	_apply_audio_settings()
	_apply_video_and_camera_settings()
	_build_interface()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_down"):
		_move_menu_selection(1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_up"):
		_move_menu_selection(-1)
		get_viewport().set_input_as_handled()

func toggle_pause() -> void:
	if _overlay == null:
		return
	if _overlay.visible:
		_close_menu()
	else:
		_open_menu()

func _open_menu() -> void:
	_overlay.visible = true
	_main_panel.visible = true
	_settings_panel.visible = false
	if _pause_touch_button != null:
		_pause_touch_button.visible = false
	get_tree().paused = true

func _close_menu() -> void:
	_overlay.visible = false
	if _pause_touch_button != null:
		_pause_touch_button.visible = true
	get_tree().paused = false

func _build_interface() -> void:
	_overlay = Control.new()
	_overlay.name = "PauseAndSettingsOverlay"
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	_overlay.visible = false
	add_child(_overlay)

	var black_backdrop := ColorRect.new()
	black_backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	black_backdrop.color = Color(0.006, 0.008, 0.007, 1.0)
	_overlay.add_child(black_backdrop)

	var header := TextureRect.new()
	header.name = "CinematicCityHeader"
	header.texture = load("res://assets/ui/pause_menu_header.svg")
	header.set_anchors_preset(Control.PRESET_TOP_WIDE)
	header.offset_bottom = 300.0
	header.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	header.stretch_mode = TextureRect.STRETCH_SCALE
	_overlay.add_child(header)

	var header_fade := ColorRect.new()
	header_fade.set_anchors_preset(Control.PRESET_TOP_WIDE)
	header_fade.offset_bottom = 315.0
	header_fade.color = Color(0.0, 0.0, 0.0, 0.30)
	_overlay.add_child(header_fade)

	_main_panel = PanelContainer.new()
	_main_panel.name = "PauseMenu"
	_main_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var transparent_style := StyleBoxEmpty.new()
	_main_panel.add_theme_stylebox_override("panel", transparent_style)
	_overlay.add_child(_main_panel)

	var menu := VBoxContainer.new()
	menu.name = "ClassicPauseOptions"
	menu.set_anchors_preset(Control.PRESET_CENTER)
	menu.position = Vector2(-300.0, -35.0)
	menu.custom_minimum_size = Vector2(600.0, 470.0)
	menu.add_theme_constant_override("separation", 5)
	_main_panel.add_child(menu)
	_menu_buttons.clear()
	_menu_cursors.clear()
	_add_classic_menu_button(menu, "RESUME", 0, _close_menu)
	_add_classic_menu_button(menu, "START NEW GAME", 1, _restart_game)
	_add_classic_menu_button(menu, "MAP", 2, _show_info.bind("الخريطة"))
	_add_classic_menu_button(menu, "STATS", 3, _show_info.bind("الإحصائيات"))
	_add_classic_menu_button(menu, "BRIEF", 4, _show_info.bind("ملخص المهام"))
	_add_classic_menu_button(menu, "OPTIONS", 5, _show_settings)
	_add_classic_menu_button(menu, "QUIT GAME", 6, _quit_game)
	_refresh_menu_selection()

	_settings_panel = _make_panel()
	_settings_panel.name = "SettingsMenu"
	_settings_panel.set_anchors_preset(Control.PRESET_CENTER)
	_settings_panel.position = Vector2(-430.0, -265.0)
	_settings_panel.custom_minimum_size = Vector2(860.0, 530.0)
	_settings_panel.visible = false
	_overlay.add_child(_settings_panel)
	_build_settings_page()

	var pause_button := _make_button("Ⅱ", 22)
	_pause_touch_button = pause_button
	pause_button.name = "PauseTouchButton"
	pause_button.anchor_left = 1.0
	pause_button.anchor_right = 1.0
	pause_button.offset_left = -82.0
	pause_button.offset_top = 18.0
	pause_button.offset_right = -18.0
	pause_button.offset_bottom = 82.0
	pause_button.custom_minimum_size = Vector2(64.0, 64.0)
	pause_button.pressed.connect(toggle_pause)
	add_child(pause_button)

func sixty_four() -> int:
	return 64

func _add_classic_menu_button(parent: VBoxContainer, caption: String, index: int, action: Callable) -> void:
	var row := HBoxContainer.new()
	row.name = "PauseOptionRow" + str(index)
	row.custom_minimum_size = Vector2(600.0, 54.0)
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 0)

	var cursor := Label.new()
	cursor.name = "SelectionCursor" + str(index)
	cursor.text = "✥"
	cursor.custom_minimum_size = Vector2(54.0, 54.0)
	cursor.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cursor.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	cursor.add_theme_font_size_override("font_size", 46)
	cursor.add_theme_color_override("font_color", Color(0.88, 0.91, 1.0, 1.0))
	row.add_child(cursor)
	_menu_cursors.append(cursor)

	var button := Button.new()
	button.name = "PauseOption" + str(index)
	button.text = caption
	button.custom_minimum_size = Vector2(546.0, 54.0)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.focus_mode = Control.FOCUS_ALL
	button.add_theme_font_size_override("font_size", 34)
	button.add_theme_color_override("font_color", Color(0.43, 0.32, 0.10, 1.0))
	button.add_theme_color_override("font_hover_color", Color(0.86, 0.65, 0.18, 1.0))
	button.add_theme_color_override("font_pressed_color", Color(0.96, 0.76, 0.25, 1.0))
	button.add_theme_color_override("font_focus_color", Color(0.86, 0.65, 0.18, 1.0))
	button.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
	button.add_theme_stylebox_override("hover", StyleBoxEmpty.new())
	button.add_theme_stylebox_override("pressed", StyleBoxEmpty.new())
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.mouse_entered.connect(_select_menu_item.bind(index))
	button.focus_entered.connect(_select_menu_item.bind(index))
	button.pressed.connect(action)
	row.add_child(button)
	parent.add_child(row)
	_menu_buttons.append(button)

func _select_menu_item(index: int) -> void:
	_selected_menu_index = clampi(index, 0, _menu_buttons.size() - 1)
	_refresh_menu_selection()

func _refresh_menu_selection() -> void:
	for i in range(_menu_buttons.size()):
		var button := _menu_buttons[i]
		_menu_cursors[i].visible = i == _selected_menu_index
		button.add_theme_color_override("font_color", Color(0.86, 0.65, 0.18, 1.0) if i == _selected_menu_index else Color(0.43, 0.32, 0.10, 1.0))

func _move_menu_selection(direction: int) -> void:
	if _overlay == null or not _overlay.visible or not _main_panel.visible or _menu_buttons.is_empty():
		return
	_selected_menu_index = posmod(_selected_menu_index + direction, _menu_buttons.size())
	_refresh_menu_selection()
	_menu_buttons[_selected_menu_index].grab_focus()

func _build_settings_page() -> void:
	var page := VBoxContainer.new()
	page.add_theme_constant_override("separation", 9)
	_settings_panel.add_child(page)
	var heading := Label.new()
	heading.text = "الإعدادات  |  OPTIONS"
	heading.add_theme_font_size_override("font_size", 25)
	heading.add_theme_color_override("font_color", ACCENT)
	page.add_child(heading)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	page.add_child(scroll)
	var rows := VBoxContainer.new()
	rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rows.add_theme_constant_override("separation", 7)
	scroll.add_child(rows)
	_add_slider(rows, "الصوت العام  |  Master", "master_volume", 0.0, 1.0, 0.05)
	_add_slider(rows, "الموسيقى  |  Music", "music_volume", 0.0, 1.0, 0.05)
	_add_slider(rows, "المؤثرات  |  Effects", "effects_volume", 0.0, 1.0, 0.05)
	_add_slider(rows, "الحوار  |  Dialogue", "dialogue_volume", 0.0, 1.0, 0.05)
	_add_slider(rows, "حساسية الكاميرا  |  Camera", "look_sensitivity", 0.2, 2.5, 0.05)
	_add_slider(rows, "حجم أزرار اللمس  |  Touch size", "touch_scale", 0.75, 1.35, 0.05)
	_add_slider(rows, "شفافية أزرار اللمس  |  Touch opacity", "touch_opacity", 0.35, 1.0, 0.05)

	var bike_steering_row := HBoxContainer.new()
	rows.add_child(bike_steering_row)
	_add_row_label(bike_steering_row, "توجيه الدراجة  |  Bike steering")
	var bike_steering := OptionButton.new()
	bike_steering.add_item("ANALOG  |  عصا", 0)
	bike_steering.add_item("BUTTONS  |  أزرار", 1)
	bike_steering.add_item("FLICK  |  سحب", 2)
	var steering_modes := ["analog", "buttons", "flick"]
	var selected_mode := steering_modes.find(str(_settings.bike_steering))
	bike_steering.select(maxi(selected_mode, 0))
	bike_steering.item_selected.connect(_on_bike_steering_selected)
	bike_steering_row.add_child(bike_steering)
	var bike_hint := Label.new()
	bike_hint.text = "يُطبَّق فوراً على الدراجة ويحفظ على هذا الجهاز."
	bike_hint.add_theme_color_override("font_color", Color(0.76, 0.82, 0.72, 1.0))
	rows.add_child(bike_hint)

	var quality_row := HBoxContainer.new()
	rows.add_child(quality_row)
	_add_row_label(quality_row, "جودة الرسومات  |  Graphics")
	var quality := OptionButton.new()
	quality.add_item("منخفضة  |  Low", 0)
	quality.add_item("متوسطة  |  Medium", 1)
	quality.add_item("عالية  |  High", 2)
	quality.select(clampi(int(_settings.graphics_quality), 0, 2))
	quality.item_selected.connect(_on_quality_selected)
	quality_row.add_child(quality)

	var fps_row := HBoxContainer.new()
	rows.add_child(fps_row)
	_add_row_label(fps_row, "معدل الإطارات  |  FPS")
	var fps := OptionButton.new()
	fps.add_item("30 FPS", 30)
	fps.add_item("60 FPS", 60)
	fps.add_item("90 FPS", 90)
	fps.select(0 if int(_settings.target_fps) == 30 else (2 if int(_settings.target_fps) == 90 else 1))
	fps.item_selected.connect(_on_fps_selected.bind(fps))
	fps_row.add_child(fps)

	var subtitles := CheckButton.new()
	subtitles.text = "إظهار الترجمة  |  Subtitles"
	subtitles.button_pressed = bool(_settings.show_subtitles)
	subtitles.toggled.connect(_on_subtitles_toggled)
	rows.add_child(subtitles)

	var language_row := HBoxContainer.new()
	rows.add_child(language_row)
	_add_row_label(language_row, "اللغة  |  Language")
	var language := OptionButton.new()
	language.add_item("العربية  |  Arabic", 0)
	language.add_item("English", 1)
	language.select(0 if str(_settings.language) == "ar" else 1)
	language.item_selected.connect(_on_language_selected)
	language_row.add_child(language)

	var footer := HBoxContainer.new()
	footer.add_theme_constant_override("separation", 10)
	page.add_child(footer)
	var back := _make_button("رجوع  |  Back", 16)
	back.pressed.connect(_show_main_menu)
	footer.add_child(back)
	var save := _make_button("حفظ الإعدادات  |  Save", 16)
	save.pressed.connect(_save_settings)
	footer.add_child(save)
	var note := Label.new()
	note.text = "يتم حفظ الخيارات على هذا الجهاز."
	note.add_theme_color_override("font_color", Color(0.76, 0.82, 0.72, 1.0))
	footer.add_child(note)

func _add_slider(parent: VBoxContainer, caption: String, key: String, minimum: float, maximum: float, step: float) -> void:
	var row := VBoxContainer.new()
	parent.add_child(row)
	var label := Label.new()
	label.text = caption + "  " + str(snappedf(float(_settings[key]), step))
	label.add_theme_color_override("font_color", TEXT_COLOR)
	row.add_child(label)
	var slider := HSlider.new()
	slider.min_value = minimum
	slider.max_value = maximum
	slider.step = step
	slider.value = float(_settings[key])
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.value_changed.connect(_on_slider_changed.bind(key, label, caption, step))
	row.add_child(slider)

func _add_row_label(parent: HBoxContainer, caption: String) -> void:
	var label := Label.new()
	label.text = caption
	label.custom_minimum_size.x = 280.0
	label.add_theme_color_override("font_color", TEXT_COLOR)
	parent.add_child(label)

func _add_nav_button(parent: VBoxContainer, caption: String, action: Callable) -> void:
	var button := _make_button(caption, 16)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.custom_minimum_size.y = 42.0
	button.pressed.connect(action)
	parent.add_child(button)

func _make_button(caption: String, font_size: int) -> Button:
	var button := Button.new()
	button.text = caption
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", font_size)
	button.add_theme_color_override("font_color", TEXT_COLOR)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.14, 0.18, 0.16, 0.98)
	style.border_color = ACCENT
	style.set_border_width_all(1)
	style.set_corner_radius_all(5)
	button.add_theme_stylebox_override("normal", style)
	var hover := style.duplicate() as StyleBoxFlat
	hover.bg_color = Color(0.25, 0.29, 0.22, 1.0)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", hover)
	return button

func _make_panel() -> PanelContainer:
	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = PANEL_COLOR
	style.border_color = Color(0.68, 0.58, 0.34, 0.95)
	style.set_border_width_all(2)
	style.set_corner_radius_all(10)
	panel.add_theme_stylebox_override("panel", style)
	panel.add_theme_constant_override("margin_left", 24)
	panel.add_theme_constant_override("margin_right", 24)
	panel.add_theme_constant_override("margin_top", 22)
	panel.add_theme_constant_override("margin_bottom", 22)
	return panel

func _show_settings() -> void:
	_main_panel.visible = false
	_settings_panel.visible = true

func _show_main_menu() -> void:
	_settings_panel.visible = false
	_main_panel.visible = true
	_refresh_menu_selection()

func _show_info(section: String) -> void:
	var dialog := AcceptDialog.new()
	dialog.dialog_text = section + "\nسيتم ربط هذه الصفحة ببيانات اللعب لاحقاً."
	dialog.title = "GTA GHIBLI"
	_overlay.add_child(dialog)
	dialog.popup_centered()

func _on_slider_changed(value: float, key: String, label: Label, caption: String, step: float) -> void:
	_settings[key] = value
	label.text = caption + "  " + str(snappedf(value, step))
	if key.ends_with("_volume"):
		_apply_audio_settings()
	if key == "look_sensitivity" or key == "touch_scale" or key == "touch_opacity":
		_apply_video_and_camera_settings()

func _on_quality_selected(index: int) -> void:
	_settings.graphics_quality = index
	_apply_video_and_camera_settings()

func _on_fps_selected(index: int, selector: OptionButton) -> void:
	_settings.target_fps = int(selector.get_item_id(index))
	_apply_video_and_camera_settings()

func _on_bike_steering_selected(index: int) -> void:
	var steering_modes := ["analog", "buttons", "flick"]
	_settings.bike_steering = steering_modes[clampi(index, 0, steering_modes.size() - 1)]
	_apply_video_and_camera_settings()


func _on_subtitles_toggled(enabled: bool) -> void:
	_settings.show_subtitles = enabled

func _on_language_selected(index: int) -> void:
	_settings.language = "ar" if index == 0 else "en"

func _apply_video_and_camera_settings() -> void:
	Engine.max_fps = int(_settings.target_fps)
	var quality := int(_settings.graphics_quality)
	get_viewport().msaa_3d = Viewport.MSAA_DISABLED if quality == 0 else (Viewport.MSAA_2X if quality == 1 else Viewport.MSAA_4X)
	for camera in get_tree().get_nodes_in_group("third_person_cameras"):
		camera.set("look_sensitivity", 0.006 * float(_settings.look_sensitivity))
	for controls in get_tree().get_nodes_in_group("mobile_controls"):
		controls.call("set_controls_preferences", float(_settings.touch_scale), float(_settings.touch_opacity))
		controls.call("set_bike_steering_mode", str(_settings.bike_steering))
	for bicycle in get_tree().get_nodes_in_group("bicycles"):
		bicycle.call("set_steering_method", str(_settings.bike_steering))

func _apply_audio_settings() -> void:
	_set_bus_volume("Master", float(_settings.master_volume))
	_set_bus_volume("Music", float(_settings.music_volume))
	_set_bus_volume("SFX", float(_settings.effects_volume))
	_set_bus_volume("Dialogue", float(_settings.dialogue_volume))

func _set_bus_volume(bus_name: String, amount: float) -> void:
	var index := AudioServer.get_bus_index(bus_name)
	if index < 0:
		return
	AudioServer.set_bus_mute(index, amount <= 0.001)
	if amount > 0.001:
		AudioServer.set_bus_volume_db(index, linear_to_db(amount))

func _save_settings() -> void:
	var config := ConfigFile.new()
	for key in _settings:
		config.set_value("game", key, _settings[key])
	var error := config.save(SETTINGS_PATH)
	if error == OK:
		_apply_audio_settings()
		print("GTA GHIBLI settings saved: ", SETTINGS_PATH)
	else:
		push_warning("Could not save settings: " + error_string(error))

func _load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) != OK:
		return
	for key in _settings:
		_settings[key] = config.get_value("game", key, _settings[key])
	if not ["analog", "buttons", "flick"].has(str(_settings.bike_steering)):
		_settings.bike_steering = "analog"

func _restart_game() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _quit_game() -> void:
	get_tree().paused = false
	get_tree().quit()
