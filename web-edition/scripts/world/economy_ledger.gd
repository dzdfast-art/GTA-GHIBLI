extends RefCounted
class_name GhibliEconomyLedger
var balance: int=0
var entries: Array[Dictionary]=[]
func transact(amount: int, reason: String) -> bool:
	if amount==0 or reason.is_empty() or balance+amount<0: return false
	balance+=amount
	entries.append({"amount":amount,"reason":reason,"balance":balance})
	return true
func get_balance() -> int:
	return balance
func history() -> Array[Dictionary]:
	return entries.duplicate(true)