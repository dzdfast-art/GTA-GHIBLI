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


---

## Daily development update — 2026-11-23: first road graph and mission GPS

### Repository state audited before this change
- main: 0e166bbd3041adbed838e8436a0eecb73da9746b.
- Web development branch before this change: fd9c6cbdf85fd804bfcbeed27b7e26fe5c486d6c.
- PR #35 was already closed and merged at 4b9c657d21870d0e2e947c041db8c2abd3ad7bdf by the previous session. This update does not attempt to rewrite or reverse main.
- PR #36 was also merged into main; it changed Web CI to retain a downloadable Actions artifact. That behavior is not copied into this development branch because the current delivery rule requires temporary export, measurement and deletion.
- PR #35 cannot be kept Draft/open after its recorded merge. No new PR is created by this update.

### Work added on the Web development branch
- Added web-edition/data/world/road_graph.json: 16 nodes and 16 edges across the four blockout regions, including the east-west arterial, four location-access spurs and a coastal bypass.
- Added web-edition/scripts/world/road_network.gd: graph validation, nearest-node endpoint selection, Dijkstra shortest path, closed-edge exclusion, unreachable-route reporting and route geometry output.
- Updated the world builder to create road surfaces from the graph instead of one hard-coded road strip.
- Updated the HUD/minimap to draw the active route and destination marker.
- The introductory mission now guides the player to Claire at stage 0 and Nora at stage 1; the route clears after the introductory mission is complete.
- Added regression cases for graph counts, road geometry, Nora routing, bypassing a closed road edge, unreachable lighthouse access and minimap route state.
- Added CI JSON validation for the road graph. No external runtime assets, remote services or public hosting are introduced.

### Status before CI result
| System | Status | Boundary |
|---|---|---|
| Road graph data | IMPLEMENTED | 16 nodes / 16 edges; prototype coverage only |
| Road surface generation | IMPLEMENTED | Visual blockout strips over the existing collidable regional ground |
| Shortest-path routing | IMPLEMENTED — awaiting CI | Dijkstra by horizontal segment length; closed edge IDs can be excluded |
| Mission-aware GPS overlay | IMPLEMENTED — awaiting CI | Introductory Claire/Nora objectives only |
| Full GPS destination selection | PLANNED | No user-selected destinations, turn-by-turn prompts or road snapping to the full world |
| Pedestrian/path navigation | PLANNED | Current graph is for roads only; endpoint connectors are straight and not obstacle-aware |
| Full road network / traffic lanes | PLANNED | Not a finished street system; traffic simulation is not implemented |
| Four-region world | PARTIALLY IMPLEMENTED | Region and building geometry remain blockout placeholders |

### Validation boundary
- Godot is not installed in the working container; no local Godot parse/import or Web export is claimed.
- The GitHub Web CI triggered by this branch update must be used to establish Godot 4.7 import, gameplay regression, Web export and Chromium/WebGL 2 results.
- Existing successful run #45025650263 tested the earlier branch head fd9c6cb, not this road-network change.
- No current export size or SHA-256 is claimed for this change until the new CI run reports them.
- No Actions artifact is requested or uploaded by the Web development workflow.


---

## Authoritative daily result — 2026-11-23: road graph milestone verified

This section supersedes the immediately preceding "Status before CI result" block.

### Repository state after this work
- main remains at 0e166bbd3041adbed838e8436a0eecb73da9746b; this run did not modify main.
- Web development branch: web/standalone-from-empty-2026-11-22; gameplay implementation commit: 63e158d7b3178bc102cb478dc9b62185348f2675; documentation-only evidence update: 40e130b902b43e7f479812e3719379e98cfac9ea. The branch link below resolves the live head.
- New development commit: https://github.com/dzdfast-art/GTA-GHIBLI/commit/63e158d7b3178bc102cb478dc9b62185348f2675.
- PR #35 is already closed and merged at 4b9c657d21870d0e2e947c041db8c2abd3ad7bdf from the previous session; it cannot truthfully be described as Draft/open. This update did not rewrite or reverse main and did not create or merge another PR.
- PR #36 is merged on main and its Web CI upload step left an existing Actions artifact: artifact ID 14757749108, 10,274,141 bytes, created by run #45033114459, scheduled to expire 2026-12-06. This branch does not copy that upload behavior. The current GitHub connector exposes artifact listing/download but not artifact deletion, so this update did not claim to remove that pre-existing artifact.
- The branch is diverged from current main: one commit ahead and two commits behind. No merge/rebase was performed.
- No PR #31 or legacy B1–B16 project files were used as a source or modified.

### CI and executable validation
- Web CI run #45159757563 (workflow run number 42): PASS on this exact commit.
- Godot 4.7 project import: PASS.
- JSON validation, including road_graph.json: PASS.
- Research registry/helper validation: PASS.
- Gameplay regression: PASS, including all pre-existing foundation checks and the new 16-node/16-edge road graph checks.
- WebAssembly export and HTML/JS/WASM/PCK presence checks: PASS.
- Chromium 140.0.7339.16 at 1280×720 with WebGL 2: PASS.
- Browser delivered WASD, right-mouse drag and M key events; no browser runtime errors and no external network requests were reported.
- Temporary export and ZIP were measured and deleted on the runner. The run produced no Actions artifact.
- No separate security-audit run was triggered for this branch commit. The latest main security audit #45033114458 passed on main commit 0e166bb, but that is not a security audit of this new branch head.

### Exact package and source measurements
| Measurement | Before this milestone | After this milestone |
|---|---:|---:|
| Tracked web-edition source files | 18 files / 60,025 bytes | 20 files / 81,801 bytes |
| Tracked source growth | — | +2 files / +21,776 bytes |
| Uncompressed Web export | 39,868,954 bytes | 39,887,794 bytes |
| Compressed Web ZIP | 10,273,661 bytes | 10,286,847 bytes |

- Current uncompressed export: 39.888 MB decimal / 38.040 MiB.
- Current compressed ZIP: 10.287 MB decimal / 9.810 MiB.
- Export files: 7.
- ZIP SHA-256: 934015e0ae6213d0d1d009b7d20c8c04a789ac5651e73b8b614af6f31644cb4b.
- The 21,776-byte source increase is code/JSON/documentation, not a new binary art/audio asset pack. The 4 GB unique-content goal remains NOT REACHED.

### Final status classification for this milestone
| System | Status | Exact boundary |
|---|---|---|
| Road graph data | TESTED | 16 stable nodes / 16 edges across the four blockout regions |
| Generated road strips | TESTED | Visible arterial, access roads and coastal bypass over the existing collidable ground |
| Dijkstra shortest path | TESTED | Segment-length weighting; excludes supplied closed edge IDs |
| Detour selection | TESTED | Coastal bypass selected when the tested arterial edge is closed |
| Unreachable reporting | TESTED | Nora's route is reported unreachable when its only lighthouse access edge is closed |
| Mission-aware minimap route | TESTED | Claire for stage 0, Nora for stage 1; route polyline and destination marker delivered to HUD |
| Full GPS | PARTIALLY IMPLEMENTED | No player-selected destinations, turn-by-turn guidance, obstacle-aware endpoint connectors or complete road coverage |
| Full world / interiors / streaming | PLANNED or PARTIALLY IMPLEMENTED | Region geometry remains blockout; this road graph is not a finished world |
| Traffic, pedestrian and police navigation | PLANNED | No traffic lane simulation or NPC pathfinding is added in this milestone |
| 4 GB real content | NOT REACHED | No filler or duplicate assets were added |

### Links
- Web CI #45159757563: https://github.com/dzdfast-art/GTA-GHIBLI/actions/runs/45159757563
- Tested commit: https://github.com/dzdfast-art/GTA-GHIBLI/commit/63e158d7b3178bc102cb478dc9b62185348f2675
- Web development branch: https://github.com/dzdfast-art/GTA-GHIBLI/tree/web/standalone-from-empty-2026-11-22

- Documentation-only follow-up commit 40e130b902b43e7f479812e3719379e98cfac9ea recorded the test evidence; it did not change gameplay code. Web CI #45160613726 was triggered for that docs commit and was still running at the time of the original status entry. The gameplay commit 63e158d7b3178bc102cb478dc9b62185348f2675 passed the full Web gate in run #45159757563. This ledger correction is documentation-only and does not alter the tested game code.
