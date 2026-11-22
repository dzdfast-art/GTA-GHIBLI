# GTA GHIBLI — Master Requirements Alignment

**Status:** requirements baseline and discrepancy register  
**Primary source:** `GTA_GHIBLI_FULL_PROMPT.txt`  
**Engine in the current prototype:** Godot 4.7 (headless CI validation)  
**Current target:** Godot 4.7 Web for modern browsers. The earlier Android / Unisoc T606 baseline is historical and is not a current acceptance gate.  
**Content growth:** no fixed final size ceiling; every increase must be genuine, useful, licensed/original and remain compatible with stable Web loading and browser runtime performance.

This document turns the supplied master prompt and the current repository evidence into one controlled implementation baseline. It does not claim that planned systems already exist.


## Current platform directive — 2026-11-22

The user has changed the current delivery target to **Godot 4.7 Web only**. Do not require, run or wait for Android APK builds, physical-phone testing, ARM64 installation, or phone-specific RAM/FPS/thermal checks. Accept the Web candidate using Godot 4.7 validation, Web export, private Chromium/WebGL 2 smoke tests, browser keyboard/mouse tests and Web privacy/security audits. Retain legacy Android source/configuration unless a separate explicit removal request is given; it is not part of the current release gate. Web exports must remain temporary and localhost-only; do not upload public artifacts, deploy Pages or publish a URL.

## 1. Authority and project identity

1. `GTA_GHIBLI_FULL_PROMPT.txt` is the governing product specification. Preserve its requirements and named entities.
2. The GitHub repository is evidence of implementation only. A file or design note is not proof of a working feature.
3. GTA San Andreas is a reference for breadth and systemic gameplay. GTA GHIBLI must use original maps, characters, missions, dialogue, UI artwork, music, models, and other assets.
4. Do not silently replace the master specification with prototype names or prototype content.
5. Do not delete the current prototype or claim it is the final game's foundation until a safe migration/new-project decision has been documented.

## 2. Canonical world and cast from the master prompt

### Required regions and location

- Harbor City
- Sapphire Coast
- Pine Highlands
- Amber Valley
- Marsa Al-Noor — a named, meaningful location whose exact placement must be defined on the world map.

### Required named characters

- Leo Bennett — main protagonist
- Claire Bennett — Leo's mother
- Mia Bennett — Leo's sister
- Nora Blake — established named character

Do not invent agreed ages, biographies, precise relationships beyond those stated, or character arcs. Develop missing details as proposals and record them as such.

## 3. Prototype-to-specification discrepancies

| Area | Current repository prototype | Master requirement | Treatment |
|---|---|---|---|
| World | Green Valley: Willow Village, Sunmeadow Fields, Old Mill Road, Mistwood Edge | Harbor City, Sapphire Coast, Pine Highlands, Amber Valley, plus Marsa Al-Noor | Keep prototype data identifiable as prototype; do not silently rename canonical regions |
| Cast | Mira caretaker prototype | Leo Bennett, Claire Bennett, Mia Bennett, Nora Blake and a larger original cast | Preserve Mira as a prototype/test NPC; do not replace or erase the required cast |
| Player | Capsule placeholder and basic third-person movement | Finished original character, rig, animations, interactions and state handling | Placeholder only |
| Dialogue | Arabic text and emotion metadata for Mira | Real expressive Arabic voice acting, consistent character voices, subtitles and synchronized presentation | Audio status remains pending until real audio is integrated and tested |
| Missions | One tutorial flow: square → Mira → garden | Main story, side missions, jobs, dynamic encounters and varied activities | Current mission is a small prototype, not the campaign |
| Vehicles | First drivable road-car prototype added: enter/exit, forward/reverse, steering, braking and contextual mobile HUD; procedural placeholder art | Cars, motorcycles, bicycles, vans, trucks, heavy vehicles, boats, aircraft, helicopters and other suitable transport | Expand vehicle physics and category-specific classes; physical Android handling test remains outstanding |
| Interaction | Mira proximity and TALK action | Reusable interactions with people, objects, buildings, food, nature and vehicles | General interaction framework remains to be implemented |
| Save | Existing per-system local persistence on main | Candidate branch adds a versioned coordinator for player/world clock/components/missions/activities/NPC relationships/vehicle condition and allowlisted legacy files | PARTIALLY IMPLEMENTED; current regression covers player transform and legacy NPC-file restore safety, while full historical migration and all world entities remain unverified |
| Platform | Godot headless CI | Android export, install, launch and physical-device testing | Not yet verified on device |

The master prompt also says the final project should be a genuinely new project from an empty directory and should not depend on old B1–B16 prototypes. The current repository contains a working starter prototype. This is a production decision that must be handled explicitly: preserve the current work as a prototype/history, and establish a clean production project separately if required by the specification. Do not destructively overwrite the existing project or mislabel it as the final clean-start build.

## 4. Required gameplay pillars

### 4.1 Physics and object interaction

The interaction design must support, when appropriate:
- Pick up, carry, drop, inspect, collect, push, pull, move, open, close, use and activate.
- Doors, gates, drawers, switches, furniture, tools, containers and mission objects.
- Object-specific collision, mass/weight behavior, gravity, friction, impact and breakability.
- Contextual prompts and animations; actions must be real and testable, not decorative buttons.
- Sensible limits for mobile performance. Not every tiny prop needs a fully simulated rigid body.

### 4.2 People and living world

- A larger original cast with distinct identities, roles, appearances, voices and motivations.
- Named story characters separated from generic pedestrians and background population.
- NPC routines, conversations, reactions, relationships, work roles and mission-specific behavior.
- Arabic voice dialogue with emotion/performance direction, subtitles and consistent voice identity.
- Ambient population and traffic scaled by distance and device performance.

### 4.3 Nature, food and daily activities

- Interactions with plants, trees, flowers, crops, water, weather and suitable wildlife.
- Gathering, farming, fishing and animal care where they support the world and story.
- Food and drink, shops, cafés, restaurants, cooking and useful player-state effects.
- Sleep/rest and other needs only where they create meaningful gameplay rather than busywork.

### 4.4 Vehicles and transport

Vehicle categories must not be treated as interchangeable static models:
- Road: cars, sedans, sports cars, vans, utility vehicles, buses, trucks and heavy vehicles.
- Two-wheel: motorcycles and bicycles.
- Marine: boats and other suitable watercraft.
- Air: airplanes and helicopters where performance and design justify them.
- Other: carts, trailers and special transport where useful.

Each implemented category needs real entry/exit, collision, movement, handling, camera behavior, sound, animations where required, and an appropriate mobile HUD. Cars/trucks, motorcycles, boats and aircraft require different control profiles. A static model does not count as a drivable vehicle.

### 4.5 Characters, missions and variety

- Main story missions, character side stories, jobs, delivery, driving, exploration, rescue, investigation, races, environmental tasks, challenges and optional encounters.
- Every mission needs a start condition, objective logic, success/failure handling where relevant, rewards/progression, dialogue and save behavior.
- Every important character needs a meaningful role; avoid adding near-duplicate characters solely to inflate population.
- Reduce excessive repetition: compare mission mechanics, locations, dialogue, rewards and narrative purpose before adding content. Reuse a mechanic only when the context or challenge changes meaningfully.
- Repeated everyday objects (roads, trees, shops) are acceptable when natural; repeated filler content is not.

## 5. Web controls and browser performance

- Context-sensitive browser HUD states: on-foot, interacting, nearby vehicle, car/truck, motorcycle, boat and aircraft where implemented.
- Keyboard and mouse are the primary desktop browser input path: WASD movement, right-mouse drag camera orbit, E interaction and Shift sprint.
- Verify browser canvas focus, pointer capture/release, window resizing, keyboard mapping and WebGL 2 using private Chromium on localhost.
- Physical Android phones, APK installation, touchscreen feel and phone-specific RAM/FPS/thermal readings are not required for the current Web deliverable.
- Use LOD, instancing, culling, simple collision, distance-based AI and region streaming to avoid browser stalls and excessive asset download size.
- Record Web export folder size, temporary ZIP size and tracked Git blob totals separately; none is an APK size or a browser runtime-memory measurement.

## 6. Current verified implementation snapshot

Repository inspection confirms:
- Godot project and main scene exist.
- Third-person capsule placeholder, camera-relative movement and touch-orbit camera exist.
- On-screen movement controls and a TALK action exist.
- Willow Village is a procedural greybox.
- Mira has proximity interaction, Arabic dialogue text and emotion metadata.
- Mira's audio asset is still marked `pending_generation`; no real integrated Arabic voice file is verified.
- The first mission reads JSON objectives, tracks the square/Mira/garden sequence and saves/restores those mission flags locally.
- The mission reward is displayed as prototype information; it is not a real currency/inventory system.
- A shared player interaction router now detects nearby registered interaction areas and dispatches the common `interact()` contract; Mira is the first target migrated to it. A new physics-backed proximity/dispatch test has been added to CI, but its latest run is not yet verified.
- A first drivable road-car prototype is present, with enter/exit, forward/reverse, steering, braking and a contextual mobile HUD. A headless test initially covered enter/forward/exit; the latest test commit adds reverse, steering, braking and collision/visibility restoration assertions. Those expanded assertions are awaiting CI confirmation and have not been run on a physical Android device.
- Advanced vehicle physics (suspension, tire grip, damage, repair, fuel, audio, passenger seats and traffic AI), other vehicle classes, a complete movable-object physics system, full NPC population and campaign are not implemented.

GitHub Actions run **43513899542** completed successfully: JSON validation, Godot 4.7 import, gameplay-script parsing, first-mission flow test and 180-frame main-scene smoke test all passed. This is a headless CI result, not Android/device validation.

## 6A. Comprehensive repair candidate branch — 2026-11-20

This section records changes on `fix/comprehensive-stability-2026-11-20`. They are **not merged into `main`**. Their new tests are pending the draft pull request's CI run until a run URL and conclusion are recorded.

- The tested gameplay HUD/player/traffic/bicycle tutorial work from PR #30 was copied onto this isolated branch as a parent commit; the PR itself was not merged.
- On-foot RUN now multiplies base movement speed by a configurable sprint multiplier (default 1.6) while the sprint action is held. A regression assertion was added.
- The local wallet now stores one-time reward transaction IDs with its balance (schema version 2, reads old balance-only files). Mission 001–004 completion paths use unique transaction IDs to prevent duplicate reward payments.
- STATS now reads the live wallet, health when present, player needs, world clock, district and population counts, mission completion count and saved side-activity completions.
- BRIEF now reads mission JSON titles/descriptions, saved progress and the active mission HUD snapshot.
- The pause menu test now checks the required seven-item order and live STATS/BRIEF data.
- The 72 existing terrain tile paths are retained, but the candidate replaces eager preload/attachment of all meshes with 72-unit load radius, 96-unit unload radius, six active-tile limit and at most two loads per 0.35-second refresh. Each loaded visual gets a matching trimesh collision.
- An original SVG application icon is added and configured in `project.godot`.
- Marsa Al-Noor is recorded as a proposed Harbor City waterfront landmark at local coordinate (14, 0, 10), world coordinate (-68, 0, -44). It is explicitly a candidate placement proposal, not a confirmed story/canon fact. A scene landmark, world-map marker and matching regression test are included.
- The candidate includes a first-pass unified save coordinator and district NavigationAgent3D routing, both PARTIALLY IMPLEMENTED. It does not claim complete world persistence, connected world-wide NavMesh/obstacle avoidance, expressive Arabic voice recordings, production-grade vehicle physics or physical Android validation. The Android ARM64 Debug workflow has been restored and its current run is pending.

The separate `web-preview` branch already completed the private Chromium smoke test on Ubuntu 24.04 (workflow run #14). This candidate branch does not publish Web content.

## 7. Production order and acceptance gates

1. Resolve the clean-production-project versus existing-prototype boundary without losing history.
2. Establish canonical world/cast data from the master prompt.
3. Build a reusable interaction contract and contextual interaction manager.
4. Make one representative object interaction and one NPC interaction pass end-to-end tests.
5. Add the first real vehicle with entry/exit, handling, collision and mobile HUD state; test transitions.
6. Expand the mission framework with distinct mission templates and a repetition audit.
7. Add the living-world, nature, food, shops, traffic and broader vehicle classes incrementally.
8. Integrate actual Arabic voice assets and verify playback/subtitle timing.
9. Build and test the Android export on the target phone.
10. Expand unique assets and regions against the auditable 4 GiB content budget.

A gate passes only when its implementation and tests exist. Keep **implemented**, **planned**, **blocked**, and **tested** statuses separate.


## 6B. Save, navigation and Android workflow status — 2026-11-20

- Unified save coordinator: PARTIALLY IMPLEMENTED on PR #31. It captures current player transform, world clock, health/wallet/needs/inventory snapshots, mission and side-activity snapshots, NPC relationship snapshots, vehicle condition and allowlisted legacy save files. It does not yet cover every spawned/destroyed world object, collectible, NPC transform or future subsystem.
- Legacy restore safety: IMPLEMENTED in the candidate code; regression is PENDING. Restore is restricted to named legacy save paths and flat safe-ID NPC relationship JSON files. Unrelated user files and traversal paths are rejected; each restored legacy record is limited to 2 MiB.
- NPC navigation: PARTIALLY IMPLEMENTED. Four prototype district grids and NavigationAgent3D path following exist; avoidance is disabled and the village, roads, interiors and all districts are not one continuous navigation surface.
- Android: ARM64 Debug export workflow restored from `main`; current run is pending. A Debug artifact is not a signed production release and is not a physical-device test.
- Content growth: no fixed numeric ceiling. Keep separate byte measurements for tracked unique blobs, raw APK, Web export and artifact ZIP. Only useful original/licensed content counts.


## 6C. Harbor City public water interaction — 2026-11-20

- **Public drinking fountain:** IMPLEMENTED on `fix/comprehensive-stability-2026-11-20`. An original low-poly 3D model and material library are loaded by a reusable Godot scene placed in Harbor City's plaza.
- **Gameplay contract:** PARTIALLY IMPLEMENTED pending current-head verification. The shared `interact()` action restores up to 30 thirst points through `PlayerNeeds`, with range, full-thirst and cooldown guards plus Arabic feedback.
- **Regression coverage:** IMPLEMENTED, TEST PENDING. A dedicated fountain test checks the gameplay effects; the district test checks that the actual Harbor City world scene instantiates the fountain and exposes its interaction area.
- **Performance / device acceptance:** NOT VERIFIED. The target 4 GB / Unisoc T606 Android device has not been used to inspect the model, measure RAM, FPS, load time or thermal impact.
- This feature is a candidate-branch addition only. It has not changed `main` and requires PR #31 review and CI before it can be considered accepted.


## 6D. Sapphire Coast seafood market — 2026-11-20

- **World content:** IMPLEMENTED on the repair candidate. A working fishmonger stand is placed along the Sapphire Coast, reusing the existing market-stall asset and adding an original fish/ice display mesh with six material groups.
- **Food catalogue:** IMPLEMENTED in source. Grilled sardines, seafood stew and red mullet plate are edible consumables with nutrition, hydration and energy values.
- **Wallet and inventory:** IMPLEMENTED in source. The vendor checks range and balance, grants products to inventory and refunds money if delivery fails. Items use the shared food-consumption contract.
- **Regression:** IMPLEMENTED, TEST PENDING. The new test checks mesh import, products, purchase signals, wallet, inventory, food effects, unknown products, insufficient funds and range rejection. The four-district test checks actual Sapphire Coast placement and interaction registration.
- **Android acceptance:** NOT VERIFIED. No physical target-device profiling was performed.
- This remains a Draft PR #31 candidate. It is not included in `main` until owner review and an explicit merge.


## 2026-11-21 implementation evidence update

- **Save:** The repair candidate now creates the unified versioned save on first launch when allowlisted legacy subsystem files exist and no unified save is present. Compatibility files are restored/reloaded first; versioned snapshots are applied last. The test verifies wallet balance, reward transaction IDs, hunger/thirst, stale legacy precedence, player transform and NPC relationship path safety. This is still **PARTIALLY IMPLEMENTED** because full mission, activity, world-object, vehicle and NPC-schedule restart coverage is not complete.
- **NPC navigation:** Agent attachment is deferred until the owning Node3D finishes child setup, and the navigation map is resolved from that Node3D owner. Regression coverage includes the pre-parented actor case and world-clock scheduling. The latest Godot validation #798 is still in progress at this update; do not mark this fully tested until its log is clean.
- **Build evidence:** The last measured Debug APK is 254,227,979 bytes on commit 9005973; current-head Android build #561 is in progress. No physical Android device test is claimed.
- **Performance:** Four district navigation grids and lightweight NPC path queries are CI prototype coverage, not proof of continuous open-world routing or 4 GB device performance.
- **Voice:** The 25 Arabic dialogue lines still require genuine expressive recordings or explicitly labelled AI-generated TTS; no completed human dubbing is claimed.


## Latest CI evidence — 2026-11-21

The NPC navigation lifecycle and save-migration code passed Godot validation #798 on game-code head ab9e707abed1863141418a8a17caa77cf9a1fe66. Android Debug APK #561 also passed on that code head at 254,232,075 raw bytes (254.232 MB / 242.455 MiB). The later 1c8da7 documentation commit changes documentation only. Security audit #743 passed. Current Web Build #94 and private Chromium #192 remain pending/in progress in the latest recorded state. No physical T606/4 GB device test has been performed.


## 2026-11-22 save-recovery alignment

- **Side activity progress:** IMPLEMENTED in source; TEST PENDING on commit 6fc51d0. Active IDs, collected-target visibility, counters and timestamps are persisted and restored with recreated markers.
- **Side activity rewards:** IMPLEMENTED in source; TEST PENDING. Stable wallet transaction IDs prevent duplicate payouts and support recovery after an interrupted completion.
- **Wallet restore precedence:** IMPLEMENTED in source; TEST PENDING. A newer compatibility wallet is timestamped, its transaction ledger is merged with the unified snapshot, and an existing on-device legacy file is not overwritten by an older embedded copy.
- **Unified save coverage:** PARTIALLY IMPLEMENTED. This change does not prove restart persistence for every mission phase, every world object, all NPC schedules or every vehicle.
- **Assets and performance:** no new assets or runtime content were added in this pass; target-device FPS/RAM/thermal acceptance remains NOT VERIFIED.


## 2026-11-22 Web privacy requirement

- **Web gameplay validation:** TESTED on commit 3d4083a in private Chromium; the preview used a local-only server, initialized WebGL 2, delivered browser input, and made no external network requests.
- **Web artifact distribution:** BLOCKED pending cleanup of the artifact from run #45008944503. The Web Build workflow has been changed to delete old GTA-GHIBLI-Web artifacts, keep size/hash measurements in logs, and remove the temporary export without uploading a bundle. No public hosting or Pages deployment is used.


- **Artifact cleanup:** TESTED for deletion of prior Web artifact 14748948497 (the previous run's artifact list is empty). The initial parallel cleanup produced one harmless 404 race; the workflow now treats an already-deleted artifact as success and serializes Web builds.


## 2026-11-22 — NPC save contract alignment

- **NPC transform and daily schedule snapshots:** IMPLEMENTED in `NPCBrain` and TESTED through the unified save manager on code/test head `2495553`. Captured values include actor global position/rotation, schedule enablement, current world hour, work-hour bounds, work/home positions, wander-home origin and relationship values.
- **Backward compatibility:** TESTED for the existing relationship-only snapshot contract; the new fields are optional when loading older saves.
- **NPC population coverage:** PARTIALLY IMPLEMENTED. Only currently instantiated nodes in `npc_brains` are captured and restored. Stable IDs, streamed NPC spawn-after-load restoration, transient alarm state and all world entities still need coverage.
- **Mission 001–004:** individual objective/flow tests passed in Godot #45011215857. Full process-stop/restart at every phase, reward interruption and cross-mission snapshot restore are NOT VERIFIED.
- **Android/Web/security:** Android ARM64 Debug #45011215912, private Web + Chromium #45011215840, Web Build #45011215820 and security audit #45011215838 passed on the same code/test head.
- **Performance:** target T606/4 GB device FPS/RAM/thermal/touch/audio acceptance remains NOT VERIFIED.
- **Voice:** BLOCKED for bundled offline delivery; text acting directions are tested, but local human/AI dialogue clips and offline playback are not present/verified.

## 2026-11-22 — Mission 002 save/resume continuity — TESTED

- Mission 002 snapshots retain both pursuer visibility states and whether the rescued witness is attached as a passenger. Older snapshots without these keys use phase-aware defaults.
- Restoring an active escape phase recreates the passenger visual on the saved vehicle and restores the witness/pursuer visibility.
- Mission 001–004 save writers explicitly flush, inspect write status and close files at mission-save boundaries.
- Regression test simulates the rescue actors being removed, restores the active pursuit from its snapshot, then continues the escape.
- **Verified code commit:** `bf5e730a91a1d002e11cd7238bc75edf19d8b668`.
- **Godot 4.7 validation #810:** PASS — import, GDScript parse, mission 001–004 tests and main-scene smoke. [Run](https://github.com/dzdfast-art/GTA-GHIBLI/actions/runs/45013217344)
- **Android ARM64 Debug #573:** PASS — archive/package checks and APK size recorded. [Run](https://github.com/dzdfast-art/GTA-GHIBLI/actions/runs/45013217408)
- **Private Web + Chromium #214:** PASS — local-only WebGL 2 runtime, input events and no external requests. [Run](https://github.com/dzdfast-art/GTA-GHIBLI/actions/runs/45013217370)
- **Web Build #116:** PASS — export, browser smoke and exact sizes recorded; temporary export and ZIP removed after the job. [Run](https://github.com/dzdfast-art/GTA-GHIBLI/actions/runs/45013217390)
- **Security audit #755:** PASS — Gitleaks reported no leaks. [Run](https://github.com/dzdfast-art/GTA-GHIBLI/actions/runs/45013217336)
- Raw ARM64 Debug APK: **254,244,363 bytes** (254.244363 MB; 242.466319 MiB), +4,096 bytes versus the previous comparable APK.
- Temporary Web export: **378,793,008 bytes** (378.793008 MB; 361.245163 MiB). Web ZIP: **237,940,158 bytes** (237.940158 MB; 226.917418 MiB); SHA-256 `5c75f2201f285a3cd347307eb575f616b32a65c86870d08cd47b57408037e664`. Both are CI-only; no public Web artifact or hosting was created.
- No game assets were added in this code-only reliability change. Physical Unisoc T606 / 4 GB FPS, RAM, heat, touch feel, install and audio remain NOT VERIFIED.
- Non-fatal OBJ ambient-light warnings and headless RID/ObjectDB/resource teardown warnings remain; successful CI does not mean warning-free logs.

## 2026-11-22 — Mission 001 immediate persistence alignment

- Mission 001 now commits each durable objective transition to the unified save coordinator immediately after successfully writing its existing compatibility record.
- The mission regression now checks serialized snapshots for the square objective, Mira dialogue, completion/reward state, stale legacy-file recovery and reward idempotency.
- Status on source/test SHA 3d1849a6c98198dc87b0d1368b7cc91488d1d0a5: **IMPLEMENTED / TESTED** — Godot validation #814 passed, including the Mission 001 unified-save recovery regression. Security Audit #759 passed. Android #577 and Web/Chromium #223 were cancelled/superseded by the docs-only follow-up; current docs-head reruns #815, #578, #225 and #127 were in progress at the time of this update.
- This does not establish complete process-stop recovery for all missions or persistence for every world entity. Overall save alignment remains **PARTIALLY IMPLEMENTED**.
- main remains unchanged (c9fc82936a43b80af0e3c25eef41c9fee59e47b7); PR #31 remains Draft and unmerged.
