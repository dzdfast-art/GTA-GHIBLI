extends RefCounted
class_name GhibliHudState
var health: float=100.0
var money: int=0
var wanted: int=0
var clock_text: String="08:00"
var vehicle_mode: bool=false
func update_health(value: float) -> void:
	health=clampf(value,0.0,100.0)
func add_money(delta: int) -> int:
	money=maxi(0,money+delta)
	return money
func set_wanted(value: int) -> void:
	wanted=clampi(value,0,5)
func set_clock(hour: int, minute: int) -> bool:
	if hour<0 or hour>23 or minute<0 or minute>59: return false
	clock_text="%02d:%02d" % [hour,minute]
	return true
func snapshot() -> Dictionary:
	return {"health":health,"money":money,"wanted":wanted,"clock":clock_text,"vehicle_mode":vehicle_mode}