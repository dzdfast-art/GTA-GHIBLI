extends SceneTree

## Headless checks for NPC perception, relationships, schedules and group alerts.
const BRAIN_SCRIPT = preload("res://scripts/systems/npc_brain.gd")


func _initialize() -> void:
	call_deferred("_run_test")


func _run_test() -> void:
	var npc := Node3D.new()
	npc.name = "TestNPC"
	root.add_child(npc)
	var brain := Node.new()
	brain.set_script(BRAIN_SCRIPT)
	npc.add_child(brain)

	var player := CharacterBody3D.new()
	player.name = "Player"
	player.add_to_group("player")
	root.add_child(player)

	player.global_position = Vector3(8.0, 0.0, 0.0)
	brain.call("_find_player")
	brain.call("_evaluate_reaction")
	if brain.get("state_id") != "curious":
		_fail("NPC did not notice a player within detection range.")
		return

	player.global_position = Vector3(3.0, 0.0, 0.0)
	brain.call("_find_player")
	brain.call("_evaluate_reaction")
	if brain.get("state_id") != "curious":
		_fail("NPC reaction did not reflect a neutral relationship.")
		return

	brain.call("record_interaction", "talk")
	brain.call("record_interaction", "help")
	if brain.get("trust") <= 0.0 or brain.get("familiarity") <= 0.0:
		_fail("Positive interactions did not improve trust and familiarity.")
		return
	brain.call("_find_player")
	brain.call("_evaluate_reaction")
	if brain.get("state_id") != "friendly":
		_fail("NPC did not become friendly after positive interactions.")
		return

	player.global_position = Vector3(1.5, 0.0, 0.0)
	player.velocity = Vector3.ZERO
	brain.call("_find_player")
	brain.call("_evaluate_reaction")
	if brain.get("state_id") != "cautious":
		_fail("NPC did not protect its personal space.")
		return

	player.velocity = Vector3(6.0, 0.0, 0.0)
	brain.call("_find_player")
	brain.call("_evaluate_reaction")
	if brain.get("state_id") != "alarmed":
		_fail("NPC did not react to a fast approach.")
		return

	player.global_position = Vector3(30.0, 0.0, 0.0)
	player.velocity = Vector3.ZERO
	brain.call("_find_player")
	brain.call("_evaluate_reaction")
	if brain.get("state_id") != "idle":
		_fail("NPC did not return to idle after the player left.")
		return

	brain.call("record_player_action", "aggression")
	if brain.get("trust") >= 0.0:
		_fail("Aggression did not reduce relationship trust.")
		return

	var schedule_brain := Node.new()
	schedule_brain.set_script(BRAIN_SCRIPT)
	npc.add_child(schedule_brain)
	schedule_brain.set("schedule_enabled", true)
	schedule_brain.call("set_world_hour", 10)
	if schedule_brain.get("state_id") != "working":
		_fail("NPC did not enter its configured work schedule.")
		return
	schedule_brain.call("set_world_hour", 22)
	if schedule_brain.get("state_id") != "resting":
		_fail("NPC did not enter its configured rest schedule.")
		return

	print("PASS: NPC perception, trust, familiarity, aggression and daily schedule checks.")
	quit(0)


func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	quit(1)
