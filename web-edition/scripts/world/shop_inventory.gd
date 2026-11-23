extends RefCounted
class_name GhibliShopInventory
var stock: Dictionary = {}
func add_item(item_id: String, price: int, quantity: int) -> bool:
	if item_id.is_empty() or price < 0 or quantity < 0 or stock.has(item_id): return false
	stock[item_id]={"price":price,"quantity":quantity}
	return true
func purchase(item_id: String, wallet: int, quantity: int = 1) -> Dictionary:
	if quantity <= 0 or not stock.has(item_id): return {"ok":false,"wallet":wallet,"reason":"invalid_item"}
	var item=stock[item_id]
	var cost=int(item.price)*quantity
	if int(item.quantity)<quantity: return {"ok":false,"wallet":wallet,"reason":"out_of_stock"}
	if wallet<cost: return {"ok":false,"wallet":wallet,"reason":"insufficient_funds"}
	item.quantity=int(item.quantity)-quantity
	return {"ok":true,"wallet":wallet-cost,"cost":cost}