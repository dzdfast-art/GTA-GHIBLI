extends Node

## Read-only chapter progress view built from the four existing local mission saves.
## This is the current first-chapter prototype, not a claim that the full game campaign is finished.

const MISSION_001_SAVE := "user://gta_ghibli_save.json"
const MISSION_002_SAVE := "user://gta_ghibli_mission_002.json"
const MISSION_003_SAVE := "user://gta_ghibli_mission_003.json"
const MISSION_004_SAVE := "user://gta_ghibli_mission_004.json"

func _ready() -> void:
	add_to_group("campaign_progress")


func get_campaign_snapshot() -> Dictionary:
	return build_snapshot(
		_is_mission_001_complete(),
		_is_saved_mission_complete(MISSION_002_SAVE, "the_old_road_rescue"),
		_is_saved_mission_complete(MISSION_003_SAVE, "shadows_over_the_harbor"),
		_is_saved_mission_complete(MISSION_004_SAVE, "the_last_train")
	)


func build_snapshot(mission_001_complete: bool, mission_002_complete: bool,
		mission_003_complete: bool, mission_004_complete: bool) -> Dictionary:
	var flags := [mission_001_complete, mission_002_complete, mission_003_complete, mission_004_complete]
	var definitions := [
		{"id": "meet_the_village", "title": "صباح جديد في قرية الصفصاف", "number": 1},
		{"id": "the_old_road_rescue", "title": "الطريق القديم: عملية الإنقاذ", "number": 2},
		{"id": "shadows_over_the_harbor", "title": "ظلال فوق الميناء", "number": 3},
		{"id": "the_last_train", "title": "القطار الأخير", "number": 4}
	]
	var missions: Array[Dictionary] = []
	var completed_count := 0
	var current_mission_id := ""
	for index in range(definitions.size()):
		var complete := bool(flags[index])
		var unlocked := index == 0 or bool(flags[index - 1])
		if complete:
			completed_count += 1
		elif unlocked and current_mission_id.is_empty():
			current_mission_id = str(definitions[index].id)
		missions.append({
			"id": definitions[index].id,
			"title": definitions[index].title,
			"number": definitions[index].number,
			"unlocked": unlocked,
			"completed": complete
		})
	return {
		"chapter_id": "chapter_01",
		"chapter_title": "الفصل الأول: طريق العودة",
		"completed_count": completed_count,
		"total_count": definitions.size(),
		"chapter_complete": completed_count == definitions.size(),
		"current_mission_id": current_mission_id,
		"missions": missions
	}


func _is_mission_001_complete() -> bool:
	if not FileAccess.file_exists(MISSION_001_SAVE):
		return false
	var file := FileAccess.open(MISSION_001_SAVE, FileAccess.READ)
	if file == null:
		return false
	var data = JSON.parse_string(file.get_as_text())
	return data is Dictionary \
		and str(data.get("mission_id", "")) == "meet_the_village" \
		and bool(data.get("square_reached", false)) \
		and bool(data.get("mira_spoken_to", false)) \
		and bool(data.get("garden_visited", false))


func _is_saved_mission_complete(path: String, expected_id: String) -> bool:
	if not FileAccess.file_exists(path):
		return false
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return false
	var data = JSON.parse_string(file.get_as_text())
	return data is Dictionary \
		and str(data.get("mission_id", "")) == expected_id \
		and bool(data.get("completed", false))
