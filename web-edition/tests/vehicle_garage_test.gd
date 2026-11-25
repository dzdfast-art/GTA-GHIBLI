extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var m=load("res://scripts/world/vehicle_garage.gd").new()
	assert(m.store("car_1",{"class":"sedan"}))
	assert(m.retrieve("car_1").get("class")=="sedan")
	assert(m.count()==1 and m.remove("car_1") and m.count()==0)
	print("PASS: Vehicle Garage Registry.")
	quit(0)
