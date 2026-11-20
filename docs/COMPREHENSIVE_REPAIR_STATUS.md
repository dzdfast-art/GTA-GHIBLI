# GTA GHIBLI — Comprehensive Repair Candidate

Date: 2026-11-20
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
