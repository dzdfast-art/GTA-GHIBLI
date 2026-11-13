# GTA GHIBLI

An original third-person 3D open-world adventure for Android, built with Godot 4.

## Project status

**Early prototype — not yet runtime-validated.** The project now has a modular player scene,
camera-relative movement, a touch-orbit camera rig, and on-screen directional controls.
The visible character is still a simple capsule and the world is still a flat test area.
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

These controls are source-level implementation and still need a Godot runtime test.

## Project documents

- [Project blueprint](docs/PROJECT_BLUEPRINT.md)
- [Core gameplay systems](docs/GAMEPLAY_SYSTEMS.md)
- [Initial quality audit](docs/QUALITY_AUDIT.md)
- [Android 4 GiB content budget](docs/ANDROID_4GB_BUDGET.md)

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
