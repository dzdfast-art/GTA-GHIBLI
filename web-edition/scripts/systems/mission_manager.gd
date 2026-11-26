extends Node
class_name GhibliMissionManager

signal objective_changed(text: String)
signal notification_requested(text: String)
signal dialogue_changed(speaker: String, line: String)
signal wallet_changed(amount: int)
signal mission_step_completed(mission_id: String, objective_id: String)
signal mission_completed(mission_id: String)
signal progress_reset

const SAVE_PATH := "user://gta_ghibli_web_save.cfg"
const MAX_MISSION_STAGE := 5

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
		2:
			return "Mission 001 مكتملة — تحدث إلى Nora لبدء المهمة 002"
		3:
			return "Mission 002 — افحص لوحة إعلانات Harbor Market"
		4:
			return "Mission 002 — عُد إلى Nora عند المنارة"
		_:
			return "Mission 002 مكتملة — استكشف المناطق الأربع"


func get_wallet() -> int:
	return wallet


func handle_interaction(action_id: String) -> void:
	match action_id:
		"claire":
			if mission_stage == 0:
				mission_stage = 1
				mission_step_completed.emit("mission_001", "speak_to_claire")
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
			match mission_stage:
				0:
					notification_requested.emit("تحدث إلى Claire أولاً لمعرفة وجهتك.")
				1:
					mission_stage = 2
					wallet += 250
					mission_step_completed.emit("mission_001", "meet_nora")
					mission_completed.emit("mission_001")
					dialogue_changed.emit(
						"Nora Blake",
						"كنت أنتظرك. وصلت إلى المكان الصحيح؛ هذه بداية ما نحتاج إلى اكتشافه."
					)
					objective_changed.emit(get_objective())
					wallet_changed.emit(wallet)
					notification_requested.emit("اكتملت المهمة الافتتاحية — مكافأة $250")
					_save_game()
				2:
					mission_stage = 3
					mission_step_completed.emit("mission_002", "start_at_nora")
					dialogue_changed.emit(
						"Nora Blake",
						"قبل أن نتابع، افحص إشعار الشحن المثبّت على لوحة سوق المرسى ثم عُد إليّ."
					)
					objective_changed.emit(get_objective())
					notification_requested.emit("بدأت المهمة 002: إشعار السوق")
					_save_game()
				3:
					notification_requested.emit("افحص لوحة إعلانات Harbor Market أولاً.")
				4:
					mission_stage = 5
					wallet += 300
					mission_step_completed.emit("mission_002", "return_to_nora")
					mission_completed.emit("mission_002")
					dialogue_changed.emit(
						"Nora Blake",
						"هذا يكفي للبدء في تتبّع الشحنة. أحسنت يا ليو؛ سنكمل التحقيق لاحقاً."
					)
					objective_changed.emit(get_objective())
					wallet_changed.emit(wallet)
					notification_requested.emit("اكتملت المهمة 002 — مكافأة $300")
					_save_game()
				_:
					dialogue_changed.emit("Nora Blake", "شكراً لعودتك. سنلتقي مجدداً في الفصل التالي.")
		"market_notice":
			if mission_stage == 3:
				mission_stage = 4
				mission_step_completed.emit("mission_002", "inspect_noticeboard")
				dialogue_changed.emit(
					"Harbor Market",
					"الإشعار يطلب مطابقة سجل الشحنة مع نورا. عُد إليها عند المنارة."
				)
				objective_changed.emit(get_objective())
				notification_requested.emit("تم فحص إشعار السوق — عُد إلى Nora")
				_save_game()
			elif mission_stage < 3:
				notification_requested.emit("تحدث إلى Nora أولاً لمعرفة ما يجب فحصه.")
			else:
				notification_requested.emit("لا يوجد إشعار جديد لفحصه الآن.")
		"mia":
			dialogue_changed.emit("Mia Bennett", "لا تنسَ أن تستكشف المدينة قبل أن تغادرها.")
		_:
			notification_requested.emit("لا يوجد تفاعل متاح هنا.")


func reset_progress() -> void:
	mission_stage = 0
	wallet = 350
	progress_reset.emit()
	_save_game()
	objective_changed.emit(get_objective())
	wallet_changed.emit(wallet)


func _load_game() -> void:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return
	mission_stage = clampi(
		int(config.get_value("progress", "mission_stage", 0)),
		0,
		MAX_MISSION_STAGE
	)
	wallet = maxi(int(config.get_value("progress", "wallet", 350)), 0)


func _save_game() -> void:
	var config := ConfigFile.new()
	config.set_value("meta", "schema_version", 1)
	config.set_value("progress", "mission_stage", mission_stage)
	config.set_value("progress", "wallet", wallet)
	var error := config.save(SAVE_PATH)
	if error != OK:
		push_warning("Could not save the Web edition progress: %s" % error)
