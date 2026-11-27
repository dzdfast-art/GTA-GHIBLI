extends RefCounted
class_name GhibliShopInventory

const MAX_STOCK: int = 99

var stock: Dictionary = {}
var inventory: Dictionary = {}
var _default_stock: Dictionary = {}


func add_item(item_id: String, price: int, quantity: int) -> bool:
	if item_id.is_empty() or price < 0 or quantity < 0 or quantity > MAX_STOCK or stock.has(item_id):
		return false
	var record := {"price": price, "quantity": quantity}
	stock[item_id] = record.duplicate(true)
	_default_stock[item_id] = record.duplicate(true)
	return true


func purchase(item_id: String, wallet: int, quantity: int = 1) -> Dictionary:
	if quantity <= 0 or not stock.has(item_id):
		return {"ok": false, "wallet": wallet, "reason": "invalid_item"}
	var item: Dictionary = stock[item_id]
	var price := int(item.get("price", -1))
	var available := int(item.get("quantity", -1))
	if price < 0 or available < 0:
		return {"ok": false, "wallet": wallet, "reason": "invalid_item"}
	if available < quantity:
		return {"ok": false, "wallet": wallet, "reason": "out_of_stock"}
	var cost := price * quantity
	if wallet < cost:
		return {"ok": false, "wallet": wallet, "reason": "insufficient_funds"}
	item["quantity"] = available - quantity
	stock[item_id] = item
	inventory[item_id] = int(inventory.get(item_id, 0)) + quantity
	return {
		"ok": true,
		"wallet": wallet - cost,
		"cost": cost,
		"quantity": int(inventory[item_id])
	}


func sell(item_id: String, wallet: int, quantity: int = 1) -> Dictionary:
	if quantity <= 0 or not stock.has(item_id):
		return {"ok": false, "wallet": wallet, "reason": "invalid_item"}
	var owned := int(inventory.get(item_id, 0))
	if owned < quantity:
		return {"ok": false, "wallet": wallet, "reason": "not_owned"}
	var item: Dictionary = stock[item_id]
	var available := int(item.get("quantity", 0))
	if available + quantity > MAX_STOCK:
		return {"ok": false, "wallet": wallet, "reason": "stock_full"}
	var unit_value := int(floor(float(item.get("price", 0)) * 0.5))
	if unit_value <= 0:
		return {"ok": false, "wallet": wallet, "reason": "not_resellable"}
	var proceeds := unit_value * quantity
	item["quantity"] = available + quantity
	stock[item_id] = item
	var remaining := owned - quantity
	if remaining == 0:
		inventory.erase(item_id)
	else:
		inventory[item_id] = remaining
	return {
		"ok": true,
		"wallet": wallet + proceeds,
		"proceeds": proceeds,
		"quantity": remaining
	}


func consume(item_id: String, quantity: int = 1) -> bool:
	if item_id.is_empty() or quantity <= 0 or not inventory.has(item_id):
		return false
	var owned := int(inventory.get(item_id, 0))
	if owned < quantity:
		return false
	var remaining := owned - quantity
	if remaining == 0:
		inventory.erase(item_id)
	else:
		inventory[item_id] = remaining
	return true


func get_quantity(item_id: String) -> int:
	return int(inventory.get(item_id, 0))


func get_catalog() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var item_ids: Array = stock.keys()
	item_ids.sort()
	for item_id in item_ids:
		var item: Dictionary = stock[item_id]
		result.append({
			"id": str(item_id),
			"price": int(item.get("price", 0)),
			"quantity": int(item.get("quantity", 0))
		})
	return result


func snapshot() -> Dictionary:
	return {
		"stock": stock.duplicate(true),
		"inventory": inventory.duplicate(true)
	}


func restore(snapshot_value: Dictionary) -> bool:
	if snapshot_value.is_empty():
		return true
	var saved_stock: Variant = snapshot_value.get("stock", {})
	var saved_inventory: Variant = snapshot_value.get("inventory", {})
	if not saved_stock is Dictionary or not saved_inventory is Dictionary:
		return false

	var next_stock: Dictionary = _default_stock.duplicate(true)
	var next_inventory: Dictionary = {}
	for item_id_value in saved_stock:
		var item_id := str(item_id_value)
		if not next_stock.has(item_id) or not saved_stock[item_id_value] is Dictionary:
			return false
		var saved_item: Dictionary = saved_stock[item_id_value]
		var default_item: Dictionary = next_stock[item_id]
		var price := int(saved_item.get("price", -1))
		var quantity := int(saved_item.get("quantity", -1))
		if price != int(default_item.get("price", -2)) or quantity < 0 or quantity > MAX_STOCK:
			return false
		default_item["quantity"] = quantity
		next_stock[item_id] = default_item

	for item_id_value in saved_inventory:
		var item_id := str(item_id_value)
		var quantity := int(saved_inventory[item_id_value])
		if not next_stock.has(item_id) or quantity < 0 or quantity > MAX_STOCK:
			return false
		if quantity > 0:
			next_inventory[item_id] = quantity

	stock = next_stock
	inventory = next_inventory
	return true


func reset() -> void:
	stock = _default_stock.duplicate(true)
	inventory.clear()
