extends CanvasLayer

## Runtime tracker for the first playable village mission.
## Mission copy is loaded from JSON; progress is persisted locally on the device.

const MISSION_DATA_PATH := "res://data/missions/mission_001.json"
const SAVE_PATH := "user://gta_ghibli_save.json"
const SAVE_VERSION := 1

var _player: Node3D
var _square_reached := false
var _mira_spoken_to := false
var _garden_visited := false
var _mission_data: Dictionary = {}
var _objectives: Array = []
var _objective_label: Label
var _status_label: Label
var _mission_title_label: Label


func _ready() -> void:
	_load_mission_data()
	_load_progress()
	_build_hud()
	_refresh_hud()


func setup(player: Node3D, mira: Node) -> void:
	_player = player
	if mira != null and mira.has_signal("dialogue_spoken"):
		var callback := Callable(self, "_on_mira_dialogue_spoken")
		if not mira.is_connected("dialogue_spoken", callback):
			mira.connect("dialogue_spoken", callback)


func _load_mission_data() -> void:
	if not FileAccess.file_exists(MISSION_DATA_PATH):
		push_warning("Mission data is missing: " + MISSION_DATA_PATH)
		return

	var file := FileAccess.open(MISSION_DATA_PATH, FileAccess.READ)
	if file == null:
		push_warning("Could not open mission data: " + MISSION_DATA_PATH)
		return

	var parsed = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		push_warning("Mission data must contain a JSON object.")
		return

	var objectives_value = parsed.get("objectives", [])
	if not objectives_value is Array:
		push_warning("Mission objectives must be a JSON array.")
		return

	_mission_data = parsed
	_objectives = objectives_value


func _load_progress() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_warning("Could not read local save file.")
		return

	var parsed = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		push_warning("Save file is invalid; starting this mission from the beginning.")
		return

	if int(parsed.get("save_version", 0)) != SAVE_VERSION:
		push_warning("Save version is not supported; starting this mission from the beginning.")
		return
	if str(parsed.get("mission_id", "")) != str(_mission_data.get("mission_id", "")):
		return

	_square_reached = bool(parsed.get("square_reached", false))
	_mira_spoken_to = bool(parsed.get("mira_spoken_to", false))
	_garden_visited = bool(parsed.get("garden_visited", false))


func _save_progress() -> bool:
	var save_data := {
		"save_version": SAVE_VERSION,
		"mission_id": str(_mission_data.get("mission_id", "meet_the_village")),
		"square_reached": _square_reached,
		"mira_spoken_to": _mira_spoken_to,
		"garden_visited": _garden_visited
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("Could not write local save file.")
		return false
	file.store_string(JSON.stringify(save_data, "\t"))
	return file.get_error() == OK


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_PREDELETE:
		_save_progress()


func _objective_description(index: int, fallback: String) -> String:
	if index >= 0 and index < _objectives.size():
		var objective = _objectives[index]
		if objective is Dictionary:
			return str(objective.get("description", fallback))
	return fallback


func _process(_delta: float) -> void:
	if _player == null:
		return

	if not _square_reached and _player.global_position.distance_to(Vector3(0.0, 0.0, 0.0)) <= 7.0:
		_square_reached = true
		_save_progress()
		_refresh_hud()

	if _mira_spoken_to and not _garden_visited:
		if _player.global_position.distance_to(Vector3(0.0, 0.0, 27.0)) <= 8.0:
			_garden_visited = true
			_save_progress()
			_refresh_hud()


func _on_mira_dialogue_spoken() -> void:
	if not _mira_spoken_to:
		_mira_spoken_to = true
		_save_progress()
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

	_mission_title_label = Label.new()
	_mission_title_label.text = str(_mission_data.get("title", "المهمة الأولى: صباح جديد"))
	_mission_title_label.text_direction = Control.TEXT_DIRECTION_RTL
	_mission_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_mission_title_label.add_theme_font_size_override("font_size", 18)
	content.add_child(_mission_title_label)

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
		_objective_label.text = "١. " + _objective_description(0, "توجّه إلى ساحة القرية")
		_status_label.text = "المهمة قيد التنفيذ"
	elif not _mira_spoken_to:
		_objective_label.text = "٢. " + _objective_description(1, "تحدّث مع ميرا")
		_status_label.text = "أحسنت! وصلت إلى الساحة."
	elif not _garden_visited:
		_objective_label.text = "٣. " + _objective_description(2, "زُر الحديقة المجتمعية")
		_status_label.text = "ميرا تنتظرك في الحديقة."
	else:
		_objective_label.text = "اكتملت المهمة الأولى!"
		var rewards: Dictionary = _mission_data.get("rewards", {})
		var currency := int(rewards.get("currency", 25))
		_status_label.text = "مكافأة تجريبية: %d قطعة نقدية" % currency
