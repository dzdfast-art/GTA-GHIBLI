extends Node

## Local consumable inventory connected to the player's survival needs.
signal inventory_changed(item_id: String, new_count: int)
signal item_consumed(item_id: String, item_name_ar: String)

const CATALOG_PATH := "res://data/items/consumables.json"
const SAVE_PATH := "user://player_inventory.json"

@export var persistence_enabled := true
var _catalog: Dictionary = {}
var _inventory: Dictionary = {}

func _ready() -> void:
	_load_catalog()
	_load_inventory()

func add_item(item_id: String, amount: int = 1) -> bool:
	if amount <= 0 or not _catalog.has(item_id):
		return false
	var new_count := int(_inventory.get(item_id, 0)) + amount
	_inventory[item_id] = new_count
	inventory_changed.emit(item_id, new_count)
	_save_inventory()
	return true

func remove_item(item_id: String, amount: int = 1) -> bool:
	var current := int(_inventory.get(item_id, 0))
	if amount <= 0 or current < amount:
		return false
	var remaining := current - amount
	if remaining == 0:
		_inventory.erase(item_id)
	else:
		_inventory[item_id] = remaining
	inventory_changed.emit(item_id, remaining)
	_save_inventory()
	return true

func consume_item(item_id: String) -> bool:
	if not _catalog.has(item_id) or get_item_count(item_id) <= 0:
		return false
	var item: Dictionary = _catalog[item_id]
	if str(item.get("category", "")) not in ["food", "drink"]:
		return false
	var actor := get_parent()
	if actor == null:
		return false
	var needs := actor.get_node_or_null("PlayerNeeds")
	if needs == null:
		return false
	if not needs.has_method("consume_food") or not needs.has_method("drink"):
		return false
	var nutrition := maxf(0.0, float(item.get("nutrition", 0.0)))
	var hydration := maxf(0.0, float(item.get("hydration", 0.0)))
	var energy_restore := maxf(0.0, float(item.get("energy", 0.0)))
	if nutrition > 0.0 or energy_restore > 0.0:
		needs.call("consume_food", nutrition, hydration, energy_restore)
	elif hydration > 0.0:
		needs.call("drink", hydration)
	else:
		return false
	if not remove_item(item_id, 1):
		return false
	item_consumed.emit(item_id, str(item.get("name_ar", item_id)))
	return true

func get_item_count(item_id: String) -> int:
	return int(_inventory.get(item_id, 0))

func get_item_name(item_id: String) -> String:
	if not _catalog.has(item_id):
		return item_id
	return str(_catalog[item_id].get("name_ar", item_id))

func get_catalog_ids() -> PackedStringArray:
	var ids := PackedStringArray()
	for item_id in _catalog.keys():
		ids.append(str(item_id))
	ids.sort()
	return ids

func get_inventory_snapshot() -> Dictionary:
	return _inventory.duplicate(true)

func _load_catalog() -> void:
	var file := FileAccess.open(CATALOG_PATH, FileAccess.READ)
	if file == null:
		push_warning("Could not open consumables catalog.")
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		push_warning("Consumables catalog root must be an object.")
		return
	var items = parsed.get("items", [])
	if not items is Array:
		return
	for value in items:
		if not value is Dictionary:
			continue
		var item_id := str(value.get("id", ""))
		if item_id.is_empty():
			continue
		_catalog[item_id] = value.duplicate(true)

func _load_inventory() -> void:
	if not persistence_enabled or not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		return
	var saved = parsed.get("items", {})
	if not saved is Dictionary:
		return
	for item_id in saved.keys():
		var key := str(item_id)
		var amount := int(saved[item_id])
		if _catalog.has(key) and amount > 0:
			_inventory[key] = amount

func _save_inventory() -> void:
	if not persistence_enabled:
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("Could not save player inventory.")
		return
	file.store_string(JSON.stringify({"schema_version": 1, "items": _inventory}, "\t"))
