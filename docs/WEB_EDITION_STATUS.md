# GTA GHIBLI Web Edition — Verified Status Ledger

Updated: 2026-11-26 — blocked IndexedDB session-only behavior verified  
Current game root: `web-edition/` — Godot 4.7, single-threaded WebAssembly, Compatibility renderer / WebGL 2

## Latest verified increment — PR #114 — 2026-11-26

- PR #114: https://github.com/dzdfast-art/GTA-GHIBLI/pull/114 — Draft/open/unmerged; branch `fix/web-indexeddb-blocked-session-only-20261126`, stacked on PR #111 branch `feature/web-save-persistence-warning-20261125`.
- Tested functional-code head: `ebf6b01ad4e01b201838cfbb07fa750980d18613`; base head: `2c62e183ef6c05e1398bac8e483a4a9245d9c849`.
- Web CI [run 45796853793](https://github.com/dzdfast-art/GTA-GHIBLI/actions/runs/45796853793): **PASS**. Security audit [run 45796853567](https://github.com/dzdfast-art/GTA-GHIBLI/actions/runs/45796853567): **PASS** — Gitleaks found no leaked secrets.
- The functional change set at the tested code head comprised three files: the CI-only Chromium blocked-storage helper, its Web CI step/path filter, and the CI-only probe mode in `web-edition/tests/web_save_probe.gd`. No legacy game scenes, scripts or assets were changed. This ledger/spec refresh adds documentation only.
- Godot 4.7 import, JSON/research-helper checks, all **61 GDScript regression tests**, WebAssembly export, HTML/JavaScript/WASM/PCK verification, normal Chromium smoke, live-game page-reload persistence and the new blocked-IndexedDB test all passed.
- The blocked-storage test removed `window.indexedDB` before the Godot runtime started. Chromium still initialized the 1280×720 WebGL 2 canvas. Godot reported `user://` as non-persistent. A successful write was readable again in the same active page session and the HUD displayed **SESSION ONLY — allow browser storage**; it did not claim durable browser storage. No external requests or browser runtime errors were observed.
- The normal Chromium context still passed the separate full-page reload test for the selected live-game fields. The two tests cover different storage states and must not be conflated.
- First CI attempt [run 45796460729](https://github.com/dzdfast-art/GTA-GHIBLI/actions/runs/45796460729) failed before executing the new test because the helper contained escaped JavaScript template-literal delimiters. The helper was corrected in `ebf6b01`; the subsequent complete Web CI run passed.
- Exact measurements from successful run 45796853793:

| Measurement | Bytes | Decimal MB | MiB |
|---|---:|---:|---:|
| Tracked `web-edition/` source | 262,378 | 0.262 | 0.250 |
| Deduplicated unique source content | 262,378 | 0.262 | 0.250 |
| Uncompressed Web export | 39,995,840 | 39.996 | 38.143 |
| Compressed Web ZIP | 10,377,709 | 10.378 | 9.897 |

- Tracked Web source files: **138**; unique content blobs: **138**; exported files: **8**.
- ZIP SHA-256: `0ce749defaffd66370f375ef75f6f36450fbc1e1b9842169070784f76bcd893d`.
- Web export and ZIP were created only on the ephemeral Actions runner, measured and deleted. The artifact list for run 45796853793 was empty. No Android/APK workflow ran for PR #114.
- The 4 GB real-content target is **NOT REACHED**. The 40 MB export includes the Godot Web runtime and current game pack; it must not be described as 40 MB of unique authored game assets.
- Remaining boundaries: this test removes the IndexedDB API in Chromium; it is not a full private-browsing, quota-exhaustion or browser-policy test. Browser close/reopen, Firefox/Safari, visual review and complete game acceptance remain unverified.

---

## Repository and review state

- `main`: `e4c26a0e4e9d6945233b3032ed6966a7356103ab`; unchanged by this increment.
- PR #35 was closed and merged on 2026-11-22 at 13:56:51 UTC. The original clean-start branch `web/standalone-from-empty-2026-11-22` currently points to `9cdcec813aa874532e9c4c5d3113f967a9a0a26a`; it is no longer the active review head.
- Active Web review chain: PR #105 (durable save backend) → PR #108 (live-game state integration) → PR #109 (Chromium page-reload verification) → [PR #111](https://github.com/dzdfast-art/GTA-GHIBLI/pull/111) (storage-status feedback).
- PR #111 is Draft/open/unmerged. Branch: `feature/web-save-persistence-warning-20261125`. Code changes were introduced at `fb16cf06a3d6d03404bb7e58900d4b38de4f90aa`; the last fully verified PR head before this ledger refresh was `24ed445c5edc48d97692e91e62abe0015471dbfe`.
- PR #111 is stacked on PR #109 branch `feature/web-browser-save-reload-20261125` at `bbf4959b43fd768798bdba706b592ae5dccf2925`. No merge or approval was performed.
- The original PR #35 state supplied in the earlier request is historical, not current. No changes from this increment were written to `main`.
- All game-code and regression-test changes in PR #111 are under `web-edition/**`; the only outside code change is the local Chromium save/reload CI helper. No Android/APK build, public deployment, Pages/Vercel hosting or public Web download was created.

## Current save-persistence status

| System | Status | Evidence and boundary |
|---|---|---|
| Versioned `user://` save-slot backend | **TESTED** | JSON envelope v1, SHA-256 integrity, safe slot IDs, atomic replacement, backup recovery and schema migration |
| Native process-restart fixture | **TESTED** | A separate Godot writer and reader process restore nested save data |
| Live-game state capture/restore | **PARTIALLY IMPLEMENTED — TESTED for selected fields** | Chromium probe verifies player transform, Mission 001 stage/wallet, health/stamina, time/weather, weapon inventory, one activity, landmark discovery, NPC relationship, wanted level, mission objective/reward, language setting, vehicle transform and active-vehicle state |
| Chromium page-reload persistence | **TESTED — same browser context and origin** | CI writes through the actual game scene, reloads the page, then checks that the same selected live-game state is restored |
| User-visible storage status | **TESTED** | HUD distinguishes browser storage, session-only storage and write failure; English and Arabic warning strings are covered by GDScript regression tests |
| Godot `OS.is_userfs_persistent()` signal | **TESTED as a status hint** | The Chromium probe reports `true` before and after page reload in the normal CI context; Godot documents that this method can produce false positives |
| IndexedDB API unavailable in Chromium | **TESTED — controlled simulation** | PR #114 removes `window.indexedDB` before Godot starts; WebGL 2 initializes, Godot reports non-persistent storage, a successful save is readable in the active page, and the HUD says session-only; not a full private-mode/quota/policy test |
| Private browsing, storage quotas and browser policy restrictions | **NOT VERIFIED** | No separate full private-mode, quota-exhaustion or enterprise-policy test has been run |
| Browser close/reopen or a new browser context | **NOT VERIFIED** | Current browser persistence gate reloads the page inside one persistent Playwright context; it is not a full browser restart test |
| Complete save/restore of all gameplay systems and Missions 001–004 | **PARTIALLY IMPLEMENTED** | The live serializer covers multiple registries, but the current reload probe verifies selected fields only; not every future entity/system is integrated or proven |

### User-facing storage behavior

- If Godot reports browser persistence, the HUD says that browser storage is available but may still be cleared by the browser.
- If Godot reports that `user://` is not persistent, the HUD warns that saves are session-only and asks the player to allow browser storage.
- A failed save write produces an explicit save-error message.
- Arabic and English status messages are implemented.
- `OS.is_userfs_persistent()` is not treated as proof by itself. Godot's documentation explicitly warns that it can give false positives. Actual page-reload restoration remains a separate CI check.
- Godot's Web export documentation says IndexedDB must be allowed for `user://` persistence. PR #114 now verifies a controlled Chromium API-unavailable simulation; full private-browsing, quota and enterprise-policy behavior remains unverified. See [Godot 4.7 Web export — data persistence](https://docs.godotengine.org/en/4.7/tutorials/export/exporting_for_web.html#using-cookies-for-data-persistence).

## Verification — tested PR head `24ed445`

- Web CI push [run 45600494780](https://github.com/dzdfast-art/GTA-GHIBLI/actions/runs/45600494780): **PASS**.
- Web CI pull-request [run 45600505696](https://github.com/dzdfast-art/GTA-GHIBLI/actions/runs/45600505696): **PASS**.
- Security audit [run 45600505678](https://github.com/dzdfast-art/GTA-GHIBLI/actions/runs/45600505678): **PASS** — Gitleaks found no leaked secrets.
- Godot 4.7 import, project JSON and research-helper validation passed.
- **61 GDScript regression tests** ran with detection for `ERROR:`, parse errors, failed assertions and invalid calls. The new storage-status test passed.
- WebAssembly export and HTML/JavaScript/WebAssembly/PCK verification passed.
- Chromium initialized a 1280×720 WebGL 2 canvas, delivered keyboard/mouse/map input, and reported no browser runtime errors or external network requests.
- The save-reload probe confirmed IndexedDB availability, read Godot's `user://` persistence flag as true before and after page reload, saved selected live-game state, reloaded the same local origin, restored the tested values, and removed its temporary autosave slot.
- This is a repeatable Chromium page-reload test, not proof of browser-restart persistence, private/blocked-storage behavior, Firefox/Safari support, visual quality or full-game acceptance.

## Exact size measurements from Web CI run 45600505696

| Measurement | Bytes | Decimal MB | MiB |
|---|---:|---:|---:|
| Tracked `web-edition/` source | 260,667 | 0.261 | 0.249 |
| Deduplicated unique source content | 260,667 | 0.261 | 0.249 |
| Uncompressed Web export | 39,995,840 | 39.996 | 38.143 |
| Compressed Web ZIP | 10,377,709 | 10.378 | 9.897 |

- Tracked source files: **138**; unique content blobs: **138**.
- Export files: **8**.
- ZIP SHA-256: `bc58102daffa0199b04f4f5014a04fe4db688d00f34d0d9a9b29d6643a696ca3`.
- Web export and ZIP were created on the ephemeral runner, measured and deleted. The Web CI artifact list for run 45600505696 was empty. The security workflow produced only its 6,772-byte Gitleaks SARIF report, not a game export.
- The 4 GB real-content target is **NOT REACHED**. Source bytes remain small; the Web export includes the Godot runtime and current game pack and must not be described as 40 MB of unique authored game content.

## Next technical steps

1. **Completed in PR #114:** Chromium test with the IndexedDB API unavailable before Godot startup; it verifies session-only readback or explicit save failure, no durable-storage claim, no runtime errors and no external requests.
2. Add a separate browser-context close/reopen test to distinguish page reload from a fresh browser session.
3. Continue integrating every mission, player, NPC, vehicle, inventory, activity and world-state owner into the live save/restore contract, with per-system restart assertions.
4. Continue expanding original world geometry, interiors, roads, character rigs/animations, real mission content and locally bundled audio. The current foundation systems are not a finished game.
5. Add Firefox and Safari jobs only when suitable runners are available; do not claim cross-browser support before those jobs pass.

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

## Authoritative Web development update — 2026-11-26 — Mission 002 first playable pass

### Repository and PR state at this run
- `main` was observed at `e4c26a0e4e9d6945233b3032ed6966a7356103ab` and was not modified by this run.
- The original clean-project branch `web/standalone-from-empty-2026-11-22` still exists at `9cdcec813aa874532e9c4c5d3113f967a9a0a26a`.
- PR #35 is **closed and merged** (2026-11-22 13:56:51 UTC); it is not an open Draft. This merge predates this run.
- PR #114 remains Draft/open and supplies the tested Web save-persistence foundation.
- PR #115 is Draft/open, stacked on PR #114, and contains this Mission 002 slice. Current source commit before this status-only follow-up: `8f2f20d4360c027fb21f3753309e68f9da867127`.
- No PR was merged or closed by this run. No changes were made to `main`, repository visibility or repository settings.

### What was implemented
- Added structured `web-edition/data/missions/mission_002.json` for the provisional original chapter `إشعار السوق`.
- Added a visible procedural Harbor Market noticeboard with a real `market_notice` interaction and a seventh point-of-interest/mission marker.
- Extended the playable mission state machine to stages 0–5:
  - Mission 001: Claire → Nora, $250.
  - Mission 002: Nora → inspect the Harbor Market noticeboard → Nora, $300.
- Added explicit mission-step and mission-completed signals, mission objective progress, prerequisite completion, idempotent reward settlement, automatic mission waypoint selection, and stage/wallet persistence.
- Added reset handling so a new game clears mission objective, reward and prerequisite registries.
- Replaced the previous text-based inference of mission objective progress with explicit step IDs.
- The road graph originally rejected the new board point because `-75.0` and `-74.8` rounded to the same node ID. The final implementation assigns stable index-based road node IDs and has a regression assertion that the two nearby coordinates remain distinct.
- Updated this master specification, the Web README, the asset provenance register and CI JSON validation.

### Exact validation evidence
- Final code commit tested: `8f2f20d4360c027fb21f3753309e68f9da867127`.
- Web CI [#45801655909 — PASS](https://github.com/dzdfast-art/GTA-GHIBLI/actions/runs/45801655909).
- Security audit [#45801722751 — PASS](https://github.com/dzdfast-art/GTA-GHIBLI/actions/runs/45801722751).
- Godot 4.7 project import and JSON validation passed.
- **62 GDScript regression tests passed**, including the new two-mission campaign test and full game-root mission integration.
- WebAssembly export and required HTML/JavaScript/WASM/PCK validation passed.
- Chromium started the exported game on `127.0.0.1` with WebGL 2 at 1280×720. WASD, right-mouse drag and map-key events were delivered; no browser runtime errors or external runtime requests were observed.
- Chromium save acceptance passed for same-origin page reload and a separate browser-process restart using the same persistent profile. The tested live-game payload included player, mission, vehicle, inventory, NPC and world state.
- With IndexedDB unavailable before runtime initialization, the game retained its WebGL 2 canvas, reported non-persistent storage, kept a successful save readable in the active page session and did not claim durable browser storage.
- The earlier failed attempt [#45801411315](https://github.com/dzdfast-art/GTA-GHIBLI/actions/runs/45801411315) is retained in history; it detected the duplicate rounded road-node ID. It is not counted as a pass. The corrected final head above passed.

### Exact source and Web export measurements
| Measurement | Result |
|---|---:|
| Tracked Web source files | 140 |
| Tracked Web source bytes | 279,043 bytes (0.279 MB) |
| Unique tracked content items | 140 |
| Unique tracked content bytes | 279,043 bytes (0.266 MiB) |
| Temporary Web export files | 8 |
| Uncompressed Web export | 40,003,704 bytes (40.004 MB; 38.151 MiB) |
| Compressed Web ZIP | 10,384,700 bytes (10.385 MB; 9.904 MiB) |
| ZIP SHA-256 | `b103ba412f2a441d59dd4bfdcdb5296717b4efe86eb8303983394c33a9deb381` |

The export and ZIP were created only on the ephemeral runner, measured and deleted. The Actions artifact list is empty. These measurements include the Godot Web runtime and current game pack; they are not 40 MB of unique authored art. The long-term 4 GB genuine-content target is **NOT REACHED**.

### System status after this increment
| System | Status | Evidence / limit |
|---|---|---|
| Godot 4.7 import and WebAssembly export | **TESTED** | CI #45801655909 |
| Chromium WebGL 2 runtime and keyboard/mouse delivery | **TESTED** | 1280×720 local browser smoke |
| Mission 001 | **TESTED — first playable pass** | Claire → Nora; $250; objective/prerequisite/reward record |
| Mission 002 | **TESTED — first playable pass** | Nora → physical noticeboard → Nora; $300; one-time reward |
| Mission save restoration | **TESTED — selected live-game state** | Mission stage 5 and $900 wallet in GDScript; player/mission/vehicle/inventory/NPC/world in Chromium reload and process-restart probe |
| Browser storage degradation | **TESTED — controlled IndexedDB-unavailable simulation** | Session-only save remains readable in current page; no durable claim |
| World map and GPS | **PARTIALLY IMPLEMENTED** | Seven POIs and small connected prototype road graph; not a complete road network |
| Four world regions | **PARTIALLY IMPLEMENTED** | Connected blockout geometry, not final detailed terrain/interiors |
| Leo/Claire/Mia/Nora character presentation | **PARTIALLY IMPLEMENTED** | Temporary placeholders; final rigs, facial animation and acting absent |
| Vehicles | **PARTIALLY IMPLEMENTED** | One playable sedan; other classes and full handling/audio remain incomplete |
| Pedestrian, traffic and police simulation | **PARTIALLY IMPLEMENTED** | Service/controller tests exist; complete live open-world simulation is not established |
| Arabic dialogue voice acting and environmental audio | **PLANNED / NOT IMPLEMENTED** | Dialogue is text-only; no actual voice/audio asset is claimed |
| Full campaign, fail/retry, cinematics | **PLANNED** | Only the first two provisional mission slices are playable |
| 4 GB unique Web content | **NOT REACHED** | Current source/export measurements above; no filler or duplicated files counted |

### Remaining limits and next technical increment
The Mission 002 story beat is a provisional original proposal, not a maintainer-approved final narrative. It has no fail/retry branch, cinematic scene or voiced dialogue. The noticeboard interaction is tested through the Godot world-signal path, but a human visual/playthrough review is still outstanding. The world remains blockout-scale, character models remain placeholders, the road network is small, and the game is not complete. Firefox/Safari, private-browsing/storage-quota edge cases and complete visual acceptance are not verified.

Next: build a third mission slice only after the current two-mission save/waypoint flow is stable, then expand the Harbor City market block with a real enterable shop interior and persistent shop transactions, with browser reload coverage.


## Authoritative Web development update — 2026-11-27 — Mission 003 first playable pass

### Repository and review state
- `main` was observed at `e4c26a0e4e9d6945233b3032ed6966a7356103ab`; this work did not modify it.
- The original clean-project branch `web/standalone-from-empty-2026-11-22` remains at `9cdcec813aa874532e9c4c5d3113f967a9a0a26a`.
- PR #35 is closed and merged since 2026-11-22; it is not an open Draft. This run did not merge, close or retarget any PR.
- PR #114, #115 and #116 are Draft/open. PR #116 is stacked on PR #115's branch `feature/web-mission-002-harbor-market-20261126`; it remains unmerged.
- Mission 003 gameplay code was tested at `4a4ad91714b394d02139643570132dbc2002f42d`. This status/spec/README follow-up changes documentation and mission notes only; the final branch head still requires its own CI result.
- Earlier Web CI [#45979482404](https://github.com/dzdfast-art/GTA-GHIBLI/actions/runs/45979482404) failed because the market-entry interaction did not record its objective. That failure is retained as evidence and is not counted as a pass. The missing objective registration and entry-step signal were corrected.
- Corrected Web CI [#45980722964 — PASS](https://github.com/dzdfast-art/GTA-GHIBLI/actions/runs/45980722964) and Security Audit [#45980987636 — PASS](https://github.com/dzdfast-art/GTA-GHIBLI/actions/runs/45980987636) both tested the gameplay commit above.

### What changed
- Mission 003, `مؤونة الطريق`, now progresses from Nora to the physical Harbor Market interior, through a real shop purchase, and back to Claire for delivery and a one-time $150 reward.
- The market-entry step now updates the registered mission objective and is included in autosave.
- The mission can no longer advance through a raw `market_shop_purchase` interaction. The game root accepts the mission purchase only after the player is inside the shop and the inventory transaction succeeds.
- The required bottle cannot be sold while delivery is pending. A successful delivery consumes one bottle from player inventory without restoring shop stock.
- The post-delivery save records mission stage 8, wallet $1,025, zero carried mission water and seven bottles remaining in shop stock.
- Added regression checks for premature delivery, direct-purchase bypass, protected mission inventory, consumption on delivery, objective progress and autosave restoration.

### Exact validation evidence
- Godot 4.7 project import, mission/world JSON validation and research helper checks passed.
- **63 GDScript regression tests passed**, with runtime-error detection enabled. This includes the campaign, shop transaction, game-root integration, world foundation and save-state tests.
- WebAssembly export and required HTML, JavaScript, WASM and PCK checks passed. The CI-only browser save-probe scene/script were excluded from the normal game PCK.
- Chromium served the exported game from `127.0.0.1`; WebGL 2 initialized at 1280×720, keyboard/mouse events were delivered, and no browser runtime errors or external runtime requests were observed.
- The live game save passed same-origin page reload and separate Chromium process restart using the same persistent profile. The controlled IndexedDB-unavailable test retained session-only readability and did not claim durable storage.
- The CI job completed successfully and removed the temporary export and ZIP. The Actions artifact list was empty.

### Exact source and Web export measurements
| Measurement | Result |
|---|---:|
| Tracked Web source files | 142 |
| Tracked Web source bytes | 318,868 bytes (0.319 MB) |
| Unique tracked content items | 142 |
| Unique tracked content bytes | 318,868 bytes (0.304 MiB) |
| Temporary Web export files | 8 |
| Uncompressed Web export | 40,023,104 bytes (40.023 MB; 38.169 MiB) |
| Compressed Web ZIP | 10,402,744 bytes (10.403 MB; 9.921 MiB) |
| ZIP SHA-256 | `0ba7eee2ddc25610cd56766b4cfc0745e283accb755c85952f1d0c80aa4cbffa` |

The export and ZIP were created only on the ephemeral runner, measured and deleted. No downloadable Actions artifact was retained. These measurements include the Godot Web runtime and current game pack; they are not all unique authored art. The long-term 4 GB genuine-content target is **NOT REACHED**.

### System status after this increment
| System | Status | Evidence / limit |
|---|---|---|
| Godot 4.7 import, WebAssembly export and export-file validation | **TESTED** | CI #45980722964 |
| Chromium WebGL 2 runtime and keyboard/mouse delivery | **TESTED** | 1280×720 localhost smoke; no runtime errors/external requests |
| Mission 001 | **TESTED — first playable pass** | Claire → Nora; $250 one-time reward |
| Mission 002 | **TESTED — first playable pass** | Nora → physical noticeboard → Nora; $300 one-time reward |
| Mission 003 | **TESTED — first playable pass** | Nora → enter market → buy water → deliver to Claire; $150 one-time reward; bottle consumed |
| Harbor Market transactions | **TESTED — first playable pass** | Bounded stock, buy/sell, mission-item protection and delivery consumption |
| Mission/shop autosave | **TESTED — selected live-game state** | Mission stage 8, wallet $1,025, carried water 0, shop water stock 7 |
| Browser save persistence | **TESTED — Chromium only** | Same-origin page reload and separate browser-process restart |
| Browser storage degradation | **TESTED — controlled IndexedDB-unavailable simulation** | Session-only save remains readable in active page; no durable claim |
| World map and GPS | **PARTIALLY IMPLEMENTED** | Eight POIs and connected prototype street grid; not a complete city network |
| Four world regions | **PARTIALLY IMPLEMENTED** | Connected blockout geometry, not final terrain/buildings/interiors |
| Leo/Claire/Mia/Nora presentation | **PARTIALLY IMPLEMENTED** | Placeholder models; final rigs, facial animation and acting absent |
| Vehicles | **PARTIALLY IMPLEMENTED** | One playable sedan and tested vehicle services; other classes and final handling/audio incomplete |
| Pedestrian, traffic and police simulation | **PARTIALLY IMPLEMENTED** | Individual services and regression tests exist; complete live simulation is not established |
| Arabic voice acting and regional environmental audio | **PLANNED / NOT IMPLEMENTED** | Dialogue remains text-only; no recorded voice performance is claimed |
| Full campaign, fail/retry and cinematics | **PLANNED** | Only the first three provisional mission slices are playable |
| 4 GB unique Web content | **NOT REACHED** | Exact source/export measurements above; no filler or duplicated files counted |

### Remaining limits and next technical increment
Mission 003 remains a provisional original story proposal, not a maintainer-approved final campaign chapter. It has no fail/retry branch, cinematic scene or voiced dialogue. The market is one prototype interior; the rest of the city, character art, vehicle classes and open-world simulation remain incomplete. This is foundation regression and Chromium smoke coverage, not full-game acceptance. Human visual review, Firefox/Safari, private-browsing and storage-quota edge cases remain unverified.

Next: build Mission 004 as an original vehicle-and-GPS delivery across a second region, with checkpoint/fail/retry rules and save/reload tests. Keep the mission linked to real world locations and road routes rather than a menu-only objective.
