extends Node

enum Stage {
	MOUNT_BIKE,
	RIDE_TO_BRIDGE,
	DISMOUNT_AT_BRIDGE,
	ENTER_HOUSE,
	COMPLETE
}

var _stage: Stage = Stage.MOUNT_BIKE
var _player: CharacterBody3D
var _bicycle: CharacterBody3D
var _bridge: Node3D
var _house_portal: Node3D
var _hud: Node
var _blue_marker: Node3D
var _refresh_timer := 0.0


func _ready() -> void:
	_bind_world_nodes()
	_create_bicycle_marker()
	_refresh_hud()


func _process(delta: float) -> void:
	_refresh_timer += delta
	if _refresh_timer >= 0.15:
		_refresh_timer = 0.0
		if not _bindings_are_valid():
			_bind_world_nodes()
			_create_bicycle_marker()
		_update_stage()
		_refresh_hud()


func get_stage_id() -> String:
	match _stage:
		Stage.MOUNT_BIKE:
			return "mount_bike"
		Stage.RIDE_TO_BRIDGE:
			return "ride_to_bridge"
		Stage.DISMOUNT_AT_BRIDGE:
			return "dismount_at_bridge"
		Stage.ENTER_HOUSE:
			return "enter_house"
		_:
			return "complete"


func get_objective_text() -> String:
	match _stage:
		Stage.MOUNT_BIKE:
			return "اركب الدراجة القريبة منك"
		Stage.RIDE_TO_BRIDGE:
			return "قد الدراجة حتى الجسر الأحمر"
		Stage.DISMOUNT_AT_BRIDGE:
			return "وصلت إلى الجسر؛ انزل من الدراجة"
		Stage.ENTER_HOUSE:
			return "اتجه إلى علامة المنزل الحمراء وادخل"
		_:
			return "اكتمل مسار التدريب بنجاح"


func get_target_position() -> Vector3:
	match _stage:
		Stage.MOUNT_BIKE, Stage.RIDE_TO_BRIDGE, Stage.DISMOUNT_AT_BRIDGE:
			if _stage == Stage.MOUNT_BIKE and _bicycle != null:
				return _bicycle.global_position
			if _bridge != null:
				return _bridge.global_position
		Stage.ENTER_HOUSE:
			if _house_portal != null:
				return _house_portal.global_position
	return Vector3.ZERO


func _bindings_are_valid() -> bool:
	return _player != null and is_instance_valid(_player) \
		and _bicycle != null and is_instance_valid(_bicycle) \
		and _bridge != null and is_instance_valid(_bridge) \
		and _house_portal != null and is_instance_valid(_house_portal)


func _bind_world_nodes() -> void:
	_player = get_parent().get_node_or_null("Player") as CharacterBody3D
	_bicycle = get_parent().get_node_or_null("StarterBicycle") as CharacterBody3D
	_house_portal = get_parent().get_node_or_null("WillowVillage/CaretakerHousePortal") as Node3D
	_bridge = null
	for landmark in get_tree().get_nodes_in_group("world_landmarks"):
		if landmark is Node3D:
			_bridge = landmark as Node3D
			break
	_hud = get_tree().get_first_node_in_group("gameplay_hud")


func _update_stage() -> void:
	if not _bindings_are_valid():
		return
	var driver = _bicycle.get("driver")
	var player_is_riding: bool = driver == _player
	match _stage:
		Stage.MOUNT_BIKE:
			if player_is_riding:
				_set_stage(Stage.RIDE_TO_BRIDGE)
		Stage.RIDE_TO_BRIDGE:
			if player_is_riding and _bicycle.global_position.distance_to(_bridge.global_position) <= 10.0:
				_set_stage(Stage.DISMOUNT_AT_BRIDGE)
		Stage.DISMOUNT_AT_BRIDGE:
			if not player_is_riding and _player.global_position.distance_to(_bridge.global_position) <= 14.0:
				_set_stage(Stage.ENTER_HOUSE)
		Stage.ENTER_HOUSE:
			if bool(_house_portal.get("_is_inside")):
				_set_stage(Stage.COMPLETE)


func _set_stage(next_stage: Stage) -> void:
	if _stage == next_stage:
		return
	_stage = next_stage
	if _blue_marker != null and is_instance_valid(_blue_marker):
		_blue_marker.visible = _stage == Stage.MOUNT_BIKE
	_refresh_hud()


func _refresh_hud() -> void:
	if _hud == null or not is_instance_valid(_hud):
		_hud = get_tree().get_first_node_in_group("gameplay_hud")
	if _hud == null or not _hud.has_method("set_tutorial_objective"):
		return
	_hud.call("set_tutorial_objective", get_objective_text(),
		get_target_position(), _stage != Stage.COMPLETE)


func _create_bicycle_marker() -> void:
	if _bicycle == null or not is_instance_valid(_bicycle):
		return
	if _bicycle.get_node_or_null("VideoReferenceBlueMarker") != null:
		_blue_marker = _bicycle.get_node("VideoReferenceBlueMarker") as Node3D
		_blue_marker.visible = _stage == Stage.MOUNT_BIKE
		return
	_blue_marker = Node3D.new()
	_blue_marker.name = "VideoReferenceBlueMarker"
	_blue_marker.position = Vector3(0.0, 2.35, 0.0)
	_bicycle.add_child(_blue_marker)

	var beam := MeshInstance3D.new()
	beam.name = "BlueMarkerBeam"
	var beam_mesh := CylinderMesh.new()
	beam_mesh.top_radius = 0.10
	beam_mesh.bottom_radius = 0.42
	beam_mesh.height = 1.55
	beam_mesh.radial_segments = 20
	beam.mesh = beam_mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.10, 0.52, 1.0, 0.62)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.emission_enabled = true
	material.emission = Color(0.04, 0.28, 1.0)
	material.emission_energy_multiplier = 1.6
	beam.material_override = material
	_blue_marker.add_child(beam)

	var beacon := OmniLight3D.new()
	beacon.name = "BlueMarkerLight"
	beacon.light_color = Color(0.12, 0.48, 1.0)
	beacon.light_energy = 0.7
	beacon.omni_range = 5.5
	_blue_marker.add_child(beacon)
	_blue_marker.visible = _stage == Stage.MOUNT_BIKE
