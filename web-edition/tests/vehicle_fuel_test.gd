extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var m=load("res://scripts/world/vehicle_fuel.gd").new()
		assert(absf(m.travel(10.0)-1.2)<0.01)
		assert(m.can_drive())
		m.travel(1000.0)
		assert(not m.can_drive())
		assert(m.refuel(10.0)>0.0 and m.can_drive())
	print("PASS: Vehicle Fuel and Consumption.")
	quit(0)
