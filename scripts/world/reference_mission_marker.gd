extends Node3D

## Original blue mission marker inspired by the supplied mobile gameplay frame.
## The marker is purely visual: mission ownership and completion remain in
## the existing mission systems and are not falsely simulated here.
@export var pulse_speed: float = 2.4
@export var rotation_speed: float = 0.65

var _beam: MeshInstance3D
var _base: MeshInstance3D
var _core: MeshInstance3D
var _elapsed := 0.0


func _ready() -> void:
	name = "ReferenceMissionMarker"
	add_to_group("reference_mission_markers")

	var base_mesh := CylinderMesh.new()
	base_mesh.top_radius = 0.82
	base_mesh.bottom_radius = 0.82
	base_mesh.height = 0.08
	base_mesh.radial_segments = 32
	_base = MeshInstance3D.new()
	_base.name = "BlueGroundRing"
	_base.mesh = base_mesh
	_base.position.y = 0.08
	_base.material_override = _emissive_blue(0.34)
	add_child(_base)

	var beam_mesh := CylinderMesh.new()
	beam_mesh.top_radius = 0.20
	beam_mesh.bottom_radius = 0.72
	beam_mesh.height = 1.45
	beam_mesh.radial_segments = 24
	_beam = MeshInstance3D.new()
	_beam.name = "BlueMissionBeam"
	_beam.mesh = beam_mesh
	_beam.position.y = 0.83
	var beam_material := _emissive_blue(0.72)
	beam_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	beam_material.albedo_color.a = 0.44
	beam_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_beam.material_override = beam_material
	add_child(_beam)

	var core_mesh := SphereMesh.new()
	core_mesh.radius = 0.16
	core_mesh.height = 0.32
	core_mesh.radial_segments = 16
	core_mesh.rings = 8
	_core = MeshInstance3D.new()
	_core.name = "BlueMarkerCore"
	_core.mesh = core_mesh
	_core.position.y = 1.08
	_core.material_override = _emissive_blue(1.2)
	add_child(_core)


func _process(delta: float) -> void:
	_elapsed += delta
	rotate_y(rotation_speed * delta)
	var pulse := 0.5 + 0.5 * sin(_elapsed * pulse_speed)
	if _beam != null:
		_beam.scale = Vector3.ONE * (0.96 + pulse * 0.08)
	if _core != null:
		_core.position.y = 1.03 + pulse * 0.16
		_core.scale = Vector3.ONE * (0.92 + pulse * 0.15)
	if _base != null:
		_base.scale = Vector3.ONE * (0.92 + pulse * 0.12)


func _emissive_blue(energy: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.08, 0.48, 1.0, 1.0)
	material.emission_enabled = true
	material.emission = Color(0.04, 0.33, 1.0)
	material.emission_energy_multiplier = energy
	material.roughness = 0.3
	return material
