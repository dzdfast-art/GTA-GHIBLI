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

**Prototype implementation added:** `scripts/systems/player_interactor.gd` detects nearby registered interaction areas, selects the nearest target and calls its `interact()` method. Mira is the first target migrated to this contract; the shared mobile/keyboard action is routed through the player. A physics-backed proximity test is included in CI, pending confirmation of the latest run.

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

NPC behaviors may include schedules, work, idle activities, conversations, reactions, help requests, fear, friendliness, conflict and mission behavior. Use distance-based simulation and population limits for mobile performance.

**Arabic audio requirement:** important dialogue must be genuinely voiced in Arabic with expressive emotional performance, consistent character voices and synchronized subtitles. Text plus an empty audio path is not dubbing. Audio remains incomplete until a real audio asset is integrated and playback is tested.

## 6. Nature, food and daily-life systems

Planned interactions include:
- Plants, trees, flowers, crops, fruit, water, fishing and suitable wildlife.
- Gathering, planting, watering, harvesting and animal care where they support gameplay.
- Food, drinks, shops, cafés, restaurants, cooking and ingredient collection.
- Meaningful player-state effects such as health, energy or hunger only where useful.

Avoid turning daily-life features into repetitive chores. Every activity should have a clear gameplay purpose, feedback and proportionate reward.

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

**Current prototype:** the first tutorial mission tracks reaching the village square, talking to Mira and visiting the garden. Its flags persist locally. The displayed currency reward is not yet connected to a real wallet or inventory.

## 9. World, buildings and services

The master specification requires four connected regions—Harbor City, Sapphire Coast, Pine Highlands and Amber Valley—and the named location Marsa Al-Noor. The existing Green Valley/Wllow Village content is a prototype slice, not a replacement for those canonical locations.

Buildings and services should have clear interaction levels:
- Exterior-only scenery with correct collision.
- Enterable interiors.
- Functional service locations such as shops, restaurants, garages and clinics.
- Mission-critical locations with scripted interactions.

Do not imply that every building is enterable. Document which category each location belongs to.

## 10. Save, progression and data

**Implemented in prototype:** versioned local save for the first mission's three progress flags.

**Planned:** a centralized versioned save manager for player position/state, mission progress, inventory, currency, settings, unlocked regions and relevant vehicle/world state. Include validation, defaults, migration and corruption handling.

## 11. Mobile performance and content budget

Target Android baseline: Infinix SMART 8, Unisoc T606, 4 GB physical RAM, 720 × 1612 display. Virtual RAM is not equivalent to physical RAM.

Use mobile renderer settings, LOD, instancing, culling, simplified collision, distance-based NPC/traffic updates, region streaming, compressed textures/audio and adjustable graphics.

The approximately 4 GiB content goal is an auditable storage/content budget, not a runtime RAM goal. Track source assets, imported project size, download size, installed size and update size separately. Never add empty or duplicate files to inflate size.

## 12. Current verification

GitHub Actions run [43513899542](https://github.com/dzdfast-art/GTA-GHIBLI/actions/runs/43513899542) passed all eight validation steps: JSON validation, Godot 4.7 resource import, script parsing, first-mission objective/save test and 180-frame main-scene smoke test.

This does not verify rendered quality, real touch behavior, Arabic audio playback, vehicle handling, Android export or performance on the physical target device.
