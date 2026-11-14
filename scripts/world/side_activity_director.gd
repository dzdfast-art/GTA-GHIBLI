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
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		var ids = parsed.get("completed_ids", [])
		if ids is Array:
			for item in ids:
				var activity_id := str(item)
				if not _completed_ids.has(activity_id):
					_completed_ids.append(activity_id)
		_total_rewards = int(parsed.get("total_rewards", 0))


func _save_progress() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("Could not save side activity progress.")
		return
	file.store_string(JSON.stringify({
		"completed_ids": _completed_ids,
		"total_rewards": _total_rewards
	}, "\t"))


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
	_active_id = activity_id
	_targets_found = 0
	_target_nodes.clear()
	var activity := _activity_by_id(activity_id)
	var target_positions: Array = activity.get("targets", [])
	for index in range(target_positions.size()):
		var marker := _make_marker("SideTarget_%s_%d" % [activity_id, index + 1], _position(target_positions[index]), activity.get("color", Color(0.90, 0.70, 0.22)))
		_target_nodes.append(marker)
	_status_override = str(activity.get("target_text", "أكمل النشاط الجانبي."))
	_accept_button.visible = false
	_refresh_hud()


func _update_active_activity() -> void:
	var activity := _activity_by_id(_active_id)
	if activity.is_empty():
		_active_id = ""
		return
	if _targets_found < _target_nodes.size():
		for marker in _target_nodes:
			if not is_instance_valid(marker) or not marker.visible:
				continue
			if _player.global_position.distance_to(marker.global_position) <= TARGET_RADIUS:
				marker.visible = false
				_targets_found += 1
				_status_override = "أنجزت %d من %d من أهداف النشاط." % [_targets_found, _target_nodes.size()]
		if _targets_found >= _target_nodes.size():
			_status_override = "أحسنت! عد إلى نقطة البداية لتسليم المهمة."
	else:
		var return_position := _position(activity.get("return", [0, 0, 0]))
		if _player.global_position.distance_to(return_position) <= RETURN_RADIUS:
			_complete_activity(activity)


func _complete_activity(activity: Dictionary) -> void:
	var reward := int(activity.get("reward", 0))
	_total_rewards += reward
	if _player != null and is_instance_valid(_player):
		var wallet := _player.get_node_or_null("PlayerWallet")
		if wallet != null and wallet.has_method("add_money"):
			wallet.call("add_money", reward)
	_completed_ids.append(_active_id)
	var activity_id := _active_id
	_active_id = ""
	_targets_found = 0
	for marker in _target_nodes:
		if is_instance_valid(marker):
			marker.queue_free()
	_target_nodes.clear()
	if _start_nodes.has(activity_id) and is_instance_valid(_start_nodes[activity_id]):
		_start_nodes[activity_id].queue_free()
	_start_nodes.erase(activity_id)
	_save_progress()
	_status_override = "اكتمل النشاط الجانبي! حصلت على %d قطعة نقدية." % reward
	_title_label.text = "أنشطة العالم"
	_refresh_hud()


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
