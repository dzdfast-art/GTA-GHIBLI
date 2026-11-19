# GTA GHIBLI — Comprehensive Repair Candidate

Date: 2026-11-20
Repository: `dzdfast-art/GTA-GHIBLI`
Base commit: `c9fc82936a43b80af0e3c25eef41c9fee59e47b7`
Branch: `fix/comprehensive-stability-2026-11-20`
Status: draft repair candidate; no merge, no public deployment.

## Changes prepared on this branch

| Area | Candidate change | Verification status |
|---|---|---|
| RUN sprint | Sprint multiplier 1.6, used by player controller while sprint action is held | Awaiting Godot CI |
| Wallet | Version 2 reward transaction ledger; duplicate transaction IDs are rejected; reads existing balance-only files | Awaiting Godot CI |
| Missions 001–004 | Completion reward callbacks use unique wallet transaction IDs | Awaiting Godot CI |
| STATS | Reads wallet, health when available, needs, world clock, region/building/population counts, mission count and side activity save | Awaiting Godot CI |
| BRIEF | Reads mission JSON and save records; uses active mission HUD snapshots | Awaiting Godot CI |
| Pause menu | Test checks exact order RESUME / START NEW GAME / MAP / STATS / BRIEF / OPTIONS / QUIT GAME | Awaiting Godot CI |
| Terrain | Keeps the existing 72-object catalog; loads within 72 units, unloads beyond 96, max six active tiles and two loads per 0.35-second update; matching trimesh collision | Awaiting Godot CI |
| Application icon | Adds SVG and configures `application/config/icon` | Awaiting Godot import / APK build |
| Marsa Al-Noor | Proposed Harbor City landmark, metadata, scene node and map marker at local (14,0,10), world (-68,0,-44) | Awaiting Godot CI; placement is a design proposal |
| Web Chromium | No change to separate `web-preview` runner | Already passed in Web Preview run #14, separate branch |

## Technical evidence retained

- Gameplay HUD/radar, procedural low-poly player, PlayerHealth node, bicycle-to-bridge-to-house tutorial and four ambient traffic cars were brought onto this branch from PR #30's tested head `42779015420d8076485ae3ba2a75c11dcac17aa2`. The PR itself remains unmerged.
- The private Chromium smoke test succeeded separately in [Web Preview run #14](https://github.com/dzdfast-art/GTA-GHIBLI/actions/runs/44633964747). It verified a canvas, WebGL 2, browser input delivery, no runtime errors and no external network requests.
- Current OBJ samples inspected from `expansion_150mb`, `expansion_300mb` and `high_detail` reference their colocated `expansion_terrain.mtl` or `high_detail_terrain.mtl`; those material files exist in the respective directories. The older warning about `terrain_300mb.mtl` was not reproduced in these samples, so no redundant symlink or duplicate MTL was added.

## Explicitly not completed

- New expressive Arabic voice recordings: all 25 dialogue lines still need retakes.
- Physical Android touch/visual/FPS/RAM/audio/thermal/install test: not available because no physical test device is connected.
- Complete game-wide save manager: current saves remain split across mission, wallet, needs and inventory files.
- Full NavMesh navigation and complete NPC schedules for all characters.
- Advanced vehicle physics, full traffic AI, damage integration and remaining vehicle classes.
- Full production content for the four regions and any final canon/story placement approval for Marsa Al-Noor.
- Signed production Android release and full per-asset provenance/legal review.

Do not label this candidate release-ready until its Godot, Android and security workflows pass and a physical-device test has been performed.