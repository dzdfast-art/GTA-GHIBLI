# GTA GHIBLI — Claude Review & Engineering Guide

## Project constraints
- Engine: Godot 4.7; Android ARM64; Compatibility renderer.
- Primary gameplay code: typed GDScript. Keep systems modular and avoid introducing another runtime language without a concrete engine need.
- Preserve existing missions 001–004, Mira dialogue data, village/bridge regions, bicycle and car interactions, needs, wallet, clock, weather, wildlife, settings and mobile controls.
- Do not remove or rename existing public methods, input actions, groups, scene paths, save keys or exported properties without a compatibility migration and tests.
- Do not commit to `main`. Work on the feature branch and submit a reviewable PR.
- Do not merge PRs automatically. Keep PR #11 and PR #13 separate until their checks and review pass.
- Never claim an APK is playable without a successful build artifact and a real-device smoke test.

## Architecture expectations
Use typed, single-responsibility GDScript systems:
- `PlayerController`: movement, locomotion state and input ownership.
- `ThirdPersonCamera`: camera orbit, touch-drag isolation and collision handling.
- `VehicleController`: common enter/drive/exit contract for cars and bicycles.
- `CharacterVisual`: imported GLB character, skeleton and animation state machine.
- `NPCBrain`: perception, navigation, reactions and interaction.
- `MissionManager`: mission state and objective snapshots.
- `GameHUD`: one active gameplay HUD; no stacked legacy objective panels.
- `WorldMapData` / `WorldMapView`: shared road graph data and map rendering.

Prefer typed exports, enums, signals, small functions, explicit null checks and stable node paths. Avoid dynamic `call()` where a typed interface is practical. Do not add large assets as unused ballast.

## Required validation
Before requesting review:
1. Run Godot 4.7 headless import and script parse.
2. Run the existing project validation workflow.
3. Test player walk/run/stop/turn and camera drag isolation.
4. Test car and bicycle mount/drive/exit, invalid driver cleanup and collision.
5. Test mission 001–004 progression, settings persistence, HUD and map.
6. Test Android export and report APK size plus artifact URL.
7. State which checks were not run and why.

## Independent review checklist
Claude must review the full diff, not only the PR description. Report:
- Confirmed regressions and exact file/line evidence.
- GDScript parse/type/runtime risks.
- Touch input and camera ownership conflicts.
- Scene/node path and signal lifecycle errors.
- Android memory/performance risks, especially mesh/material/texture budgets.
- Asset provenance and license compliance.
- Missing tests and reproducible steps.

Claude must not edit or merge as part of a review-only pass. Any proposed fixes should be returned as a separate patch or explicit recommendations for GPT to implement and test.
