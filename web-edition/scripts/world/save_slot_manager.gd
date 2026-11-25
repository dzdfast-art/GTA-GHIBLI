extends RefCounted
class_name GhibliSaveSlotManager

const SAVE_PATH := "user://gta_ghibli_runtime_slots.cfg"
const SAVE_VERSION := 1

var slots: Dictionary = {}


func _init() -> void:
	_load_from_disk()


func save_slot(slot_id: String, payload: Dictionary, timestamp: int) -> bool:
	if slot_id.is_empty() or timestamp < 0:
		return false
	slots[slot_id] = {"payload": payload.duplicate(true), "timestamp": timestamp}
	return _persist()


func load_slot(slot_id: String) -> Dictionary:
	if not slots.has(slot_id):
		_load_from_disk()
	return slots.get(slot_id, {}).duplicate(true)


func delete_slot(slot_id: String) -> bool:
	if not slots.erase(slot_id):
		return false
	return _persist()


func list_slots() -> Array[String]:
	var result: Array[String] = []
	for key in slots:
		result.append(str(key))
	result.sort()
	return result


func _load_from_disk() -> void:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return
	if int(config.get_value("meta", "version", 0)) != SAVE_VERSION:
		return
	var stored: Variant = config.get_value("slots", "data", {})
	if stored is Dictionary:
		slots = stored.duplicate(true)


func _persist() -> bool:
	var config := ConfigFile.new()
	config.set_value("meta", "version", SAVE_VERSION)
	config.set_value("slots", "data", slots)
	return config.save(SAVE_PATH) == OK
