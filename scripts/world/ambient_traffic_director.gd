extends Node3D

const TRAFFIC_CAR_SCRIPT = preload("res://scripts/world/ambient_traffic_car.gd")

@export_range(2, 12, 1) var vehicle_count := 4


func _ready() -> void:
	_build_village_traffic()


func get_traffic_vehicle_count() -> int:
	return get_tree().get_nodes_in_group("ambient_traffic_vehicles").size()


func _build_village_traffic() -> void:
	var horizontal_start := Vector3(-21.0, 0.0, 0.0)
	var horizontal_end := Vector3(21.0, 0.0, 0.0)
	var vertical_start := Vector3(0.0, 0.0, -21.0)
	var vertical_end := Vector3(0.0, 0.0, 21.0)
	var paint_colors := [
		Color(0.13, 0.28, 0.52),
		Color(0.78, 0.78, 0.72),
		Color(0.55, 0.20, 0.16),
		Color(0.22, 0.25, 0.28)
	]
	var definitions := [
		{"start": horizontal_start, "end": horizontal_end, "lane": Vector3(0.0, 0.0, -0.82), "speed": 3.1, "distance": 5.0, "reverse": false},
		{"start": horizontal_start, "end": horizontal_end, "lane": Vector3(0.0, 0.0, 0.82), "speed": 2.8, "distance": 26.0, "reverse": true},
		{"start": vertical_start, "end": vertical_end, "lane": Vector3(-0.82, 0.0, 0.0), "speed": 2.9, "distance": 9.0, "reverse": false},
		{"start": vertical_start, "end": vertical_end, "lane": Vector3(0.82, 0.0, 0.0), "speed": 3.0, "distance": 29.0, "reverse": true}
	]
	for index in range(mini(vehicle_count, definitions.size())):
		var data: Dictionary = definitions[index]
		var vehicle := Node3D.new()
		vehicle.name = "AmbientTraffic_%02d" % (index + 1)
		vehicle.set_script(TRAFFIC_CAR_SCRIPT)
		vehicle.set("paint_color", paint_colors[index % paint_colors.size()])
		vehicle.call("configure", data.start, data.end, data.speed,
			data.lane, data.distance, data.reverse)
		add_child(vehicle)
