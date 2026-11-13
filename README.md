# GTA GHIBLI

An original third-person 3D open-world adventure for Android, built with Godot 4. The current repository is an **early playable-systems prototype**, not the finished game.

## Current verified status

Implemented in the prototype:
- Godot project configured with the Compatibility renderer.
- Third-person capsule placeholder, camera-relative movement and touch-orbit camera.
- On-screen directional controls and a contextual TALK action.
- Procedural Willow Village greybox with a square, placeholder houses, paths, garden, trees, well and sign.
- Mira NPC prototype with proximity detection and Arabic dialogue text/emotion metadata.
- First tutorial mission tracking: reach the square → talk to Mira → visit the garden.
- Local save/restore for the first mission's three progress flags.

Not yet verified or not yet implemented:
- Final character models, rigs and animations.
- Real integrated Arabic voice acting (Mira's audio is still pending).
- A complete reusable physics/object interaction system.
- Drivable vehicles and category-specific vehicle controls.
- Full main story, broad cast, varied side missions and living-world systems.
- Canonical final regions and world map/GPS.
- Complete inventory/currency and game-wide save system.
- Android export, installation, physical-device performance and touch testing.

The first mission's currency reward is currently displayed as prototype information; it is not connected to a real wallet or inventory.

## Important product specification

The governing requirements and prototype discrepancies are recorded in [Master Requirements Alignment](docs/MASTER_REQUIREMENTS_ALIGNMENT.md). The supplied `GTA_GHIBLI_FULL_PROMPT.txt` remains the primary product brief.

The master brief names the four canonical regions **Harbor City, Sapphire Coast, Pine Highlands and Amber Valley**, plus **Marsa Al-Noor**, and the required cast **Leo Bennett, Claire Bennett, Mia Bennett and Nora Blake**. Current names such as Green Valley, Willow Village and Mira belong to the existing prototype and must not silently replace those requirements.

The project must include systemic interactions, physics, people, nature, food, varied missions and genuinely controllable vehicles. Repetition should be reviewed and reduced rather than used to inflate content counts. See [Core Gameplay Systems](docs/GAMEPLAY_SYSTEMS.md).

## Open the prototype

1. Open Godot 4.7.
2. Choose **Import** and select the repository folder.
3. Open `project.godot`.
4. Press **F6** to run the current scene, or **F5** to run the project.

## Current controls

- Keyboard: arrow keys / Godot UI direction actions.
- Touch: hold the directional buttons on the lower-left side.
- Camera: drag on the right side of the screen; on desktop, hold the right mouse button and move.
- Interaction: approach Mira and use TALK (or press E on desktop).

## Automated validation

GitHub Actions run [43513899542](https://github.com/dzdfast-art/GTA-GHIBLI/actions/runs/43513899542) completed successfully. All eight validation steps passed: JSON validation, Godot 4.7 resource import, gameplay-script parsing, first-mission objective/save test and a 180-frame headless main-scene smoke test.

This is headless CI validation only. It does not prove visual quality, real touchscreen behavior, audio playback, vehicle gameplay, Android export or performance on a physical phone.

## Project documents

- [Master requirements alignment](docs/MASTER_REQUIREMENTS_ALIGNMENT.md)
- [Project blueprint](docs/PROJECT_BLUEPRINT.md)
- [Core gameplay systems](docs/GAMEPLAY_SYSTEMS.md)
- [Initial quality audit](docs/QUALITY_AUDIT.md)
- [Android 4 GiB content budget](docs/ANDROID_4GB_BUDGET.md)

## Prototype scene and structured data

- [Willow Village scene](scenes/world/willow_village.tscn)
- [Willow Village generator](scripts/world/willow_village.gd)
- [World prototype data](data/world/regions.json)
- [First tutorial mission](data/missions/mission_001.json)
- [Mira Arabic dialogue data](data/dialogue/mira_intro_ar.json)

## Creative direction and ownership

Create an original, warm, hand-painted fantasy atmosphere with systemic open-world gameplay. GTA San Andreas is a high-level genre reference only. Do not copy its maps, characters, dialogue, missions, branding, music, source code or extracted assets.

## Size target

The planned total installed content budget is **4,096 MiB (4 GiB)**. This is not the current repository size, not the current download size, and not a measured Android build. See [Android content budget](docs/ANDROID_4GB_BUDGET.md).

## Quality rule

Do not describe a feature as working until it has been run and tested. For mobile features, distinguish headless tests from actual Android-device tests.
