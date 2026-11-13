extends CanvasLayer

## Runtime tracker for the first playable village mission.

var _player: Node3D
var _square_reached := false
var _mira_spoken_to := false
var _garden_visited := false
var _objective_label: Label
var _status_label: Label


func _ready() -> void:
	_build_hud()
	_refresh_hud()


func setup(player: Node3D, mira: Node) -> void:
	_player = player
	if mira != null and mira.has_signal("dialogue_spoken"):
		var callback := Callable(self, "_on_mira_dialogue_spoken")
		if not mira.is_connected("dialogue_spoken", callback):
			mira.connect("dialogue_spoken", callback)


func _process(_delta: float) -> void:
	if _player == null:
		return

	if not _square_reached and _player.global_position.distance_to(Vector3(0.0, 0.0, 0.0)) <= 7.0:
		_square_reached = true
		_refresh_hud()

	if _mira_spoken_to and not _garden_visited:
		if _player.global_position.distance_to(Vector3(0.0, 0.0, 27.0)) <= 8.0:
			_garden_visited = true
			_refresh_hud()


func _on_mira_dialogue_spoken() -> void:
	if not _mira_spoken_to:
		_mira_spoken_to = true
		_refresh_hud()


func _build_hud() -> void:
	var panel := PanelContainer.new()
	panel.name = "MissionPanel"
	panel.anchor_left = 0.02
	panel.anchor_top = 0.13
	panel.anchor_right = 0.55
	panel.anchor_bottom = 0.34
	add_child(panel)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 5)
	panel.add_child(content)

	var title := Label.new()
	title.text = "المهمة الأولى: صباح جديد"
	title.text_direction = Control.TEXT_DIRECTION_RTL
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	title.add_theme_font_size_override("font_size", 18)
	content.add_child(title)

	_objective_label = Label.new()
	_objective_label.text_direction = Control.TEXT_DIRECTION_RTL
	_objective_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_objective_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_objective_label.add_theme_font_size_override("font_size", 15)
	content.add_child(_objective_label)

	_status_label = Label.new()
	_status_label.text_direction = Control.TEXT_DIRECTION_RTL
	_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_status_label.add_theme_font_size_override("font_size", 13)
	content.add_child(_status_label)


func _refresh_hud() -> void:
	if _objective_label == null or _status_label == null:
		return

	if not _square_reached:
		_objective_label.text = "١. توجّه إلى ساحة القرية"
		_status_label.text = "المهمة قيد التنفيذ"
	elif not _mira_spoken_to:
		_objective_label.text = "٢. تحدّث مع ميرا"
		_status_label.text = "أحسنت! وصلت إلى الساحة."
	elif not _garden_visited:
		_objective_label.text = "٣. زر الحديقة المجتمعية"
		_status_label.text = "ميرا تنتظرك في الحديقة."
	else:
		_objective_label.text = "اكتملت المهمة الأولى!"
		_status_label.text = "مكافأة تجريبية: ٢٥ قطعة نقدية"
