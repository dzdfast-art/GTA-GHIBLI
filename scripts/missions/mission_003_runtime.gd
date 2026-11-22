extends CanvasLayer

## Lightweight playable stealth/investigation blockout for mission 003.
const MISSION_DATA_PATH := "res://data/missions/mission_003.json"
const MISSION_002_SAVE := "user://gta_ghibli_mission_002.json"
const COMPLETION_SAVE := "user://gta_ghibli_mission_003.json"

enum Phase { LOCKED, MEET_CONTACT, ENTER_HARBOR, COLLECT_EVIDENCE, RETURN_EVIDENCE, COMPLETE, FAILED }

const CONTACT_POSITION := Vector3(20.0, 0.0, -18.0)
const HARBOR_GATE_POSITION := Vector3(22.0, 0.0, -29.0)
const EVIDENCE_POSITIONS := [
	Vector3(27.0, 0.0, -34.0),
	Vector3(41.0, 0.0, -45.0),
	Vector3(27.0, 0.0, -55.0)
]
const DETECTION_RADIUS := 3.2
const MAX_DETECTIONS := 3

var _player: CharacterBody3D
var _mission_data: Dictionary = {}
var _world_root: Node3D
var _phase: Phase = Phase.LOCKED
var _evidence_found := 0
var _detections := 0
var _elapsed := 0.0
var _guards: Array[Node3D] = []
var _guard_alert_state: Dictionary = {}
var _evidence_markers: Array[Node3D] = []
var _panel: PanelContainer
var _objective_label: Label
var _status_label: Label
var _progress_label: Label
var _retry_button: Button
var _visuals_created := false
var _status_override := ""


func _ready() -> void:
	_load_mission_data()
	_world_root = get_tree().current_scene as Node3D
	_build_hud()
	if _is_completed():
		_phase = Phase.COMPLETE
	elif _mission_002_completed():
		_start_mission()
	else:
		_phase = Phase.LOCKED
	_refresh_hud()


func setup(player: CharacterBody3D) -> void:
	_player = player
	if _phase == Phase.COMPLETE:
		_award_completion_reward()


func _physics_process(delta: float) -> void:
	if _phase == Phase.LOCKED:
		if _mission_002_completed():
			_start_mission()
		else:
			return
	if _player == null:
		return

	_elapsed += delta
	if _phase == Phase.MEET_CONTACT:
		if _player.global_position.distance_to(CONTACT_POSITION) <= 5.0:
			_set_phase(Phase.ENTER_HARBOR, "نورا أعطتك وصف الشحنة. توجه إلى بوابة الميناء.")
	elif _phase == Phase.ENTER_HARBOR:
		if _player.global_position.distance_to(HARBOR_GATE_POSITION) <= 5.0:
			_set_phase(Phase.COLLECT_EVIDENCE, "اجمع الأدلة الثلاثة وابق بعيداً عن الحراس.")
	elif _phase == Phase.COLLECT_EVIDENCE:
		_update_guards(delta)
		_check_evidence_pickups()
		if _detections >= MAX_DETECTIONS:
			_fail_mission("كشف الحراس أمرك ثلاث مرات. انسحب وحاول مجدداً.")
		elif _evidence_found >= EVIDENCE_POSITIONS.size():
			_set_phase(Phase.RETURN_EVIDENCE, "جمعت الأدلة! عد إلى نورا دون أن يمسك بك الحراس.")
	elif _phase == Phase.RETURN_EVIDENCE:
		_update_guards(delta)
		if _detections >= MAX_DETECTIONS:
			_fail_mission("كشف الحراس أمرك ثلاث مرات أثناء الانسحاب. حاول مجدداً.")
		elif _player.global_position.distance_to(CONTACT_POSITION) <= 5.0:
			_complete_mission()
	_refresh_hud()


func _mission_002_completed() -> bool:
	if not FileAccess.file_exists(MISSION_002_SAVE):
		return false
	var file := FileAccess.open(MISSION_002_SAVE, FileAccess.READ)
	if file == null:
		return false
	var data = JSON.parse_string(file.get_as_text())
	return data is Dictionary and str(data.get("mission_id", "")) == "the_old_road_rescue" and bool(data.get("completed", false))


func _load_mission_data() -> void:
	if not FileAccess.file_exists(MISSION_DATA_PATH):
		push_warning("Mission 003 data is missing.")
		return
	var file := FileAccess.open(MISSION_DATA_PATH, FileAccess.READ)
	if file == null:
		push_warning("Could not open Mission 003 data.")
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		_mission_data = parsed


func _is_completed() -> bool:
	if not FileAccess.file_exists(COMPLETION_SAVE):
		return false
	var file := FileAccess.open(COMPLETION_SAVE, FileAccess.READ)
	if file == null:
		return false
	var data = JSON.parse_string(file.get_as_text())
	return data is Dictionary and str(data.get("mission_id", "")) == "shadows_over_the_harbor" and bool(data.get("completed", false))


func _start_mission() -> void:
	_phase = Phase.MEET_CONTACT
	_evidence_found = 0
	_detections = 0
	_guard_alert_state.clear()
	_elapsed = 0.0
	_status_override = "مهمة جديدة: قابل نورا قرب الميناء."
	_create_harbor_blockout()
	_refresh_hud()


func _set_phase(next_phase: Phase, status: String) -> void:
	_phase = next_phase
	_status_override = status
	_refresh_hud()


func _update_guards(delta: float) -> void:
	for index in range(_guards.size()):
		var guard := _guards[index]
		if not is_instance_valid(guard):
			continue
		var origin: Vector3 = EVIDENCE_POSITIONS[index % EVIDENCE_POSITIONS.size()] + Vector3(0.0, 0.0, 4.0)
		var patrol_offset := sin(_elapsed * (0.65 + float(index) * 0.12)) * 3.0
		guard.global_position = origin + Vector3(patrol_offset, 0.0, 0.0)
		var guard_id := guard.get_instance_id()
		var distance := _player.global_position.distance_to(guard.global_position)
		var can_see_player := _guard_can_see_player(guard, distance)
		if can_see_player and not bool(_guard_alert_state.get(guard_id, false)):
			_guard_alert_state[guard_id] = true
			_detections += 1
			_status_override = "انتبه! رآك الحارس داخل مجال نظره. احتمِ خلف الحاويات وغيّر مسارك."
			if _detections >= MAX_DETECTIONS:
				return
		elif distance > DETECTION_RADIUS + 1.5:
			_guard_alert_state[guard_id] = false


func _guard_can_see_player(guard: Node3D, distance: float) -> bool:
	if distance > DETECTION_RADIUS:
		return false
	var to_player := _player.global_position - guard.global_position
	to_player.y = 0.0
	if to_player.length_squared() < 0.01:
		return true
	var guard_forward := -guard.global_basis.z
	guard_forward.y = 0.0
	if guard_forward.length_squared() < 0.01:
		guard_forward = Vector3.FORWARD
	var half_fov_cos := cos(deg_to_rad(50.0))
	if guard_forward.normalized().dot(to_player.normalized()) < half_fov_cos:
		return false
	if _world_root == null or not is_instance_valid(_world_root):
		return true
	if not Engine.is_in_physics_frame():
		return true
	var space_state := _world_root.get_world_3d().direct_space_state
	var ray_start := guard.global_position + Vector3.UP * 1.35
	var ray_end := _player.global_position + Vector3.UP * 0.9
	var query := PhysicsRayQueryParameters3D.create(ray_start, ray_end)
	query.collision_mask = 1
	var hit := space_state.intersect_ray(query)
	if not hit.is_empty() and hit.get("collider") != _player:
		return false
	return true


func _check_evidence_pickups() -> void:
	for marker in _evidence_markers:
		if not is_instance_valid(marker) or not marker.visible:
			continue
		if _player.global_position.distance_to(marker.global_position) <= 2.5:
			marker.visible = false
			_evidence_found += 1
			_status_override = "حصلت على دليل %d من 3." % _evidence_found


func _complete_mission() -> void:
	_phase = Phase.COMPLETE
	var file := FileAccess.open(COMPLETION_SAVE, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify({
			"mission_id": "shadows_over_the_harbor",
			"completed": true,
			"evidence_found": _evidence_found,
			"detections": _detections,
			"reward_currency": 220
		}, "\t"))
		file.flush()
		var write_error := file.get_error()
		file.close()
		if write_error != OK:
			push_warning("Mission 003 completion could not be flushed to storage.")
	else:
		push_warning("Could not open Mission 003 completion save.")
	_award_completion_reward()
	_status_override = "أحسنت! وصلت الأدلة إلى نورا. انفتح مسار التحقيق في الميناء."
	for guard in _guards:
		if is_instance_valid(guard):
			guard.visible = false
	if _retry_button != null:
		_retry_button.visible = false
	_refresh_hud()



func _get_mission_reward_currency() -> int:
	const MISSION_PATH := "res://data/missions/mission_003.json"
	if not FileAccess.file_exists(MISSION_PATH):
		return 220
	var file := FileAccess.open(MISSION_PATH, FileAccess.READ)
	if file == null:
		return 220
	var parsed = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		return 220
	var rewards: Dictionary = parsed.get("rewards", {})
	return maxi(0, int(rewards.get("currency", 220)))


func get_hud_snapshot() -> Dictionary:
	var is_complete := _phase == Phase.COMPLETE
	var is_active := _phase != Phase.LOCKED and not is_complete
	var status_text := _status_label.text if _status_label != null else _status_override
	var objective_text := _objective_label.text if _objective_label != null else status_text
	return {
		"active": is_active,
		"priority": 2,
		"title": str(_mission_data.get("title", "المهمة")),
		"objective": objective_text,
		"status": status_text,
		"completed": is_complete
}


func _award_completion_reward() -> void:
	if _player == null:
		return
	var wallet := _player.get_node_or_null("PlayerWallet")
	if wallet == null or not wallet.has_method("add_money_once"):
		return
	wallet.call("add_money_once", "mission_003_completion", _get_mission_reward_currency())

func _fail_mission(reason: String) -> void:
	_phase = Phase.FAILED
	_status_override = reason
	if _retry_button != null:
		_retry_button.visible = true
	_refresh_hud()


func _on_retry_pressed() -> void:
	for marker in _evidence_markers:
		if is_instance_valid(marker):
			marker.visible = true
	for guard in _guards:
		if is_instance_valid(guard):
			guard.visible = true
	_evidence_found = 0
	_detections = 0
	_guard_alert_state.clear()
	_elapsed = 0.0
	_phase = Phase.MEET_CONTACT
	_status_override = "حاول مجدداً: قابل نورا قرب الميناء."
	_refresh_hud()


func _create_harbor_blockout() -> void:
	if _visuals_created or _world_root == null:
		return
	_visuals_created = true
	_add_box("HarborAccessRoad", Vector3(25.0, 0.04, -38.0), Vector3(12.0, 0.08, 32.0), Color(0.22, 0.25, 0.27))
	_add_box("HarborContainerA", Vector3(31.0, 1.5, -39.0), Vector3(5.0, 3.0, 8.0), Color(0.55, 0.20, 0.14))
	_add_box("HarborContainerB", Vector3(37.0, 1.5, -49.0), Vector3(5.0, 3.0, 8.0), Color(0.15, 0.32, 0.40))
	_add_box("HarborContainerC", Vector3(22.0, 1.5, -53.0), Vector3(5.0, 3.0, 8.0), Color(0.48, 0.43, 0.20))
	for index in range(EVIDENCE_POSITIONS.size()):
		var evidence := _make_marker("Evidence_%d" % (index + 1), EVIDENCE_POSITIONS[index] + Vector3.UP * 0.8, Color(0.95, 0.78, 0.22))
		_evidence_markers.append(evidence)
		var guard := _make_guard("HarborGuard_%d" % (index + 1), EVIDENCE_POSITIONS[index] + Vector3(0.0, 0.0, 7.5))
		_guards.append(guard)
	_make_marker("NoraContactMarker", CONTACT_POSITION + Vector3.UP * 0.15, Color(0.25, 0.85, 0.75))
	_make_marker("HarborGateMarker", HARBOR_GATE_POSITION + Vector3.UP * 0.15, Color(0.95, 0.55, 0.18))


func _make_marker(node_name: String, at: Vector3, tint: Color) -> Node3D:
	var marker := Node3D.new()
	marker.name = node_name
	marker.position = at
	_world_root.add_child(marker)
	var mesh_instance := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = 0.55
	mesh.height = 1.1
	mesh_instance.mesh = mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = tint
	material.emission_enabled = true
	material.emission = tint * 0.35
	mesh_instance.material_override = material
	marker.add_child(mesh_instance)
	return marker


func _make_guard(node_name: String, at: Vector3) -> Node3D:
	var guard := Node3D.new()
	guard.name = node_name
	guard.position = at
	_world_root.add_child(guard)
	var body := MeshInstance3D.new()
	var mesh := CapsuleMesh.new()
	mesh.radius = 0.38
	mesh.height = 1.8
	body.mesh = mesh
	body.position.y = 0.9
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.16, 0.20, 0.24)
	body.material_override = material
	guard.add_child(body)
	return guard


func _add_box(node_name: String, at: Vector3, size: Vector3, tint: Color) -> void:
	var body := StaticBody3D.new()
	body.name = node_name
	body.position = at
	var mesh_instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh_instance.mesh = mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = tint
	material.roughness = 0.92
	mesh_instance.material_override = material
	body.add_child(mesh_instance)
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	body.add_child(collision)
	_world_root.add_child(body)


func _build_hud() -> void:
	_panel = PanelContainer.new()
	_panel.name = "Mission003Panel"
	_panel.anchor_left = 0.02
	_panel.anchor_top = 0.60
	_panel.anchor_right = 0.58
	_panel.anchor_bottom = 0.82
	add_child(_panel)
	add_to_group("mission_hud_sources")
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 4)
	_panel.add_child(content)
	var title := Label.new()
	title.text = "ظلال فوق الميناء"
	title.text_direction = Control.TEXT_DIRECTION_RTL
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	title.add_theme_font_size_override("font_size", 17)
	content.add_child(title)
	_objective_label = Label.new()
	_objective_label.text_direction = Control.TEXT_DIRECTION_RTL
	_objective_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_objective_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(_objective_label)
	_status_label = Label.new()
	_status_label.text_direction = Control.TEXT_DIRECTION_RTL
	_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(_status_label)
	_progress_label = Label.new()
	_progress_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	content.add_child(_progress_label)
	_retry_button = Button.new()
	_retry_button.text = "إعادة المحاولة"
	_retry_button.visible = false
	_retry_button.pressed.connect(_on_retry_pressed)
	content.add_child(_retry_button)


func _refresh_hud() -> void:
	if _objective_label == null:
		return
	match _phase:
		Phase.LOCKED:
			_objective_label.text = "أكمل مهمة الإنقاذ الثانية لفتح هذه المهمة."
		Phase.MEET_CONTACT:
			_objective_label.text = "١. قابل نورا قرب الميناء."
		Phase.ENTER_HARBOR:
			_objective_label.text = "٢. توجه إلى بوابة الميناء."
		Phase.COLLECT_EVIDENCE:
			_objective_label.text = "٣. اجمع ثلاث قطع دليل وتجنب الحراس."
		Phase.RETURN_EVIDENCE:
			_objective_label.text = "٤. عد إلى نورا وسلّم الأدلة."
		Phase.COMPLETE:
			_objective_label.text = "اكتملت المهمة الثالثة! مكافأتك 220 قطعة نقدية."
		Phase.FAILED:
			_objective_label.text = "فشلت المهمة. يمكنك إعادة المحاولة."
	_status_label.text = _status_override
	_progress_label.text = "الأدلة: %d/3   |   مرات الانكشاف: %d/%d" % [_evidence_found, _detections, MAX_DETECTIONS]

func get_save_snapshot() -> Dictionary:
	var guard_positions: Array = []
	var evidence_visibility: Array = []
	for guard in _guards:
		guard_positions.append(_node_position_snapshot(guard))
	for marker in _evidence_markers:
		evidence_visibility.append(marker.visible if is_instance_valid(marker) else false)
	return {
		"phase": int(_phase),
		"evidence_found": _evidence_found,
		"detections": _detections,
		"elapsed": _elapsed,
		"status_override": _status_override,
		"guard_positions": guard_positions,
		"evidence_visibility": evidence_visibility
	}


func apply_save_snapshot(snapshot: Dictionary) -> bool:
	if not snapshot.has("phase"):
		return false
	_phase = clampi(int(snapshot.get("phase", int(Phase.LOCKED))), int(Phase.LOCKED), int(Phase.FAILED))
	_evidence_found = clampi(int(snapshot.get("evidence_found", 0)), 0, EVIDENCE_POSITIONS.size())
	_detections = clampi(int(snapshot.get("detections", 0)), 0, MAX_DETECTIONS)
	_elapsed = maxf(0.0, float(snapshot.get("elapsed", 0.0)))
	_status_override = str(snapshot.get("status_override", ""))
	if _phase != Phase.LOCKED and _phase != Phase.COMPLETE and _phase != Phase.FAILED and not _visuals_created:
		_create_harbor_blockout()
	var positions = snapshot.get("guard_positions", [])
	if positions is Array:
		for index in range(mini(positions.size(), _guards.size())):
			_restore_node_position(_guards[index], positions[index])
	var visibility = snapshot.get("evidence_visibility", [])
	if visibility is Array:
		for index in range(mini(visibility.size(), _evidence_markers.size())):
			if is_instance_valid(_evidence_markers[index]):
				_evidence_markers[index].visible = bool(visibility[index])
	_refresh_hud()
	return true


func reload_saved_state() -> void:
	if _is_completed():
		_phase = Phase.COMPLETE
		_award_completion_reward()
	elif _mission_002_completed():
		if not _visuals_created:
			_start_mission()
	else:
		_phase = Phase.LOCKED
	_refresh_hud()


func _node_position_snapshot(node: Node3D) -> Array:
	if not is_instance_valid(node):
		return []
	return [node.global_position.x, node.global_position.y, node.global_position.z]


func _restore_node_position(node: Node3D, value: Variant) -> void:
	if not is_instance_valid(node) or not value is Array or value.size() < 3:
		return
	node.global_position = Vector3(float(value[0]), float(value[1]), float(value[2]))
