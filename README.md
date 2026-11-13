# GTA GHIBLI

An original third-person 3D open-world adventure for Android, built with Godot 4.

## Project status

**Early prototype with a first village blockout — headless validated, not yet Android/device validated.** The project now has a modular player scene,
camera-relative movement, a touch-orbit camera rig, and on-screen directional controls.
The visible character is still a simple capsule. Willow Village now has a procedural blockout with a central square, four placeholder houses, paths, a garden, trees, a well, and a village sign.
No finished art, vehicles, NPCs, or playable mission system are included yet.

## Open the project

1. Open Godot 4.
2. Choose **Import** and select the repository folder.
3. Open the project.godot file.
4. Press **F6** to run the current scene, or **F5** to run the project.

## Current controls

- Keyboard: arrow keys / Godot UI direction actions.
- Phone: hold the directional buttons on the lower-left side.
- Camera: drag on the right side of the screen; on desktop, hold the right mouse button and move.

The GitHub Actions validation passed with Godot 4.7: project import, GDScript parsing, and a 180-frame headless main-scene smoke test. Visual behavior and touch controls still need testing on a real Android device.

## Project documents

- [Project blueprint](docs/PROJECT_BLUEPRINT.md)
- [Core gameplay systems](docs/GAMEPLAY_SYSTEMS.md)
- [Initial quality audit](docs/QUALITY_AUDIT.md)
- [Android 4 GiB content budget](docs/ANDROID_4GB_BUDGET.md)

## First world slice

- [Willow Village scene](scenes/world/willow_village.tscn)
- [Willow Village generator](scripts/world/willow_village.gd)

This is a lightweight greybox made from primitive shapes, not finished art. NPC dialogue, mission triggers, and final terrain are still future work.

## Structured game data

- [World regions](data/world/regions.json)
- [First tutorial mission](data/missions/mission_001.json)

The mission and region files are design data only; they are not connected to runtime managers yet.

## Creative direction and ownership

Create an original, warm, hand-painted fantasy atmosphere with exploration, characters, missions,
and vehicles. GTA San Andreas may be used as a high-level genre reference only. Do not copy its
maps, characters, dialogue, missions, branding, music, source code, or extracted assets.

## Size target

The planned total installed content budget is **4,096 MiB (4 GiB)**. This is not the current
repository size, not the current download size, and not a measured Android build. See the
content budget document for allocations and measurement gates.

## Quality rule

Do not describe a feature as working until it has been run and tested in Godot and, for mobile
features, on an Android device.
