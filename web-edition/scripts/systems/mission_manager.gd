extends Node
class_name GhibliMissionManager

signal objective_changed(text: String)
signal notification_requested(text: String)
signal dialogue_changed(speaker: String, line: String)
signal wallet_changed(amount: int)

const SAVE_PATH := "user://gta_ghibli_web_save.cfg"

var mission_stage: int = 0
var wallet: int = 350


func _ready() -> void:
	_load_game()


func get_objective() -> String:
	match mission_stage:
		0:
			return "Mission 001 — تحدث إلى Claire Bennett"
		1:
			return "Mission 001 — قابل Nora قرب Marsa Al-Noor"
		_:
			return "Mission 001 مكتملة — استكشف المناطق الأربع"


func get_wallet() -> int:
	return wallet


func handle_interaction(action_id: String) -> void:
	match action_id:
		"claire":
			if mission_stage == 0:
				mission_stage = 1
				dialogue_changed.emit(
					"Claire Bennett",
					"ليو، وصلت رسالة من نورا. ابحث عنها قرب منارة Marsa Al-Noor."
				)
				objective_changed.emit(get_objective())
				notification_requested.emit("بدأت المهمة 001: رسالة عند المرسى")
				_save_game()
			else:
				dialogue_changed.emit("Claire Bennett", "انتبه لنفسك يا ليو.")
		"nora":
			if mission_stage == 1:
				mission_stage = 2
				wallet += 250
				dialogue_changed.emit(
					"Nora Blake",
					"كنت أنتظرك. وصلت إلى المكان الصحيح؛ هذه بداية ما نحتاج إلى اكتشافه."
				)
				objective_changed.emit(get_objective())
				wallet_changed.emit(wallet)
				notification_requested.emit("اكتملت المهمة الافتتاحية — مكافأة $250")
				_save_game()
			elif mission_stage == 0:
				notification_requested.emit("تحدث إلى Claire أولاً لمعرفة وجهتك.")
			else:
				dialogue_changed.emit("Nora Blake", "سنلتقي مجدداً في الفصل التالي.")
		"mia":
			dialogue_changed.emit("Mia Bennett", "لا تنسَ أن تستكشف المدينة قبل أن تغادرها.")
		_:
			notification_requested.emit("لا يوجد تفاعل متاح هنا.")


func reset_progress() -> void:
	mission_stage = 0
	wallet = 350
	_save_game()
	objective_changed.emit(get_objective())
	wallet_changed.emit(wallet)


func _load_game() -> void:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return
	mission_stage = clampi(int(config.get_value("progress", "mission_stage", 0)), 0, 2)
	wallet = maxi(int(config.get_value("progress", "wallet", 350)), 0)


func _save_game() -> void:
	var config := ConfigFile.new()
	config.set_value("meta", "schema_version", 1)
	config.set_value("progress", "mission_stage", mission_stage)
	config.set_value("progress", "wallet", wallet)
	var error := config.save(SAVE_PATH)
	if error != OK:
		push_warning("Could not save the Web edition progress: %s" % error)
