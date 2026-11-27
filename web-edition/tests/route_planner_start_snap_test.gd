extends SceneTree


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var planner: RefCounted = load("res://scripts/world/route_planner.gd").new()
	var graph := {
		"nodes": [
			{"id": "road_a", "position": Vector3(0.0, 0.0, 0.0), "kind": "road"},
			{"id": "road_b", "position": Vector3(10.0, 0.0, 0.0), "kind": "road"},
			{"id": "poi_near_start", "position": Vector3(1.0, 0.0, 0.0), "kind": "poi"},
			{"id": "poi_destination", "position": Vector3(11.0, 0.0, 0.0), "kind": "poi"}
		],
		"edges": [
			{"id": "road_ab", "from": "road_a", "to": "road_b", "cost": 10.0},
			{"id": "access_start", "from": "road_a", "to": "poi_near_start", "cost": 1.0},
			{"id": "access_destination", "from": "road_b", "to": "poi_destination", "cost": 1.0}
		]
	}
	assert(planner.call("configure", graph))
	var route: Dictionary = planner.call(
		"find_route",
		Vector3(1.0, 0.0, 0.0),
		Vector3(11.0, 0.0, 0.0),
		20.0
	)
	assert(bool(route.get("reachable", false)))
	assert(str(route.get("start_node_id", "")) == "road_a")
	assert(str(route.get("destination_node_id", "")) == "poi_destination")
	assert(route.get("node_ids", []).has("road_b"))
	print("PASS: player GPS snapping prefers road nodes while destination snapping can still select a nearby POI.")
	quit(0)
