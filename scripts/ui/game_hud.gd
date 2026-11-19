extends Control

const RADAR_SCRIPT = preload("res://scripts/ui/minimap_radar.gd")

var _player: Node3D
var _radar: Control
var _clock_label: Label
var _cash_label: Label
var _health_label: Label
var _health_bar: ProgressBar
var _refresh_timer := 0.0


func _ready() -> void:
	add_to_group("gameplay_hud")
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_interface()


func bind_player(player: Node3D) -> void:
	_player = player
	if _radar != null:
		_radar.call("set_player", _player)
	_refresh_status()


func set_gameplay_visible(value: bool) -> void:
	visible = value


func set_target_position(position: Vector3, active: bool) -> void:
	if _radar != null:
		_radar.call("set_target_position", position, active)


func _process(delta: float) -> void:
	_refresh_timer += delta
	if _refresh_timer < 0.20:
		return
	_refresh_timer = 0.0
	if _player == null or not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player") as Node3D
		if _radar != null:
			_radar.call("set_player", _player)
	_refresh_status()


func _build_interface() -> void:
	_radar = RADAR_SCRIPT.new() as Control
	_radar.name = "LiveRadar"
	_radar.set_anchors_preset(Control.PRESET_TOP_LEFT)
	_radar.offset_left = 16.0
	_radar.offset_top = 16.0
	_radar.offset_right = 172.0
	_radar.offset_bottom = 172.0
	add_child(_radar)

	var status := VBoxContainer.new()
	status.name = "PlayerStatus"
	status.anchor_left = 1.0
	status.anchor_top = 0.0
	status.anchor_right = 1.0
	status.anchor_bottom = 0.0
	status.offset_left = -304.0
	status.offset_top = 14.0
	status.offset_right = -16.0
	status.offset_bottom = 116.0
	status.add_theme_constant_override("separation", 2)
	status.alignment = BoxContainer.ALIGNMENT_END
	add_child(status)

	var clock_row := HBoxContainer.new()
	clock_row.name = "ClockRow"
	clock_row.alignment = BoxContainer.ALIGNMENT_END
	status.add_child(clock_row)

	var fist := TextureRect.new()
	fist.name = "UnarmedFistIcon"
	fist.texture = load("res://assets/ui/hud/fist.svg")
	fist.custom_minimum_size = Vector2(30.0, 30.0)
	fist.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	fist.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	clock_row.add_child(fist)

	_clock_label = Label.new()
	_clock_label.name = "WorldClock"
	_clock_label.text = "05:00"
	_clock_label.add_theme_font_size_override("font_size", 20)
	_clock_label.add_theme_color_override("font_color", Color(1.0, 0.94, 0.78, 1.0))
	_clock_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.95))
	_clock_label.add_theme_constant_override("shadow_offset_x", 2)
	_clock_label.add_theme_constant_override("shadow_offset_y", 2)
	clock_row.add_child(_clock_label)

	_cash_label = Label.new()
	_cash_label.name = "CashBalance"
	_cash_label.text = "$ 250"
	_cash_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_cash_label.add_theme_font_size_override("font_size", 20)
	_cash_label.add_theme_color_override("font_color", Color(0.45, 0.95, 0.58, 1.0))
	_cash_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.95))
	_cash_label.add_theme_constant_override("shadow_offset_x", 2)
	_cash_label.add_theme_constant_override("shadow_offset_y", 2)
	status.add_child(_cash_label)

	var health_row := HBoxContainer.new()
	health_row.name = "HealthRow"
	health_row.alignment = BoxContainer.ALIGNMENT_END
	status.add_child(health_row)

	_health_label = Label.new()
	_health_label.name = "HealthValue"
	_health_label.text = "100"
	_health_label.add_theme_font_size_override("font_size", 13)
	_health_label.add_theme_color_override("font_color", Color(1.0, 0.82, 0.78, 1.0))
	health_row.add_child(_health_label)

	_health_bar = ProgressBar.new()
	_health_bar.name = "PlayerHealthBar"
	_health_bar.custom_minimum_size = Vector2(132.0, 14.0)
	_health_bar.min_value = 0.0
	_health_bar.max_value = 100.0
	_health_bar.value = 100.0
	_health_bar.show_percentage = false
	var bar_background := StyleBoxFlat.new()
	bar_background.bg_color = Color(0.05, 0.05, 0.06, 0.82)
	bar_background.set_corner_radius_all(6)
	var bar_fill := StyleBoxFlat.new()
	bar_fill.bg_color = Color(0.86, 0.12, 0.15, 0.98)
	bar_fill.set_corner_radius_all(6)
	_health_bar.add_theme_stylebox_override("background", bar_background)
	_health_bar.add_theme_stylebox_override("fill", bar_fill)
	health_row.add_child(_health_bar)


func _refresh_status() -> void:
	if _player == null or not is_instance_valid(_player):
		return
	var wallet := _player.get_node_or_null("PlayerWallet")
	if wallet != null and wallet.has_method("get_balance"):
		_cash_label.text = "$ %d" % int(wallet.call("get_balance"))

	var clock := get_tree().get_first_node_in_group("world_clock")
	if clock != null and clock.has_method("get_clock_text"):
		_clock_label.text = str(clock.call("get_clock_text"))

	var health := _player.get_node_or_null("PlayerHealth")
	if health != null:
		var current := float(health.get("current_health"))
		var maximum := maxf(1.0, float(health.get("maximum_health")))
		_health_bar.max_value = maximum
		_health_bar.value = clampf(current, 0.0, maximum)
		_health_label.text = str(int(round(current)))
