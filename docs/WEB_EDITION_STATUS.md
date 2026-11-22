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

