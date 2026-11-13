extends Node3D

# GTA GHIBLI - first playable foundation
const MOVE_SPEED := 6.0
const GRAVITY := 18.0

var player: CharacterBody3D
var move_up := false
var move_down := false
var move_left := false
var move_right := false

func _ready() -> void:
	_create_world()
	_create_player()
	_create_mobile_controls()

func _create_world() -> void:
	var ground := StaticBody3D.new()
	ground.name = "Ground"
	add_child(ground)

	var ground_mesh := MeshInstance3D.new()
	var plane := BoxMesh.new()
	plane.size = Vector3(100.0, 1.0, 100.0)
	ground_mesh.mesh = plane
	ground_mesh.position.y = -0.5
	var grass := StandardMaterial3D.new()
	grass.albedo_color = Color(0.32, 0.50, 0.32)
	ground_mesh.material_override = grass
	ground.add_child(ground_mesh)

	var ground_collision := CollisionShape3D.new()
	var ground_shape := BoxShape3D.new()
	ground_shape.size = Vector3(100.0, 1.0, 100.0)
	ground_collision.shape = ground_shape
	ground_collision.position.y = -0.5
	ground.add_child(ground_collision)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-50.0, -30.0, 0.0)
	sun.light_energy = 1.1
	add_child(sun)

	var world_environment := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_SKY
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.68, 0.76, 0.90)
	environment.ambient_light_energy = 0.8
	world_environment.environment = environment
	add_child(world_environment)

func _create_player() -> void:
	player = CharacterBody3D.new()
	player.name = "Player"
	player.position = Vector3(0.0, 1.2, 0.0)
	add_child(player)

	var body_mesh := MeshInstance3D.new()
	var capsule_mesh := CapsuleMesh.new()
	capsule_mesh.radius = 0.42
	capsule_mesh.height = 1.8
	body_mesh.mesh = capsule_mesh
	var body_material := StandardMaterial3D.new()
	body_material.albedo_color = Color(0.15, 0.32, 0.78)
	body_mesh.material_override = body_material
	player.add_child(body_mesh)

	var body_collision := CollisionShape3D.new()
	var capsule_shape := CapsuleShape3D.new()
	capsule_shape.radius = 0.42
	capsule_shape.height = 1.8
	body_collision.shape = capsule_shape
	player.add_child(body_collision)

	var camera_pivot := Node3D.new()
	camera_pivot.name = "CameraPivot"
	camera_pivot.position = Vector3(0.0, 1.8, 0.0)
	player.add_child(camera_pivot)

	var camera := Camera3D.new()
	camera.position = Vector3(0.0, 3.0, 7.0)
	camera.look_at_from_position(camera.position, Vector3(0.0, 0.0, 0.0), Vector3.UP)
	camera.current = true
	camera_pivot.add_child(camera)

func _create_mobile_controls() -> void:
	var layer := CanvasLayer.new()
	layer.name = "MobileControls"
	add_child(layer)

	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(root)

	var title := Label.new()
	title.text = "GTA GHIBLI  |  نموذج أولي"
	title.position = Vector2(20, 18)
	title.add_theme_font_size_override("font_size", 22)
	root.add_child(title)

	var hint := Label.new()
	hint.text = "استخدم الأزرار لتحريك الشخصية"
	hint.position = Vector2(20, 52)
	hint.add_theme_font_size_override("font_size", 16)
	root.add_child(hint)

	var pad := VBoxContainer.new()
	pad.position = Vector2(30, 0)
	pad.anchor_top = 1.0
	pad.anchor_bottom = 1.0
	pad.offset_top = -205
	pad.offset_bottom = -25
	pad.add_theme_constant_override("separation", 8)
	root.add_child(pad)

	var up_button := _make_control_button("▲")
	pad.add_child(up_button)
	_connect_hold(up_button, "up")

	var middle := HBoxContainer.new()
	middle.add_theme_constant_override("separation", 8)
	pad.add_child(middle)

	var left_button := _make_control_button("◀")
	middle.add_child(left_button)
	_connect_hold(left_button, "left")

	var down_button := _make_control_button("▼")
	middle.add_child(down_button)
	_connect_hold(down_button, "down")

	var right_button := _make_control_button("▶")
	middle.add_child(right_button)
	_connect_hold(right_button, "right")

func _make_control_button(caption: String) -> Button:
	var button := Button.new()
	button.text = caption
	button.custom_minimum_size = Vector2(64, 64)
	button.add_theme_font_size_override("font_size", 26)
	button.focus_mode = Control.FOCUS_NONE
	return button

func _connect_hold(button: Button, direction: String) -> void:
	match direction:
		"up":
			button.button_down.connect(func(): move_up = true)
			button.button_up.connect(func(): move_up = false)
		"down":
			button.button_down.connect(func(): move_down = true)
			button.button_up.connect(func(): move_down = false)
		"left":
			button.button_down.connect(func(): move_left = true)
			button.button_up.connect(func(): move_left = false)
		"right":
			button.button_down.connect(func(): move_right = true)
			button.button_up.connect(func(): move_right = false)

func _physics_process(delta: float) -> void:
	if player == null:
		return

	var keyboard := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var x_axis := keyboard.x + float(move_right) - float(move_left)
	var z_axis := keyboard.y + float(move_down) - float(move_up)
	var direction := Vector3(x_axis, 0.0, z_axis).normalized()

	player.velocity.x = direction.x * MOVE_SPEED
	player.velocity.z = direction.z * MOVE_SPEED

	if not player.is_on_floor():
		player.velocity.y -= GRAVITY * delta
	else:
		player.velocity.y = 0.0

	player.move_and_slide()
