extends Node

## Local player currency wallet used by optional jobs and village shops.
signal balance_changed(new_balance: int)
const SAVE_PATH := "user://player_wallet.json"

@export_range(0, 1000000, 1) var initial_balance := 350
@export var persistence_enabled := true
var balance := 0

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

func _save_balance() -> void:
	if not persistence_enabled:
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("Could not save player wallet.")
		return
	file.store_string(JSON.stringify({"schema_version": 1, "balance": balance}, "\t"))
