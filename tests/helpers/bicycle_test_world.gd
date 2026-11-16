extends RefCounted

const PLAYER_SCENE: PackedScene = preload("res://scenes/player/player.tscn")
const BICYCLE_SCENE: PackedScene = preload("res://scenes/vehicles/starter_bicycle.tscn")
const MOBILE_CONTROLS_SCRIPT = preload("res://scripts/ui/mobile_controls.gd")

static func build(tree: SceneTree, with_wall: bool = false) -> Dictionary:
	var root := tree.root
	var floor_body := StaticBody3D.new()
	root.add_child(floor_body)
	var floor_collision := CollisionShape3D.new()
	var floor_shape := BoxShape3D.new()
	floor_shape.size = Vector3(80.0, 1.0, 120.0)
	floor_collision.shape = floor_shape
	floor_collision.position.y = -0.5
	floor_body.add_child(floor_collision)
	if with_wall:
		var wall := StaticBody3D.new()
		root.add_child(wall)
		var wall_collision := CollisionShape3D.new()
		var wall_shape := BoxShape3D.new()
		wall_shape.size = Vector3(10.0, 3.0, 1.0)
		wall_collision.shape = wall_shape
		wall.position = Vector3(0.0, 1.5, 6.0)
		wall.add_child(wall_collision)
	var player := PLAYER_SCENE.instantiate() as CharacterBody3D
	player.name = "Player"
	player.add_to_group("player")
	player.position = Vector3(0.0, 0.95, 0.0)
	root.add_child(player)
	var controls: CanvasLayer = MOBILE_CONTROLS_SCRIPT.new() as CanvasLayer
	root.add_child(controls)
	var bicycle := BICYCLE_SCENE.instantiate() as CharacterBody3D
	bicycle.position = Vector3(0.0, 0.0, 1.6)
	bicycle.rotation.y = PI
	root.add_child(bicycle)
	await tree.process_frame
	await tree.process_frame
	for _frame in range(4):
		await tree.physics_frame
	return {"player": player, "bicycle": bicycle, "controls": controls}

static func fail(tree: SceneTree, message: String) -> void:
	push_error("FAIL: " + message)
	tree.quit(1)
