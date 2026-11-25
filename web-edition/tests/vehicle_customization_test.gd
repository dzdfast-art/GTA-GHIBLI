extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var m=load("res://scripts/world/vehicle_customization.gd").new()
	m.set_paint(Color.RED)
	assert(m.set_wheel_style("sport") and not m.set_wheel_style("unknown"))
	assert(m.set_plate("GH-123") and not m.set_plate(""))
	assert(m.snapshot().wheel_style=="sport")
	print("PASS: Vehicle Customization Paint.")
	quit(0)
