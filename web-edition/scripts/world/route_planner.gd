extends RefCounted
class_name GhibliRoutePlanner


var _nodes: Dictionary = {}
var _adjacency: Dictionary = {}
var _edge_ids: Dictionary = {}
var _blocked_edge_ids: Dictionary = {}


func configure(graph: Dictionary) -> bool:
	_nodes.clear()
	_adjacency.clear()
	_edge_ids.clear()
	_blocked_edge_ids.clear()
	var graph_nodes: Array = graph.get("nodes", [])
	var graph_edges: Array = graph.get("edges", [])
	if graph_nodes.size() < 2 or graph_edges.is_empty():
		return false

	for entry in graph_nodes:
		if not entry is Dictionary:
			return false
		var node_id := str(entry.get("id", ""))
		if node_id.is_empty() or _nodes.has(node_id):
			return false
		if not entry.has("position") or not entry.get("position") is Vector3:
			return false
		_nodes[node_id] = entry.duplicate(true)
		_adjacency[node_id] = []

	for edge in graph_edges:
		if not edge is Dictionary:
			return false
		var edge_id := str(edge.get("id", ""))
		var from_id := str(edge.get("from", ""))
		var to_id := str(edge.get("to", ""))
		if edge_id.is_empty() or _edge_ids.has(edge_id) or not _nodes.has(from_id) or not _nodes.has(to_id):
			return false
		if from_id == to_id:
			return false
		var from_position: Vector3 = _nodes[from_id]["position"]
		var to_position: Vector3 = _nodes[to_id]["position"]
		var edge_cost := float(edge.get("cost", from_position.distance_to(to_position)))
		if edge_cost <= 0.0:
			return false
		var direction := str(edge.get("direction", "both"))
		if not ["both", "forward", "reverse"].has(direction):
			return false
		_edge_ids[edge_id] = true
		if bool(edge.get("blocked", false)):
			_blocked_edge_ids[edge_id] = true
		if direction == "both" or direction == "forward":
			_adjacency[from_id].append({"to": to_id, "edge_id": edge_id, "cost": edge_cost})
		if direction == "both" or direction == "reverse":
			_adjacency[to_id].append({"to": from_id, "edge_id": edge_id, "cost": edge_cost})

	return true


func find_route(
	start_position: Vector3,
	destination_position: Vector3,
	max_snap_distance: float = 36.0
) -> Dictionary:
	if _nodes.is_empty() or max_snap_distance <= 0.0:
		return _unreachable("Road graph is not configured.")

	var start_id := _find_nearest_node(start_position, max_snap_distance)
	var destination_id := _find_nearest_node(destination_position, max_snap_distance)
	if start_id.is_empty() or destination_id.is_empty():
		return _unreachable("Start or destination is too far from the road graph.")

	var open_set: Dictionary = {start_id: true}
	var closed_set: Dictionary = {}
	var came_from: Dictionary = {}
	var came_from_edge: Dictionary = {}
	var path_costs: Dictionary = {start_id: 0.0}
	var found := false

	while not open_set.is_empty():
		var current_id := _lowest_estimated_node(open_set, path_costs, destination_id)
		if current_id.is_empty():
			break
		if current_id == destination_id:
			found = true
			break

		open_set.erase(current_id)
		closed_set[current_id] = true
		for connection in _adjacency.get(current_id, []):
			var edge_id := str(connection.get("edge_id", ""))
			if _blocked_edge_ids.has(edge_id):
				continue
			var next_id := str(connection.get("to", ""))
			if closed_set.has(next_id):
				continue
			var tentative_cost := float(path_costs[current_id]) + float(connection.get("cost", 0.0))
			if tentative_cost >= float(path_costs.get(next_id, INF)):
				continue
			came_from[next_id] = current_id
			came_from_edge[next_id] = str(connection.get("edge_id", ""))
			path_costs[next_id] = tentative_cost
			open_set[next_id] = true

	if not found:
		return _unreachable("No connected road path reaches this destination.")

	var reversed_nodes: Array[String] = [destination_id]
	var cursor := destination_id
	while cursor != start_id:
		if not came_from.has(cursor):
			return _unreachable("The route reconstruction was incomplete.")
		cursor = str(came_from[cursor])
		reversed_nodes.append(cursor)
	reversed_nodes.reverse()

	var route_path: Array[Vector3] = []
	_append_distinct(route_path, start_position)
	for node_id in reversed_nodes:
		var node_position: Vector3 = _nodes[node_id]["position"]
		_append_distinct(route_path, node_position)
	_append_distinct(route_path, destination_position)

	var route_distance := 0.0
	for index in range(1, route_path.size()):
		route_distance += route_path[index - 1].distance_to(route_path[index])

	var route_edges: Array[String] = []
	for index in range(1, reversed_nodes.size()):
		route_edges.append(str(came_from_edge[reversed_nodes[index]]))
	var maneuvers := _build_maneuvers(route_path)

	return {
		"reachable": true,
		"reason": "",
		"distance": route_distance,
		"path": route_path,
		"node_ids": reversed_nodes,
		"edge_ids": route_edges,
		"maneuvers": maneuvers,
		"start_node_id": start_id,
		"destination_node_id": destination_id
	}


func get_node_count() -> int:
	return _nodes.size()


func get_edge_count() -> int:
	return _edge_ids.size()


func get_blocked_edge_count() -> int:
	return _blocked_edge_ids.size()


func set_edge_blocked(edge_id: String, blocked: bool) -> bool:
	if not _edge_ids.has(edge_id):
		return false
	if blocked:
		_blocked_edge_ids[edge_id] = true
	else:
		_blocked_edge_ids.erase(edge_id)
	return true


func _build_maneuvers(path: Array[Vector3]) -> Array[Dictionary]:
	var maneuvers: Array[Dictionary] = []
	for index in range(1, path.size() - 1):
		var previous_position: Vector3 = path[index - 1]
		var turn_position: Vector3 = path[index]
		var next_position: Vector3 = path[index + 1]
		var incoming := Vector2(
			turn_position.x - previous_position.x,
			turn_position.z - previous_position.z
		)
		var outgoing := Vector2(
			next_position.x - turn_position.x,
			next_position.z - turn_position.z
		)
		if incoming.length_squared() < 0.01 or outgoing.length_squared() < 0.01:
			continue
		var signed_angle := rad_to_deg(incoming.normalized().angle_to(outgoing.normalized()))
		var absolute_angle := absf(signed_angle)
		if absolute_angle < 35.0 or absolute_angle > 150.0:
			continue
		var turn_kind := "right" if signed_angle > 0.0 else "left"
		maneuvers.append({
			"kind": turn_kind,
			"instruction": "Turn " + turn_kind,
			"position": turn_position,
			"path_index": index,
			"angle_degrees": signed_angle
		})
	return maneuvers


func _find_nearest_node(position: Vector3, max_distance: float) -> String:
	var nearest_id := ""
	var nearest_distance := max_distance
	for node_id in _nodes:
		var node_position: Vector3 = _nodes[node_id]["position"]
		var distance := position.distance_to(node_position)
		if distance <= nearest_distance:
			nearest_distance = distance
			nearest_id = str(node_id)
	return nearest_id


func _lowest_estimated_node(
	open_set: Dictionary,
	path_costs: Dictionary,
	destination_id: String
) -> String:
	var best_id := ""
	var best_score := INF
	var destination_position: Vector3 = _nodes[destination_id]["position"]
	for node_id in open_set:
		var node_position: Vector3 = _nodes[node_id]["position"]
		var score := float(path_costs.get(node_id, INF)) + node_position.distance_to(destination_position)
		if score < best_score:
			best_score = score
			best_id = str(node_id)
	return best_id


func _append_distinct(path: Array[Vector3], position: Vector3) -> void:
	if path.is_empty() or path[path.size() - 1].distance_to(position) > 0.01:
		path.append(position)


func _unreachable(reason: String) -> Dictionary:
	return {
		"reachable": false,
		"reason": reason,
		"distance": 0.0,
		"path": [],
		"node_ids": [],
		"edge_ids": [],
		"maneuvers": [],
		"start_node_id": "",
		"destination_node_id": ""
	}
