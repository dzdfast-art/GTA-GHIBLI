# GTA GHIBLI — Gameplay Systems Specification

**Status key:** Implemented = present in repository; Planned = required but not yet implemented; Tested = verified by a named test. A design specification is not proof of gameplay.

## 1. Design principles

- Original world, cast, story, dialogue, missions, art, music and assets.
- Mobile-first third-person open-world game for Android.
- Reusable systems and data-driven content; avoid giant scripts and duplicated logic.
- Variety before volume: no filler characters, copy-paste missions or meaningless repeated interactions.
- Build a small end-to-end feature, test it, then expand.
- GTA San Andreas is a reference for gameplay breadth and systems only; do not copy its protected content.

The canonical world and cast are defined in [Master Requirements Alignment](MASTER_REQUIREMENTS_ALIGNMENT.md). Prototype names must not silently replace the canonical requirements.

## 2. Player and movement

**Implemented in prototype:** capsule placeholder, camera-relative movement, gravity/floor handling, third-person camera and touch orbit.

**Planned:** final original character rig, walk/run/sprint/jump, climbing, swimming/diving, stealth/crouch where useful, animation state machine, health/status, interaction states and responsive input.

Acceptance: movement, collisions, camera and touch release behavior must be tested on desktop and the target Android device. A capsule is not a finished character.

## 3. Universal interaction system

**Prototype implementation added:** `scripts/systems/player_interactor.gd` detects nearby registered interaction areas, selects the nearest target and calls its `interact()` method. Mira is the first target migrated to this contract. The shared mobile/keyboard action also drops an item currently held by the player.

A reusable animated gate is implemented in `scripts/systems/interactable_door.gd`; the village garden now has an interactive swing gate, with solid collision on the fence sections so the gate is a meaningful entrance rather than decoration. A reusable physics prop in `scripts/systems/carryable_prop.gd` can be picked up, carried in front of the player and dropped with the same interaction button. The village prototype includes a carryable garden basket inside the garden. Automated tests cover door state changes and prop pickup/drop; the object tests passed in CI run [43518667393](https://github.com/dzdfast-art/GTA-GHIBLI/actions/runs/43518667393). The latest fence-collision/world placement commit is undergoing a separate CI run.

All usable entities should follow a shared interaction contract rather than implementing unrelated input logic in every object.

Each interactable should provide:
- Stable unique ID and category.
- Localized display name and contextual prompt.
- Interaction range and eligibility conditions.
- Action identifier and result.
- Optional animation, audio, VFX and mission event.
- Clear unavailable/locked feedback.

Supported interaction verbs, as appropriate to the object:
- Talk, inspect, collect, pick up, carry, drop.
- Push, pull, move, open, close, activate, use.
- Enter, exit, consume, purchase, repair and operate.

Examples include NPCs, doors, gates, drawers, switches, furniture, tools, containers, collectibles, crops, food, shop counters and vehicles.

The player should see the most relevant nearby action, not a stack of unrelated prompts. Touch interaction and keyboard/controller input must call the same gameplay action.

**Planned acceptance tests:** nearest-target selection; entering/leaving range; occlusion/line-of-sight where needed; locked conditions; repeated activation protection; target changes; mobile button state; mission event delivery.

## 4. Physics and object behavior

Use physics according to gameplay need:
- Static collision for buildings, roads and fixed scenery.
- Character collision for people and the player.
- Rigid-body simulation for selected movable objects.
- Area triggers for proximity, pickups and mission zones.
- Object-specific mass, friction, bounce, damage and breakability where meaningful.

Support gravity, falling, impacts, pushing/pulling and collisions. Do not simulate every decorative leaf or small prop as a full physics body. Keep collision shapes simpler than visual meshes and profile the result on the target phone.

**Planned:** a reusable physical-object component, object interaction states and tests for pickup/drop, push/pull, impact and collision stability.

## 5. NPCs, conversations and relationships

Distinguish:
- Named story characters.
- Recurring supporting characters.
- Generic pedestrians.
- Workers and service NPCs.
- Mission-specific actors.

Important characters need a distinct purpose, personality, visual identity, voice profile, relationships and authored dialogue. Generic pedestrians may use shared rigs/animations but should vary in appearance and behavior without creating duplicate named identities.

**Expanded reactive-NPC prototype added:** `scripts/systems/npc_brain.gd` tracks per-NPC trust and familiarity, reacts to positive or hostile player actions, supports work/rest hours through `set_world_hour()`, moves alarmed NPCs away from danger and propagates nearby alarms. On the comprehensive repair candidate, each brain creates a NavigationAgent3D and follows a live navigation map when one exists. Four prototype district grids are generated in the candidate branch. The NPC test covers perception, relationship changes, persistence of trust/familiarity and schedule transitions.

**Current limits:** navigation is PARTIALLY IMPLEMENTED. Agent avoidance is disabled; the village, roads, interiors and four districts are not one continuous NavMesh; areas without a live navigation map still use direct-movement fallback. Full obstacle avoidance, no-path behavior across every district, saved daily schedule state and persistent NPC world transforms remain unverified or planned. Use distance-based simulation and population limits for mobile performance.

**Arabic audio requirement:** important dialogue must be genuinely voiced in Arabic with expressive emotional performance, consistent character voices and synchronized subtitles. Text plus an empty audio path is not dubbing. Audio remains incomplete until a real audio asset is integrated and playback is tested.

## 6. Nature, food and daily-life systems

Planned interactions include:
- Plants, trees, flowers, crops, fruit, water, fishing and suitable wildlife.
- Gathering, planting, watering, harvesting and animal care where they support gameplay.
- Food, drinks, shops, cafés, restaurants, cooking and ingredient collection.
- Meaningful player-state effects such as health, energy or hunger only where useful.

Avoid turning daily-life features into repetitive chores. Every activity should have a clear gameplay purpose, feedback and proportionate reward.



**Implemented on the repair candidate:** Harbor City now has an original public drinking fountain scene and imported low-poly OBJ model with stone, copper and water material surfaces. It uses the shared `interact()` contract and the player's existing `PlayerNeeds.drink()` API; drinking restores up to 30 thirst points, shows an Arabic prompt/feedback, and applies a short use cooldown. The scene is instantiated once in the district plaza. Regression coverage checks model surface import, proximity eligibility, hydration amount, cooldown and full-thirst handling. This is source-integrated; current-head import and runtime verification remain pending until CI completes.

## 7. Vehicles and transportation

A vehicle is complete only when it can be entered, controlled, exited and tested in gameplay. A static vehicle mesh does not count.

Required categories to develop where appropriate:
- Cars: compact, sedan, sports, utility and service vehicles.
- Vans, buses, trucks and heavy vehicles.
- Motorcycles and bicycles.
- Boats and other watercraft.
- Airplanes and helicopters.
- Carts, trailers and other useful special transport.

Shared vehicle architecture should cover identity, seats, entry/exit points, collision, engine state, acceleration, steering, braking, reverse, damage, camera, audio, animation and save data.

Use category-specific handling and touch HUDs:
- Cars/trucks: steering, acceleration, brake/reverse, handbrake, horn and exit.
- Motorcycles/bicycles: balance/lean and suitable braking/acceleration controls.
- Boats: steering, throttle, deceleration/reverse where supported, buoyancy and water interaction.
- Aircraft/helicopters: pitch, roll, yaw, throttle, climb/descent and landing controls.

Do not show aircraft controls while driving a car. The HUD must transition correctly between on-foot, nearby-vehicle, entering, each vehicle category and exiting states.

**Planned first vehicle gate:** one original drivable car with entry/exit, collision, camera, handling and a mobile driving HUD, followed by an automated test and a real-device test.

**Functional vehicle service added on the repair candidate:** `scenes/world/vehicle_service_garage.tscn` places an original six-material repair workshop in Amber Valley. The Arabic service panel finds a nearby stopped vehicle, quotes the full repair from its missing health, charges the existing player wallet, and calls the vehicle health/repair API. It rejects moving vehicles, out-of-range interactions and insufficient balances; failed repair delivery refunds the charge. `tests/vehicle_service_garage_test.gd` covers those paths. Current-head Godot import and runtime results remain pending until CI finishes; real Android touch/performance acceptance is not claimed.

## 8. Mission framework and content variety

Missions are data-driven. Each mission should define:
- Unique ID, title, description, chapter and region.
- Start condition and mission giver.
- Ordered or explicitly parallel objectives.
- Objective targets and completion rules.
- Failure/retry behavior where relevant.
- Dialogue, cutscene or event references.
- Rewards, unlocks and save behavior.
- Status: design_only, available, active, completed or locked.

Content categories can include main story, character stories, deliveries, driving, races, rescue, investigation, exploration, timed challenges, work/jobs, nature activities, collection, social requests and dynamic encounters.

### Anti-repetition review

Before approving a new character, mission or activity, compare it against existing content:
1. Is its narrative purpose distinct?
2. Does it use a meaningfully different objective combination or decision?
3. Does it introduce a new location, mechanic, character relationship or challenge?
4. Are dialogue, rewards and outcomes sufficiently distinct?
5. Could it be improved by merging it with an existing entry?

Reuse of a core mechanic is acceptable when context, stakes, route, constraints or player choices create a different experience. Remove or merge repetition that adds no meaningful value. Do not inflate counts to make the game appear larger.

**Current prototype:** the first tutorial mission tracks reaching the village square, talking to Mira and visiting the garden. Its flags persist locally. On the comprehensive repair candidate branch, completing it credits the configured 25-currency reward through a wallet transaction ID so the same mission cannot pay twice; this branch change remains subject to its new CI run.

### Cinematic storytelling and mission content

**Opening cinematic presentation added:** `scripts/missions/cinematic_director.gd` displays an Arabic chapter card, cinematic letterbox bars, timed story subtitles and touch/keyboard advance over the live game view. The opening introduces Leo Bennett, Mira and a mysterious radio signal. It is a presentation-layer prototype, not yet a fully animated camera cutscene; recorded Arabic voices are still pending.

**Three original main-story mission prototypes added:** `data/missions/mission_002.json`, `mission_003.json`, and `mission_004.json` each have a corresponding runtime state machine in `scripts/missions/`. Their automated state-flow tests cover rescue/chase, harbor evidence collection, and the train escort/route choice. They are playable blockout prototypes, not finished production missions or a complete campaign. The repair candidate branch adds idempotent wallet reward transactions to all four mission completions and exposes active mission objectives to BRIEF; this new integration awaits CI confirmation.

## 9. World, buildings and services

The master specification requires four connected regions—Harbor City, Sapphire Coast, Pine Highlands and Amber Valley—and the named location Marsa Al-Noor. The existing Green Valley/Wllow Village content is a prototype slice, not a replacement for those canonical locations.

Buildings and services should have clear interaction levels:
- Exterior-only scenery with correct collision.
- Enterable interiors.
- Functional service locations such as shops, restaurants, garages and clinics.
- Mission-critical locations with scripted interactions.

Do not imply that every building is enterable. Document which category each location belongs to.

## 10. Save, progression and data

**Implemented in the repair candidate (PARTIALLY IMPLEMENTED):** `game_save_manager.gd` writes a versioned unified record containing player transform, world clock, health/wallet/needs/inventory snapshots, mission and side-activity snapshots, NPC relationship snapshots, vehicle-condition snapshots and allowlisted legacy JSON/CFG files. It validates a temporary JSON record and rotates a backup before replacing the active save. The wallet reward ledger also preserves one-time reward transaction IDs.

**Current save acceptance limits:** the regression now checks player transform restore and a legacy NPC relationship file round-trip while rejecting unrelated and traversal paths. Complete migration of every historical save format, corruption recovery on real device storage, all world object spawn/destruction/collectible states, every NPC transform and all future subsystem snapshots are still PARTIALLY IMPLEMENTED or NOT VERIFIED. Do not describe the whole world as fully persistent until each entity type has a tested snapshot contract.

## 11. Mobile performance and content budget

Target Android baseline: Infinix SMART 8, Unisoc T606, 4 GB physical RAM, 720 × 1612 display. Virtual RAM is not equivalent to physical RAM.

Use mobile renderer settings, LOD, instancing, culling, simplified collision, distance-based NPC/traffic updates, region streaming, compressed textures/audio and adjustable graphics.

Content growth has no fixed final size ceiling and is not a runtime RAM goal. Track unique tracked source blobs, imported project size, raw APK, Web export, artifact ZIP, download size and installed size separately. Never add empty, duplicate or filler files; profile import time, memory and frame time on the target Android device.

## 12. Current verification

GitHub Actions run [43513899542](https://github.com/dzdfast-art/GTA-GHIBLI/actions/runs/43513899542) passed all eight validation steps: JSON validation, Godot 4.7 resource import, script parsing, first-mission objective/save test and 180-frame main-scene smoke test.

This does not verify rendered quality, real touch behavior, Arabic audio playback, vehicle handling, Android export or performance on the physical target device.


## Optional open-world side activities — 2026-11-14

A first side-activity runtime is integrated through `scripts/world/side_activity_director.gd` and `main.gd`. Four distinct activity patterns are available in the early world: recover a lost delivery, collect and return three farmer crates, retrieve a roadside repair kit, and reunite a lost dog with its owner. Activities are accepted from a nearby mobile-friendly HUD button, use different target counts, award 80–140 currency, and save completed IDs plus total rewards to `user://gta_ghibli_side_activities.json`.

The data catalogue is `data/world/side_activities.json`; the headless regression test is `tests/side_activity_director_test.gd`. This is a functional blockout, not final content: people, dog, package, crates and repair kit are simple visual markers; the current interactions are proximity-based. Final character/animal models, carry animations, voice lines, richer task logic and Android touch testing remain outstanding.


### ذاكرة علاقات الشخصيات غير القابلة للعب

يحفظ نظام `npc_brain.gd` مستوى الثقة والألفة لكل شخصية في ملفات محلية منفصلة داخل `user://npc_relationships/`، ويستعيدها عند إنشاء الشخصية مجدداً. يمكن ضبط `persistence_id` كمعرّف ثابت لتفادي الاعتماد على اسم العقدة، وتعطيل الحفظ عبر `relationship_persistence_enabled` عند الحاجة. الحفظ محلي على جهاز اللاعب ولا يرسل بيانات إلى الإنترنت. هذا النظام أولي ولا يربط العلاقات بعد بكل الحوارات والمهام والاختيارات القصصية.


### احتياجات اللاعب والطعام والشراب

أضيف مكوّن `player_needs.gd` للاعب بثلاث قيم: الجوع والعطش والطاقة. تنخفض تدريجياً مع وقت اللعب، ويمكن استعادتها عبر الطعام والشراب والراحة. تُحفظ القيم محلياً في `user://player_needs.json`، ويصدر النظام إشارة عند وصول حاجة إلى مستوى حرج، كما يوفر معامل حركة عند الجوع أو العطش الشديد. قائمة العناصر الأولية موجودة في `data/items/consumables.json`. هذا إصدار نظامي أولي؛ لم تُربط العناصر بعد بمتاجر فعلية أو واجهة شراء أو رسوم/حركات الأكل والشرب.


### حقيبة الطعام والشراب

يرتبط `consumable_inventory.gd` بعقدة اللاعب ويفتح كتالوج `data/items/consumables.json`. يدعم إضافة العناصر وإزالتها وعدّها واستهلاكها، ويرسل إشارات عند تغير الحقيبة أو استهلاك عنصر. عند أكل الطعام أو شرب الماء يحدّث مكوّن احتياجات اللاعب، ويحفظ محتويات الحقيبة محلياً في `user://player_inventory.json`. الاختبار الآلي يغطي تحميل الكتالوج، الإضافة، الاستهلاك، وتأثير الطعام والشراب. واجهة المتجر والشراء ورسوم الأكل والشرب لم تُنفذ بعد.


### ساعة العالم ودورة النهار والليل

يدير `world_clock.gd` وقتاً موحداً للعالم، ويعرض المرحلة (فجر، نهار، غروب، ليل) والوقت بصيغة 24 ساعة. يحدّث اتجاه الشمس وشدة ضوئها، ويرسل الساعة إلى أدمغة الشخصيات لتفعيل جداول العمل والراحة. كما يقرأ نظام أصوات الطبيعة الساعة المشتركة بدلاً من حساب وقت مستقل. دورة الوقت قابلة للضبط في خصائص العقدة، ويمكن تغيير الوقت عبر `set_time(hour, minute)` لأغراض الاختبار والمشاهد. دورة الطقس الديناميكية الكاملة والإنارة الليلية للمباني ما زالت بحاجة إلى تنفيذ.


### المحفظة ومتجر قرية الصفصاف

أضيف `player_wallet.gd` لمحفظة اللاعب مع رصيد ابتدائي قابل للضبط وحفظ محلي. متجر `consumable_shop.gd` موجود الآن قرب المخبز في Willow Village؛ يفتح عند التفاعل ويعرض ستة منتجات بأسعار محددة، ويتحقق من الرصيد قبل الخصم ثم يضيف المشتريات إلى حقيبة الطعام والشراب. مكافآت الأنشطة الجانبية تضاف إلى المحفظة عند إكمال النشاط. الاختبارات تغطي الرصيد والشراء وإضافة المنتج إلى الحقيبة. هذه نسخة أولية من اقتصاد اللعبة؛ لا تشمل بعد متاجر متعددة أو تفاوض الأسعار أو نظام بيع العناصر.


### توسيع العالم المفتوح إلى أربع مناطق

أضيف `open_world_regions.gd` لتوليد أربع مناطق منفصلة حول قرية الصفصاف: مدينة الميناء، مرتفعات الصنوبر، وادي الكهرمان، وساحل الياقوت. يتضمن كل حي مساحة أرضية مميزة وستة مبانٍ تصادمية؛ وتختلف التفاصيل بين حاويات الميناء وأشجار المرتفعات وصفوف الزراعة ومرفأ الساحل. رُبطت المناطق بطرق مرئية مع مركز العالم، وأضيف ثمانية مدنيين تجريبيين بجداول دوام وراحة وذاكرة علاقات منفصلة. هذه مناطق blockout قابلة للاستكشاف وليست خرائط نهائية مفصلة؛ ما زالت تحتاج نماذج أصلية عالية الجودة، تفاصيل داخلية، وطرق ذات تصادمات ومركبات مرور.


### الحياة البرية والتفاعل مع الحيوانات

أضيفت نماذج أولية للغزال والأرنب والنورس في موائلها المناسبة: مرتفعات الصنوبر ووادي الكهرمان وساحل الياقوت. تتحرك الحيوانات داخل نطاق تجوال، وتهرب عند اقتراب اللاعب، ويمكن إطعامها بالجزر أو التوت البري من الحقيبة. بعد إطعام الحيوان مرتين يدخل حالة مرافقة بسيطة ويتبع اللاعب على مسافة قصيرة. الكتالوج في `data/world/wildlife_catalog.json`، ويختبر `wildlife_director_test.gd` إنشاء 12 حيواناً واستهلاك الطعام وتكوين رابطة. الأشكال والحركات مؤقتة؛ لا توجد بعد هياكل عظمية أو تحريك نهائي أو أصوات منفصلة أو نظام بيطري/تكاثر.


### الطقس والأمطار

أضيف `world_weather.gd` للتحكم في حالات الجو: صافٍ وممطر وعاصفة. يستخدم المطر مؤثر جسيمات محدود العدد (110 للمطر و190 للعاصفة) لتقليل التكلفة على الهاتف، ويتبع اللاعب حتى لا يُنشأ مؤثر ضخم على كامل الخريطة. يرسل النظام حالة الطقس إلى أصوات الطبيعة لتتغير طبقات المطر والرياح والطيور. التغيير التلقائي اختياري ومعطل افتراضياً حتى لا يفاجئ اللاعب؛ يمكن تفعيله من خصائص العقدة. لا توجد بعد سحب volumetric أو بلل للأسطح أو برك أو عواصف رعدية برق مرئية.


### حزمة الأصوات البيئية الأصلية

أضيفت 12 مقطع WAV أصلياً مولّداً تركيبياً، موزعة على ست بيئات: الفجر، الغابة نهاراً، الليل، الساحل، المطر، والعاصفة. كل بيئة تتكون من مقطعين متتابعين مدة كل منهما 22.5 ثانية، ليشكلا دورة مدتها 45 ثانية. المواصفات 22,050 هرتز، ستيريو، PCM بدقة 16 بت. يختار `nature_ambience.gd` المجموعة وفق ساعة العالم والمنطقة والطقس، ويشغّل طبقة الصوت الجديدة بمستوى منخفض فوق المؤثرات الإجرائية الحالية. هذه أصوات مصنّعة للمشروع وليست تسجيلات طبيعية حقيقية؛ ولا تمثل بعد الدبلجة العربية التمثيلية المطلوبة للشخصيات. اختبار `nature_ambience_assets_test.gd` يتحقق من تحميل WAV وتبديل البيئات.


## 13. Repair candidate verification status — 2026-11-20

- The Android ARM64 Debug workflow is present again on PR #31, restored from the current `main` copy. Its new run is pending; do not quote an older APK size for the current head.
- Unified save restore now accepts only the named legacy save paths and flat safe-ID NPC relationship JSON files. The new regression checks a legacy-file round-trip and rejects unrelated/traversal writes; CI is pending.
- District NavigationAgent3D path following is PARTIALLY IMPLEMENTED. Avoidance remains disabled and there is no connected world-wide NavMesh.
- Physical Android install/touch/FPS/RAM/thermal/audio acceptance remains NOT VERIFIED.
- Arabic dialogue performance remains incomplete until local offline audio files are present and playback is tested; synthetic TTS must not be labelled human acting.
- No new asset was added in the save-safety/CI repair commit, so the ownership/asset register has no new row to add.


## Sapphire Coast seafood market — IMPLEMENTED on repair candidate

The district instantiates a functional Arabic fishmonger stall using the existing original market-stall model and a new six-material seafood-display mesh (timber, ice, silver fish, golden fish, red fish and weighing-scale details). Three ready-to-eat foods are added to the consumables catalogue: grilled sardines, seafood stew and red mullet plate. The vendor uses the common `interact()` contract, debits the player wallet, grants the food to inventory and refunds the debit if item delivery fails. The foods use the existing consumption/needs system. Regression coverage checks imported display surfaces, world placement, purchase signals, wallet/inventory, food use, unknown products, insufficient funds and interaction range. **CI verification is pending; physical-device performance is NOT VERIFIED.**


## 6A. Sapphire Coast lighthouse landmark

**Implemented on the repair candidate:** `scenes/world/coastal_lighthouse.tscn` adds an original 19.8 m coastal tower to Sapphire Coast. Its seven-material OBJ model includes dressed stone courses, tapered plaster masonry, framed glass windows, a brass balcony rail, a lantern room, copper roof and timber entry. The MTL references two project-authored tiled SVG surface textures. `scripts/world/coastal_lighthouse.gd` adds solid tower collision, a shared proximity interaction prompt in Arabic, and a rotating SpotLight3D beacon that activates at dawn, dusk and night and switches off during daytime. Real-time shadows are disabled for mobile cost control. `tests/coastal_lighthouse_test.gd` checks model import, collision, interaction, time-of-day state and rotation; world integration is also checked in `tests/open_world_regions_test.gd`. This is source integration only until current-head Godot import and CI tests pass; physical-device rendering/performance is not claimed.


## 2026-11-21 reliability implementation addendum

### Unified save migration

When the configured unified save does not exist, GameSaveManager now checks its allowlisted legacy save paths. If legacy data exists, it reloads the compatible subsystem state and writes a versioned unified snapshot rather than starting from defaults. During restore, legacy files are restored and reloaded first; authoritative versioned snapshots are applied afterwards so stale compatibility files cannot overwrite newer wallet/needs state.

Regression coverage: first-launch migration, wallet balance and reward transaction ledger, hunger/thirst/energy, canonical snapshot precedence over deliberately stale legacy files, player transform, NPC relationship round-trip and traversal rejection. **Status: PARTIALLY IMPLEMENTED** until every mission 001–004, side activity, world entity, NPC schedule and vehicle condition is verified across a full restart.

### NPC navigation-agent lifecycle

NPCBrain now defers creation of its NavigationAgent3D sibling until the owning Node3D has completed its child setup. The agent's navigation map is resolved through the owning Node3D when the agent enters the tree; the brain frees the sibling agent when it exits. Tests cover actors whose brains are attached before the actor enters the SceneTree and world-clock schedule integration.

The Godot 4.7 test run #797 passed the individual navigation tests but its log exposed a wrong get_world_3d call on NavigationAgent3D and a headless root-viewport scenario warning. The current head corrects the world lookup through the owner and gives the district test its own SubViewport World3D. Run #798 is the pending verification. Continuous region/road connectivity, avoidance and physical NPC behavior remain planned/partial.


## Latest verification — 2026-11-21

The save migration and deferred NPC navigation-agent lifecycle passed the Godot 4.7 validation workflow #798 on game-code commit ab9e707. The Android Debug APK build #561 passed on that same code commit at 254,232,075 bytes raw. The subsequent 1c8da7 commit changes documentation only. The latest Web export and private Chromium reruns (#94 and #192) were still in progress when this record was written. Navigation remains partial: district grids and test path queries are not yet proof of continuous road links, obstacle avoidance, no-path recovery or physical-device NPC performance.
