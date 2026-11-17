extends SceneTree

const REGIONS_SCRIPT = preload("res://scripts/world/open_world_regions.gd")

func _initialize() -> void:
	call_deferred("_run_test")

func _run_test() -> void:
	var regions := Node3D.new()
	regions.set_script(REGIONS_SCRIPT)
	root.add_child(regions)
	await process_frame

	var coast := regions.get_node_or_null("SapphireCoast") as Node3D
	if coast == null:
		_fail("Sapphire Coast district was not created.")
		return
	var boat := coast.get_node_or_null("SapphireFishingBoat") as Node3D
	if boat == null:
		_fail("The original fishing boat scene is not integrated into Sapphire Coast.")
		return
	if not boat.is_in_group("world_landmarks"):
		_fail("The fishing boat is missing from the world_landmarks group.")
		return
	if not boat.has_method("get_motion_phase") or not boat.is_processing():
		_fail("The fishing boat idle-motion controller is not active.")
		return
	var hull := boat.get_node_or_null("HullMesh") as MeshInstance3D
	if hull == null or hull.mesh == null or hull.mesh.get_surface_count() < 4:
		_fail("The imported fishing boat mesh or its material surfaces are missing.")
		return
	var collision_body := boat.get_node_or_null("HullCollisionBody") as AnimatableBody3D
	var collision := boat.get_node_or_null("HullCollisionBody/HullCollision") as CollisionShape3D
	if collision_body == null or collision == null or not (collision.shape is BoxShape3D):
		_fail("The simplified moving hull collision is missing or invalid.")
		return
	if boat.position.distance_to(Vector3(0.0, 0.48, 14.0)) > 0.2:
		_fail("The fishing boat is not positioned in the Sapphire Coast harbour water.")
		return
	print("PASS: original fishing boat OBJ import, material surfaces, harbour placement, bobbing and hull collision.")
	quit(0)

func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	quit(1)
