extends Node

## Versioned local save coordinator. Existing per-system files are retained as
## compatibility backups inside one portable save record.
signal game_saved(path: String)
signal game_loaded(path: String)
signal save_failed(reason: String)

const SAVE_PATH := "user://gta_ghibli_unified_save.json"
const SAVE_TEMP_PATH := "user://gta_ghibli_unified_save.tmp"
const SAVE_BACKUP_PATH := "user://gta_ghibli_unified_save.bak"
const SAVE_SCHEMA_VERSION := 1
const AUTOSAVE_INTERVAL := 90.0
const LEGACY_SAVE_PATHS := [
	"user://gta_ghibli_save.json",
	"user://gta_ghibli_mission_002.json",
	"user://gta_ghibli_mission_003.json",
	"user://gta_ghibli_mission_004.json",
	"user://player_wallet.json",
	"user://player_needs.json",
	"user://player_inventory.json",
	"user://gta_ghibli_side_activities.json",
	"user://gta_ghibli_settings.cfg"
]

var _autosave_elapsed := 0.0
var _restoring := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("game_save_manager")
	call_deferred("_load_existing_save")


func _process(delta: float) -> void:
	if _restoring:
		return
	_autosave_elapsed += delta
	if _autosave_elapsed >= AUTOSAVE_INTERVAL:
		_autosave_elapsed = 0.0
		save_game()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_APPLICATION_PAUSED:
		save_game()


func save_game() -> bool:
	var scene := get_tree().current_scene
	if scene == null:
		save_failed.emit("لا يوجد مشهد نشط لحفظ اللعبة.")
		return false

	var data := {
		"schema_version": SAVE_SCHEMA_VERSION,
		"saved_at_unix": Time.get_unix_time_from_system(),
		"player": _capture_player(),
		"world_clock": _capture_world_clock(),
		"components": _capture_player_components(),
		"missions": _capture_named_snapshots(scene, [
			"MissionManager",
			"Mission002Runtime",
			"Mission003Runtime",
			"Mission004Runtime",
			"SideActivityDirector"
		]),
		"npc_relationships": _capture_npc_snapshots(),
		"vehicles": _capture_vehicles(),
		"legacy_files": _capture_legacy_files()
	}

	var json_text := JSON.stringify(data, "\t")
	var temporary := FileAccess.open(SAVE_TEMP_PATH, FileAccess.WRITE)
	if temporary == null:
		save_failed.emit("تعذر إنشاء ملف الحفظ المؤقت.")
		return false
	temporary.store_string(json_text)
	temporary.flush()
	var write_error := temporary.get_error()
	temporary.close()
	if write_error != OK:
		save_failed.emit("حدث خطأ أثناء كتابة ملف الحفظ.")
		return false

	var verify := FileAccess.open(active_temp_path, FileAccess.READ)
	if verify == null:
		save_failed.emit("تعذر قراءة ملف الحفظ للتحقق منه.")
		return false
	var parsed = JSON.parse_string(verify.get_as_text())
	verify.close()
	if not parsed is Dictionary or int(parsed.get("schema_version", 0)) != SAVE_SCHEMA_VERSION:
		save_failed.emit("فشل التحقق من بنية ملف الحفظ.")
		return false

	var final_abs := ProjectSettings.globalize_path(active_save_path)
	var temp_abs := ProjectSettings.globalize_path(active_temp_path)
	var backup_abs := ProjectSettings.globalize_path(active_backup_path)
	if FileAccess.file_exists(active_backup_path):
		DirAccess.remove_absolute(backup_abs)
	if FileAccess.file_exists(active_save_path):
		var backup_error := DirAccess.rename_absolute(final_abs, backup_abs)
		if backup_error != OK:
			save_failed.emit("تعذر إنشاء نسخة احتياطية من الحفظ السابق.")
			return false
	var rename_error := DirAccess.rename_absolute(temp_abs, final_abs)
	if rename_error != OK:
		if FileAccess.file_exists(SAVE_BACKUP_PATH):
			DirAccess.rename_absolute(backup_abs, final_abs)
		save_failed.emit("تعذر اعتماد ملف الحفظ الجديد.")
		return false

	game_saved.emit(_active_save_path())
	return true


func load_game() -> bool:
	if not FileAccess.file_exists(_active_save_path()):
		return false
	var file := FileAccess.open(_active_save_path(), FileAccess.READ)
	if file == null:
		save_failed.emit("تعذر فتح ملف الحفظ الموحد.")
		return false
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	if not parsed is Dictionary:
		save_failed.emit("ملف الحفظ الموحد تالف أو غير صالح.")
		return false
	if int(parsed.get("schema_version", 0)) != SAVE_SCHEMA_VERSION:
		save_failed.emit("إصدار ملف الحفظ غير مدعوم؛ احتُفظ بالملف دون حذفه.")
		return false

	_restoring = true
	_restore_legacy_files(parsed.get("legacy_files", {}))
	_restore_player(parsed.get("player", {}))
	_restore_world_clock(parsed.get("world_clock", {}))
	_restore_player_components(parsed.get("components", {}))
	_restore_named_snapshots(parsed.get("missions", {}))
	_restore_npc_snapshots(parsed.get("npc_relationships", {}))
	_restore_vehicles(parsed.get("vehicles", []))
	_reload_legacy_components()
	_restoring = false
	game_loaded.emit(_active_save_path())
	return true


func get_save_path() -> String:
	return _active_save_path()


func _load_existing_save() -> void:
	if FileAccess.file_exists(_active_save_path()):
		load_game()


func _capture_player() -> Dictionary:
	var player := get_tree().get_first_node_in_group("player") as Node3D
	if player == null:
		return {}
	return {
		"position": _vector3_to_array(player.global_position),
		"rotation": _vector3_to_array(player.rotation),
		"scale": _vector3_to_array(player.scale)
	}


func _restore_player(snapshot: Dictionary) -> void:
	var player := get_tree().get_first_node_in_group("player") as Node3D
	if player == null:
		return
	if snapshot.get("position") is Array:
		player.global_position = _array_to_vector3(snapshot["position"], player.global_position)
	if snapshot.get("rotation") is Array:
		player.rotation = _array_to_vector3(snapshot["rotation"], player.rotation)
	if snapshot.get("scale") is Array:
		player.scale = _array_to_vector3(snapshot["scale"], player.scale)


func _capture_world_clock() -> Dictionary:
	var clock := get_tree().get_first_node_in_group("world_clock")
	if clock == null:
		return {}
	return {"hour": int(clock.call("get_hour")), "minute": int(clock.call("get_minute"))}


func _restore_world_clock(snapshot: Dictionary) -> void:
	var clock := get_tree().get_first_node_in_group("world_clock")
	if clock != null and clock.has_method("set_time") and snapshot.has("hour"):
		clock.call("set_time", int(snapshot.get("hour", 5)), int(snapshot.get("minute", 0)))


func _capture_player_components() -> Dictionary:
	var player := get_tree().get_first_node_in_group("player")
	if player == null:
		return {}
	var result: Dictionary = {}
	for child_name in ["PlayerHealth", "PlayerWallet", "PlayerNeeds", "ConsumableInventory"]:
		var component := player.get_node_or_null(NodePath(child_name))
		if component != null and component.has_method("get_save_snapshot"):
			result[child_name] = component.call("get_save_snapshot")
	return result


func _restore_player_components(snapshots: Dictionary) -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player == null:
		return
	for child_name in snapshots.keys():
		var component := player.get_node_or_null(NodePath(str(child_name)))
		if component != null and component.has_method("apply_save_snapshot"):
			component.call("apply_save_snapshot", snapshots[child_name])


func _capture_named_snapshots(scene: Node, node_names: Array) -> Dictionary:
	var result: Dictionary = {}
	for node_name in node_names:
		var node := scene.find_child(str(node_name), true, false)
		if node != null and node.has_method("get_save_snapshot"):
			result[str(node_name)] = node.call("get_save_snapshot")
	return result


func _restore_named_snapshots(snapshots: Dictionary) -> void:
	var scene := get_tree().current_scene
	if scene == null:
		return
	for node_name in snapshots.keys():
		var node := scene.find_child(str(node_name), true, false)
		if node != null and node.has_method("apply_save_snapshot"):
			node.call("apply_save_snapshot", snapshots[node_name])


func _capture_npc_snapshots() -> Dictionary:
	var result: Dictionary = {}
	for brain in get_tree().get_nodes_in_group("npc_brains"):
		if not is_instance_valid(brain) or not brain.has_method("get_save_snapshot"):
			continue
		var snapshot: Dictionary = brain.call("get_save_snapshot")
		var key := str(snapshot.get("persistence_id", brain.get_parent().name if brain.get_parent() != null else ""))
		if not key.is_empty():
			result[key] = snapshot
	return result


func _restore_npc_snapshots(snapshots: Dictionary) -> void:
	for brain in get_tree().get_nodes_in_group("npc_brains"):
		if not is_instance_valid(brain) or not brain.has_method("apply_save_snapshot"):
			continue
		var snapshot: Dictionary = brain.call("get_save_snapshot")
		var key := str(snapshot.get("persistence_id", brain.get_parent().name if brain.get_parent() != null else ""))
		if snapshots.has(key):
			brain.call("apply_save_snapshot", snapshots[key])


func _capture_vehicles() -> Array:
	var result: Array = []
	for vehicle in get_tree().get_nodes_in_group("vehicles"):
		if is_instance_valid(vehicle) and vehicle.has_method("get_vehicle_save_snapshot"):
			result.append({
				"name": vehicle.name,
				"state": vehicle.call("get_vehicle_save_snapshot")
			})
	return result


func _restore_vehicles(snapshots: Array) -> void:
	for vehicle in get_tree().get_nodes_in_group("vehicles"):
		if not is_instance_valid(vehicle) or not vehicle.has_method("apply_vehicle_save_snapshot"):
			continue
		for snapshot in snapshots:
			if snapshot is Dictionary and str(snapshot.get("name", "")) == str(vehicle.name):
				vehicle.call("apply_vehicle_save_snapshot", snapshot.get("state", {}))
				break


func _capture_legacy_files() -> Dictionary:
	var result: Dictionary = {}
	for path in LEGACY_SAVE_PATHS:
		if FileAccess.file_exists(path):
			var file := FileAccess.open(path, FileAccess.READ)
			if file != null:
				result[path] = file.get_as_text()
				file.close()
	var relationship_dir := DirAccess.open("user://npc_relationships")
	if relationship_dir != null:
		for filename in relationship_dir.get_files():
			if filename.get_extension().to_lower() != "json":
				continue
			var path := "user://npc_relationships/" + filename
			var file := FileAccess.open(path, FileAccess.READ)
			if file != null:
				result[path] = file.get_as_text()
				file.close()
	return result


func _restore_legacy_files(files: Variant) -> void:
	if not files is Dictionary:
		return
	for path_value in files.keys():
		var path := str(path_value)
		if not path.begins_with("user://") or path.contains(".."):
			continue
		var absolute_directory := ProjectSettings.globalize_path(path.get_base_dir())
		var make_error := DirAccess.make_dir_recursive_absolute(absolute_directory)
		if make_error != OK and make_error != ERR_ALREADY_EXISTS:
			continue
		var file := FileAccess.open(path, FileAccess.WRITE)
		if file == null:
			continue
		file.store_string(str(files[path_value]))
		file.flush()
		file.close()


func _reload_legacy_components() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player != null:
		for child_name in ["PlayerWallet", "PlayerNeeds", "ConsumableInventory"]:
			var component := player.get_node_or_null(NodePath(child_name))
			if component != null and component.has_method("reload_saved_state"):
				component.call("reload_saved_state")
	for brain in get_tree().get_nodes_in_group("npc_brains"):
		if is_instance_valid(brain) and brain.has_method("reload_saved_state"):
			brain.call("reload_saved_state")


func _vector3_to_array(value: Vector3) -> Array:
	return [value.x, value.y, value.z]


func _array_to_vector3(value: Array, fallback: Vector3) -> Vector3:
	if value.size() < 3:
		return fallback
	return Vector3(float(value[0]), float(value[1]), float(value[2]))


func _active_save_path() -> String:
	var override_path := save_path_override.strip_edges()
	return override_path if not override_path.is_empty() else SAVE_PATH
