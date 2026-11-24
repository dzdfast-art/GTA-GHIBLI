extends RefCounted
class_name GhibliSaveSlotManager

const SAVE_VERSION: int = 1
const SAVE_DIRECTORY: String = "user://gta_ghibli_web_saves"

var slots: Dictionary = {}


func save_slot(slot_id: String, payload: Dictionary, timestamp: int) -> bool:
	if not _is_valid_slot_id(slot_id) or timestamp < 0:
		return false
	if not _ensure_directory():
		return false

	var payload_json: String = JSON.stringify(payload)
	if payload_json.is_empty():
		return false
	var envelope: Dictionary = {
		"version": SAVE_VERSION,
		"slot_id": slot_id,
		"timestamp": timestamp,
		"payload_json": payload_json,
		"checksum": _calculate_checksum(payload_json)
	}
	if str(envelope.checksum).is_empty() or not _write_envelope(slot_id, envelope):
		return false

	slots[slot_id] = {
		"payload": payload.duplicate(true),
		"timestamp": timestamp,
		"version": SAVE_VERSION
	}
	return true


func load_slot(slot_id: String) -> Dictionary:
	if not _is_valid_slot_id(slot_id):
		return {}
	var record: Dictionary = _read_slot_file(slot_id, _slot_path(slot_id))
	if record.is_empty():
		var backup_path: String = _slot_path(slot_id) + ".bak"
		record = _read_slot_file(slot_id, backup_path)
		if record.is_empty():
			slots.erase(slot_id)
			return {}
		_restore_backup_file(slot_id, backup_path)
	slots[slot_id] = record.duplicate(true)
	return record.duplicate(true)


func delete_slot(slot_id: String) -> bool:
	if not _is_valid_slot_id(slot_id):
		return false
	var base_path: String = _slot_path(slot_id)
	var existed := false
	for suffix in ["", ".bak", ".tmp", ".recover"]:
		var path: String = base_path + str(suffix)
		if FileAccess.file_exists(path):
			existed = true
			var error: Error = DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
			if error != OK:
				return false
	slots.erase(slot_id)
	return existed


func list_slots() -> Array[String]:
	var result: Array[String] = []
	if not _ensure_directory():
		return result
	var directory := DirAccess.open(SAVE_DIRECTORY)
	if directory == null:
		return result
	directory.list_dir_begin()
	var filename: String = directory.get_next()
	while not filename.is_empty():
		if not directory.current_is_dir() and filename.ends_with(".json"):
			var slot_id: String = filename.substr(0, filename.length() - 5)
			if _is_valid_slot_id(slot_id):
				var record: Dictionary = _read_slot_file(slot_id, _slot_path(slot_id))
				if record.is_empty():
					record = _read_slot_file(slot_id, _slot_path(slot_id) + ".bak")
				if not record.is_empty():
					slots[slot_id] = record.duplicate(true)
					result.append(slot_id)
		filename = directory.get_next()
	directory.list_dir_end()
	result.sort()
	return result


func _write_envelope(slot_id: String, envelope: Dictionary) -> bool:
	var final_path: String = _slot_path(slot_id)
	var temporary_path: String = final_path + ".tmp"
	var backup_path: String = final_path + ".bak"
	var file := FileAccess.open(temporary_path, FileAccess.WRITE)
	if file == null:
		push_warning("Could not open temporary save file: %s" % FileAccess.get_open_error())
		return false
	file.store_string(JSON.stringify(envelope))
	file.flush()
	var write_error: Error = file.get_error()
	file.close()
	if write_error != OK:
		_remove_path(temporary_path)
		return false

	var moved_previous_save := false
	if FileAccess.file_exists(final_path):
		var existing_record: Dictionary = _read_slot_file(slot_id, final_path)
		if not existing_record.is_empty():
			_remove_path(backup_path)
			var backup_error: Error = DirAccess.rename_absolute(
				ProjectSettings.globalize_path(final_path),
				ProjectSettings.globalize_path(backup_path)
			)
			if backup_error != OK:
				_remove_path(temporary_path)
				return false
			moved_previous_save = true
		else:
			var valid_backup: Dictionary = _read_slot_file(slot_id, backup_path)
			if valid_backup.is_empty():
				_remove_path(backup_path)
			_remove_path(final_path)

	var commit_error: Error = DirAccess.rename_absolute(
		ProjectSettings.globalize_path(temporary_path),
		ProjectSettings.globalize_path(final_path)
	)
	if commit_error != OK:
		if moved_previous_save and FileAccess.file_exists(backup_path) and not FileAccess.file_exists(final_path):
			DirAccess.rename_absolute(
				ProjectSettings.globalize_path(backup_path),
				ProjectSettings.globalize_path(final_path)
			)
		_remove_path(temporary_path)
		return false
	return true


func _read_slot_file(slot_id: String, path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var raw: String = FileAccess.get_file_as_string(path)
	if raw.is_empty():
		return {}
	var parsed: Variant = _parse_json(raw)
	if not parsed is Dictionary:
		return {}
	var envelope: Dictionary = parsed
	var stored_id: String = str(envelope.get("slot_id", ""))
	var version: int = int(envelope.get("version", -1))
	var timestamp: int = int(envelope.get("timestamp", -1))
	var payload_json: String = str(envelope.get("payload_json", ""))
	var checksum: String = str(envelope.get("checksum", ""))
	if stored_id != slot_id or version < 0 or version > SAVE_VERSION or timestamp < 0:
		return {}
	if payload_json.is_empty() or checksum != _calculate_checksum(payload_json):
		return {}
	var payload_variant: Variant = _parse_json(payload_json)
	if not payload_variant is Dictionary:
		return {}
	var payload: Dictionary = _migrate_payload(version, payload_variant)
	return {
		"payload": payload,
		"timestamp": timestamp,
		"version": SAVE_VERSION
	}


func _parse_json(raw: String) -> Variant:
	var parser := JSON.new()
	if parser.parse(raw) != OK:
		return null
	return parser.data

func _migrate_payload(from_version: int, payload: Dictionary) -> Dictionary:
	var migrated: Dictionary = payload.duplicate(true)
	var version := from_version
	while version < SAVE_VERSION:
		match version:
			0:
				if not migrated.has("schema_version"):
					migrated["schema_version"] = 1
				version = 1
			_:
				return {}
	return migrated


func _restore_backup_file(slot_id: String, backup_path: String) -> bool:
	var backup_text: String = FileAccess.get_file_as_string(backup_path)
	if backup_text.is_empty():
		return false
	var recovery_path: String = _slot_path(slot_id) + ".recover"
	var file := FileAccess.open(recovery_path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(backup_text)
	file.flush()
	var write_error: Error = file.get_error()
	file.close()
	if write_error != OK:
		_remove_path(recovery_path)
		return false
	_remove_path(_slot_path(slot_id))
	var rename_error: Error = DirAccess.rename_absolute(
		ProjectSettings.globalize_path(recovery_path),
		ProjectSettings.globalize_path(_slot_path(slot_id))
	)
	if rename_error != OK:
		_remove_path(recovery_path)
		return false
	return true


func _calculate_checksum(payload_json: String) -> String:
	var context := HashingContext.new()
	if context.start(HashingContext.HASH_SHA256) != OK:
		return ""
	context.update(payload_json.to_utf8_buffer())
	return context.finish().hex_encode()


func _ensure_directory() -> bool:
	if DirAccess.open(SAVE_DIRECTORY) != null:
		return true
	var error: Error = DirAccess.make_dir_recursive_absolute(
		ProjectSettings.globalize_path(SAVE_DIRECTORY)
	)
	if error != OK and error != ERR_ALREADY_EXISTS:
		push_warning("Could not create save directory: %s" % error)
		return false
	return DirAccess.open(SAVE_DIRECTORY) != null


func _is_valid_slot_id(slot_id: String) -> bool:
	if slot_id.is_empty() or slot_id.length() > 32:
		return false
	for index in range(slot_id.length()):
		var code: int = slot_id.unicode_at(index)
		var is_digit: bool = code >= 48 and code <= 57
		var is_upper: bool = code >= 65 and code <= 90
		var is_lower: bool = code >= 97 and code <= 122
		if not (is_digit or is_upper or is_lower or code == 45 or code == 95):
			return false
	return true


func _slot_path(slot_id: String) -> String:
	return SAVE_DIRECTORY + "/" + slot_id + ".json"


func _remove_path(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
