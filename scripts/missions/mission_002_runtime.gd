extends CanvasLayer

## First action-story mission runtime. It unlocks after mission_001 is completed.
## The pursuer is a lightweight scripted vehicle actor for the current blockout.

const MISSION_DATA_PATH := "res://data/missions/mission_002.json"
const FIRST_MISSION_SAVE := "user://gta_ghibli_save.json"
const COMPLETION_SAVE := "user://gta_ghibli_mission_002.json"

enum Phase { LOCKED, ENTER_VEHICLE, REACH_CHECKPOINT, PASS_BLOCKADE, RESCUE_WITNESS, ESCAPE_PURSUIT, COMPLETE, FAILED }

const CHECKPOINT := Vector3(0.0, 0.0, -25.0)
const BLOCKADE_LINE_Z := -34.0
const WITNESS_POSITION := Vector3(0.0, 0.0, -42.0)
const HOME_POSITION := Vector3(0.0, 0.0, 0.0)
const ESCAPE_TIME_LIMIT := 90.0
const PURSUER_SPEED := 6.8
const PURSUER_CATCH_DISTANCE := 3.2

var _player: CharacterBody3D
var _vehicle: CharacterBody3D
var _phase: Phase = Phase.LOCKED
var _mission_data: Dictionary = {}
var _escape_time_left := ESCAPE_TIME_LIMIT
var _pursuer: Node3D
var _witness: Node3D
var _passenger_visual: Node3D
var _world_root: Node3D
var _panel: PanelContainer
var _objective_label: Label
var _status_label: Label
var _timer_label: Label
var _retry_button: Button
var _visuals_created := false


func _ready() -> void:
	_load_mission_data()
	_world_root = get_tree().current_scene as Node3D
	_build_hud()
	if _is_mission_completed():
		_phase = Phase.COMPLETE
	elif _is_first_mission_complete():
		_start_mission()
	else:
		_phase = Phase.LOCKED
	_refresh_hud()


func setup(player: CharacterBody3D, vehicle: CharacterBody3D) -> void:
	_player = player
	_vehicle = vehicle


func _process(delta: float) -> void:
	if _phase == Phase.LOCKED:
		if _is_first_mission_complete():
			_start_mission()
		else:
			return

	if _phase == Phase.ENTER_VEHICLE:
		if _is_vehicle_driven():
			_set_phase(Phase.REACH_CHECKPOINT, "انطلقت! اتبع الطريق القديم.")
	elif _phase == Phase.REACH_CHECKPOINT:
		if _vehicle != null and _vehicle.global_position.distance_to(CHECKPOINT) <= 6.0:
			_set_phase(Phase.PASS_BLOCKADE, "اقتربت من الحاجز. اعبر الفتحة بحذر.")
	elif _phase == Phase.PASS_BLOCKADE:
		if _vehicle != null and _vehicle.global_position.z <= BLOCKADE_LINE_Z and absf(_vehicle.global_position.x) <= 2.2:
			_set_phase(Phase.RESCUE_WITNESS, "وصلت إلى المنطقة. اخرج من السيارة وابحث عن الشاهد.")
	elif _phase == Phase.RESCUE_WITNESS:
		if _player != null and not _player_is_driving() and _player.global_position.distance_to(WITNESS_POSITION) <= 4.2:
			_rescue_witness()
	elif _phase == Phase.ESCAPE_PURSUIT:
		_escape_time_left = maxf(0.0, _escape_time_left - delta)
		_update_pursuer(delta)
		if _vehicle != null and _vehicle.global_position.distance_to(HOME_POSITION) <= 9.0:
			var pursuer_distance := 999.0
			if _pursuer != null and is_instance_valid(_pursuer):
				pursuer_distance = _pursuer.global_position.distance_to(_vehicle.global_position)
			if pursuer_distance >= 7.0:
				_complete_mission()
				return
		if _escape_time_left <= 0.0:
			_fail_mission("انتهى الوقت قبل الإفلات من المطاردين.")
		elif _pursuer != null and is_instance_valid(_pursuer) and _pursuer.global_position.distance_to(_vehicle.global_position) <= PURSUER_CATCH_DISTANCE:
			_fail_mission("لحق بك المطاردون. حاول مرة أخرى.")

	_refresh_hud()


func _load_mission_data() -> void:
	if not FileAccess.file_exists(MISSION_DATA_PATH):
		push_warning("Mission 002 data is missing.")
		return
	var file := FileAccess.open(MISSION_DATA_PATH, FileAccess.READ)
	if file == null:
		push_warning("Could not open Mission 002 data.")
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		_mission_data = parsed
	else:
		push_warning("Mission 002 data must be a JSON object.")


func _is_first_mission_complete() -> bool:
	if not FileAccess.file_exists(FIRST_MISSION_SAVE):
		return false
	var file := FileAccess.open(FIRST_MISSION_SAVE, FileAccess.READ)
	if file == null:
		return false
	var parsed = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		return false
	return bool(parsed.get("square_reached", false)) and bool(parsed.get("mira_spoken_to", false)) and bool(parsed.get("garden_visited", false))


func _is_mission_completed() -> bool:
	if not FileAccess.file_exists(COMPLETION_SAVE):
		return false
	var file := FileAccess.open(COMPLETION_SAVE, FileAccess.READ)
	if file == null:
		return false
	var parsed = JSON.parse_string(file.get_as_text())
	return parsed is Dictionary and str(parsed.get("mission_id", "")) == "the_old_road_rescue" and bool(parsed.get("completed", false))


func _save_completion() -> void:
	var file := FileAccess.open(COMPLETION_SAVE, FileAccess.WRITE)
	if file == null:
		push_warning("Could not save Mission 002 completion.")
		return
	file.store_string(JSON.stringify({
		"mission_id": "the_old_road_rescue",
		"completed": true,
		"reward_currency": int(_mission_data.get("rewards", {}).get("currency", 180))
	}, "\t"))


func _start_mission() -> void:
	_phase = Phase.ENTER_VEHICLE
	_escape_time_left = ESCAPE_TIME_LIMIT
	_create_route_visuals()
	_refresh_hud()


func _set_phase(next_phase: Phase, status: String) -> void:
	_phase = next_phase
	if _status_label != null:
		_status_label.text = status
	_refresh_hud()


func _rescue_witness() -> void:
	if _witness != null and is_instance_valid(_witness):
		_witness.visible = false
	_add_passenger_visual()
	_phase = Phase.ESCAPE_PURSUIT
	_escape_time_left = ESCAPE_TIME_LIMIT
	if _pursuer != null and is_instance_valid(_pursuer):
		_pursuer.visible = true
		_pursuer.global_position = Vector3(-2.8, 0.0, -49.0)
	_set_phase(Phase.ESCAPE_PURSUIT, "أنقذت الشاهد! ارجع إلى ساحة القرية قبل أن يمسك بك المطاردون.")


func _complete_mission() -> void:
	_phase = Phase.COMPLETE
	_save_completion()
	if _pursuer != null and is_instance_valid(_pursuer):
		_pursuer.visible = false
	_set_phase(Phase.COMPLETE, "نجحت العملية! عاد الشاهد إلى الأمان.")
	if _retry_button != null:
		_retry_button.visible = false


func _fail_mission(reason: String) -> void:
	_phase = Phase.FAILED
	if _status_label != null:
		_status_label.text = reason
	if _retry_button != null:
		_retry_button.visible = true
	_refresh_hud()


func _on_retry_pressed() -> void:
	if _vehicle != null:
		if _vehicle.get("driver") != null:
			_vehicle.call("_exit_vehicle")
		_vehicle.global_position = Vector3(2.4, 0.0, -18.0)
		_vehicle.rotation = Vector3.ZERO
	if _player != null:
		_player.global_position = Vector3(0.0, 0.95, -18.0)
		_player.rotation.y = PI
	if _witness != null and is_instance_valid(_witness):
		_witness.visible = true
	if _passenger_visual != null and is_instance_valid(_passenger_visual):
		_passenger_visual.queue_free()
		_passenger_visual = null
	if _pursuer != null and is_instance_valid(_pursuer):
		_pursuer.visible = false
	_phase = Phase.ENTER_VEHICLE
	_escape_time_left = ESCAPE_TIME_LIMIT
	_refresh_hud()


func _is_vehicle_driven() -> bool:
	return _player_is_driving() and _vehicle != null and _vehicle.get("driver") == _player


func _player_is_driving() -> bool:
	return _player != null and bool(_player.get("is_driving"))


func _update_pursuer(delta: float) -> void:
	if _pursuer == null or not is_instance_valid(_pursuer) or _vehicle == null:
		return
	var direction := _vehicle.global_position - _pursuer.global_position
	direction.y = 0.0
	if direction.length_squared() <= 0.01:
		return
	direction = direction.normalized()
	_pursuer.global_position += direction * PURSUER_SPEED * delta
	_pursuer.rotation.y = atan2(-direction.x, -direction.z)


func _create_route_visuals() -> void:
	if _visuals_created or _world_root == null:
		return
	_visuals_created = true
	_add_box(_world_root, "OldRoadSurface", Vector3(0.0, 0.035, -35.0), Vector3(4.2, 0.07, 34.0), Color(0.34, 0.32, 0.27), false)
	_add_box(_world_root, "RescueBlockadeLeft", Vector3(-3.2, 0.65, -31.0), Vector3(4.0, 1.3, 0.55), Color(0.75, 0.22, 0.12), true)
	_add_box(_world_root, "RescueBlockadeRight", Vector3(3.2, 0.65, -31.0), Vector3(4.0, 1.3, 0.55), Color(0.75, 0.22, 0.12), true)
	_add_checkpoint_marker()
	_create_witness()
	_create_pursuer()


func _add_checkpoint_marker() -> void:
	var marker := MeshInstance3D.new()
	marker.name = "OldRoadCheckpoint"
	var ring := CylinderMesh.new()
	ring.top_radius = 2.0
	ring.bottom_radius = 2.0
	ring.height = 0.08
	marker.mesh = ring
	marker.position = CHECKPOINT + Vector3.UP * 0.08
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.95, 0.72, 0.20, 0.8)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	marker.material_override = material
	_world_root.add_child(marker)


func _create_witness() -> void:
	_witness = Node3D.new()
	_witness.name = "RescueWitness"
	_witness.position = WITNESS_POSITION
	_world_root.add_child(_witness)
	var body := MeshInstance3D.new()
	var capsule := CapsuleMesh.new()
	capsule.radius = 0.38
	capsule.height = 1.7
	body.mesh = capsule
	body.position.y = 0.85
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.82, 0.72, 0.54)
	body.material_override = material
	_witness.add_child(body)
	var label := Label3D.new()
	label.text = "الشاهد"
	label.position.y = 2.0
	label.font_size = 28
	label.modulate = Color(1.0, 0.9, 0.65)
	_witness.add_child(label)


func _create_pursuer() -> void:
	_pursuer = Node3D.new()
	_pursuer.name = "PursuitVehicle"
	_pursuer.position = Vector3(-2.8, 0.0, -49.0)
	_pursuer.visible = false
	_world_root.add_child(_pursuer)
	var body := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(2.0, 0.8, 3.8)
	body.mesh = mesh
	body.position.y = 0.75
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.45, 0.12, 0.10)
	body.material_override = material
	_pursuer.add_child(body)
	var cabin := MeshInstance3D.new()
	var cabin_mesh := BoxMesh.new()
	cabin_mesh.size = Vector3(1.5, 0.65, 1.7)
	cabin.mesh = cabin_mesh
	cabin.position = Vector3(0.0, 1.35, 0.15)
	var cabin_material := StandardMaterial3D.new()
	cabin_material.albedo_color = Color(0.16, 0.18, 0.19)
	cabin.material_override = cabin_material
	_pursuer.add_child(cabin)


func _add_passenger_visual() -> void:
	if _vehicle == null or _passenger_visual != null:
		return
	_passenger_visual = Node3D.new()
	_passenger_visual.name = "RescuedWitnessPassenger"
	_passenger_visual.position = Vector3(0.0, 1.5, 0.35)
	_vehicle.add_child(_passenger_visual)
	var body := MeshInstance3D.new()
	var capsule := CapsuleMesh.new()
	capsule.radius = 0.27
	capsule.height = 0.9
	body.mesh = capsule
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.82, 0.72, 0.54)
	body.material_override = material
	_passenger_visual.add_child(body)


func _add_box(parent: Node3D, node_name: String, position: Vector3, size: Vector3, tint: Color, with_collision: bool) -> void:
	var mesh := BoxMesh.new()
	mesh.size = size
	var visual := MeshInstance3D.new()
	visual.name = node_name
	visual.mesh = mesh
	visual.position = position
	var material := StandardMaterial3D.new()
	material.albedo_color = tint
	material.roughness = 0.88
	visual.material_override = material
	parent.add_child(visual)
	if with_collision:
		var obstacle := StaticBody3D.new()
		obstacle.name = node_name + "Body"
		obstacle.position = position
		var shape := BoxShape3D.new()
		shape.size = size
		var collision := CollisionShape3D.new()
		collision.shape = shape
		obstacle.add_child(collision)
		parent.add_child(obstacle)


func _build_hud() -> void:
	_panel = PanelContainer.new()
	_panel.name = "Mission002Panel"
	_panel.anchor_left = 0.02
	_panel.anchor_top = 0.37
	_panel.anchor_right = 0.58
	_panel.anchor_bottom = 0.57
	add_child(_panel)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 4)
	_panel.add_child(content)
	var title := Label.new()
	title.text = str(_mission_data.get("title", "الطريق القديم: عملية الإنقاذ"))
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
	_timer_label = Label.new()
	_timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	content.add_child(_timer_label)
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
			_objective_label.text = "أكمل مهمة القرية الأولى لفتح هذه المهمة."
			_status_label.text = "المهمة مقفلة حالياً"
		Phase.ENTER_VEHICLE:
			_objective_label.text = "١. استقل السيارة وانطلق نحو الطريق القديم."
			_status_label.text = "اقترب من السيارة واضغط زر التفاعل للدخول."
		Phase.REACH_CHECKPOINT:
			_objective_label.text = "٢. اتبع الطريق حتى نقطة التفتيش."
			_status_label.text = "تجاوز الحاجز الأحمر عبر الفتحة الوسطى."
		Phase.PASS_BLOCKADE:
			_objective_label.text = "٣. اعبر الحاجز وتابع إلى موقع الشاهد."
			_status_label.text = "حافظ على السيارة داخل الطريق."
		Phase.RESCUE_WITNESS:
			_objective_label.text = "٤. اخرج من السيارة واقترب من الشاهد لإنقاذه."
			_status_label.text = "موقع الشاهد محدد أمامك."
		Phase.ESCAPE_PURSUIT:
			_objective_label.text = "٥. عد بالشاهد إلى ساحة القرية وأفلت من المطاردين."
			_status_label.text = "لا تدع السيارة الحمراء تقترب منك."
		Phase.COMPLETE:
			_objective_label.text = "اكتملت المهمة الثانية!"
			_status_label.text = "مكافأة المهمة: %d قطعة نقدية (نموذج أولي)." % int(_mission_data.get("rewards", {}).get("currency", 180))
		Phase.FAILED:
			_objective_label.text = "فشلت المهمة. يمكنك المحاولة من جديد."
			_timer_label.text = ""
	if _phase == Phase.ESCAPE_PURSUIT:
		_timer_label.text = "الوقت المتبقي: %d ثانية" % ceili(_escape_time_left)
	elif _phase != Phase.FAILED:
		_timer_label.text = ""
