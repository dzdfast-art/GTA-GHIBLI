extends Node

## Runtime bridge for the imported Quaternius humanoid skeleton.
## Uses authored AnimationPlayer clips when present and a deterministic,
## lightweight bone-pose fallback when the model contains a rig only.

@export var animation_player_path: NodePath
@export_range(0.01, 1.0, 0.01) var idle_speed_threshold: float = 0.12
@export_range(0.1, 5.0, 0.1) var run_speed_threshold: float = 5.5

var _animation_player: AnimationPlayer
var _skeleton: Skeleton3D
var _current_animation: StringName = &""
var _state: StringName = &"idle"
var _vehicle_kind: StringName = &"vehicle"
var _planar_speed: float = 0.0
var _sprint_requested: bool = false
var _time: float = 0.0
var _bone_indices: Dictionary = {}
var _base_bone_rotations: Dictionary = {}

const REQUIRED_BONES: Array[StringName] = [
	&"pelvis", &"spine_01", &"spine_02", &"spine_03", &"Head",
	&"upperarm_l", &"lowerarm_l", &"upperarm_r", &"lowerarm_r",
	&"thigh_l", &"calf_l", &"foot_l", &"thigh_r", &"calf_r", &"foot_r"
]


func _ready() -> void:
	_resolve_rig()


func _process(delta: float) -> void:
	_time += delta
	if _skeleton == null or not is_instance_valid(_skeleton):
		_resolve_rig()
	if _skeleton != null:
		_apply_procedural_pose()


func update_locomotion(planar_speed: float, sprint_requested: bool, grounded: bool) -> void:
	_planar_speed = maxf(planar_speed, 0.0)
	_sprint_requested = sprint_requested
	_vehicle_kind = &""
	if not grounded:
		_state = &"fall"
	elif _planar_speed <= idle_speed_threshold:
		_state = &"idle"
	elif sprint_requested and _planar_speed >= run_speed_threshold:
		_state = &"run"
	else:
		_state = &"walk"
	_play_first_available(_clips_for_state(_state))


func set_vehicle_state(active: bool, vehicle_kind: StringName = &"vehicle") -> void:
	if not active:
		_state = &"idle"
		_vehicle_kind = &""
		_play_first_available([&"idle", &"idle_loop", &"breathing_idle"])
		return
	_vehicle_kind = vehicle_kind
	if vehicle_kind == &"bicycle" or vehicle_kind == &"bike":
		_state = &"bicycle"
		_play_first_available([&"bicycle_idle", &"bike_idle", &"ride_idle", &"cycling_idle"])
	else:
		_state = &"car"
		_play_first_available([&"vehicle_idle", &"car_idle", &"drive_idle"])


func get_active_animation() -> StringName:
	return _current_animation


func get_locomotion_state() -> StringName:
	return _state


func has_humanoid_skeleton() -> bool:
	return _skeleton != null and _bone_indices.has(&"pelvis") and _bone_indices.has(&"Head")


func _clips_for_state(state: StringName) -> Array[StringName]:
	match state:
		&"idle":
			return [&"idle", &"idle_loop", &"breathing_idle"]
		&"walk":
			return [&"walk", &"walking", &"walk_forward"]
		&"run":
			return [&"run", &"running", &"sprint", &"run_forward"]
		&"fall":
			return [&"fall", &"jump_fall", &"falling"]
	return []


func _play_first_available(candidates: Array[StringName]) -> void:
	if _animation_player == null or not is_instance_valid(_animation_player):
		return
	var available: PackedStringArray = _animation_player.get_animation_list()
	for candidate in candidates:
		var wanted := String(candidate).to_lower()
		for animation_name in available:
			var normalized := animation_name.to_lower()
			if normalized == wanted or normalized.ends_with("|" + wanted) or normalized.ends_with("_" + wanted):
				if _current_animation == StringName(animation_name) and _animation_player.current_animation == animation_name:
					return
				_current_animation = StringName(animation_name)
				_animation_player.play(_current_animation)
				return


func _resolve_rig() -> void:
	var player_root := get_parent()
	if player_root == null:
		return
	_skeleton = null
	_animation_player = null
	if not animation_player_path.is_empty():
		_animation_player = get_node_or_null(animation_player_path) as AnimationPlayer
	_skeleton = _find_skeleton_recursive(player_root)
	if _animation_player == null:
		_animation_player = _find_animation_player_recursive(player_root)
	_capture_base_pose()


func _find_skeleton_recursive(node: Node) -> Skeleton3D:
	for child in node.get_children():
		var candidate := child as Skeleton3D
		if candidate != null:
			return candidate
		var nested := _find_skeleton_recursive(child)
		if nested != null:
			return nested
	return null


func _find_animation_player_recursive(node: Node) -> AnimationPlayer:
	for child in node.get_children():
		var candidate := child as AnimationPlayer
		if candidate != null:
			return candidate
		var nested := _find_animation_player_recursive(child)
		if nested != null:
			return nested
	return null


func _capture_base_pose() -> void:
	_bone_indices.clear()
	_base_bone_rotations.clear()
	if _skeleton == null:
		return
	for bone_name in REQUIRED_BONES:
		var index := _skeleton.find_bone(String(bone_name))
		if index < 0:
			continue
		_bone_indices[bone_name] = index
		_base_bone_rotations[bone_name] = _skeleton.get_bone_pose_rotation(index)


func _apply_procedural_pose() -> void:
	if _animation_player != null and _animation_player.is_playing():
		return
	# Start every frame from the imported rest/pose rotations to avoid drift.
	for bone_name in _bone_indices:
		var index := int(_bone_indices[bone_name])
		_skeleton.set_bone_pose_rotation(index, _base_bone_rotations[bone_name])

	match _state:
		&"idle":
			_apply_idle_pose()
		&"walk":
			_apply_locomotion_pose(0.48, 0.34, 5.5)
		&"run":
			_apply_locomotion_pose(0.78, 0.58, 8.5)
		&"fall":
			_apply_fall_pose()
		&"bicycle":
			_apply_bicycle_pose()
		&"car":
			_apply_car_pose()


func _apply_idle_pose() -> void:
	var breath := sin(_time * 1.8) * 0.018
	_set_bone_x(&"spine_02", breath)
	_set_bone_x(&"spine_03", breath * 0.65)
	_set_bone_z(&"Head", sin(_time * 0.7) * 0.012)


func _apply_locomotion_pose(stride: float, arm_swing: float, frequency: float) -> void:
	var phase := _time * frequency
	var left_leg := sin(phase) * stride
	var right_leg := -sin(phase) * stride
	_set_bone_x(&"thigh_l", left_leg)
	_set_bone_x(&"thigh_r", right_leg)
	_set_bone_x(&"calf_l", maxf(0.0, -sin(phase)) * stride * 0.95)
	_set_bone_x(&"calf_r", maxf(0.0, sin(phase)) * stride * 0.95)
	_set_bone_x(&"upperarm_l", -sin(phase) * arm_swing)
	_set_bone_x(&"upperarm_r", sin(phase) * arm_swing)
	_set_bone_x(&"lowerarm_l", -0.12)
	_set_bone_x(&"lowerarm_r", -0.12)
	_set_bone_x(&"spine_01", -absf(sin(phase)) * 0.035 if _state == &"run" else 0.0)
	_set_bone_z(&"Head", sin(phase * 2.0) * 0.012)


func _apply_fall_pose() -> void:
	_set_bone_z(&"upperarm_l", -0.8)
	_set_bone_z(&"upperarm_r", 0.8)
	_set_bone_x(&"thigh_l", -0.25)
	_set_bone_x(&"thigh_r", 0.35)
	_set_bone_x(&"spine_01", -0.25)


func _apply_bicycle_pose() -> void:
	var phase := _time * 6.4
	_set_bone_x(&"spine_01", -0.16)
	_set_bone_x(&"spine_02", -0.08)
	_set_bone_x(&"upperarm_l", 0.62)
	_set_bone_x(&"upperarm_r", 0.62)
	_set_bone_x(&"lowerarm_l", -0.22)
	_set_bone_x(&"lowerarm_r", -0.22)
	_set_bone_x(&"thigh_l", 0.25 + sin(phase) * 0.42)
	_set_bone_x(&"thigh_r", 0.25 + sin(phase + PI) * 0.42)
	_set_bone_x(&"calf_l", 0.48 + maxf(0.0, -sin(phase)) * 0.62)
	_set_bone_x(&"calf_r", 0.48 + maxf(0.0, sin(phase)) * 0.62)


func _apply_car_pose() -> void:
	_set_bone_x(&"spine_01", -0.08)
	_set_bone_x(&"upperarm_l", 0.30)
	_set_bone_x(&"upperarm_r", 0.30)
	_set_bone_x(&"lowerarm_l", -0.18)
	_set_bone_x(&"lowerarm_r", -0.18)
	_set_bone_x(&"thigh_l", 0.70)
	_set_bone_x(&"thigh_r", 0.70)
	_set_bone_x(&"calf_l", -0.78)
	_set_bone_x(&"calf_r", -0.78)


func _set_bone_x(bone_name: StringName, angle: float) -> void:
	_set_bone_rotation(bone_name, Vector3.RIGHT, angle)


func _set_bone_z(bone_name: StringName, angle: float) -> void:
	_set_bone_rotation(bone_name, Vector3.FORWARD, angle)


func _set_bone_rotation(bone_name: StringName, axis: Vector3, angle: float) -> void:
	if _skeleton == null or not _bone_indices.has(bone_name):
		return
	var index := int(_bone_indices[bone_name])
	var base_rotation: Quaternion = _base_bone_rotations[bone_name]
	_skeleton.set_bone_pose_rotation(index, base_rotation * Quaternion(axis, angle))
