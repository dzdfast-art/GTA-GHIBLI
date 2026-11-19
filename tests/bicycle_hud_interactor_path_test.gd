extends SceneTree

const WORLD = preload("res://tests/helpers/bicycle_test_world.gd")

func _initialize() -> void:
	call_deferred("_run")

func _tap_interact(button: Button) -> void:
	button.button_down.emit()
	await process_frame
	await process_frame
	button.button_up.emit()
	await process_frame
	await process_frame


func _run() -> void:
	var w: Dictionary = await WORLD.build(self)
	var player: CharacterBody3D = w["player"]
	var bicycle: CharacterBody3D = w["bicycle"]
	var controls: CanvasLayer = w["controls"]
	if not InputMap.has_action("interact"):
		WORLD.fail(self, "InputMap has no interact action.")
		return
	var detector := player.get_node("PlayerInteractor/InteractionDetector") as Area3D
	var expected_detector_position := player.global_position + Vector3.UP * 0.9
	if detector.global_position.distance_to(expected_detector_position) > 0.01:
		WORLD.fail(self, "interaction detector did not inherit the player's world transform.")
		return
	var button := controls.get_node("HUD/ContextAction") as Button
	var distances := [1.5, 2.6, 2.8, 3.0, 3.2, 3.4, 3.6, 3.8, 4.0, 4.2, 5.0]
	var report: Array[String] = []
	for distance in distances:
		player.global_position = Vector3(0.0, 0.95, 0.0)
		player.velocity = Vector3.ZERO
		bicycle.global_position = Vector3(0.0, 0.0, distance)
		for _frame in range(4):
			await physics_frame
		await process_frame
		await process_frame
		var shows_ride: bool = button.tooltip_text == "اركب الدراجة"
		await _tap_interact(button)
		for _frame in range(2):
			await physics_frame
		var mounted: bool = bicycle.get("driver") == player
		report.append("%.1f m: RIDE=%s mounted=%s" % [distance, shows_ride, mounted])
		if shows_ride != mounted:
			print("\n".join(report))
			WORLD.fail(self, "distance %.1f m: RIDE=%s but mounted=%s" % [distance, shows_ride, mounted])
			return
		if distance == 1.5 and not mounted:
			print("\n".join(report))
			WORLD.fail(self, "close range did not mount through HUD.")
			return
		if distance == 5.0 and (shows_ride or mounted):
			print("\n".join(report))
			WORLD.fail(self, "far range should neither show RIDE nor mount.")
			return
		if mounted:
			await _tap_interact(button)
			for _frame in range(2):
				await physics_frame
			if bicycle.get("driver") != null:
				print("\n".join(report))
				WORLD.fail(self, "dismount through HUD failed.")
				return
	print("\n".join(report))
	print("PASS: HUD prompt matches real interaction target; mount and dismount via HUD.")
	quit(0)
