# GTA GHIBLI Web Edition — Verified Status Ledger

Updated: 2026-11-22 — minimap milestone under CI verification from `28d3c9acb133f8a2bd9255dd0f500433e2bd05c3`  
New project root: `web-edition/`  
Development branch: `web/standalone-from-empty-2026-11-22`  
Base: `main` at `c9fc82936a43b80af0e3c25eef41c9fee59e47b7`

## Platform and isolation

- **Current platform:** Web only.
- **Engine target:** Godot 4.7.
- **Web renderer:** Compatibility / WebGL 2.
- **Export:** single-threaded WebAssembly.
- **Clean start:** the new project is authored inside a fresh `web-edition/` directory. It has no references to old project scripts, scenes, assets, add-ons or imported files.
- **Android/APK/phone testing:** excluded from current delivery and acceptance. No physical phone is requested or required.
- **Publishing:** no public hosting or download artifact is authorized. CI exports are temporary and local to the runner.

## Current first playable foundation

| System | Current status | Evidence / limit |
|---|---|---|
| Godot project + main scene | **TESTED** | Godot 4.7 import and scene startup passed in Web CI #18 |
| Four named regions | **TESTED — blockout only** | Coordinate assertions passed for all four; one connecting road corridor, not a finished open world |
| Marsa Al-Noor | Provisional landmark | Lighthouse blockout in Harbor City; final map/story placement not approved |
| Leo Bennett | Placeholder player | Capsule-based temporary visual; no final rig or animation |
| Claire / Mia / Nora | Placeholder interactive characters | Names and confirmed family relationships preserved; not final character models |
| Walking / sprinting / jumping | **TESTED** | WASD movement assertion passed; Shift/Space bindings exist but their animations/visual transitions are not final |
| Camera orbit / zoom | IMPLEMENTED; input delivery smoke-tested | Chromium delivered right-mouse drag; exact camera transform/zoom behavior has not yet been asserted by an automated test |
| Character / vehicle interaction | **PARTIALLY TESTED** | Claire/Nora actor signals drive the mission; proximity vehicle-entry/exit handler passes. Actual browser E press end-to-end assertion remains to be added |
| Sedan | **TESTED — first pass** | Nearby entry, acceleration/movement and exit passed; advanced handling, suspension, damage, audio and extra vehicle classes absent |
| Mission 001 | **TESTED — introductory mission only** | Claire signal -> Nora signal -> $250 reward; duplicate payout rejected |
| Local save | **PARTIALLY TESTED** | A new MissionManager instance restored Mission 001 stage and $600 wallet; world/player/NPC/vehicle-wide persistence is not implemented |
| HUD | First implementation; visual review pending | Objective, region, wallet, prompt and dialogue elements exist; visual layout has not had a human screenshot review |
| Map / minimap | **PARTIALLY IMPLEMENTED — new minimap awaiting CI** | New top-right minimap draws the four region bands, east-west starter road, Marsa Al-Noor lighthouse and a live player marker/heading. Coordinate conversion and player-position update have regression assertions. No GPS routing, destination selection, minimap rotation or route-following guidance yet |
| Browser audio | Not implemented | No placeholder/silent audio used; Arabic voice acting remains unverified/not included |
| CI Web export / Chromium | **PASS** | Web CI #18 on `e50cdc`; WebGL 2 canvas, keyboard/mouse event delivery, no runtime errors or external requests |

## Not yet implemented / not claimed

- Full detailed world, final district geometry, complete road/interior/bridge/tunnel network, terrain streaming and GPS route navigation.
- Finished human character models, rig, facial expressions and complete animations.
- Complete campaign and all mission stages, failure states, cinematic scenes and full restart recovery.
- Motorcycle, truck, bus, boat, airplane, helicopter, cart and trailer systems.
- Weapons, combat, aiming, firing, hit detection and contextual weapon HUD.
- Pedestrian/traffic route AI, obstacle avoidance, police and pursuit systems.
- Full time-of-day cycle, rain, clouds and regional weather.
- Complete title/menu/settings/pause/save-load system and final Arabic RTL typography.
- Original music, ambience banks, vehicle sound, SFX and expressive Arabic voice acting.
- Final visual parity with the requested painterly anime-inspired direction.
- 4 GB content milestone; no size target is claimed as reached.

## Latest verified Web foundation — 2026-11-22

**Source commit:** `e50cdcdd1cf7a99fa0d00768ca6b640500bcfea9`  
**Draft PR:** [#35](https://github.com/dzdfast-art/GTA-GHIBLI/pull/35)  
**Web CI #18:** [PASS](https://github.com/dzdfast-art/GTA-GHIBLI/actions/runs/45021272226)  
**Security Audit #776:** [PASS](https://github.com/dzdfast-art/GTA-GHIBLI/actions/runs/45021272233)

The CI log confirms:
- Godot 4.7 clean import and project startup.
- Region/cast/mission JSON validation.
- End-to-end foundation test: WASD movement; Claire/Nora world-signal interaction; Mission 001 reward paid once; nearby E interaction enters the starter sedan; the sedan moves; E exits; a fresh mission-manager instance restores Mission 001 and the $600 balance.
- Web export completed with non-empty HTML, JavaScript, WebAssembly and PCK.
- Chromium initialized a 1280×720 Godot canvas with WebGL 2.
- Browser delivered WASD, right-mouse drag and M-key events.
- No JavaScript/runtime errors and no external network requests.

### Exact temporary Web export measurement

| Measurement | Bytes | Decimal MB | MiB |
|---|---:|---:|---:|
| Uncompressed Web export folder | 39,865,354 | 39.865 | 38.019 |
| Compressed Web ZIP | 10,270,137 | 10.270 | 9.794 |

- Export files: **7**
- ZIP SHA-256: `0af14cc871ecf9315886287297072f4fc2e68733b786d5fd02ad15762b1ec3d1`
- The export and ZIP were created only on the ephemeral GitHub Actions runner, measured, and deleted. No artifact or public download link was uploaded.
- These bytes include the Godot Web runtime, loader and current small game pack. They are not 10 MB of unique authored game art. The long-term 4 GB genuine-content milestone is **NOT REACHED**.

### Remaining major requirements

The foundation is not the complete game. Still incomplete: detailed connected four-region world and Marsa Al-Noor story role; finished Leo/Claire/Mia/Nora models, rigs and animations; full campaign and restart coverage; real roads/interiors/bridges/streaming/GPS/minimap; motorcycles/trucks/boats/aircraft/helicopters; weapons and combat; pedestrian/traffic/police AI; day/night/weather; final menu/settings/Arabic RTL UI; original music/ambience/SFX; expressive Arabic voice performances; asset provenance/expanded inventory; cross-browser validation beyond Chromium; and meaningful original content growth toward 4 GB.

A green CI foundation run proves only the cases above. It does not prove full-game acceptance, final visual quality, cross-browser compatibility, or completion of the full specification.




---

## Authoritative update — forensic research package and current CI boundary

Updated: 2026-11-22. This block supersedes earlier statements in this file that described the live minimap as awaiting CI.

### Current repository state
- Web development branch: `web/standalone-from-empty-2026-11-22`.
- Current PR #35 head at the time this ledger update was authored: latest research/documentation commits are being added sequentially to this branch; verify the PR head and Actions run before describing the documentation commit as CI-passed.
- PR #35 remains Draft/open and unmerged.
- Base `main` remains `c9fc82936a43b80af0e3c25eef41c9fee59e47b7`; do not merge automatically.
- No public deployment or retained export artifact has been created.

### Latest executable foundation checks verified before research-file additions
- Web CI #25: PASS — https://github.com/dzdfast-art/GTA-GHIBLI/actions/runs/45022089816
- Web CI #26: PASS — https://github.com/dzdfast-art/GTA-GHIBLI/actions/runs/45022091816
- Security Audit #776: PASS — https://github.com/dzdfast-art/GTA-GHIBLI/actions/runs/45022091822
- Tested commit: `9dd7fd2cc8da2a8beee7affe6895c80f223a8016`.
- Covered: Godot 4.7 import, current JSON data validation, foundation gameplay test (player movement, sedan entry/drive/exit, Claire/Nora mission/reward idempotency and mission-manager wallet/stage restoration), WebAssembly export file check, Chromium localhost WebGL2 startup, input-event delivery, no browser runtime errors and no external requests.
- These runs predate the handbook/registry/helper additions; they do not certify those added files until a later CI run validates the newer branch head.
- No full visual/manual UI audit, Firefox/Safari test or complete-game acceptance is claimed.

### Research deliverables added to the Web branch
- `docs/GTASA_RESEARCH_HANDBOOK.md`: sourced partial history, version-scope notes, technical testimony, production-role sample, research trail, engineering design, proposed physics, event ordering, starter character records, Windows CMD usage and exact coverage audit.
- `docs/research/gtasa_registry.json`: machine-readable source register and CORE/GFX/EXTRA/PHY/CHAR registries.
- `web-edition/tools/research_helper.py`: local-only Python 3.10+ helper to import local JSON/text notes, search the registry, export JSON/CSV and validate IDs/counts/references. It does not browse the web or guarantee exhaustive research. Plain .txt/.md import only; PDF/DOCX extraction is not included.

### Exact literal registry audit in the added package
| Registry | Required | Actual | Missing |
|---|---:|---:|---:|
| CORE parent details | 50 | 50 | 0 |
| CORE substantive elements | 2,250 | 50 (one per parent) | 2,200 |
| GFX parent details | 50 | 50 | 0 |
| GFX substantive elements | 2,250 | 50 (one per parent) | 2,200 |
| EXTRA-D | 100 | 20 | 80 |
| EXTRA-E | 100 | 20 | 80 |
| Physics records | no fixed cap | 19 proposed systems | Historical implementation details and full test matrix still missing |
| Character records | evidence-complete census requested | 4 named manual-listed individuals | Voice-only, mentioned-only, mission-role, ambient archetype, cut/disputed and exhaustive story census missing |
| Verified overflow | as required | 0 | None admitted without additional sourced evidence |

- Actual numbered total for the four fixed registries: **140 / 4,700**.
- Missing numbered IDs: each `CORE-01` through `CORE-50` lacks `.02`–`.45` (2,200); each `GFX-01` through `GFX-50` lacks `.02`–`.45` (2,200); `EXTRA-D-021`–`EXTRA-D-100` (80); `EXTRA-E-021`–`EXTRA-E-100` (80).
- Automated ID/count checking does not prove semantic uniqueness or historical truth. Editorial and build-scope review remain required.
- Character subset is sourced to the official PS2 manual; it is not the complete character census.

### Historical research boundaries
- Primary/official artifacts used: Rockstar/Take-Two 2004 PS2 announcement, Rockstar-hosted PS2 manual, official December 2004 PC/Xbox announcement.
- Attributable developer material used: GameSpot 2006 Q&A (PC-framed context; developers discuss world streaming/object limits/map extent) and GTABase 2024 interview with former technical director Obbe Vermeij (RenderWare recollection).
- Secondary material used: GamesRadar 2024 report about the discarded early separate-city-map proposal; GTA-SanAndreas.com credits transcription; GTADb multi-platform catalogue as context only, not PS2-only count evidence.
- PS2 manual text was inspected; screenshot extraction failed because the PDF exceeded the screenshot service's size limit. MobyGames credits page returned 403. Rockstar current page body was not extractable; its search-result synopsis was used as such.
- No PS2 disc image, executable, hardware/emulator capture, proprietary source code, original asset package or private studio tools were accessed.

### Measurement and package size
- Existing previous foundation measurement (from the earlier baseline run, not the newly expanded documentation head): uncompressed Web export 39,865,354 bytes; ZIP 10,270,137 bytes; seven files; ZIP SHA-256 `0af14cc871ecf9315886287297072f4fc2e68733b786d5fd02ad15762b1ec3d1`.
- This earlier measurement is not a current-head build-size result and is not proof of 4 GB content. The export contained runtime/loader/current game pack and very little authored content. The latest documentation additions have no new export-size measurement yet.

### Immediate runtime gaps
GPS road routing/destination selection, complete roads/interiors/sector streaming, finished player and character rigs/animations, expanded campaign with fail/retry, full-state persistence, safe vehicle exit reservations, traffic/pedestrian/police AI, other vehicle classes, weapons/combat, activities/collectibles/economy/property systems, day/night/weather, original audio/radio/Arabic voice performance, final menus/settings/RTL audit, full asset provenance, browser performance budgets, Firefox/Safari validation and complete research registries remain incomplete or unverified.

This is an intentional partial delivery record. Do not represent the 140 fixed-registry entries or current playable foundation as the completed encyclopaedia or final open-world game.
