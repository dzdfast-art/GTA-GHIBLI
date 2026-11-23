extends RefCounted
class_name GhibliSafehouseRegistry
var houses: Dictionary={}
func register_house(id: String, position: Vector3, price: int) -> bool:
	if id.is_empty() or price<0 or houses.has(id): return false
	houses[id]={"position":position,"price":price,"owned":false}
	return true
func purchase(id: String, wallet: int) -> Dictionary:
	if not houses.has(id) or houses[id].owned: return {"ok":false,"wallet":wallet}
	var price=int(houses[id].price)
	if wallet<price: return {"ok":false,"wallet":wallet}
	houses[id].owned=true
	return {"ok":true,"wallet":wallet-price,"position":houses[id].position}
func owns(id: String) -> bool:
	return houses.has(id) and houses[id].owned