# GTA GHIBLI Web Edition — Verified Status Ledger

Updated: 2026-11-22  
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
| Godot project + main scene | Implemented, CI pending | Fresh project files in `web-edition/` |
| Four named regions | Blockout implemented | Four adjacent ground areas with a single road corridor; not a finished open world |
| Marsa Al-Noor | Provisional landmark | Lighthouse blockout in Harbor City; final map/story placement not approved |
| Leo Bennett | Placeholder player | Capsule-based temporary visual; no final rig or animation |
| Claire / Mia / Nora | Placeholder interactive characters | Names and confirmed family relationships preserved; not final character models |
| Walking / sprinting / jumping | Implemented in source, CI pending | WASD, Shift, Space |
| Camera orbit / zoom | Implemented in source, CI pending | Right mouse drag and wheel |
| Interaction | Implemented in source, CI pending | E near Claire/Mia/Nora or starter sedan |
| Sedan | First drivable pass, CI pending | Basic acceleration, steering, reverse, brake and enter/exit; advanced physics/audio absent |
| Mission 001 | First playable pass, CI pending | Claire interaction -> Nora interaction -> $250 reward |
| Local save | Partial implementation | Mission stage and wallet written using ConfigFile; complete save coverage absent |
| HUD | First pass | Objective, region, wallet, prompt and dialogue text |
| Map | Preliminary overlay | Region labels only; no live minimap, GPS or road route guidance |
| Browser audio | Not implemented | No placeholder/silent audio used; Arabic voice acting remains unverified/not included |
| CI Web export / Chromium | Configured, pending this branch | See the new Web Edition CI workflow once it runs |

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

## Required verification before promoting this milestone

1. Godot 4.7 clean import and script parser.
2. JSON validation for region, cast and mission records.
3. Automated test for main-scene startup, four-region mapping, character interactions, mission progression/reward, player movement and vehicle drive/exit.
4. Godot Web export producing non-empty HTML, JavaScript, WebAssembly and PCK.
5. Local-only Chromium/WebGL 2 startup, keyboard and mouse input smoke test.
6. No JavaScript/runtime errors and no external network requests.
7. Exact tracked source, uncompressed export and compressed ZIP sizes plus Web ZIP SHA-256.

A green foundation test proves only the tested foundation. It is not full-game acceptance.
