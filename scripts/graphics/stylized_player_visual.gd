extends MeshInstance3D

## Procedural, original third-person character art for the Android prototype.
## The parent Visual node remains the visibility switch used by vehicle enter/exit.

var _arm_pivots: Array[Node3D] = []
var _leg_pivots: Array[Node3D] = []
var _walk_clock := 0.0
var _attack_remaining := 0.0


func _ready() -> void:
	mesh = null
	# The gameplay capsule is centered on the player origin; align the model feet
	# with the capsule bottom instead of placing the model above the collision.
	position.y = -0.9
	_build_character()


func _process(delta: float) -> void:
	var player := get_parent() as CharacterBody3D
	if player == null:
		return
	_walk_clock += delta
	var speed := Vector2(player.velocity.x, player.velocity.z).length()
	var swing := sin(_walk_clock * 9.0) * clampf(speed / 3.2, 0.0, 1.0) * 0.42
	if Input.is_action_just_pressed("attack"):
		_attack_remaining = 0.26
	if _attack_remaining > 0.0:
		_attack_remaining = maxf(0.0, _attack_remaining - delta)
	if _arm_pivots.size() == 2:
		_arm_pivots[0].rotation.x = swing
		_arm_pivots[1].rotation.x = lerpf(-swing, 1.18, clampf(_attack_remaining / 0.26, 0.0, 1.0)) if _attack_remaining > 0.0 else -swing
	if _leg_pivots.size() == 2:
		_leg_pivots[0].rotation.x = -swing * 0.82
		_leg_pivots[1].rotation.x = swing * 0.82


func _build_character() -> void:
	var hoodie := Color(0.055, 0.065, 0.085)
	var hoodie_light := Color(0.12, 0.14, 0.17)
	var pants := Color(0.12, 0.16, 0.22)
	var skin := Color(0.78, 0.56, 0.40)
	var hair := Color(0.055, 0.045, 0.04)
	var white := Color(0.92, 0.93, 0.88)
	var red := Color(0.82, 0.075, 0.065)

	_add_capsule(self, "HoodieBody", 0.35, 0.92, Vector3(0.0, 1.05, 0.0), hoodie)
	_add_box(self, "HoodiePocket", Vector3(0.43, 0.13, 0.025),
		Vector3(0.0, 0.82, -0.337), hoodie_light)
	_add_box(self, "HoodieSeam", Vector3(0.025, 0.52, 0.025),
		Vector3(0.0, 1.08, -0.35), Color(0.22, 0.23, 0.25))

	_add_sphere(self, "Neck", 0.105, Vector3(0.0, 1.52, 0.0), skin)
	_add_sphere(self, "Head", 0.235, Vector3(0.0, 1.66, -0.01), skin)
	_add_sphere(self, "HairCap", 0.245, Vector3(0.0, 1.78, 0.025), hair,
		Vector3(1.04, 0.70, 1.05))
	_add_sphere(self, "HairBack", 0.19, Vector3(0.0, 1.62, 0.16), hair,
		Vector3(1.0, 0.92, 0.60))
	for index in range(5):
		var x := -0.18 + float(index) * 0.09
		var tuft := SphereMesh.new()
		tuft.radius = 0.095
		tuft.height = 0.19
		_add_mesh(self, "HairTuft_%02d" % index, tuft,
			Vector3(x, 1.91 + float(index % 2) * 0.035, 0.035), hair)

	# Small face details face the character's forward (-Z) direction.
	_add_sphere(self, "Eye_L", 0.022, Vector3(-0.078, 1.68, -0.218), Color(0.08, 0.06, 0.05))
	_add_sphere(self, "Eye_R", 0.022, Vector3(0.078, 1.68, -0.218), Color(0.08, 0.06, 0.05))
	_add_box(self, "Mouth", Vector3(0.065, 0.018, 0.018),
		Vector3(0.0, 1.57, -0.235), Color(0.34, 0.12, 0.10))

	_add_sphere(self, "Hood", 0.245, Vector3(0.0, 1.48, 0.20), hoodie_light,
		Vector3(1.18, 1.0, 0.62))

	# Layered fabric seams, zipper and cuffs give the hoodie a more finished silhouette.
	_add_box(self, "HoodieChestSeam", Vector3(0.025, 0.55, 0.018),
		Vector3(0.0, 1.10, -0.356), Color(0.25, 0.27, 0.29))
	_add_box(self, "HoodieLeftCuff", Vector3(0.26, 0.12, 0.22),
		Vector3(-0.43, 0.91, 0.0), hoodie_light)
	_add_box(self, "HoodieRightCuff", Vector3(0.26, 0.12, 0.22),
		Vector3(0.43, 0.91, 0.0), hoodie_light)
	_add_box(self, "HoodieLeftPocket", Vector3(0.19, 0.23, 0.035),
		Vector3(-0.25, 1.17, -0.348), hoodie_light)
	_add_box(self, "HoodieRightPocket", Vector3(0.19, 0.23, 0.035),
		Vector3(0.25, 1.17, -0.348), hoodie_light)
	_add_box(self, "TrouserLeftPocket", Vector3(0.20, 0.34, 0.045),
		Vector3(-0.29, 0.42, -0.18), Color(0.18, 0.22, 0.28))
	_add_box(self, "TrouserRightPocket", Vector3(0.20, 0.34, 0.045),
		Vector3(0.29, 0.42, -0.18), Color(0.18, 0.22, 0.28))
	_add_box(self, "HoodieShoulderStripeLeft", Vector3(0.20, 0.055, 0.28),
		Vector3(-0.32, 1.42, 0.0), hoodie_light)
	_add_box(self, "HoodieShoulderStripeRight", Vector3(0.20, 0.055, 0.28),
		Vector3(0.32, 1.42, 0.0), hoodie_light)


	var logo := Label3D.new()
	logo.name = "GhibliBackLogo"
	logo.text = "GTA\nGHIBLI"
	logo.position = Vector3(0.0, 1.13, 0.354)
	logo.font_size = 38
	logo.pixel_size = 0.0034
	logo.modulate = Color(1.0, 0.94, 0.78)
	logo.outline_size = 7
	logo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(logo)

	_add_leg(-1.0, pants, white, red)
	_add_leg(1.0, pants, white, red)
	_add_arm(-1.0, hoodie, skin)
	_add_arm(1.0, hoodie, skin)


func _add_leg(side: float, pants_color: Color, shoe_white: Color,
		shoe_red: Color) -> void:
	var pivot := Node3D.new()
	pivot.name = "LegPivot_Left" if side < 0.0 else "LegPivot_Right"
	pivot.position = Vector3(side * 0.18, 0.70, 0.0)
	add_child(pivot)
	_leg_pivots.append(pivot)
	_add_capsule(pivot, "TrouserLeg", 0.145, 0.76, Vector3(0.0, -0.34, 0.0), pants_color)
	_add_box(pivot, "SneakerSole", Vector3(0.40, 0.07, 0.54),
		Vector3(0.0, -0.61, -0.065), shoe_red)
	_add_box(pivot, "SneakerUpper", Vector3(0.38, 0.17, 0.51),
		Vector3(0.0, -0.51, -0.07), shoe_white)
	_add_box(pivot, "SneakerToeAccent", Vector3(0.25, 0.055, 0.075),
		Vector3(0.0, -0.50, -0.30), shoe_red)
	_add_box(pivot, "SneakerHeelAccent", Vector3(0.16, 0.085, 0.075),
		Vector3(0.0, -0.47, 0.17), shoe_red)

	_add_box(pivot, "SneakerLace_1", Vector3(0.19, 0.018, 0.028),
		Vector3(0.0, -0.46, -0.14), Color(0.78, 0.78, 0.72))
	_add_box(pivot, "SneakerLace_2", Vector3(0.19, 0.018, 0.028),
		Vector3(0.0, -0.43, -0.06), Color(0.78, 0.78, 0.72))
	_add_box(pivot, "SneakerLace_3", Vector3(0.19, 0.018, 0.028),
		Vector3(0.0, -0.40, 0.02), Color(0.78, 0.78, 0.72))



func _add_arm(side: float, sleeve_color: Color, skin_color: Color) -> void:
	var pivot := Node3D.new()
	pivot.name = "ArmPivot_Left" if side < 0.0 else "ArmPivot_Right"
	pivot.position = Vector3(side * 0.43, 1.28, 0.0)
	add_child(pivot)
	_arm_pivots.append(pivot)
	_add_capsule(pivot, "HoodieSleeve", 0.115, 0.76,
		Vector3(0.0, -0.29, 0.0), sleeve_color)
	_add_sphere(pivot, "Hand", 0.105, Vector3(0.0, -0.70, -0.015), skin_color)


func _add_capsule(parent: Node3D, node_name: String, radius: float,
		height: float, at: Vector3, color: Color) -> MeshInstance3D:
	var capsule := CapsuleMesh.new()
	capsule.radius = radius
	capsule.height = height
	return _add_mesh(parent, node_name, capsule, at, color)


func _add_sphere(parent: Node3D, node_name: String, radius: float,
		at: Vector3, color: Color, shape_scale: Vector3 = Vector3.ONE) -> MeshInstance3D:
	var sphere := SphereMesh.new()
	sphere.radius = radius
	sphere.height = radius * 2.0
	var instance := _add_mesh(parent, node_name, sphere, at, color)
	instance.scale = shape_scale
	return instance


func _add_box(parent: Node3D, node_name: String, dimensions: Vector3,
		at: Vector3, color: Color) -> MeshInstance3D:
	var box := BoxMesh.new()
	box.size = dimensions
	return _add_mesh(parent, node_name, box, at, color)


func _add_mesh(parent: Node3D, node_name: String, mesh_resource: Mesh,
		at: Vector3, color: Color) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.name = node_name
	instance.mesh = mesh_resource
	instance.position = at
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.88
	instance.material_override = material
	parent.add_child(instance)
	return instance
