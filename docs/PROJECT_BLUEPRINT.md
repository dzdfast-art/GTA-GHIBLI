# GTA GHIBLI — Project Blueprint

## Vision and governing brief

GTA GHIBLI is an original third-person open-world action-adventure for Android, with systemic exploration, driving, characters, missions and a warm painterly visual identity. GTA San Andreas is a reference for breadth and gameplay systems only; all maps, cast, missions, dialogue, music, UI artwork and assets must be original or properly licensed.

The governing product brief is `GTA_GHIBLI_FULL_PROMPT.txt`. See [Master Requirements Alignment](MASTER_REQUIREMENTS_ALIGNMENT.md) for canonical requirements and discrepancies between that brief and the current prototype.

## Canonical product targets

- Platform: Android smartphones.
- Engine currently used by the prototype: Godot 4.7.
- Baseline device: Infinix SMART 8, Unisoc T606, 4 GB physical RAM, 720 × 1612 display.
- Camera: third-person, touch orbit, collision-aware.
- Art: original stylized 3D with a hand-painted/painterly look.
- Content planning target: 4,096 MiB (4 GiB) of genuine useful content, measured separately from runtime RAM.
- Canonical regions: Harbor City, Sapphire Coast, Pine Highlands and Amber Valley.
- Named central location: Marsa Al-Noor.
- Required named cast: Leo Bennett, Claire Bennett, Mia Bennett and Nora Blake.

The canonical region/cast requirements are not yet implemented in the current prototype. Green Valley, Willow Village and Mira are prototype content, not replacements for the canonical brief.

## Current verified prototype baseline

- Root Godot project points to `main.tscn`.
- `main.tscn` loads `main.gd`.
- Compatibility renderer is configured.
- `main.gd` creates a test environment and instantiates the player, village, touch controls and mission manager.
- `scenes/player/player.tscn` contains a capsule placeholder, collision, camera pivot, spring arm and camera.
- `scripts/player/player_controller.gd` implements camera-relative movement and gravity.
- `scripts/camera/third_person_camera.gd` implements touch/desktop camera orbit.
- `scripts/ui/mobile_controls.gd` creates directional buttons and a shared interaction action.
- `scripts/systems/player_interactor.gd` routes that action to the nearest registered interaction area; Mira is the first integrated target.
- Willow Village is a procedural greybox.
- Mira has proximity interaction, Arabic dialogue text and emotion metadata. Her audio path is pending; real integrated Arabic voice playback is not verified.
- The first mission reads JSON, tracks reaching the square, talking to Mira and visiting the garden, and persists those three flags locally.
- The prototype reward display is not connected to a real currency or inventory system.
- No working drivable vehicle, complete physics/object interaction framework, full campaign, final art, Android export or physical-device test is verified.

GitHub Actions run [43513899542](https://github.com/dzdfast-art/GTA-GHIBLI/actions/runs/43513899542) passed all eight validation steps using Godot 4.7: JSON validation, resource import, script parsing, first mission/save test and a 180-frame headless main-scene smoke test. This does not validate rendered visuals, real touch controls, audio, vehicles, Android export or target-device performance.

## Prototype architecture

```
res://
  project.godot
  main.tscn
  main.gd
  scenes/
    player/
    world/
  scripts/
    player/
    camera/
    ui/
    world/
    characters/
    missions/
  data/
    dialogue/
    missions/
    world/
  docs/
  tests/
  .github/workflows/
```

Future production systems should be modular and data-driven. Expected responsibilities include player, input, interaction, physics objects, characters/NPCs, vehicles by category, dynamic HUD, world/region streaming, map/GPS, missions, dialogue/audio, inventory, save, traffic, police, time/weather and performance management.

## Development sequence

1. Resolve the clean-production-project boundary while preserving the existing prototype and its history.
2. Establish canonical world, cast and narrative data from the master brief.
3. Implement a reusable contextual interaction framework and test one object and one NPC end-to-end.
4. Add one genuinely drivable car with safe entry/exit, collision, handling, camera and mobile HUD transitions.
5. Expand mission data/runtime with varied main, side and job templates plus an explicit anti-repetition review.
6. Add object physics, buildings/services, nature, food and living-world systems incrementally.
7. Expand to motorcycles, bicycles, trucks, boats, aircraft and helicopters with suitable control profiles.
8. Integrate original optimized art, animations, expressive Arabic voice assets, music and effects.
9. Implement canonical regions, seamless world connectivity, map/minimap and road-aware GPS.
10. Build Android exports, test installation and controls on the target phone, profile memory/FPS, and maintain the asset inventory.

Each stage requires real implementation, reproducible tests, known-issue notes and evidence. A document or placeholder does not count as a completed gameplay feature.

## 4 GiB content policy

The 4 GiB target is a storage/content budget, not a runtime RAM requirement and not a target for the early prototype. Do not create empty or duplicated files to inflate size. Track source asset size, imported project size, download size, installed size and update size separately. Reuse assets only where quality permits; use LOD, instancing, culling and region-based streaming. See [ANDROID_4GB_BUDGET.md](ANDROID_4GB_BUDGET.md).

## Quality rules

- Build one small feature at a time and test it.
- Keep planned, implemented, blocked and tested statuses separate.
- Prefer modular geometry, simple collision, LOD, instancing and distance-based simulation.
- Keep touch targets large and support Android aspect ratios and safe areas.
- Test on the actual target device before claiming mobile performance.
- Do not copy GTA San Andreas code, maps, characters, missions, logos, music or extracted assets.
- Record known issues and acceptance tests in [QUALITY_AUDIT.md](QUALITY_AUDIT.md).
