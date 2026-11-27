extends RefCounted
class_name GhibliRoutePlanner


var _nodes: Dictionary = {}
var _adjacency: Dictionary = {}
var _edge_ids: Dictionary = {}
var _blocked_edge_ids: Dictionary = {}
var _turn_restrictions: Dictionary = {}


func configure(graph: Dictionary) -> bool:
	_nodes.clear()
	_adjacency.clear()
	_edge_ids.clear()
	_blocked_edge_ids.clear()
	_turn_restrictions.clear()
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

	for restriction in graph.get("turn_restrictions", []):
		if not restriction is Dictionary:
			return false
		var via_id := str(restriction.get("via", ""))
		var from_edge_id := str(restriction.get("from_edge", ""))
		var to_edge_id := str(restriction.get("to_edge", ""))
		var restriction_type := str(restriction.get("type", "no"))
		if not _nodes.has(via_id) or not _edge_ids.has(from_edge_id) or not _edge_ids.has(to_edge_id):
			return false
		if from_edge_id == to_edge_id or not ["no", "only"].has(restriction_type):
			return false
		if not _edge_connects_to(from_edge_id, via_id) or not _edge_leaves_from(to_edge_id, via_id):
			return false
		var restriction_key := _turn_key(via_id, from_edge_id)
		if not _turn_restrictions.has(restriction_key):
			_turn_restrictions[restriction_key] = {"no": {}, "only": {}}
		_turn_restrictions[restriction_key][restriction_type][to_edge_id] = true

	return true


func find_route(
	start_position: Vector3,
	destination_position: Vector3,
	max_snap_distance: float = 36.0
) -> Dictionary:
	if _nodes.is_empty() or max_snap_distance <= 0.0:
		return _unreachable("Road graph is not configured.")

	var start_id := _find_nearest_node(start_position, max_snap_distance, true)
	var destination_id := _find_nearest_node(destination_position, max_snap_distance, false)
	if start_id.is_empty() or destination_id.is_empty():
		return _unreachable("Start or destination is too far from the road graph.")

	# The incoming edge is part of the search state: legal exits depend on
	# how the vehicle entered a junction, not only on the junction node.
	var start_state := _state_key(start_id, "")
	var open_set: Dictionary = {start_state: true}
	var closed_set: Dictionary = {}
	var state_nodes: Dictionary = {start_state: start_id}
	var state_incoming_edges: Dictionary = {start_state: ""}
	var came_from: Dictionary = {}
	var path_costs: Dictionary = {start_state: 0.0}
	var found_state := ""
	while not open_set.is_empty():
		var current_state := _lowest_estimated_state(open_set, path_costs, state_nodes, destination_id)
		if current_state.is_empty():
			break
		var current_id := str(state_nodes[current_state])
		if current_id == destination_id:
			found_state = current_state
			break

		open_set.erase(current_state)
		closed_set[current_state] = true
		var incoming_edge_id := str(state_incoming_edges[current_state])
		for connection in _adjacency.get(current_id, []):
			var edge_id := str(connection.get("edge_id", ""))
			if _blocked_edge_ids.has(edge_id) or not _is_turn_allowed(current_id, incoming_edge_id, edge_id):
				continue
			var next_id := str(connection.get("to", ""))
			var next_state := _state_key(next_id, edge_id)
			if closed_set.has(next_state):
				continue
			var tentative_cost := float(path_costs[current_state]) + float(connection.get("cost", 0.0))
			if tentative_cost >= float(path_costs.get(next_state, INF)):
				continue
			came_from[next_state] = current_state
			path_costs[next_state] = tentative_cost
			state_nodes[next_state] = next_id
			state_incoming_edges[next_state] = edge_id
			open_set[next_state] = true

	if found_state.is_empty():
		return _unreachable("No connected road path reaches this destination under the active turn restrictions.")

	var reversed_states: Array[String] = [found_state]
	var cursor := found_state
	while cursor != start_state:
		if not came_from.has(cursor):
			return _unreachable("The route reconstruction was incomplete.")
		cursor = str(came_from[cursor])
		reversed_states.append(cursor)
	reversed_states.reverse()

	var reversed_nodes: Array[String] = []
	var route_edges: Array[String] = []
	for index in range(reversed_states.size()):
		var state := reversed_states[index]
		reversed_nodes.append(str(state_nodes[state]))
		if index > 0:
			route_edges.append(str(state_incoming_edges[state]))

	var route_path: Array[Vector3] = []
	_append_distinct(route_path, start_position)
	for node_id in reversed_nodes:
		var node_position: Vector3 = _nodes[node_id]["position"]
		_append_distinct(route_path, node_position)
	_append_distinct(route_path, destination_position)

	var route_distance := 0.0
	for index in range(1, route_path.size()):
		route_distance += route_path[index - 1].distance_to(route_path[index])

	return {
		"reachable": true,
		"reason": "",
		"distance": route_distance,
		"path": route_path,
		"node_ids": reversed_nodes,
		"edge_ids": route_edges,
		"maneuvers": _build_maneuvers(route_path),
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


func _is_turn_allowed(via_id: String, incoming_edge_id: String, outgoing_edge_id: String) -> bool:
	if incoming_edge_id.is_empty():
		return true
	var restriction_key := _turn_key(via_id, incoming_edge_id)
	if not _turn_restrictions.has(restriction_key):
		return true
	var rules: Dictionary = _turn_restrictions[restriction_key]
	var only_rules: Dictionary = rules.get("only", {})
	if not only_rules.is_empty() and not only_rules.has(outgoing_edge_id):
		return false
	return not rules.get("no", {}).has(outgoing_edge_id)


func _edge_connects_to(edge_id: String, node_id: String) -> bool:
	for connections in _adjacency.values():
		for connection in connections:
			if str(connection.get("edge_id", "")) == edge_id and str(connection.get("to", "")) == node_id:
				return true
	return false


func _edge_leaves_from(edge_id: String, node_id: String) -> bool:
	for connection in _adjacency.get(node_id, []):
		if str(connection.get("edge_id", "")) == edge_id:
			return true
	return false


func _turn_key(via_id: String, incoming_edge_id: String) -> String:
	return via_id + "\u001f" + incoming_edge_id


func _state_key(node_id: String, incoming_edge_id: String) -> String:
	return node_id + "\u001f" + incoming_edge_id


func _build_maneuvers(path: Array[Vector3]) -> Array[Dictionary]:
	var maneuvers: Array[Dictionary] = []
	for index in range(1, path.size() - 1):
		var previous_position: Vector3 = path[index - 1]
		var turn_position: Vector3 = path[index]
		var next_position: Vector3 = path[index + 1]
		var incoming := Vector2(turn_position.x - previous_position.x, turn_position.z - previous_position.z)
		var outgoing := Vector2(next_position.x - turn_position.x, next_position.z - turn_position.z)
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


func _find_nearest_node(position: Vector3, max_distance: float, road_nodes_only: bool = false) -> String:
	var nearest_id := ""
	var nearest_distance := max_distance
	for node_id in _nodes:
		var node: Dictionary = _nodes[node_id]
		if road_nodes_only and str(node.get("kind", "")) == "poi":
			continue
		var node_position: Vector3 = node["position"]
		var distance := position.distance_to(node_position)
		if distance <= nearest_distance:
			nearest_distance = distance
			nearest_id = str(node_id)
	return nearest_id


func _lowest_estimated_state(
	open_set: Dictionary,
	path_costs: Dictionary,
	state_nodes: Dictionary,
	destination_id: String
) -> String:
	var best_state := ""
	var best_score := INF
	var destination_position: Vector3 = _nodes[destination_id]["position"]
	for state in open_set:
		var node_position: Vector3 = _nodes[str(state_nodes[state])]["position"]
		var score := float(path_costs.get(state, INF)) + node_position.distance_to(destination_position)
		if score < best_score:
			best_score = score
			best_state = str(state)
	return best_state


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
