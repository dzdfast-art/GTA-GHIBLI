# GTA GHIBLI — Comprehensive Repair Candidate

Date: 2026-11-21 (latest verified candidate head recorded below)
Repository: `dzdfast-art/GTA-GHIBLI`
Base commit: `c9fc82936a43b80af0e3c25eef41c9fee59e47b7`
Branch: `fix/comprehensive-stability-2026-11-20`
Pull request: #31 (Draft, open, not merged)
Status: repair candidate; no changes to `main`, no public Web deployment.

## Repairs included on this branch

| Area | Implementation | Verification |
|---|---|---|
| RUN sprint | Sprint multiplier 1.6 applied while the on-foot sprint action is held | Existing Godot regression suite; final branch run pending |
| Wallet rewards | Versioned wallet ledger rejects duplicate reward transaction IDs | Existing wallet and mission regression tests; final branch run pending |
| Missions 001–004 | Completion rewards are credited through unique wallet transaction IDs | Existing mission tests; final branch run pending |
| STATS / BRIEF | Data-driven reports use live wallet, health, needs, time, regions and mission snapshots | Existing pause menu/report tests; final branch run pending |
| Terrain streaming | Preserves the 72-mesh catalog; near-load radius 72, far-unload radius 96, up to six active tiles and two loads per 0.35-second refresh | Existing terrain lifecycle regression; final branch run pending |
| District navigation | Four prototype districts receive lightweight authored navigation grids made from walkable cells around the six building footprints | New path-query checks in `open_world_regions_test.gd`; final branch run pending |
| NPC movement | NPC brains create NavigationAgent3D and use a live navigation map for wandering, schedules and fleeing; legacy direct movement remains a fallback only where no navigation region exists | Existing NPC tests plus district path-query checks; final branch run pending |
| Sapphire Coast seafood market | Functional Arabic vendor in Sapphire Coast; reuses the existing original stall model and adds a six-material fish/ice display, three edible catalogue items, wallet/inventory transactions and refund-on-delivery-failure | New `seafood_market_test.gd` and district integration assertions; current-head CI pending |
| Amber Valley vehicle service garage | Original six-material workshop OBJ/MTL, repair-lift and tool details, Arabic service UI, stopped-vehicle lookup, health-based full-repair quote, wallet charge/refund and shared interaction registration | New `vehicle_service_garage_test.gd` plus four-district integration assertions; current-head CI pending |
| Public drinking fountain | Original OBJ/MTL prop scene integrated into Harbor City plaza; shared interaction restores up to 30 thirst using PlayerNeeds, with cooldown and Arabic prompt/feedback | New `public_drinking_fountain_test.gd`; current-head CI pending |
| Vehicle condition | Vehicle health, collision-impact damage, disabled state, repairs, speed degradation and a serializable condition snapshot | New `vehicle_damage_repair_test.gd`; final branch run pending |
| Vehicle visuals | Rear brake lights and animated wheel meshes | New vehicle visual regression; final branch run pending |
| Unified local save | Versioned local save coordinator captures player transform, world clock, player components, mission snapshots, NPC relationships, vehicle state and allowlisted legacy JSON/CFG files | `game_save_manager_test.gd` checks a legacy NPC file round-trip and rejects unrelated/traversal restore paths; full-world persistence remains partial |
| Save recovery | Writes a temporary file, validates its JSON/schema, preserves a previous backup and then replaces the active local save | Included in unified save manager; final branch run pending |
| Web dialogue privacy | Prevents Mira and world NPC dialogue from requesting remote audio when running as a Web build; bundled and cached clips remain eligible | New `web_dialogue_privacy_audit.py`; final branch run pending |
| Application icon | Adds an original SVG icon and connects it in project settings | Previous Godot import and APK build passed on earlier stable candidate commit |
| Marsa Al-Noor | Candidate Harbor City landmark and map marker; position is explicitly documented as a story/design proposal | Previous canonical-world regression passed; owner/story approval still required |

## Technical evidence retained from earlier successful commit

The earlier candidate commit `518205b8b73e8741dcc373ff818687b3a110af36` passed:
- Godot validation run #677: https://github.com/dzdfast-art/GTA-GHIBLI/actions/runs/44640989501
- Android ARM64 Debug APK run #447: https://github.com/dzdfast-art/GTA-GHIBLI/actions/runs/44640989559
- Repository secret scan: https://github.com/dzdfast-art/GTA-GHIBLI/actions/runs/44640989613

That APK was measured at 250,755,028 bytes (250.76 MB decimal / 239.14 MiB). It is an earlier Debug APK, not an artifact from the latest repair commits. Do not claim that size for the newest branch head until the latest Android workflow finishes.

The separate private Web Preview Chromium smoke test passed on `web-preview`, not on this repair branch:
https://github.com/dzdfast-art/GTA-GHIBLI/actions/runs/44633964747

## Still incomplete or constrained

- The 25 Arabic dialogue lines have existing or cached clips, but all are still flagged for expressive performance retakes. The new Web guard does not create new recordings and does not make Android dialogue fully offline.
- No physical Android device is connected. Touch feel, real-device FPS, RAM, thermal behavior, speaker output and installation cannot be certified from headless CI.
- Navigation grids are currently authored for four prototype districts. The village slice and wider roads are not yet one continuous world-wide NavMesh; disconnected areas continue to use the prototype fallback.
- NPC avoidance, obstacle-aware combat reactions, advanced car suspension/tire dynamics, complete damage model, broad traffic AI and remaining vehicle categories are not finished.
- Unified saves now combine and snapshot the current major systems, but world object destruction/spawn state, every collectible, all NPC transforms and all future systems still need to adopt the snapshot contract before calling the entire world persistence complete.
- Marsa Al-Noor remains a proposal requiring owner/story approval.
- The Android ARM64 Debug APK workflow was restored from `main` on this repair branch in this run; the latest Godot, Android, Web/Chromium and security runs are pending. Web export remains a private CI check only; no public hosting or bundle publishing is enabled.
- Content growth has no fixed final size ceiling. Add only original or properly licensed, useful content and profile import time, APK size, memory and frame time against the 4 GB / Unisoc T606 baseline; never add padding.

## Release gate

Do not merge this Draft PR, label the game release-ready, publish a Web page or produce a public Web bundle until the owner reviews the PR, the latest Godot/Android/security/Web tests pass, and device/release prerequisites are addressed.

## Graphics focus — San Andreas Mobile reference

Reference asset reviewed: user-supplied 127-second, 1280×644 video. The current graphics pass adds an original low-poly protagonist clothing silhouette, 5.8 m follow arm / 65° camera profile, a textured stone-walled starter alley, original willow/street props, 16 imported Harbor City houses and their original street mesh network, more detailed varied traffic sedans, warmer morning lighting and a 06:51 opening time.

A dedicated visual regression now runs in Godot CI: `tests/graphics_reference_profile_test.gd`. This is a source/scene-level gate only; it does not prove exact visual parity. Review running screenshots and a physical Android device before accepting the final appearance. Details: [GRAPHICS_REFERENCE_PROFILE.md](GRAPHICS_REFERENCE_PROFILE.md).


## Run update — 2026-11-20

| Gate | Current classification | Evidence / limitation |
|---|---|---|
| Android ARM64 debug export workflow | IMPLEMENTED; TESTED only after its current run finishes | Workflow restored from the unchanged `main` version. Current run is linked from PR #31 Checks; its result is pending. |
| Unified save coordinator | PARTIALLY IMPLEMENTED | Player transform, world clock, component snapshots, mission/activity snapshots, NPC relationship snapshots, vehicle conditions and legacy files are represented. Full-world persistence and all historical save migrations are not proven. |
| Legacy restore path safety | IMPLEMENTED; TEST PENDING | Only explicit legacy save paths and flat `user://npc_relationships/<safe-id>.json` files are accepted; restore payloads are limited to 2 MiB per file. Regression covers allowlisted round-trip, unrelated-file preservation and traversal rejection. |
| District NPC navigation | PARTIALLY IMPLEMENTED | Four prototype district navigation grids and NavigationAgent3D usage exist. Avoidance is disabled and unconnected/no-map areas retain direct-movement fallback. |
| Expressive Arabic dialogue | BLOCKED / NOT VERIFIED | The 25 dialogue lines still need local, offline, expressive audio files and playback verification; TTS is not human acting. |
| Physical Android performance | NOT VERIFIED | No authorized physical device session is available for install, touch feel, FPS, RAM, heat or speaker testing. |

No asset files were added in this save-safety/CI repair commit. The asset register remains unchanged because there is no new asset provenance to record.


## Content growth update — 2026-11-20

- Added one original, usable Harbor City public drinking fountain (OBJ/MTL + Godot scene + interaction script) and a regression test. It is instantiated in the Harbor City plaza and uses the existing player needs API.
- Model provenance is recorded in [OWNERSHIP_AND_ASSET_REGISTER.md](OWNERSHIP_AND_ASSET_REGISTER.md).
- The new test is wired into the Godot 4.7 validation workflow. No imported audio or external runtime service is used.
- Physical performance acceptance remains pending on the 4 GB / Unisoc T606 device; the prop uses one imported mesh, one static collision cylinder and one proximity area.


## Seafood market content update — 2026-11-20

- Added a six-material original seafood display OBJ/MTL and placed it with the existing modular market stall in Sapphire Coast. The existing stall asset is reused rather than duplicated.
- Added grilled sardines, seafood stew and red mullet plate to the validated consumables catalogue. They are edible and use the existing PlayerNeeds/ConsumableInventory flow.
- Added vendor purchase handling, transaction rollback, a dedicated regression test and world district integration assertions. Godot CI is pending for this head.
- Physical Unisoc T606 / 4 GB frame-time, memory, thermal and touch acceptance remains NOT VERIFIED.

## Amber Valley garage content update — 2026-11-20

- Added an original six-material repair workshop OBJ/MTL with a roof frame, shutter details, hydraulic lift, floor safety markings, tool cabinets, workbench, compressor, tires, drums and service equipment.
- Added a functional Arabic vehicle-service panel in Amber Valley. It identifies a nearby parked vehicle, computes the repair quote from missing vehicle health, debits the existing wallet, restores vehicle health through the shared vehicle API and refunds the payment if repair does not complete.
- The service rejects out-of-range use, moving vehicles, already healthy cars and insufficient balance. A disabled vehicle can be recovered after the player has enough currency.
- Added `tests/vehicle_service_garage_test.gd`, expanded `tests/open_world_regions_test.gd`, and registered script parsing, the dedicated service test and four-district integration assertions in the Godot validation workflow.
- This is source-level integration; current-head Godot/Android workflow results and physical-device FPS, RAM, temperature and touch acceptance remain pending.


## Daily verification — 2026-11-21

**Current candidate:** fix/comprehensive-stability-2026-11-20 at ab9e707abed1863141418a8a17caa77cf9a1fe66  
**Base/main:** c9fc82936a43b80af0e3c25eef41c9fee59e47b7 (unchanged)  
**PR:** [#31](https://github.com/dzdfast-art/GTA-GHIBLI/pull/31), Draft and open; no merge or public deployment.

### Changes made in this run

- Added first-launch migration when no unified save exists but allowlisted legacy subsystem save files do. The old wallet/needs/NPC data is loaded before a new versioned unified save is written.
- Changed restore ordering: compatibility files load first, then versioned player/component/mission/NPC/vehicle snapshots apply last. This prevents stale legacy JSON from overwriting a newer canonical snapshot.
- Expanded game_save_manager_test.gd to cover first-launch wallet/needs migration, reward transaction ledger preservation, stale-legacy-vs-current-snapshot precedence, NPC relationship file safety, player transform restore, and traversal rejection.
- Fixed NPC navigation-agent creation during actor child setup by deferring sibling attachment to the owning Node3D; the navigation map is resolved through that owner when the agent enters the tree, and the agent is cleaned up when its brain exits.
- Added regression checks for NPCs whose brain is attached before the actor enters the tree, plus scheduled NPCs and world-clock integration.
- Corrected the headless district test to use its own SubViewport World3D rather than replacing the already-running root viewport world. The canonical-location test now uses the real region director in the SceneTree and frees its test scene.
- Replaced the flaky Playwright canvas locator click with a real viewport-coordinate mouse click. The prior same-commit Web/Chromium push validation passed this input path.

### CI status for the current head

- Repository security audit #742: **success**.
- Godot validation #798: **in progress** at the time this document was updated.
- Android ARM64 Debug APK #561: **in progress**.
- Web Build #92: **in progress**.
- Private Web + Chromium #190: **in progress**.
- Push Web Build #91 and private Chromium #189: **in progress**.

An intermediate Godot run #795 failed because the new callback inferred an untyped World3D variable. That parser issue was corrected before the current head. Run #797 then passed its test steps but exposed two runtime test-log errors (calling get_world_3d on NavigationAgent3D and replacing the root viewport world). Both were corrected in the current head; #798 is the verification run for those corrections. Do not describe #798 as passed until GitHub reports its completed conclusion.

### Last measured build evidence (not the current head)

The latest fully measured APK available during this run is from commit 9005973907dbe56392d2571f6bf4fe8ef84e8aca, not the current ab9e707 head:

| Measurement | Exact bytes | Decimal MB | MiB |
|---|---:|---:|---:|
| Raw Android Debug APK | 254,227,979 | 254.228 | 242.451 |
| Android artifact ZIP | 252,474,278 | 252.474 | 240.779 |
| Web export folder | 378,778,637 | 378.779 | 361.231 |
| Web bundle ZIP inside export | 237,926,349 | 237.926 | 226.904 |
| Web Actions artifact ZIP | 236,469,268 | 236.469 | 225.515 |

Compared with the previous comparable raw APK of 250,819,279 bytes, the measured increase was **3,408,700 bytes** (3.409 MB / 3.251 MiB). The current head's Android build is still running, so these figures must not be labelled as the current-head APK measurement.

The GitHub Git-tree blob sum (tracked repository files, not Git internals or expanded LFS payloads) is 350,450,243 bytes (350.450 MB / 334.215 MiB) on the current candidate, versus 346,596,568 bytes (346.597 MB / 330.540 MiB) on main: +3,853,675 bytes (3.854 MB / 3.675 MiB). This run added code/tests only; it added no new asset files.

### Open gates

- Full save coverage for every mission, side activity, world entity, NPC schedule and vehicle is not yet proven; unified save remains **PARTIALLY IMPLEMENTED**.
- The four prototype district navigation meshes and NPC agent attachment are present, but continuous cross-district/road links, obstacle avoidance, no-path behavior and persisted life schedules remain **PARTIALLY IMPLEMENTED / NOT VERIFIED**.
- No physical Unisoc T606 / 4 GB device was connected. FPS, RAM, heat, touch feel, install/launch and offline audio remain **NOT VERIFIED**.
- The 25 Arabic dialogue lines are not confirmed as human-performed voice acting; voice-over remains **BLOCKED / NOT VERIFIED** until real bundled clips are present and tested.
- No new asset was added in this reliability pass; no size increase is being claimed as new gameplay content.

### Other open pull requests reviewed

- PR #33 overlaps files already changed on #31; its relevant graphics/pause-menu changes are present on the repair candidate, so it is not merged.
- PR #32 and PR #34 add lint/tooling documentation/workflow work on separate bases. They remain separate and unmerged pending independent review.
- PRs #27, #26, #21, #12, #10, #23 and #24 contain distinct crane, bicycle-audio, boat, architecture or surface/terrain candidates. They were not imported into this repair branch in this run because their assets/code require current-head regression, provenance and Android performance checks first.
- No open issue result requiring an immediate fix was returned by the repository issue search.


## Verification correction — 2026-11-21 (after Godot/Android completion)

The current documentation head is 1c8da7dddc07a707dc5b6a0518922bfd1c934135. The only changes after game-code head ab9e707abed1863141418a8a17caa77cf9a1fe66 are documentation files; GitHub compare confirms no script, scene, asset or project-setting changes in that final docs commit.

- Godot validation #798: **success** on game-code head ab9e707. The first-launch migration test, NPC brain test, four-district NavMesh path test, world-clock test, canonical-world test, parser and main-scene smoke all passed.
- Android Debug APK #561: **success** on game-code head ab9e707. Raw APK: **254,232,075 bytes** (254.232 MB / 242.455 MiB). Android artifact ZIP: **252,475,148 bytes** (252.475 MB / 240.780 MiB).
- Compared with the previous comparable raw APK of 250,819,279 bytes, this is +3,412,796 bytes (3.413 MB / 3.255 MiB). Compared with the previous candidate build of 254,227,979 bytes, it is +4,096 bytes (0.004 MB / 0.004 MiB).
- Repository security audit #743: **success** on documentation head 1c8da7.
- Android run #562, Web Build #94, private Web + Chromium #192, and push Web/Chromium runs #93/#191 were still running when this correction was recorded. The previous Web/Chromium success on commit 900597 remains evidence for the coordinate-based browser input change, not a completed current-head Web export.

The #798 Godot log no longer contains the earlier NavigationAgent3D get_world_3d script errors, the parent-busy add_child error, or the root-viewport null-scenario error. Non-fatal OBJ ambient-light import warnings and test-process ObjectDB/resource teardown warnings remain; the workflow passed, but the log is not completely warning-free.

The Git-tree measurement on docs head 1c8da7 is 350,461,886 bytes (350.462 MB / 334.226 MiB), 397 tracked blobs. Main remains 346,596,568 bytes (346.597 MB / 330.540 MiB), 329 tracked blobs. Difference: 3,865,318 bytes (3.865 MB / 3.686 MiB). No new game assets were added in this pass.


## 2026-11-22 — side-activity restart and reward recovery

- **Implemented in source:** active side-activity ID, target visibility, target count and progress timestamp are stored in the compatibility file and unified snapshot. Restoring an active activity recreates its objective markers and hides targets already collected.
- **Implemented in source:** completion rewards use stable transaction IDs through the wallet's one-time reward API. If the process stops after wallet credit but before the activity ledger is committed, resuming recognizes the existing transaction and completes without paying twice.
- **Implemented in source:** completed activities reject repeat completion; reward totals no longer increase on duplicate callbacks.
- **Implemented in source:** wallet snapshots include an update timestamp and merge reward transaction IDs from a newer compatibility wallet. Unified restore does not overwrite an existing allowlisted device file with an older embedded copy.
- **Regression coverage added:** active-target reconstruction, duplicate completion, interrupted reward recovery, newer wallet transaction recovery, and preservation of a newer existing NPC relationship file.
- **Verification status:** pending Godot 4.7 validation and Android ARM64 Debug CI for commit 6fc51d0. Do not mark this addendum TESTED until the new-head workflows finish.
- **Scope limit:** mission 001–004 restart timing, all world entities, NPC schedules and every vehicle state still require broader restart tests. Unified save coverage remains PARTIALLY IMPLEMENTED.
- No game assets were added. Main remains unchanged and PR #31 remains Draft/unmerged.


## 2026-11-22 Web artifact privacy correction

The previous Web Build workflow uploaded a downloadable GTA-GHIBLI-Web artifact even though the gameplay preview was tested locally. Because the repository is public, GitHub documents that public artifact endpoints can be accessed without authentication. The workflow now deletes prior artifacts named GTA-GHIBLI-Web, does not upload a new Web ZIP, records export/ZIP bytes and SHA-256 in the Actions log only, and removes the temporary export before the runner exits. The cleanup uses only the workflow-scoped GITHUB_TOKEN with actions:write; fork pull requests skip deletion. The earlier run #45008944503 artifact (ID 14748948497) is targeted by this cleanup on the next same-repository run. No Pages deployment is configured.


### Cleanup race correction — 2026-11-22

The first parallel push/PR cleanup pair raced: one run deleted artifact 14748948497 and the other then received HTTP 404. The artifact list for the old run is now empty, confirming deletion. The workflow cleanup is now idempotent for an artifact already removed by another run, and push/PR Web builds share one concurrency group to prevent duplicate export work. The first run's cleanup failure was a duplicate-delete race, not a Godot/Web export failure.


## 2026-11-22 — NPC transform and daily schedule persistence

- **Code:** commit `a5e4101` extends `NPCBrain.get_save_snapshot()` with the actor's global position and rotation, schedule-enabled flag, current world hour, work-hour window, work/home destinations, wander-home origin, trust and familiarity. `apply_save_snapshot()` restores those fields with bounded hour and relationship values.
- **Compatibility:** the new fields are additive. Older snapshots that contain only trust/familiarity remain accepted; missing transform/schedule fields leave the current authored defaults unchanged. No save-schema version bump was required.
- **Regression coverage:** `tests/game_save_manager_test.gd` verifies stable-ID capture, serialized NPC transform/schedule fields, transform and schedule restoration, relationship restoration and unified-save round-trip. The fixture disables wandering so the test measures persistence rather than autonomous movement.
- **Verification on code/test head `24955534577968ba310812c87c5bbedd23290bff`:** Godot 4.7 #45011215857 PASS; Android ARM64 Debug #45011215912 PASS; private Web + Chromium #45011215840 PASS; Web Build + Chromium #45011215820 PASS; repository secret audit #45011215838 PASS.
- **APK:** 254,240,267 raw bytes (254.240267 MB / 242.462413 MiB), +4,096 bytes versus the previous comparable 254,236,171-byte build. Android artifact ZIP: 252,487,129 bytes.
- **Private Web measurement:** temporary export folder 378,790,880 bytes (378.790880 MB / 361.243134 MiB); temporary ZIP 237,938,088 bytes (237.938088 MB / 226.915443 MiB), SHA-256 `2c8797cbf72a50761e91e44c599744cc0b5947508e0d09c441ade4bc83fc6381`. The workflow removed the export and ZIP from the ephemeral runner; no Web Actions artifact was produced.
- **Tracked Git tree:** candidate 350,494,147 bytes (350.494 MB / 334.257 MiB), 397 unique blobs; main 346,596,568 bytes (346.597 MB / 330.540 MiB), 329 unique blobs. Candidate is +3,897,579 bytes versus main. No duplicate blob references were present.
- **Scope limits:** only NPCBrain instances currently registered in `npc_brains` are captured/restored. A stable unique `persistence_id` is required where actor names may collide. Deferred restore for NPCs spawned after load, full streamed-world entity state, path/animation/transient alarm state and complete mission 001–004 restart coverage remain PARTIALLY IMPLEMENTED or NOT VERIFIED.
- **Warnings:** Godot validation passed, but the log still contains OBJ material ambient-light warnings and several headless-test RID/ObjectDB/resource teardown warnings. It is not warning-free.
- No new game assets were added. Main remains unchanged; PR #31 remains Draft and unmerged.

## 2026-11-22 — Mission 002 save/resume continuity candidate

- Mission 002 snapshots now retain both pursuer visibility states and whether the rescued witness is attached as a passenger. Older snapshots without these keys use phase-aware defaults.
- Restoring an active escape phase recreates the passenger visual on the existing vehicle and restores witness/pursuer visibility, preventing a resumed chase from silently losing its actors.
- Mission 001–004 save writers now explicitly flush, check the write result and close their files at mission-save boundaries.
- Regression coverage simulates removal of the rescue actors and restores the active pursuit from its snapshot before continuing the mission.
- This change adds no game assets. Current-head CI is required before classifying this candidate as TESTED; no physical-device result is implied.
