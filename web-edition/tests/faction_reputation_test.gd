extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var m=load("res://scripts/world/faction_reputation.gd").new()
		assert(m.adjust("dockers",60)==60 and m.get_standing("dockers")=="ally")
		assert(m.adjust("dockers",-120)==-60 and m.get_standing("dockers")=="enemy")
		assert(m.get_score("unknown")==0)
	print("PASS: Faction Reputation.")
	quit(0)
