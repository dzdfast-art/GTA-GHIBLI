extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var m=load("res://scripts/world/player_vitals.gd").new()
		assert(m.apply_damage(30.0)==30.0 and m.health==70.0)
		assert(m.heal(50.0)==30.0 and m.health==100.0)
		assert(m.use_stamina(40.0) and not m.use_stamina(100.0))
		assert(m.restore_stamina(20.0)==20.0)
	print("PASS: Health and Stamina Model.")
	quit(0)
