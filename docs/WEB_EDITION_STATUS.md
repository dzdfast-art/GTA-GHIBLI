# Current authoritative snapshot — 2026-11-24 — PR #105 save-slot hardening

This block supersedes the older branch/PR snapshots below. Historical entries are retained, but their PR #35 Draft/open and PR #42 pending descriptions no longer represent the current repository state.

## Repository and review state

- `main`: `e35a0ca72d8209f2a6b8295f6a1f89091b563f24`; unchanged by this run.
- PR #35: closed and merged on 2026-11-22 at 13:56:51 UTC. The former clean-start branch `web/standalone-from-empty-2026-11-22` now points to `9cdcec813aa874532e9c4c5d3113f967a9a0a26a`; it is not the active development head.
- Current active review: [PR #105](https://github.com/dzdfast-art/GTA-GHIBLI/pull/105), Draft/open/unmerged.
- Active branch: `feature/web-durable-save-slots-20261124`.
- Tested code head before this documentation-only update: `359870a666c7ceeb25f15f13aee9aa49143520d0`.
- PR #105 is stacked on PR #104 branch `fix/web-pr50-100-tests-strict-20261124` at `34e3561699699ed3546a5a8a1b131937ffa433c7`. The stacked PRs remain open; no merge was performed.
- All game code changed in this increment remains under `web-edition/**`. The other changes are Web CI and Web Edition documentation only. No Android/APK build, public deployment or public game download was created.

## Save-system status

| System | Status | Evidence and boundary |
|---|---|---|
| Versioned local save-slot backend | **TESTED** | JSON envelope v1, payload SHA-256, safe slot IDs, non-negative timestamps, deep-copy round-trip |
| Atomic replacement and backup recovery | **TESTED** | Temporary-file write, previous-save backup, corrupt-primary recovery |
| Save schema migration | **TESTED** | Version-zero payload migrates to version one |
| Invalid/empty JSON payload handling | **TESTED** | Invalid JSON is rejected; a valid empty dictionary remains valid |
| Process restart | **TESTED — native runner** | A writer and a separate Godot reader process restore nested player, missions, wallet, inventory, vehicle, world and activity fixture data |
| Live-game autosave | **PARTIALLY IMPLEMENTED** | The game-root wallet-change hook stores only Mission 001 stage and wallet |
| Whole-game state integration | **PLANNED** | Player transform/vitals, all mission progress, inventory, NPCs, active vehicles, activities and world state are not yet wired into live save/restore |
| Browser IndexedDB reload persistence | **NOT VERIFIED** | Chromium smoke test does not reload the page or prove save survival across browser sessions |

The restart fixture's nested dictionaries are test data, not proof that the live game currently captures all those systems. Godot 4.7's Web documentation states that `user://` persistence depends on IndexedDB/storage permission; private browsing or blocked storage prevents persistence. `OS.is_userfs_persistent()` can be a false positive. See the [Godot 4.7 Web export persistence note](https://docs.godotengine.org/en/4.7/tutorials/export/exporting_for_web.html#using-cookies-for-data-persistence).

## Verification — code head `359870a`

- Web CI [run 45372352700](https://github.com/dzdfast-art/GTA-GHIBLI/actions/runs/45372352700): **PASS** — Godot 4.7 import, JSON/research validation, all 59 GDScript regression tests, WebAssembly export, export-file verification, Chromium localhost/WebGL 2 smoke, package measurement and temporary cleanup.
- Security audit [run 45372362353](https://github.com/dzdfast-art/GTA-GHIBLI/actions/runs/45372362353): **PASS** — Gitleaks reported no leaks.
- The save-slot regression passed corruption recovery, invalid JSON payload rejection, empty payload round-trip, version migration and separate-process restart.
- Chromium reported a 1280×720 canvas with WebGL 2, delivered WASD/right-mouse/map-key input, and reported no browser runtime errors or external network requests. This remains a smoke test, not full-game acceptance or a visual review.
- The workflow rejected Godot `ERROR:` output after the parser was changed to use `JSON.parse()` result handling. The prior code head's corruption test had emitted a deliberate `ERROR: Parse JSON failed` line; that noise is absent from the passing hardened run.

## Exact size measurements

- Tracked `web-edition/` source: 134 files, **213,789 bytes** (0.214 MB decimal).
- Deduplicated unique source contents: 134 contents, **213,789 bytes** (0.204 MiB).
- Uncompressed Web export: 7 files, **40,058,343 bytes** (38.203 MiB).
- Compressed Web ZIP: **10,428,513 bytes** (10.429 MB decimal / 9.945 MiB).
- ZIP SHA-256: `3c569e481f45f6de126a2a103569239db01e713de78ad7408ba2c6c0a8379a06`.
- The 4 GB target is **not reached**. These measurements are source/export/package measurements, not an APK, cache or Git-internals measurement.
- Web CI artifact listing was empty. The separate security audit produced only its Gitleaks SARIF report; no Web export or ZIP was uploaded. The runner cleanup step completed.

## Next technical step

Wire the save service to the live authoritative state in bounded increments, then add a Chromium test that saves, reloads the page and verifies recovery with IndexedDB enabled, plus a clear blocked-storage behavior. Keep the PR Draft until those checks pass and do not claim full-game persistence.
 
---


---

## Verified navigation baseline — PR #41 passed — 2026-11-23

- PR #41: https://github.com/dzdfast-art/GTA-GHIBLI/pull/41 — Draft/open/unmerged; stacked on PR #40.
- Tested branch-head run: https://github.com/dzdfast-art/GTA-GHIBLI/actions/runs/45230635607 — PASS.
- Security audit: https://github.com/dzdfast-art/GTA-GHIBLI/actions/runs/45230669321 — PASS.
- Tested PR #41 head: ba9396d61c0e72491c7fdc10a8e31d914b647ce0.
- Godot import, JSON/research checks, foundation gameplay regression, WebAssembly export, export-file verification, Chromium/WebGL2 smoke test, package measurement and cleanup all passed.
- Added regression evidence: GPS turns identified left/right on a controlled graph; the lighthouse route shows the expected right-turn prompt and HUD displays the next turn with remaining distance.
- Chromium reported a 1280x720 Godot canvas with WebGL2, keyboard/mouse/map input delivered, no runtime errors and no external requests. This is not full-game or cross-browser acceptance.
- PR #41 Web ZIP: 10,297,171 bytes (10.297 MB decimal / 9.820 MiB); uncompressed export: 39,893,174 bytes (38.045 MiB); seven files; SHA-256 d7e6bb4bde4868214c98639dd89bf8e3d3c7b40638a4f5f363dfe5af62a0c823.
- CI artifact list for run 45230635607 was empty; temporary Web export directory was removed after measurement.

## Next increment — PR #42 road closures and one-way edges — CI pending

- PR #42 candidate branch: feature/web-gps-road-closures-20261123, stacked on PR #41 branch feature/web-gps-turn-guidance-20261123.
- Route graph validation now supports bidirectional, forward-only and reverse-only edges; duplicate IDs and unsupported direction values are rejected.
- The planner supports runtime edge blocking/unblocking. A* skips blocked edges and recalculates from the current position; the game root exposes set_road_edge_blocked for gameplay/world systems.
- Regression coverage added for a live closure clearing the active HUD/map route, reopening restoring it, a synthetic alternate path selected after a closure, unreachable status when all paths close, and enforcement of a one-way edge.
- The current actual world remains a single starter corridor with six access spurs and has no alternate street grid/closure simulation. The alternate-route test uses a controlled graph until the world topology grows.
- PR #42 code is IMPLEMENTED — CI NOT YET VERIFIED.

---

## Verified navigation baseline — PR #40 passed — 2026-11-23

- PR #40: https://github.com/dzdfast-art/GTA-GHIBLI/pull/40 — Draft/open/unmerged, stacked on PR #39.
- Tested PR #40 merge-ref run: https://github.com/dzdfast-art/GTA-GHIBLI/actions/runs/45229951546 — PASS.
- Security audit: https://github.com/dzdfast-art/GTA-GHIBLI/actions/runs/45229951201 — PASS.
- Tested PR #40 head: 1b84a1e5cdb06b8180ab49d017546ff667b7e0ab.
- Godot import, foundation regression, WebAssembly export, export-file verification, Chromium/WebGL2 localhost smoke, size/hash measurement and temporary build cleanup all passed.
- Foundation regression specifically confirms all six POIs reachable on the starter road graph, out-of-range snap rejected, road distance and route geometry updated on full map/minimap, player movement, sedan entry/drive/exit, Mission 001 reward idempotency and mission-stage/wallet restoration.
- Chromium confirms a 1280x720 WebGL2 canvas, keyboard/mouse/map event delivery, no runtime errors and no external requests. This is a smoke test, not complete-game or cross-browser acceptance.
- PR #40 measured Web ZIP 10,294,008 bytes (10.294 MB decimal / 9.817 MiB); uncompressed export 39,889,958 bytes (38.042 MiB); seven export files; ZIP SHA-256 b697d7c4c1ed810299757a5b3ca28581d1842185117e97db1dd670c2220f4b11.
- CI artifact listing for PR #40 returned no artifacts; the export folder was deleted on the runner after measurement.

## Next increment — PR #41 basic turn guidance — CI pending

- PR #41: https://github.com/dzdfast-art/GTA-GHIBLI/pull/41 — draft branch feature/web-gps-turn-guidance-20261123, stacked on PR #40.
- Added route-derived left/right maneuver data to the A* result, excluding near-straight and near-reversal bends.
- The gameplay HUD now displays the next turn instruction and its remaining distance; when the route has no remaining turn, it displays continuation guidance. Unreachable routes produce a no-connected-road-route message.
- Regression coverage added for left and right turns in an isolated three-node graph, the lighthouse route's right turn and HUD instruction/distance.
- This increment is IMPLEMENTED — CI NOT YET VERIFIED. It is only basic turn guidance on the tiny starter corridor/access-spur graph, not full navigation voice prompts or comprehensive step-by-step guidance.

---

## Authoritative status update — 2026-11-23 — PR #40 road-graph GPS (CI pending)

This section is the current status snapshot for the Web Edition. Older entries below are retained as historical records and may describe earlier branches, CI runs or delivery rules.

### Current branch and review stack
- PR #39: [Add interactive world map and selectable waypoints](https://github.com/dzdfast-art/GTA-GHIBLI/pull/39), open, Draft, unmerged; head 5f3a8dd5e135feb2af0cd09c426a007cc11185d4.
- PR #40 candidate branch: feature/web-road-graph-gps-20261123, based on the PR #39 head. PR #40 is intended to stack on PR #39 rather than repeat its entire diff against main.
- main has not been edited or merged by this work.
- Godot/Web edition only. No Android export or phone acceptance is included.

### Verified previous baseline
- PR #39 Web CI: [run 45221217715](https://github.com/dzdfast-art/GTA-GHIBLI/actions/runs/45221217715) — PASS.
- The completed Chromium localhost step reported WebGL 2 initialisation, delivery of keyboard/mouse/map input, no browser runtime errors and no external requests.
- The same run reported a 10,284,365-byte Web ZIP (10.284 MB decimal), an uncompressed export of 39,880,082 bytes (38.033 MiB), and ZIP SHA-256 43286ecfabf9905a519eab051bf3a4f128739a9883ad22d015796fae81590202.
- Security audit: [run 45221217828](https://github.com/dzdfast-art/GTA-GHIBLI/actions/runs/45221217828) — PASS.
- These are PR #39 measurements, not measurements for PR #40.

### Navigation increment — implemented, awaiting CI
- Added web-edition/scripts/world/route_planner.gd: a small A* route planner with graph validation, bounded nearest-node snapping, road-edge costs, reconstructed route geometry, route distance and explicit unreachable results.
- Added road graph data in world_builder.gd: a bidirectional east-west starter corridor plus six point-of-interest access spurs.
- Added visible access-road strips from the corridor to the six current points of interest.
- Connected waypoint selection and player movement to route recalculation, with route geometry drawn on the full map and minimap.
- HUD distance now identifies a road route rather than a straight-line distance.
- Expanded web_foundation_test.gd to check graph completeness, reachability of all six points of interest, bounded-snap rejection, route distance beyond direct distance for the lighthouse route, and route propagation to both maps.
- These code changes are IMPLEMENTED — CI NOT YET VERIFIED at the time of this status entry. Do not describe the new GPS as tested until PR #40 CI completes successfully.

### Navigation limits that remain
- This graph models only the existing straight east-west corridor and six simple access spurs.
- Full local streets, intersections, junction turn restrictions, one-way roads, closures, alternate routes, dynamic obstacles, pedestrian paths, voice guidance and turn-by-turn instructions remain unimplemented.
- The current bounded nearest-node snap is 36 world units for gameplay route updates. A distant start or destination can be correctly reported as unreachable; this is not a complete GPS for the eventual open world.

### CI package privacy correction
- PR #39 run 45221217715 created Actions artifact ID 14839509383, named GTA-GHIBLI-Web-Edition, size 10,284,845 bytes, with recorded expiry 2026-12-07T16:53:58Z. Because the repository is public, it must be treated as downloadable by the public until expiry.
- The available GitHub actions in this session expose artifact listing and download, but not artifact deletion. The existing PR #39 artifact has therefore NOT been deleted; no claim of deletion is made.
- PR #40 updates the workflow to stop uploading Actions artifacts and to remove the temporary Web export directory on the runner after measurement. This correction applies to subsequent workflow runs; it does not retroactively remove artifact ID 14839509383.
- No Pages, Vercel or other public game deployment was created.
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



---

## CI result and fresh Web package measurement — 2026-11-22

Tested branch head: `e743cc23b6ced0dff1e87a7903e6be294f80f530`  
PR #35: https://github.com/dzdfast-art/GTA-GHIBLI/pull/35

- Web CI run **#45025430985: PASS** — https://github.com/dzdfast-art/GTA-GHIBLI/actions/runs/45025430985
- Security Audit run **#45025431054: PASS** — https://github.com/dzdfast-art/GTA-GHIBLI/actions/runs/45025431054
- The research validation CI step passed: JSON parsing, Python bytecode compilation, and all 3 local research-helper CLI tests.
- Godot 4.7 import passed.
- The existing gameplay foundation regression test passed.
- WebAssembly export and HTML/JS/WASM/PCK validation passed.
- Chromium started a 1280×720 Godot canvas with WebGL 2; WASD, right-mouse drag and map input were delivered; no browser runtime errors and no external network requests were reported.
- Temporary export and ZIP were deleted after measurement; no GitHub artifact was uploaded.

### Exact package measurement from run #45025430985

| Measurement | Bytes | Decimal MB | MiB |
|---|---:|---:|---:|
| Uncompressed Web export | 39,868,954 | 39.869 | 38.022 |
| Compressed Web ZIP | 10,273,661 | 10.274 | 9.798 |

- Export files: 7.
- ZIP SHA-256: `9bffd8bf660f18bee7bdb67a59631a1fcb59a175273376f132de3bb10b9f0885`.
- The ZIP contains the existing Godot Web runtime and small foundation game pack, not 10.274 MB of unique authored gameplay assets.
- This measurement is for tested head `e743cc...`; it is not a 4 GB milestone. No current 4 GB claim is made.

### Helper use documentation
- `docs/research/RESEARCH_HELPER_README.md` now contains Windows CMD setup, an end-to-end workflow, commands, limits and expected incomplete validator exit code.
- `docs/research/sample_source_note.md` is a sample note explicitly marked `USER_NOTE_NOT_VERIFIED`; it must not be cited as historical evidence.
- These two added documentation/sample files were committed after the tested head. They do not alter the Godot project or CI scripts. The tested head still includes the helper code, its automated tests and the CI validation step.

### Final current boundary
This release is a playable Web foundation with a researched implementation reference package—not the finished San Andreas-scale open world and not a completed 4,700-entry historical encyclopedia. The four required research registries remain at 140 / 4,700 actual numbered entries, the physics registry has 19 proposed systems and the character subset has four named PS2-manual entries. The exact gaps above remain open.
