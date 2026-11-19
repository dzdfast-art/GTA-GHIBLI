extends Node

## Local player currency wallet used by optional jobs and village shops.
signal balance_changed(new_balance: int)
const SAVE_PATH := "user://player_wallet.json"

@export_range(0, 1000000, 1) var initial_balance := 250
@export var persistence_enabled := true
var balance := 0
var claimed_reward_ids: PackedStringArray = PackedStringArray()

func _ready() -> void:
	balance = maxi(0, initial_balance)
	_load_balance()

func add_money(amount: int) -> bool:
	if amount <= 0:
		return false
	balance = mini(balance + amount, 999999999)
	_save_balance()
	balance_changed.emit(balance)
	return true

func claim_reward(reward_id: String, amount: int) -> bool:
	var stable_id := reward_id.strip_edges()
	if stable_id.is_empty() or amount <= 0 or claimed_reward_ids.find(stable_id) >= 0:
		return false
	claimed_reward_ids.append(stable_id)
	balance = mini(balance + amount, 999999999)
	_save_balance()
	balance_changed.emit(balance)
	return true

func spend_money(amount: int) -> bool:
	if amount <= 0 or balance < amount:
		return false
	balance -= amount
	_save_balance()
	balance_changed.emit(balance)
	return true

func get_balance() -> int:
	return balance

func _load_balance() -> void:
	if not persistence_enabled or not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		balance = clampi(int(parsed.get("balance", balance)), 0, 999999999)
		var saved_claims = parsed.get("claimed_reward_ids", [])
		if saved_claims is Array:
			claimed_reward_ids.clear()
			for reward_id in saved_claims:
				var stable_id := str(reward_id).strip_edges()
				if not stable_id.is_empty() and claimed_reward_ids.find(stable_id) < 0:
					claimed_reward_ids.append(stable_id)

func _save_balance() -> void:
	if not persistence_enabled:
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("Could not save player wallet.")
		return
	file.store_string(JSON.stringify({
		"schema_version": 2,
		"balance": balance,
		"claimed_reward_ids": Array(claimed_reward_ids)
	}, "\t"))
