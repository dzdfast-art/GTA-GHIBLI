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
const MAX_MISSION_STAGE := 12

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
		5:
			return "Mission 002 مكتملة — تحدث إلى Nora لبدء مهمة المؤونة"
		6:
			return "Mission 003 — اشترِ زجاجة ماء من Harbor Market"
		7:
			return "Mission 003 — سلّم زجاجة الماء إلى Claire Bennett"
		8:
			return "Mission 003 مكتملة — تحدث إلى Nora لبدء مهمة الساحل"
		9:
			return "Mission 004 — اشترِ سلة فواكه من Harbor Market"
		10:
			return "Mission 004 — قُد السيارة إلى Sapphire Coast Cafe"
		11:
			return "Mission 004 — انزل وسلّم سلة الفواكه إلى المقهى"
		_:
			return "Mission 004 مكتملة — استكشف المدينة"

func get_wallet() -> int:
	return wallet


func set_wallet_balance(amount: int, _reason: String = "wallet_update") -> bool:
	if amount < 0:
		return false
	if amount == wallet:
		return true
	wallet = amount
	wallet_changed.emit(wallet)
	_save_game()
	return true


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
			elif mission_stage == 7:
				mission_stage = 8
				wallet += 150
				mission_step_completed.emit("mission_003", "return_to_claire")
				mission_completed.emit("mission_003")
				dialogue_changed.emit(
					"Claire Bennett",
					"شكراً يا ليو. هذه المؤونة ستساعدنا حتى نعرف ما يحدث في الميناء."
				)
				objective_changed.emit(get_objective())
				wallet_changed.emit(wallet)
				notification_requested.emit("اكتملت المهمة 003 — مكافأة $150")
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
				5:
					mission_stage = 6
					mission_step_completed.emit("mission_003", "start_at_nora")
					dialogue_changed.emit(
						"Nora Blake",
						"أحتاج إلى مؤونة بسيطة للرحلة التالية. ادخل سوق المرسى واشترِ زجاجة ماء، ثم أوصلها إلى Claire."
					)
					objective_changed.emit(get_objective())
					notification_requested.emit("بدأت المهمة 003: مؤونة الطريق")
					_save_game()
				6:
					notification_requested.emit("اشترِ زجاجة ماء من متجر Harbor Market أولاً.")
				7:
					dialogue_changed.emit("Nora Blake", "تأكد من تسليم المؤونة إلى Claire قبل أن نتابع.")
				8:
					mission_stage = 9
					mission_step_completed.emit("mission_004", "start_at_nora")
					dialogue_changed.emit(
						"Nora Blake",
						"وصلت سلة فواكه طازجة إلى المرسى. اشترِ واحدة من السوق وخذها بالسيارة إلى مقهى الساحل في Sapphire Coast."
					)
					objective_changed.emit(get_objective())
					notification_requested.emit("بدأت المهمة 004: رسالة إلى الساحل")
					_save_game()
				9:
					notification_requested.emit("اشترِ سلة الفواكه من Harbor Market أولاً.")
				10:
					dialogue_changed.emit("Nora Blake", "اتبع مسار GPS إلى Sapphire Coast Cafe وأوصل السلة.")
				11:
					dialogue_changed.emit("Nora Blake", "وصلت إلى الساحل. انزل من السيارة وسلّم السلة عند المنضدة.")
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
		"market_enter":
			if mission_stage == 6:
				mission_step_completed.emit("mission_003", "enter_market")
				notification_requested.emit("دخلت متجر Harbor Market — اختر المؤونة المطلوبة.")
				_save_game()
			elif mission_stage == 9:
				mission_step_completed.emit("mission_004", "enter_market")
				notification_requested.emit("دخلت متجر Harbor Market — اختر سلة الفواكه للرحلة.")
				_save_game()
		"market_shop_purchase":
			notification_requested.emit("أكمل الشراء من واجهة متجر Harbor Market أولاً.")
		"sapphire_cafe_delivery":
			if mission_stage == 10:
				notification_requested.emit("قُد السيارة إلى Sapphire Coast Cafe أولاً.")
			elif mission_stage == 11:
				mission_stage = 12
				wallet += 200
				mission_step_completed.emit("mission_004", "deliver_basket")
				mission_completed.emit("mission_004")
				dialogue_changed.emit(
					"Sapphire Coast Cafe",
					"وصلت السلة في الوقت المناسب. شكراً لمساعدتك في تجهيز مقهى الساحل."
				)
				objective_changed.emit(get_objective())
				wallet_changed.emit(wallet)
				notification_requested.emit("اكتملت المهمة 004 — مكافأة $200")
				_save_game()
			else:
				notification_requested.emit("لا توجد عملية تسليم مطلوبة هنا الآن.")
		"mia":
			dialogue_changed.emit("Mia Bennett", "لا تنسَ أن تستكشف المدينة قبل أن تغادرها.")
		_:
			notification_requested.emit("لا يوجد تفاعل متاح هنا.")



func get_required_market_item() -> String:
	if mission_stage == 6:
		return "bottled_water"
	if mission_stage == 9:
		return "fruit_basket"
	return ""


func record_market_purchase(item_id: String, owned_quantity: int) -> bool:
	if owned_quantity < 1:
		notification_requested.emit("يجب امتلاك السلعة المطلوبة قبل تسجيل الشراء.")
		return false
	if mission_stage == 6 and item_id == "bottled_water":
		mission_stage = 7
		mission_step_completed.emit("mission_003", "buy_water")
		dialogue_changed.emit(
			"Harbor Market",
			"حصلت على زجاجة الماء. عُد بها إلى Claire في Harbor City."
		)
		objective_changed.emit(get_objective())
		notification_requested.emit("تم شراء المؤونة — عُد إلى Claire")
		_save_game()
		return true
	if mission_stage == 9 and item_id == "fruit_basket":
		mission_stage = 10
		mission_step_completed.emit("mission_004", "buy_fruit_basket")
		dialogue_changed.emit(
			"Harbor Market",
			"أصبحت سلة الفواكه معك. قُد السيارة عبر الطريق إلى Sapphire Coast Cafe."
		)
		objective_changed.emit(get_objective())
		notification_requested.emit("تم شراء السلة — اتبع GPS إلى Sapphire Coast")
		_save_game()
		return true
	notification_requested.emit("هذه ليست السلعة المطلوبة للمهمة الحالية.")
	return false


func record_vehicle_delivery_arrival() -> bool:
	if mission_stage != 10:
		return false
	mission_stage = 11
	mission_step_completed.emit("mission_004", "arrive_by_vehicle")
	dialogue_changed.emit(
		"Sapphire Coast Cafe",
		"وصلت بالسيارة إلى الساحل. انزل وسلّم سلة الفواكه عند المنضدة."
	)
	objective_changed.emit(get_objective())
	notification_requested.emit("وصلت إلى Sapphire Coast — سلّم السلة عند المنضدة")
	_save_game()
	return true

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
