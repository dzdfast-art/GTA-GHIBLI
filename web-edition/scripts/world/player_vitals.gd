extends RefCounted
class_name GhibliPlayerVitals
var max_health: float=100.0
var health: float=100.0
var max_stamina: float=100.0
var stamina: float=100.0
func apply_damage(amount: float) -> float:
	if amount<=0.0: return 0.0
	var used=minf(health,amount)
	health-=used
	return used
func heal(amount: float) -> float:
	if amount<=0.0: return 0.0
	var gained=minf(max_health-health,amount)
	health+=gained
	return gained
func use_stamina(amount: float) -> bool:
	if amount<=0.0 or stamina<amount: return false
	stamina-=amount
	return true
func restore_stamina(amount: float) -> float:
	if amount<=0.0: return 0.0
	var gained=minf(max_stamina-stamina,amount)
	stamina+=gained
	return gained
func is_alive() -> bool:
	return health>0.0