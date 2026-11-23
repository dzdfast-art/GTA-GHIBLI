extends RefCounted
class_name GhibliVehicleFuel
var capacity: float=60.0
var fuel: float=60.0
var consumption_per_km: float=0.12
func configure(capacity_value: float, consumption: float) -> bool:
	if capacity_value<=0.0 or consumption<0.0: return false
	capacity=capacity_value
	fuel=clampf(fuel,0.0,capacity)
	consumption_per_km=consumption
	return true
func travel(distance_km: float) -> float:
	if distance_km<=0.0: return 0.0
	var used=minf(fuel,distance_km*consumption_per_km)
	fuel-=used
	return used
func refuel(amount: float) -> float:
	if amount<=0.0: return 0.0
	var added=minf(amount,capacity-fuel)
	fuel+=added
	return added
func can_drive() -> bool:
	return fuel>0.0