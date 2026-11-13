extends Node3D

## Main scene bootstrap. Gameplay components live in their own files.

const PLAYER_SCENE: PackedScene = preload("res://scenes/player/player.tscn")
const MOBILE_CONTROLS_SCRIPT = preload("res://scripts/ui/mobile_controls.gd")


func _ready() -> void:
	_create_world()
	_create_player()
	_create_mobile_controls()


func _create_world() -> void:
	var world_environment := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_SKY
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.70, 0.78, 0.88)
	environment.ambient_light_energy = 0.85

	var sky := Sky.new()
	var sky_material := ProceduralSkyMaterial.new()
	sky_material.sky_top_color = Color(0.20, 0.34, 0.52)
	sky_material.sky_horizon_color = Color(0.70, 0.78, 0.86)
	sky_material.ground_bottom_color = Color(0.18, 0.22, 0.20)
	sky_material.ground_horizon_color = Color(0.58, 0.63, 0.60)
	sky.sky_material = sky_material
	environment.sky = sky
	world_environment.environment = environment
	add_child(world_environment)

	var sun := DirectionalLight3D.new()
	sun.name = "Sun"
	sun.rotation_degrees = Vector3(-48.0, -32.0, 0.0)
	sun.light_energy = 1.0
	sun.shadow_enabled = false
	add_child(sun)

	var ground := StaticBody3D.new()
	ground.name = "Ground"
	ground.collision_layer = 1
	ground.collision_mask = 1
	add_child(ground)

	var ground_mesh := MeshInstance3D.new()
	ground_mesh.name = "GroundVisual"
	var box_mesh := BoxMesh.new()
	box_mesh.size = Vector3(100.0, 1.0, 100.0)
	ground_mesh.mesh = box_mesh
	ground_mesh.position.y = -0.5
	var grass_material := StandardMaterial3D.new()
	grass_material.albedo_color = Color(0.32, 0.50, 0.32)
	grass_material.roughness = 1.0
	ground_mesh.material_override = grass_material
	ground.add_child(ground_mesh)

	var ground_collision := CollisionShape3D.new()
	ground_collision.name = "GroundCollision"
	var ground_shape := BoxShape3D.new()
	ground_shape.size = Vector3(100.0, 1.0, 100.0)
	ground_collision.shape = ground_shape
	ground_collision.position.y = -0.5
	ground.add_child(ground_collision)


func _create_player() -> void:
	var player: CharacterBody3D = PLAYER_SCENE.instantiate() as CharacterBody3D
	player.name = "Player"
	player.position = Vector3(0.0, 0.95, 0.0)
	add_child(player)


func _create_mobile_controls() -> void:
	var mobile_controls: CanvasLayer = MOBILE_CONTROLS_SCRIPT.new() as CanvasLayer
	mobile_controls.name = "MobileControls"
	add_child(mobile_controls)
