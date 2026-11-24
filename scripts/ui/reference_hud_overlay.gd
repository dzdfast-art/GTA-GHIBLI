extends CanvasLayer

const MINIMAP_SCRIPT = preload("res://scripts/ui/minimap_widget.gd")

var _root: Control
var _minimap: Control
var _money_label: Label
var _clock_label: Label
var _weapon_label: Label
var _ammo_label: Label
var _health_bar: ProgressBar
var _armor_bar: ProgressBar
var _wanted_stars: Array[Label] = []
var _player: CharacterBody3D
var _wallet: Node
var _status: Node
var _clock: Node
var _refresh_timer := 0.0


func _ready() -> void:
	layer = 1
	add_to_group("reference_hud")
	_build_hud()
	_bind_player()


func _process(delta: float) -> void:
	if not is_instance_valid(_player):
		_bind_player()
	_refresh_timer -= delta
	if _refresh_timer > 0.0:
		return
	_refresh_timer = 0.12
	_refresh_values()


func _build_hud() -> void:
	_root = Control.new()
	_root.name = "ReferenceHUD"
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_root)

	_minimap = MINIMAP_SCRIPT.new() as Control
	_minimap.name = "CircularMinimap"
	_minimap.position = Vector2(20.0, 18.0)
	_minimap.size = Vector2(210.0, 210.0)
	_root.add_child(_minimap)

	var north := _make_label("CompassNorth", "N", 20, Color(1.0, 0.97, 0.83))
	north.position = Vector2(105.0, 0.0)
	north.size = Vector2(22.0, 24.0)
	north.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_minimap.add_child(north)

	_money_label = _make_label("Money", "$0000250", 29, Color(0.25, 1.0, 0.20))
	_place_top_right(_money_label, -306.0, 18.0, -118.0, 52.0)
	_money_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_root.add_child(_money_label)

	_clock_label = _make_label("GameClock", "05:00", 18, Color(1.0, 0.96, 0.82))
	_place_top_right(_clock_label, -306.0, 54.0, -118.0, 78.0)
	_clock_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_root.add_child(_clock_label)

	var stars_row := HBoxContainer.new()
	stars_row.name = "WantedStars"
	_place_top_right(stars_row, -306.0, 80.0, -116.0, 109.0)
	stars_row.alignment = BoxContainer.ALIGNMENT_END
	stars_row.add_theme_constant_override("separation", 1)
	_root.add_child(stars_row)
	for index in range(5):
		var star := _make_label("Star_%d" % index, "★", 23, Color(0.37, 0.40, 0.42, 0.78))
		star.size_flags_horizontal = Control.SIZE_SHRINK_END
		stars_row.add_child(star)
		_wanted_stars.append(star)

	_health_bar = _make_bar("HealthBar", Color(0.84, 0.10, 0.10))
	_place_top_right(_health_bar, -304.0, 115.0, -118.0, 132.0)
	_root.add_child(_health_bar)

	_armor_bar = _make_bar("ArmorBar", Color(0.65, 0.80, 0.88))
	_place_top_right(_armor_bar, -304.0, 137.0, -118.0, 154.0)
	_root.add_child(_armor_bar)

	var weapon_panel := PanelContainer.new()
	weapon_panel.name = "WeaponPanel"
	_place_top_right(weapon_panel, -108.0, 18.0, -18.0, 154.0)
	weapon_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.025, 0.035, 0.045, 0.88), Color(0.88, 0.86, 0.76, 0.86)))
	_root.add_child(weapon_panel)
	var weapon_stack := VBoxContainer.new()
	weapon_stack.alignment = BoxContainer.ALIGNMENT_CENTER
	weapon_stack.add_theme_constant_override("separation", 1)
	weapon_panel.add_child(weapon_stack)
	_weapon_label = _make_label("WeaponIcon", "✊", 36, Color(1.0, 0.98, 0.88))
	_weapon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	weapon_stack.add_child(_weapon_label)
	var weapon_name := _make_label("WeaponName", "FIST", 11, Color(1.0, 0.88, 0.55))
	weapon_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	weapon_stack.add_child(weapon_name)
	_ammo_label = _make_label("Ammo", "MELEE", 11, Color(1.0, 1.0, 1.0))
	_ammo_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	weapon_stack.add_child(_ammo_label)


func _bind_player() -> void:
	_player = get_tree().get_first_node_in_group("player") as CharacterBody3D
	if _player == null:
		return
	_wallet = _player.get_node_or_null("PlayerWallet")
	_status = _player.get_node_or_null("PlayerStatus")
	_clock = get_tree().get_first_node_in_group("world_clock")
	if _minimap != null and _minimap.has_method("set_player"):
		_minimap.call("set_player", _player)
	_refresh_values()


func _refresh_values() -> void:
	if is_instance_valid(_wallet) and _wallet.has_method("get_balance"):
		_money_label.text = "$%07d" % int(_wallet.call("get_balance"))
	if is_instance_valid(_clock) and _clock.has_method("get_clock_text"):
		_clock_label.text = str(_clock.call("get_clock_text"))
	if is_instance_valid(_status):
		var health := float(_status.get("health"))
		var max_health := maxf(1.0, float(_status.get("max_health")))
		var armor := float(_status.get("armor"))
		var max_armor := maxf(1.0, float(_status.get("max_armor")))
		var wanted := clampi(int(_status.get("wanted_level")), 0, 5)
		_health_bar.value = health / max_health * 100.0
		_armor_bar.value = armor / max_armor * 100.0
		for index in range(_wanted_stars.size()):
			_wanted_stars[index].modulate = Color(1.0, 0.82, 0.22) if index < wanted else Color(0.34, 0.39, 0.43, 0.75)
		var weapon_id := str(_status.get("equipped_weapon_id"))
		if weapon_id == "fists":
			_weapon_label.text = "✊"
			_ammo_label.text = "MELEE"
		else:
			_weapon_label.text = _weapon_icon_for(weapon_id)
			_ammo_label.text = "%d/%d" % [int(_status.get("magazine_ammo")), int(_status.get("reserve_ammo"))]


func _weapon_icon_for(weapon_id: String) -> String:
	match weapon_id:
		"pistol":
			return "P"
		"rifle", "smg":
			return "▰"
		"shotgun":
			return "━"
		"knife":
			return "╱"
	return "•"


func _make_label(node_name: String, caption: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.name = node_name
	label.text = caption
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color(0.015, 0.02, 0.025, 1.0))
	label.add_theme_constant_override("outline_size", 4)
	return label


func _make_bar(node_name: String, fill_color: Color) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.name = node_name
	bar.min_value = 0.0
	bar.max_value = 100.0
	bar.value = 100.0
	bar.show_percentage = false
	bar.add_theme_stylebox_override("background", _panel_style(Color(0.04, 0.05, 0.055, 0.92), Color(0.02, 0.025, 0.03, 1.0)))
	bar.add_theme_stylebox_override("fill", _panel_style(fill_color, fill_color.darkened(0.22)))
	return bar


func _panel_style(fill: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(2)
	style.set_corner_radius_all(3)
	return style


func _place_top_right(control: Control, left: float, top: float, right: float, bottom: float) -> void:
	control.anchor_left = 1.0
	control.anchor_right = 1.0
	control.anchor_top = 0.0
	control.anchor_bottom = 0.0
	control.offset_left = left
	control.offset_top = top
	control.offset_right = right
	control.offset_bottom = bottom


func get_minimap() -> Control:
	return _minimap
