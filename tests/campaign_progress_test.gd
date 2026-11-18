extends SceneTree

const CAMPAIGN_SCRIPT = preload("res://scripts/missions/campaign_progress.gd")

func _initialize() -> void:
	call_deferred("_run_test")


func _run_test() -> void:
	var campaign: Node = CAMPAIGN_SCRIPT.new()
	root.add_child(campaign)

	var zero: Dictionary = campaign.call("build_snapshot", false, false, false, false)
	if int(zero.get("completed_count", -1)) != 0 or str(zero.get("current_mission_id", "")) != "meet_the_village":
		_fail("A new save must start at mission 001.")
		return

	var after_one: Dictionary = campaign.call("build_snapshot", true, false, false, false)
	if int(after_one.get("completed_count", -1)) != 1 or str(after_one.get("current_mission_id", "")) != "the_old_road_rescue":
		_fail("Completing mission 001 must unlock mission 002.")
		return

	var after_two: Dictionary = campaign.call("build_snapshot", true, true, false, false)
	if int(after_two.get("completed_count", -1)) != 2 or str(after_two.get("current_mission_id", "")) != "shadows_over_the_harbor":
		_fail("Completing mission 002 must unlock mission 003.")
		return

	var after_three: Dictionary = campaign.call("build_snapshot", true, true, true, false)
	if int(after_three.get("completed_count", -1)) != 3 or str(after_three.get("current_mission_id", "")) != "the_last_train":
		_fail("Completing mission 003 must unlock mission 004.")
		return

	var complete: Dictionary = campaign.call("build_snapshot", true, true, true, true)
	if int(complete.get("completed_count", -1)) != 4 or not bool(complete.get("chapter_complete", false)) or not str(complete.get("current_mission_id", "")).is_empty():
		_fail("Completing mission 004 must mark chapter 01 complete.")
		return

	print("PASS: chapter 01 unlock order and four-mission completion summary.")
	quit(0)


func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	quit(1)
