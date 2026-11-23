extends RefCounted
class_name GhibliWeaponInventory
var weapons: Dictionary={}
var selected: String=""
func add_weapon(id: String, ammo: int) -> bool:
	if id.is_empty() or ammo<0 or weapons.has(id): return false
	weapons[id]=ammo
	if selected=="": selected=id
	return true
func select_weapon(id: String) -> bool:
	if not weapons.has(id): return false
	selected=id
	return true
func consume_ammo(amount: int=1) -> bool:
	if selected=="" or amount<=0 or int(weapons[selected])<amount: return false
	weapons[selected]=int(weapons[selected])-amount
	return true
func ammo_count(id: String) -> int:
	return int(weapons.get(id,-1))