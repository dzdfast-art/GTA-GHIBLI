extends Node3D

const PLAYER_SCENE: PackedScene = preload("res://scenes/player/player.tscn")
const VILLAGE_SCENE: PackedScene = preload("res://scenes/world/willow_village.tscn")
const STARTER_CAR_SCENE: PackedScene = preload("res://scenes/vehicles/starter_car.tscn")
const MOBILE_CONTROLS_SCRIPT = preload("res://scripts/ui/mobile_controls.gd")
const MISSION_MANAGER_SCRIPT = preload("res://scripts/missions/mission_manager.gd")
const MISSION_002_RUNTIME_SCRIPT = preload("res://scripts/missions/mission_002_runtime.gd")
const CINEMATIC_DIRECTOR_SCRIPT = preload("res://scripts/missions/cinematic_director.gd")
const AMBIENCE_SCRIPT = preload("res://scripts/audio/nature_ambience.gd")

func _ready() -> void:
	_create_world()
	_create_village()
	_create_player()
	_create_starter_car()
	_create_mobile_controls()
	_create_mission_manager()
	_create_mission_002_runtime()
	_create_story_cinematic()
	_create_nature_ambience()

func _create_world() -> void:
	var world_environment := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_SKY
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	environment.ambient_light_color = Color(0.78, 0.84, 0.92)
	environment.ambient_light_energy = 0.82
	environment.ambient_light_sky_contribution = 0.72
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.adjustment_enabled = true
	environment.adjustment_brightness = 1.04
	environment.adjustment_contrast = 1.08
	environment.adjustment_saturation = 1.12
	environment.fog_enabled = true
	environment.fog_light_color = Color(0.70, 0.79, 0.82)
	environment.fog_density = 0.0025
	environment.fog_sun_scatter = 0.12
	var sky := Sky.new()
	var sky_material := ProceduralSkyMaterial.new()
	sky_material.sky_top_color = Color(0.20, 0.34, 0.52)
	sky_material.sky_horizon_color = Color(0.70, 0.78, 0.86)
	sky_material.ground_bottom_color = Color(0.18, 0.22, 0.20)
	sky_material.ground_horizon_color = Color(0.58, 0.63, 0.60)
	sky.sky_material = sky_material
	environment.sky = sky
	environment.glow_enabled = true
	environment.glow_intensity = 0.28
	environment.glow_strength = 0.35
	world_environment.environment = environment
	add_child(world_environment)
	var sun := DirectionalLight3D.new()
	sun.name = "Sun"
	sun.rotation_degrees = Vector3(-48.0, -32.0, 0.0)
	sun.light_energy = 1.0
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 55.0
	sun.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_2_SPLITS
	sun.shadow_bias = 0.06
	sun.shadow_normal_bias = 1.2
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

func _create_village() -> void:
	var village: Node3D = VILLAGE_SCENE.instantiate() as Node3D
	village.name = "WillowVillage"
	add_child(village)

func _create_player() -> void:
	var player: CharacterBody3D = PLAYER_SCENE.instantiate() as CharacterBody3D
	player.name = "Player"
	player.add_to_group("player")
	player.position = Vector3(0.0, 0.95, -18.0)
	player.rotation.y = PI
	add_child(player)

func _create_starter_car() -> void:
	var car: CharacterBody3D = STARTER_CAR_SCENE.instantiate() as CharacterBody3D
	car.name = "StarterCar"
	car.position = Vector3(2.4, 0.0, -18.0)
	add_child(car)

func _create_mobile_controls() -> void:
	var mobile_controls: CanvasLayer = MOBILE_CONTROLS_SCRIPT.new() as CanvasLayer
	mobile_controls.name = "MobileControls"
	add_child(mobile_controls)

func _create_mission_manager() -> void:
	var player := get_node_or_null("Player") as Node3D
	var mira := get_node_or_null("WillowVillage/MiraCaretaker")
	var mission_manager: CanvasLayer = MISSION_MANAGER_SCRIPT.new() as CanvasLayer
	mission_manager.name = "MissionManager"
	add_child(mission_manager)
	mission_manager.setup(player, mira)

func _create_nature_ambience() -> void:
	var ambience: Node = AMBIENCE_SCRIPT.new()
	ambience.name = "NatureAmbience"
	ambience.set("biome", "village")
	add_child(ambience)

func _create_mission_002_runtime() -> void:
	var player := get_node_or_null("Player") as CharacterBody3D
	var vehicle := get_node_or_null("StarterCar") as CharacterBody3D
	var mission_runtime: CanvasLayer = MISSION_002_RUNTIME_SCRIPT.new() as CanvasLayer
	mission_runtime.name = "Mission002Runtime"
	add_child(mission_runtime)
	mission_runtime.setup(player, vehicle)

func _create_story_cinematic() -> void:
	var cinematic: CanvasLayer = CINEMATIC_DIRECTOR_SCRIPT.new() as CanvasLayer
	cinematic.name = "StoryCinematic"
	add_child(cinematic)
