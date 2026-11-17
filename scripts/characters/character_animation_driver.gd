extends Node

## Bridges locomotion state to AnimationPlayer clips imported with a rigged
## character scene. The controller deliberately remains safe while the
## project is still using its temporary capsule placeholder.

@export var animation_player_path: NodePath
@export_range(0.01, 1.0, 0.01) var idle_speed_threshold: float = 0.12
@export_range(0.1, 5.0, 0.1) var run_speed_threshold: float = 5.5

var _animation_player: AnimationPlayer
var _current_animation: StringName = &""
var _is_in_vehicle: bool = false


func _ready() -> void:
	_resolve_animation_player()


func update_locomotion(planar_speed: float, sprint_requested: bool, grounded: bool) -> void:
	_is_in_vehicle = false
	if not grounded:
		_play_first_available([&"fall", &"jump_fall", &"falling"])
	elif planar_speed <= idle_speed_threshold:
		_play_first_available([&"idle", &"idle_loop", &"breathing_idle"])
	elif sprint_requested and planar_speed >= run_speed_threshold:
		_play_first_available([&"run", &"running", &"sprint", &"run_forward"])
	else:
		_play_first_available([&"walk", &"walking", &"walk_forward"])


func set_vehicle_state(active: bool, vehicle_kind: StringName = &"vehicle") -> void:
	_is_in_vehicle = active
	if not active:
		_play_first_available([&"idle", &"idle_loop", &"breathing_idle"])
		return

	if vehicle_kind == &"bicycle" or vehicle_kind == &"bike":
		_play_first_available([&"bicycle_idle", &"bike_idle", &"ride_idle", &"cycling_idle"])
	else:
		_play_first_available([&"vehicle_idle", &"car_idle", &"drive_idle"])


func get_active_animation() -> StringName:
	return _current_animation


func _play_first_available(candidates: Array[StringName]) -> void:
	if _animation_player == null or not is_instance_valid(_animation_player):
		_resolve_animation_player()
	if _animation_player == null:
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


func _resolve_animation_player() -> void:
	_animation_player = null
	if not animation_player_path.is_empty():
		_animation_player = get_node_or_null(animation_player_path) as AnimationPlayer
	if _animation_player != null:
		return

	var search_root := get_parent()
	if search_root == null:
		return
	_animation_player = _find_animation_player_recursive(search_root)


func _find_animation_player_recursive(node: Node) -> AnimationPlayer:
	for child in node.get_children():
		var candidate := child as AnimationPlayer
		if candidate != null:
			return candidate
		var nested := _find_animation_player_recursive(child)
		if nested != null:
			return nested
	return null
