extends Node

## Local player currency wallet used by optional jobs and village shops.
signal balance_changed(new_balance: int)
const SAVE_PATH := "user://player_wallet.json"

@export_range(0, 1000000, 1) var initial_balance := 350
@export var persistence_enabled := true
var balance := 0
var _reward_transactions: Array[String] = []
var _updated_at_unix := 0


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


## Credits a named mission/job reward once, even if the completion callback runs again.
## The transaction ID and balance are saved together in the wallet record.
func add_money_once(transaction_id: String, amount: int) -> bool:
	var normalized_id := transaction_id.strip_edges()
	if normalized_id.is_empty() or amount <= 0 or _reward_transactions.has(normalized_id):
		return false
	_reward_transactions.append(normalized_id)
	balance = mini(balance + amount, 999999999)
	_save_balance()
	balance_changed.emit(balance)
	return true


func has_reward_transaction(transaction_id: String) -> bool:
	return _reward_transactions.has(transaction_id.strip_edges())


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
	if not parsed is Dictionary:
		return
	_updated_at_unix = maxi(0, int(parsed.get("updated_at_unix", 0)))
	balance = clampi(int(parsed.get("balance", balance)), 0, 999999999)
	var transactions = parsed.get("reward_transactions", [])
	if transactions is Array:
		_reward_transactions.clear()
		for transaction in transactions:
			var transaction_id := str(transaction).strip_edges()
			if not transaction_id.is_empty() and not _reward_transactions.has(transaction_id):
				_reward_transactions.append(transaction_id)


func _save_balance() -> void:
	if not persistence_enabled:
		return
	var now := int(Time.get_unix_time_from_system())
	_updated_at_unix = maxi(now, _updated_at_unix + 1)
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("Could not save player wallet.")
		return
	file.store_string(JSON.stringify({
		"schema_version": 2,
		"balance": balance,
		"reward_transactions": _reward_transactions,
		"updated_at_unix": _updated_at_unix
	}, "\t"))

func get_save_snapshot() -> Dictionary:
	return {
		"schema_version": 2,
		"balance": balance,
		"reward_transactions": _reward_transactions.duplicate(),
		"updated_at_unix": _updated_at_unix
	}


func apply_save_snapshot(snapshot: Dictionary) -> bool:
	if not snapshot.has("balance"):
		return false
	var current_balance := balance
	var current_updated_at := _updated_at_unix
	var current_transactions := _reward_transactions.duplicate()
	var snapshot_updated_at := maxi(0, int(snapshot.get("updated_at_unix", 0)))
	var preserve_newer_legacy_state := current_updated_at > snapshot_updated_at

	var snapshot_transactions = snapshot.get("reward_transactions", [])
	var merged_transactions: Array[String] = []
	if snapshot_transactions is Array:
		for transaction in snapshot_transactions:
			var transaction_id := str(transaction).strip_edges()
			if not transaction_id.is_empty() and not merged_transactions.has(transaction_id):
				merged_transactions.append(transaction_id)
	for transaction in current_transactions:
		var transaction_id := str(transaction).strip_edges()
		if not transaction_id.is_empty() and not merged_transactions.has(transaction_id):
			merged_transactions.append(transaction_id)

	balance = current_balance if preserve_newer_legacy_state else clampi(int(snapshot.get("balance", balance)), 0, 999999999)
	_reward_transactions = merged_transactions
	_updated_at_unix = maxi(current_updated_at, snapshot_updated_at)
	_save_balance()
	balance_changed.emit(balance)
	return true


func reload_saved_state() -> void:
	_load_balance()
	balance_changed.emit(balance)
