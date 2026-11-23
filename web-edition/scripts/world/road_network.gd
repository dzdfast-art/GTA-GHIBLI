extends RefCounted
class_name GhibliRoadNetwork

const INFINITE_DISTANCE: float = 1.0e30

var _nodes: Dictionary = {}
var _edges: Dictionary = {}
var _adjacency: Dictionary = {}


func load_graph(data: Dictionary) -> bool:
	_nodes.clear()
	_edges.clear()
	_adjacency.clear()

	var raw_nodes: Variant = data.get("nodes", [])
	var raw_edges: Variant = data.get("edges", [])
	if typeof(raw_nodes) != TYPE_ARRAY or typeof(raw_edges) != TYPE_ARRAY:
		return false
	if raw_nodes.is_empty() or raw_edges.is_empty():
		return false

	for raw_node in raw_nodes:
		if typeof(raw_node) != TYPE_DICTIONARY:
			return _reject_graph()
		var node_data: Dictionary = raw_node
		var node_id := str(node_data.get("id", "")).strip_edges()
		var raw_position: Variant = node_data.get("position", null)
		if node_id.is_empty() or _nodes.has(node_id) or typeof(raw_position) != TYPE_ARRAY:
			return _reject_graph()
		var coordinates: Array = raw_position
		if coordinates.size() != 3:
			return _reject_graph()

		var position := Vector3(float(coordinates[0]), float(coordinates[1]), float(coordinates[2]))
		_nodes[node_id] = {
			"position": position,
			"name": str(node_data.get("name", node_id)),
			"region_id": str(node_data.get("region_id", ""))
		}
		_adjacency[node_id] = []

	for raw_edge in raw_edges:
		if typeof(raw_edge) != TYPE_DICTIONARY:
			return _reject_graph()
		var edge_data: Dictionary = raw_edge
		var edge_id := str(edge_data.get("id", "")).strip_edges()
		var from_id := str(edge_data.get("from", ""))
		var to_id := str(edge_data.get("to", ""))
		if edge_id.is_empty() or _edges.has(edge_id) or from_id == to_id:
			return _reject_graph()
		if not _nodes.has(from_id) or not _nodes.has(to_id):
			return _reject_graph()

		var from_position: Vector3 = _nodes[from_id]["position"]
		var to_position: Vector3 = _nodes[to_id]["position"]
		var segment_length := Vector2(to_position.x - from_position.x, to_position.z - from_position.z).length()
		if segment_length <= 0.01:
			return _reject_graph()

		var one_way := bool(edge_data.get("one_way", false))
		_edges[edge_id] = {
			"from": from_id,
			"to": to_id,
			"length": segment_length,
			"width": maxf(float(edge_data.get("width", 6.0)), 1.0),
			"road_type": str(edge_data.get("road_type", "local")),
			"one_way": one_way
		}
		_adjacency[from_id].append({"to": to_id, "edge_id": edge_id, "length": segment_length})
		if not one_way:
			_adjacency[to_id].append({"to": from_id, "edge_id": edge_id, "length": segment_length})

	return true


func get_node_count() -> int:
	return _nodes.size()


func get_edge_count() -> int:
	return _edges.size()


func get_segments() -> Array:
	var segments: Array = []
	for edge_variant in _edges.keys():
		var edge_id := str(edge_variant)
		var edge: Dictionary = _edges[edge_id]
		var from_node: Dictionary = _nodes[str(edge["from"])]
		var to_node: Dictionary = _nodes[str(edge["to"])]
		segments.append({
			"id": edge_id,
			"from_position": from_node["position"],
			"to_position": to_node["position"],
			"width": float(edge["width"]),
			"road_type": str(edge["road_type"])
		})
	return segments


func find_route(start_position: Vector3, destination_position: Vector3, blocked_edge_ids: Array = []) -> Dictionary:
	if _nodes.is_empty():
		return _empty_route("invalid_graph")

	var start_node_id := _nearest_node_id(start_position)
	var goal_node_id := _nearest_node_id(destination_position)
	if start_node_id.is_empty() or goal_node_id.is_empty():
		return _empty_route("invalid_graph")

	if start_node_id == goal_node_id:
		var direct_points := PackedVector3Array()
		direct_points.append(start_position)
		if start_position.distance_to(destination_position) > 0.05:
			direct_points.append(destination_position)
		return {
			"status": "ok",
			"start_node": start_node_id,
			"goal_node": goal_node_id,
			"node_ids": [start_node_id],
			"edge_ids": [],
			"points": direct_points,
			"distance": start_position.distance_to(destination_position)
		}

	var distances: Dictionary = {}
	var previous_nodes: Dictionary = {}
	var previous_edges: Dictionary = {}
	var remaining: Dictionary = {}
	for node_variant in _nodes.keys():
		var node_id := str(node_variant)
		distances[node_id] = INFINITE_DISTANCE
		remaining[node_id] = true
	distances[start_node_id] = 0.0

	while not remaining.is_empty():
		var current_node_id := ""
		var current_distance := INFINITE_DISTANCE
		for candidate_variant in remaining.keys():
			var candidate_id := str(candidate_variant)
			var candidate_distance := float(distances[candidate_id])
			if candidate_distance < current_distance:
				current_distance = candidate_distance
				current_node_id = candidate_id

		if current_node_id.is_empty() or current_distance >= INFINITE_DISTANCE:
			break
		remaining.erase(current_node_id)
		if current_node_id == goal_node_id:
			break

		var links: Array = _adjacency.get(current_node_id, [])
		for link_variant in links:
			var link: Dictionary = link_variant
			var edge_id := str(link.get("edge_id", ""))
			if blocked_edge_ids.has(edge_id):
				continue
			var next_node_id := str(link.get("to", ""))
			if not remaining.has(next_node_id):
				continue
			var candidate_total := current_distance + float(link.get("length", 0.0))
			if candidate_total < float(distances[next_node_id]):
				distances[next_node_id] = candidate_total
				previous_nodes[next_node_id] = current_node_id
				previous_edges[next_node_id] = edge_id

	if float(distances.get(goal_node_id, INFINITE_DISTANCE)) >= INFINITE_DISTANCE:
		return _empty_route("unreachable")

	var node_path: Array[String] = []
	var cursor := goal_node_id
	while not cursor.is_empty():
		node_path.push_front(cursor)
		if cursor == start_node_id:
			break
		cursor = str(previous_nodes.get(cursor, ""))
	if node_path.is_empty() or node_path[0] != start_node_id:
		return _empty_route("unreachable")

	var edge_path: Array[String] = []
	for path_index in range(1, node_path.size()):
		edge_path.append(str(previous_edges.get(node_path[path_index], "")))

	var route_points := PackedVector3Array()
	route_points.append(start_position)
	for node_id in node_path:
		var node_position: Vector3 = _nodes[node_id]["position"]
		if route_points[route_points.size() - 1].distance_to(node_position) > 0.05:
			route_points.append(node_position)
	if route_points[route_points.size() - 1].distance_to(destination_position) > 0.05:
		route_points.append(destination_position)

	var start_node_position: Vector3 = _nodes[start_node_id]["position"]
	var goal_node_position: Vector3 = _nodes[goal_node_id]["position"]
	var total_distance := float(distances[goal_node_id])
	total_distance += start_position.distance_to(start_node_position)
	total_distance += goal_node_position.distance_to(destination_position)

	return {
		"status": "ok",
		"start_node": start_node_id,
		"goal_node": goal_node_id,
		"node_ids": node_path,
		"edge_ids": edge_path,
		"points": route_points,
		"distance": total_distance
	}


func _nearest_node_id(position: Vector3) -> String:
	var nearest_id := ""
	var nearest_distance := INFINITE_DISTANCE
	for node_variant in _nodes.keys():
		var node_id := str(node_variant)
		var node_position: Vector3 = _nodes[node_id]["position"]
		var distance := Vector2(node_position.x - position.x, node_position.z - position.z).length()
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_id = node_id
	return nearest_id


func _empty_route(status: String) -> Dictionary:
	return {
		"status": status,
		"start_node": "",
		"goal_node": "",
		"node_ids": [],
		"edge_ids": [],
		"points": PackedVector3Array(),
		"distance": 0.0
	}


func _reject_graph() -> bool:
	_nodes.clear()
	_edges.clear()
	_adjacency.clear()
	return false
