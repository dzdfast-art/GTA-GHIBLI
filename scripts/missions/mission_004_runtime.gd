extends CanvasLayer

## Mission 004: escort Mia and protect the last train.
## Lightweight runtime blockout; final train art, animation and voice acting are pending.

const MISSION_003_SAVE := "user://gta_ghibli_mission_003.json"
const COMPLETION_SAVE := "user://gta_ghibli_mission_004.json"

enum Phase { LOCKED, MEET_MIA, REACH_TRAIN, DISABLE_ALARMS, ESCORT_TRAIN, CHOOSE_ROUTE, COMPLETE, FAILED }

const MIA_POSITION := Vector3(52.0, 0.0, -70.0)
const TRAIN_START := Vector3(62.0, 0.0, -70.0)
const ALARM_POSITIONS := [
	Vector3(70.0, 0.0, -66.0),
	Vector3(78.0, 0.0, -74.0)
]
const NORTH_ROUTE := Vector3(112.0, 0.0, -84.0)
const SOUTH_ROUTE := Vector3(112.0, 0.0, -56.0)
const TRAIN_SPEED := 2.2
const ESCORT_DURATION := 20.0
const MAX_MISSION_TIME := 180.0
const MAX_ABANDON_TIME := 7.0

var _player: CharacterBody3D
var _world_root: Node3D
var _phase: Phase = Phase.LOCKED
var _mia: Node3D
var _train: Node3D
var _alarm_markers: Array[Node3D] = []
var _alarms_disabled := 0
var _mission_elapsed := 0.0
var _escort_elapsed := 0.0
var _abandon_elapsed := 0.0
var _route_choice := ""
var _visuals_created := false
var _panel: PanelContainer
var _objective_label: Label
var _status_label: Label
var _progress_label: Label
var _retry_button: Button
var _status_override := ""


func _ready() -> void:
	add_to_group("mission_hud_sources")
	_world_root = get_tree().current_scene as Node3D
	_build_hud()
	if _is_completed():
		_phase = Phase.COMPLETE
	elif _mission_003_completed():
		_start_mission()
	else:
		_phase = Phase.LOCKED
	_refresh_hud()


func setup(player: CharacterBody3D) -> void:
	_player = player


func _physics_process(delta: float) -> void:
	if _phase == Phase.LOCKED:
		if _mission_003_completed():
			_start_mission()
		else:
			return
	if _player == null:
		return

	if _phase != Phase.COMPLETE and _phase != Phase.FAILED:
		_mission_elapsed += delta
		if _mission_elapsed >= MAX_MISSION_TIME:
			_fail_mission("تأخرت كثيراً! غادر القطار المحطة قبل إتمام المهمة.")
			return

	match _phase:
		Phase.MEET_MIA:
			if _player.global_position.distance_to(MIA_POSITION) <= 5.0:
				_set_phase(Phase.REACH_TRAIN, "وجدت ميا. اتبعها إلى القطار الأخير.")
		Phase.REACH_TRAIN:
			if _player.global_position.distance_to(TRAIN_START) <= 6.0:
				_set_phase(Phase.DISABLE_ALARMS, "عطّل لوحتي الإنذار قبل تحرك القطار.")
		Phase.DISABLE_ALARMS:
			_check_alarm_panels()
			if _alarms_disabled >= ALARM_POSITIONS.size():
				_set_phase(Phase.ESCORT_TRAIN, "انطلق القطار! ابق قريباً منه واحمِ ميا.")
		Phase.ESCORT_TRAIN:
			_update_train_escort(delta)
		Phase.CHOOSE_ROUTE:
			if _player.global_position.distance_to(NORTH_ROUTE) <= 5.0:
				_complete_mission("north")
			elif _player.global_position.distance_to(SOUTH_ROUTE) <= 5.0:
				_complete_mission("south")
	_refresh_hud()


func _mission_003_completed() -> bool:
	if not FileAccess.file_exists(MISSION_003_SAVE):
		return false
	var file := FileAccess.open(MISSION_003_SAVE, FileAccess.READ)
	if file == null:
		return false
	var data = JSON.parse_string(file.get_as_text())
	return data is Dictionary and str(data.get("mission_id", "")) == "shadows_over_the_harbor" and bool(data.get("completed", false))


func _is_completed() -> bool:
	if not FileAccess.file_exists(COMPLETION_SAVE):
		return false
	var file := FileAccess.open(COMPLETION_SAVE, FileAccess.READ)
	if file == null:
		return false
	var data = JSON.parse_string(file.get_as_text())
	return data is Dictionary and str(data.get("mission_id", "")) == "the_last_train" and bool(data.get("completed", false))


func _start_mission() -> void:
	_phase = Phase.MEET_MIA
	_alarms_disabled = 0
	_mission_elapsed = 0.0
	_escort_elapsed = 0.0
	_abandon_elapsed = 0.0
	_route_choice = ""
	_status_override = "مهمة جديدة: قابل ميا في المحطة قبل مغادرة القطار."
	_create_station_blockout()
	_refresh_hud()


func _set_phase(next_phase: Phase, status: String) -> void:
	_phase = next_phase
	_status_override = status
	_refresh_hud()


func _check_alarm_panels() -> void:
	for marker in _alarm_markers:
		if not is_instance_valid(marker) or not marker.visible:
			continue
		if _player.global_position.distance_to(marker.global_position) <= 2.8:
			marker.visible = false
			_alarms_disabled += 1
			_status_override = "عطّلت لوحة إنذار %d من 2." % _alarms_disabled


func _update_train_escort(delta: float) -> void:
	if _train == null or not is_instance_valid(_train):
		_fail_mission("تعذر العثور على القطار.")
		return
	_train.global_position.x += TRAIN_SPEED * delta
	var distance := _player.global_position.distance_to(_train.global_position)
	if distance <= 14.0:
		_escort_elapsed += delta
		_abandon_elapsed = 0.0
	else:
		_abandon_elapsed += delta
		if _abandon_elapsed >= MAX_ABANDON_TIME:
			_fail_mission("ابتعدت عن القطار أكثر من اللازم. لم تستطع حماية ميا.")
			return
	if _escort_elapsed >= ESCORT_DURATION or _train.global_position.x >= 110.0:
		_set_phase(Phase.CHOOSE_ROUTE, "وصل القطار إلى المفترق. اختر المسار الشمالي أو الجنوبي.")


func _complete_mission(choice: String) -> void:
	_phase = Phase.COMPLETE
	_route_choice = choice
	var reward := 350 if choice == "north" else 400
	var file := FileAccess.open(COMPLETION_SAVE, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify({
			"mission_id": "the_last_train",
			"completed": true,
			"route_choice": choice,
			"alarms_disabled": _alarms_disabled,
			"reward_currency": reward
		}, "\t"))
	_status_override = "نجحت! أنقذت ميا وأوصلت القطار عبر المسار %s. مكافأتك %d." % ["الشمالي" if choice == "north" else "الجنوبي", reward]
	if _retry_button != null:
		_retry_button.visible = false
	_refresh_hud()


func _fail_mission(reason: String) -> void:
	_phase = Phase.FAILED
	_status_override = reason
	if _retry_button != null:
		_retry_button.visible = true
	_refresh_hud()


func _on_retry_pressed() -> void:
	_alarms_disabled = 0
	_mission_elapsed = 0.0
	_escort_elapsed = 0.0
	_abandon_elapsed = 0.0
	_route_choice = ""
	if _mia != null and is_instance_valid(_mia):
		_mia.visible = true
	if _train != null and is_instance_valid(_train):
		_train.global_position = TRAIN_START
	for marker in _alarm_markers:
		if is_instance_valid(marker):
			marker.visible = true
	_phase = Phase.MEET_MIA
	_status_override = "حاول مجدداً: قابل ميا في المحطة."
	_refresh_hud()


func _create_station_blockout() -> void:
	if _visuals_created or _world_root == null:
		return
	_visuals_created = true
	_add_box("LastTrainPlatform", Vector3(75.0, 0.12, -70.0), Vector3(42.0, 0.24, 12.0), Color(0.30, 0.32, 0.34))
	_add_box("RailBed", Vector3(85.0, 0.02, -70.0), Vector3(55.0, 0.12, 3.0), Color(0.20, 0.19, 0.18))
	for index in range(18):
		_add_box("RailSleeper_%02d" % index, Vector3(59.0 + float(index) * 3.0, 0.10, -70.0), Vector3(0.35, 0.18, 4.2), Color(0.28, 0.20, 0.14))
	_add_box("RailLeft", Vector3(85.0, 0.24, -71.0), Vector3(55.0, 0.16, 0.12), Color(0.56, 0.57, 0.58))
	_add_box("RailRight", Vector3(85.0, 0.24, -69.0), Vector3(55.0, 0.16, 0.12), Color(0.56, 0.57, 0.58))
	_mia = _make_actor("MiaStationContact", MIA_POSITION, Color(0.30, 0.52, 0.78))
	_train = _make_train()
	for index in range(ALARM_POSITIONS.size()):
		var marker := _make_marker("AlarmPanel_%d" % (index + 1), ALARM_POSITIONS[index] + Vector3.UP * 0.8, Color(0.95, 0.35, 0.18))
		_alarm_markers.append(marker)
	_make_marker("NorthRouteMarker", NORTH_ROUTE + Vector3.UP * 0.15, Color(0.25, 0.75, 0.55))
	_make_marker("SouthRouteMarker", SOUTH_ROUTE + Vector3.UP * 0.15, Color(0.25, 0.55, 0.90))


func _make_train() -> Node3D:
	var train := Node3D.new()
	train.name = "LastTrain"
	train.position = TRAIN_START
	_world_root.add_child(train)
	_add_child_box(train, "LocomotiveBody", Vector3(0.0, 1.5, 0.0), Vector3(7.0, 2.4, 2.8), Color(0.16, 0.28, 0.34))
	_add_child_box(train, "LocomotiveCab", Vector3(-2.0, 3.0, 0.0), Vector3(2.8, 1.0, 2.6), Color(0.22, 0.40, 0.48))
	_add_child_box(train, "FrontWindow", Vector3(-0.55, 3.05, -1.34), Vector3(1.3, 0.62, 0.06), Color(0.12, 0.20, 0.24))
	_add_child_box(train, "PassengerCar", Vector3(6.0, 1.5, 0.0), Vector3(6.0, 2.2, 2.7), Color(0.52, 0.48, 0.34))
	_add_child_box(train, "PassengerWindowA", Vector3(5.0, 2.0, -1.38), Vector3(1.0, 0.65, 0.06), Color(0.12, 0.20, 0.24))
	_add_child_box(train, "PassengerWindowB", Vector3(7.0, 2.0, -1.38), Vector3(1.0, 0.65, 0.06), Color(0.12, 0.20, 0.24))
	for x_position in [-2.4, 2.4, 4.0, 8.0]:
		for z_position in [-1.25, 1.25]:
			var wheel := MeshInstance3D.new()
			var wheel_mesh := CylinderMesh.new()
			wheel_mesh.top_radius = 0.48
			wheel_mesh.bottom_radius = 0.48
			wheel_mesh.height = 0.24
			wheel.mesh = wheel_mesh
			wheel.position = Vector3(x_position, 0.65, z_position)
			wheel.rotation_degrees.x = 90.0
			var wheel_material := StandardMaterial3D.new()
			wheel_material.albedo_color = Color(0.10, 0.11, 0.12)
			wheel.material_override = wheel_material
			train.add_child(wheel)
	return train


func _make_actor(node_name: String, at: Vector3, tint: Color) -> Node3D:
	var actor := Node3D.new()
	actor.name = node_name
	actor.position = at
	_world_root.add_child(actor)
	var body := MeshInstance3D.new()
	var capsule := CapsuleMesh.new()
	capsule.radius = 0.38
	capsule.height = 1.8
	body.mesh = capsule
	body.position.y = 0.9
	var material := StandardMaterial3D.new()
	material.albedo_color = tint
	body.material_override = material
	actor.add_child(body)
	return actor


func _make_marker(node_name: String, at: Vector3, tint: Color) -> Node3D:
	var marker := Node3D.new()
	marker.name = node_name
	marker.position = at
	_world_root.add_child(marker)
	var mesh_instance := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = 0.48
	mesh.height = 0.96
	mesh_instance.mesh = mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = tint
	material.emission_enabled = true
	material.emission = tint * 0.25
	mesh_instance.material_override = material
	marker.add_child(mesh_instance)
	return marker


func _add_box(node_name: String, at: Vector3, size: Vector3, tint: Color) -> void:
	var visual := MeshInstance3D.new()
	visual.name = node_name
	visual.position = at
	var mesh := BoxMesh.new()
	mesh.size = size
	visual.mesh = mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = tint
	material.roughness = 0.95
	visual.material_override = material
	_world_root.add_child(visual)


func _add_child_box(parent: Node3D, node_name: String, at: Vector3, size: Vector3, tint: Color) -> void:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = node_name
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh_instance.mesh = mesh
	mesh_instance.position = at
	var material := StandardMaterial3D.new()
	material.albedo_color = tint
	material.roughness = 0.78
	mesh_instance.material_override = material
	parent.add_child(mesh_instance)


func _add_box_visual(parent: Node3D, size: Vector3, tint: Color) -> void:
	var mesh_instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh_instance.mesh = mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = tint
	material.roughness = 0.95
	mesh_instance.material_override = material
	parent.add_child(mesh_instance)


func get_hud_snapshot() -> Dictionary:
	var target := MIA_POSITION
	var has_target := true
	match _phase:
		Phase.MEET_MIA:
			target = MIA_POSITION
		Phase.REACH_TRAIN:
			target = TRAIN_START
		Phase.DISABLE_ALARMS:
			has_target = false
			for marker in _alarm_markers:
				if is_instance_valid(marker) and marker.visible:
					target = marker.global_position
					has_target = true
					break
		Phase.ESCORT_TRAIN:
			target = _train.global_position if _train != null and is_instance_valid(_train) else TRAIN_START
		Phase.CHOOSE_ROUTE:
			target = NORTH_ROUTE
		_:
			has_target = false
	var active := _phase != Phase.LOCKED and _phase != Phase.COMPLETE
	return {
		"active": active,
		"priority": 4,
		"title": "القطار الأخير",
		"objective": _objective_label.text if _objective_label != null else "",
		"status": _status_override,
		"target_position": target,
		"has_target": has_target and active,
		"can_retry": _phase == Phase.FAILED
	}


func retry_from_hud() -> void:
	_on_retry_pressed()


func _build_hud() -> void:
	_panel = PanelContainer.new()
	_panel.name = "Mission004Panel"
	_panel.anchor_left = 0.02
	_panel.anchor_top = 0.60
	_panel.anchor_right = 0.58
	_panel.anchor_bottom = 0.84
	_panel.visible = false
	add_child(_panel)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 4)
	_panel.add_child(content)
	var title := Label.new()
	title.text = "القطار الأخير"
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
			_objective_label.text = "أكمل مهمة الميناء الثالثة لفتح هذه المهمة."
		Phase.MEET_MIA:
			_objective_label.text = "١. قابل ميا في محطة القطار."
		Phase.REACH_TRAIN:
			_objective_label.text = "٢. اتبع ميا إلى القطار."
		Phase.DISABLE_ALARMS:
			_objective_label.text = "٣. عطّل لوحتي الإنذار."
		Phase.ESCORT_TRAIN:
			_objective_label.text = "٤. ابق قريباً من القطار حتى يصل إلى المفترق."
		Phase.CHOOSE_ROUTE:
			_objective_label.text = "٥. اختر المسار الشمالي أو الجنوبي."
		Phase.COMPLETE:
			_objective_label.text = "اكتملت مهمة القطار الأخير!"
		Phase.FAILED:
			_objective_label.text = "فشلت المهمة. يمكنك إعادة المحاولة."
	_status_label.text = _status_override
	_progress_label.text = "الإنذارات: %d/2   |   مرافقة القطار: %d%%   |   الوقت: %dث" % [
		_alarms_disabled,
		int(clampf(_escort_elapsed / ESCORT_DURATION, 0.0, 1.0) * 100.0),
		int(maxf(0.0, MAX_MISSION_TIME - _mission_elapsed))
	]
