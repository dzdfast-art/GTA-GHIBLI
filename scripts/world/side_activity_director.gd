extends CanvasLayer

## Four varied, optional side activities with local progress saves.
## All characters and props are lightweight blockout placeholders.

const SAVE_PATH := "user://gta_ghibli_side_activities.json"
const START_RADIUS := 4.0
const TARGET_RADIUS := 2.6
const RETURN_RADIUS := 4.0

const ACTIVITY_DATA := [
	{
		"id": "lost_delivery",
		"title": "الطرد المفقود",
		"start": [-14.0, 0.0, -12.0],
		"targets": [[12.0, 0.0, -24.0]],
		"return": [-14.0, 0.0, -12.0],
		"target_text": "اعثر على الطرد وأعده إلى صاحب المتجر.",
		"reward": 80,
		"color": Color(0.82, 0.62, 0.30)
	},
	{
		"id": "farmer_crates",
		"title": "مساعدة المزارع",
		"start": [-35.0, 0.0, -20.0],
		"targets": [[-30.0, 0.0, -28.0], [-24.0, 0.0, -31.0], [-19.0, 0.0, -34.0]],
		"return": [-35.0, 0.0, -20.0],
		"target_text": "اجمع الصناديق الثلاثة وأعدها إلى المزارع.",
		"reward": 120,
		"color": Color(0.52, 0.72, 0.38)
	},
	{
		"id": "roadside_repair",
		"title": "مساعدة سائق عالق",
		"start": [30.0, 0.0, -12.0],
		"targets": [[34.0, 0.0, -26.0]],
		"return": [30.0, 0.0, -12.0],
		"target_text": "أحضر حقيبة الإصلاح إلى السائق العالق.",
		"reward": 100,
		"color": Color(0.34, 0.66, 0.82)
	},
	{
		"id": "missing_dog",
		"title": "الكلب الضائع",
		"start": [-42.0, 0.0, -40.0],
		"targets": [[-20.0, 0.0, -48.0]],
		"return": [-42.0, 0.0, -40.0],
		"target_text": "ابحث عن الكلب وأعده إلى صاحبه.",
		"reward": 140,
		"color": Color(0.78, 0.54, 0.38)
	}
]

var _player: CharacterBody3D
var _world_root: Node3D
var _completed_ids: Array[String] = []
var _active_id := ""
var _target_nodes: Array[Node3D] = []
var _targets_found := 0
var _start_nodes: Dictionary = {}
var _visuals_created := false
var _total_rewards := 0
var _panel: PanelContainer
var _title_label: Label
var _objective_label: Label
var _status_label: Label
var _accept_button: Button
var _status_override := ""
var save_path_override := ""
var _progress_updated_at_unix := 0
var _saved_target_visibility: Array = []


func _ready() -> void:
	_world_root = get_tree().current_scene as Node3D
	_load_progress()
	_build_hud()
	_ensure_world_content()
	_refresh_hud()


func setup(player: CharacterBody3D) -> void:
	_player = player
	_ensure_world_content()


func _physics_process(_delta: float) -> void:
	if _world_root == null or not is_instance_valid(_world_root):
		_world_root = get_tree().current_scene as Node3D
		_ensure_world_content()
	if _player == null or not _visuals_created:
		return

	if _active_id.is_empty():
		var candidate := _nearest_available_activity()
		if candidate.is_empty():
			_accept_button.visible = false
			_objective_label.text = "لا توجد أنشطة قريبة حالياً."
			return
		var activity := _activity_by_id(candidate)
		var distance := _player.global_position.distance_to(_position(activity.get("start", [0, 0, 0])))
		_accept_button.visible = distance <= START_RADIUS
		if distance <= START_RADIUS:
			_title_label.text = str(activity.get("title", "نشاط جانبي"))
			_objective_label.text = "اقتربت من نشاط جانبي. اضغط لقبوله."
		else:
			_accept_button.visible = false
			_objective_label.text = "أنشطة جانبية متاحة حول العالم."
	else:
		_update_active_activity()
	_refresh_hud()


func _load_progress() -> void:
	_completed_ids.clear()
	_active_id = ""
	_targets_found = 0
	_total_rewards = 0
	_status_override = ""
	_progress_updated_at_unix = 0
	_saved_target_visibility.clear()
	var path := _active_save_path()
	if not FileAccess.file_exists(path):
		return
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	if not parsed is Dictionary:
		return
	var ids = parsed.get("completed_ids", [])
	if ids is Array:
		for item in ids:
			var activity_id := str(item)
			if not _activity_by_id(activity_id).is_empty() and not _completed_ids.has(activity_id):
				_completed_ids.append(activity_id)
	_total_rewards = maxi(0, int(parsed.get("total_rewards", 0)))
	_progress_updated_at_unix = maxi(0, int(parsed.get("updated_at_unix", 0)))
	var saved_active_id := str(parsed.get("active_id", ""))
	var activity := _activity_by_id(saved_active_id)
	if not activity.is_empty() and not _completed_ids.has(saved_active_id):
		_active_id = saved_active_id
		var target_positions: Array = activity.get("targets", [])
		_targets_found = clampi(int(parsed.get("targets_found", 0)), 0, target_positions.size())
		var visibility = parsed.get("target_visibility", [])
		if visibility is Array:
			_saved_target_visibility = visibility.duplicate()
		_status_override = str(parsed.get("status_override", ""))


func _save_progress() -> void:
	_progress_updated_at_unix = maxi(int(Time.get_unix_time_from_system()), _progress_updated_at_unix + 1)
	var file := FileAccess.open(_active_save_path(), FileAccess.WRITE)
	if file == null:
		push_warning("Could not save side activity progress.")
		return
	file.store_string(JSON.stringify({
		"completed_ids": _completed_ids,
		"active_id": _active_id,
		"targets_found": _targets_found,
		"target_visibility": _capture_target_visibility(),
		"total_rewards": _total_rewards,
		"status_override": _status_override,
		"updated_at_unix": _progress_updated_at_unix
	}, "\t"))
	file.flush()
	file.close()


func _ensure_world_content() -> void:
	if _visuals_created or _world_root == null or not is_instance_valid(_world_root):
		return
	_visuals_created = true
	for activity in ACTIVITY_DATA:
		var activity_id := str(activity.get("id", ""))
		if _completed_ids.has(activity_id):
			continue
		var marker := _make_marker("SideActivity_" + activity_id, _position(activity.get("start", [0, 0, 0])), activity.get("color", Color(0.90, 0.70, 0.22)))
		_start_nodes[activity_id] = marker
	if not _active_id.is_empty():
		_restore_active_activity_targets()


func _nearest_available_activity() -> String:
	var nearest_id := ""
	var nearest_distance := INF
	for activity in ACTIVITY_DATA:
		var activity_id := str(activity.get("id", ""))
		if _completed_ids.has(activity_id):
			continue
		var distance := _player.global_position.distance_to(_position(activity.get("start", [0, 0, 0])))
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_id = activity_id
	return nearest_id


func _activity_by_id(activity_id: String) -> Dictionary:
	for activity in ACTIVITY_DATA:
		if str(activity.get("id", "")) == activity_id:
			return activity
	return {}


func _position(values: Array) -> Vector3:
	if values.size() < 3:
		return Vector3.ZERO
	return Vector3(float(values[0]), float(values[1]), float(values[2]))


func _on_accept_pressed() -> void:
	if _active_id.is_empty():
		var candidate := _nearest_available_activity()
		if candidate.is_empty():
			return
		var activity := _activity_by_id(candidate)
		if _player.global_position.distance_to(_position(activity.get("start", [0, 0, 0]))) > START_RADIUS:
			return
		_start_activity(candidate)


func _start_activity(activity_id: String) -> void:
	if _activity_by_id(activity_id).is_empty() or _completed_ids.has(activity_id):
		return
	_active_id = activity_id
	_targets_found = 0
	_saved_target_visibility.clear()
	for existing_marker in _target_nodes:
		if is_instance_valid(existing_marker):
			existing_marker.queue_free()
	_target_nodes.clear()
	var activity := _activity_by_id(activity_id)
	var target_positions: Array = activity.get("targets", [])
	for index in range(target_positions.size()):
		var marker := _make_marker("SideTarget_%s_%d" % [activity_id, index + 1], _position(target_positions[index]), activity.get("color", Color(0.90, 0.70, 0.22)))
		_target_nodes.append(marker)
	_status_override = str(activity.get("target_text", "أكمل النشاط الجانبي."))
	_accept_button.visible = false
	_save_progress()
	_save_unified_snapshot()
	_refresh_hud()


func _update_active_activity() -> void:
	var activity := _activity_by_id(_active_id)
	if activity.is_empty():
		_active_id = ""
		return
	if _targets_found < _target_nodes.size():
		var collected_target := false
		for marker in _target_nodes:
			if not is_instance_valid(marker) or not marker.visible:
				continue
			if _player.global_position.distance_to(marker.global_position) <= TARGET_RADIUS:
				marker.visible = false
				_targets_found += 1
				collected_target = true
				_status_override = "أنجزت %d من %d من أهداف النشاط." % [_targets_found, _target_nodes.size()]
		if _targets_found >= _target_nodes.size():
			_status_override = "أحسنت! عد إلى نقطة البداية لتسليم المهمة."
		if collected_target:
			_saved_target_visibility = _capture_target_visibility()
			_save_progress()
			_save_unified_snapshot()
	else:
		var return_position := _position(activity.get("return", [0, 0, 0]))
		if _player.global_position.distance_to(return_position) <= RETURN_RADIUS:
			_complete_activity(activity)


func _complete_activity(activity: Dictionary) -> bool:
	var activity_id := _active_id
	if activity_id.is_empty() or _completed_ids.has(activity_id):
		return false
	var known_activity := _activity_by_id(activity_id)
	if known_activity.is_empty() or str(activity.get("id", "")) != activity_id:
		return false

	var reward := maxi(0, int(known_activity.get("reward", 0)))
	if reward > 0:
		if _player == null or not is_instance_valid(_player):
			return false
		var wallet := _player.get_node_or_null("PlayerWallet")
		if wallet == null or not wallet.has_method("add_money_once"):
			push_warning("Side activity reward was not committed because the wallet has no transaction API.")
			return false
		var transaction_id := "side_activity_%s_completion" % activity_id
		var credited := bool(wallet.call("add_money_once", transaction_id, reward))
		if not credited:
			if not wallet.has_method("has_reward_transaction") or not bool(wallet.call("has_reward_transaction", transaction_id)):
				push_warning("Side activity reward transaction could not be confirmed.")
				return false
		else:
			# Persist the wallet transaction before marking the activity complete.
			# If the app closes here, the resumed activity recognizes the paid ID.
			_save_unified_snapshot()

	_total_rewards += reward
	_completed_ids.append(activity_id)
	_active_id = ""
	_targets_found = 0
	_saved_target_visibility.clear()
	for marker in _target_nodes:
		if is_instance_valid(marker):
			marker.queue_free()
	_target_nodes.clear()
	if _start_nodes.has(activity_id) and is_instance_valid(_start_nodes[activity_id]):
		_start_nodes[activity_id].queue_free()
	_start_nodes.erase(activity_id)
	_save_progress()
	_save_unified_snapshot()
	_status_override = "اكتمل النشاط الجانبي! حصلت على %d قطعة نقدية." % reward
	_title_label.text = "أنشطة العالم"
	_refresh_hud()
	return true


func _make_marker(node_name: String, at: Vector3, tint: Color) -> Node3D:
	var marker := Node3D.new()
	marker.name = node_name
	marker.position = at
	_world_root.add_child(marker)
	var mesh_instance := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = 0.58
	mesh.height = 1.16
	mesh_instance.mesh = mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = tint
	material.emission_enabled = true
	material.emission = tint * 0.28
	mesh_instance.material_override = material
	marker.add_child(mesh_instance)
	return marker


func _build_hud() -> void:
	_panel = PanelContainer.new()
	_panel.name = "SideActivityPanel"
	_panel.anchor_left = 0.62
	_panel.anchor_top = 0.72
	_panel.anchor_right = 0.98
	_panel.anchor_bottom = 0.98
	add_child(_panel)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 3)
	_panel.add_child(content)
	_title_label = Label.new()
	_title_label.text = "أنشطة العالم"
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_title_label.text_direction = Control.TEXT_DIRECTION_RTL
	content.add_child(_title_label)
	_objective_label = Label.new()
	_objective_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_objective_label.text_direction = Control.TEXT_DIRECTION_RTL
	_objective_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(_objective_label)
	_status_label = Label.new()
	_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_status_label.text_direction = Control.TEXT_DIRECTION_RTL
	_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(_status_label)
	_accept_button = Button.new()
	_accept_button.text = "قبول النشاط"
	_accept_button.visible = false
	_accept_button.pressed.connect(_on_accept_pressed)
	content.add_child(_accept_button)


func _refresh_hud() -> void:
	if _objective_label == null:
		return
	if not _active_id.is_empty():
		var activity := _activity_by_id(_active_id)
		_title_label.text = str(activity.get("title", "نشاط جانبي"))
		_objective_label.text = str(activity.get("target_text", "أكمل النشاط."))
	_status_label.text = "%s\nالأنشطة المكتملة: %d/4 | المكافآت: %d" % [
		_status_override,
		_completed_ids.size(),
		_total_rewards
	]

func get_save_snapshot() -> Dictionary:
	return {
		"completed_ids": _completed_ids.duplicate(),
		"active_id": _active_id,
		"targets_found": _targets_found,
		"target_visibility": _capture_target_visibility(),
		"total_rewards": _total_rewards,
		"status_override": _status_override,
		"updated_at_unix": _progress_updated_at_unix
	}


func apply_save_snapshot(snapshot: Dictionary) -> bool:
	var completed = snapshot.get("completed_ids", [])
	if not completed is Array:
		return false
	var snapshot_updated_at := maxi(0, int(snapshot.get("updated_at_unix", 0)))
	if _progress_updated_at_unix > snapshot_updated_at:
		_restore_active_activity_targets()
		_refresh_hud()
		return true

	_completed_ids.clear()
	for value in completed:
		var activity_id := str(value)
		if not _activity_by_id(activity_id).is_empty() and not _completed_ids.has(activity_id):
			_completed_ids.append(activity_id)
	_active_id = str(snapshot.get("active_id", ""))
	if _activity_by_id(_active_id).is_empty() or _completed_ids.has(_active_id):
		_active_id = ""
	var active_activity := _activity_by_id(_active_id)
	var active_targets: Array = active_activity.get("targets", [])
	_targets_found = clampi(int(snapshot.get("targets_found", 0)), 0, active_targets.size())
	var visibility = snapshot.get("target_visibility", [])
	_saved_target_visibility = visibility.duplicate() if visibility is Array else []
	_total_rewards = maxi(0, int(snapshot.get("total_rewards", 0)))
	_status_override = str(snapshot.get("status_override", ""))
	_progress_updated_at_unix = snapshot_updated_at
	for activity_id in _start_nodes.keys():
		var marker = _start_nodes[activity_id]
		if is_instance_valid(marker):
			marker.visible = not _completed_ids.has(str(activity_id))
	_restore_active_activity_targets()
	_save_progress()
	_refresh_hud()
	return true


func reload_saved_state() -> void:
	_load_progress()
	_restore_active_activity_targets()
	_refresh_hud()


func _restore_active_activity_targets() -> void:
	for marker in _target_nodes:
		if is_instance_valid(marker):
			marker.queue_free()
	_target_nodes.clear()
	if _active_id.is_empty() or _world_root == null or not is_instance_valid(_world_root):
		return
	var activity := _activity_by_id(_active_id)
	if activity.is_empty() or _completed_ids.has(_active_id):
		_active_id = ""
		_targets_found = 0
		_saved_target_visibility.clear()
		return
	var target_positions: Array = activity.get("targets", [])
	if target_positions.is_empty():
		_active_id = ""
		_targets_found = 0
		return
	var tint: Color = activity.get("color", Color(0.90, 0.70, 0.22))
	var restored_found := 0
	for index in range(target_positions.size()):
		var marker := _make_marker("SideTarget_%s_%d" % [_active_id, index + 1], _position(target_positions[index]), tint)
		var marker_visible := index >= _targets_found
		if index < _saved_target_visibility.size():
			marker_visible = bool(_saved_target_visibility[index])
		marker.visible = marker_visible
		if not marker_visible:
			restored_found += 1
		_target_nodes.append(marker)
	_targets_found = restored_found
	if _targets_found >= _target_nodes.size():
		_status_override = "أحسنت! عد إلى نقطة البداية لتسليم المهمة."
	_refresh_hud()


func _capture_target_visibility() -> Array:
	if _target_nodes.is_empty():
		return _saved_target_visibility.duplicate()
	var result: Array = []
	for marker in _target_nodes:
		result.append(is_instance_valid(marker) and marker.visible)
	return result


func _save_unified_snapshot() -> void:
	var manager := get_tree().get_first_node_in_group("game_save_manager")
	if manager != null and manager.has_method("save_game"):
		if not bool(manager.call("save_game")):
			push_warning("Side activity progress changed, but the unified save could not be written.")


func _active_save_path() -> String:
	var override_path := save_path_override.strip_edges()
	return override_path if not override_path.is_empty() else SAVE_PATH
