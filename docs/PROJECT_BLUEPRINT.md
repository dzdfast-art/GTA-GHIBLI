# GTA GHIBLI — Project Blueprint

## Vision
A small, original, third-person 3D open-world adventure for Android, combining the freedom and systemic gameplay of classic open-world games with a warm, hand-painted fantasy atmosphere. The project must use original characters, locations, missions, dialogue, music, and assets.

## Current verified baseline
- Godot project configuration exists at the repository root.
- Main scene: `main.tscn`.
- Main prototype script: `main.gd`.
- The main scene and script paths in the project have been corrected.
- The prototype currently creates a flat test ground, a capsule player, a follow camera, lighting, and basic touch movement buttons.
- The repository has not yet been run or validated in the Godot editor in this workflow.

## Target architecture
Keep gameplay code separated by responsibility as the project grows:

```
res://
  project.godot
  main.tscn
  main.gd
  scenes/
    world/
    player/
    vehicles/
    characters/
    ui/
  scripts/
    player/
    world/
    vehicles/
    missions/
    systems/
  assets/
    models/
    materials/
    textures/
    audio/
    fonts/
  data/
    missions/
    characters/
    vehicles/
  docs/
```

## Development phases
1. **Playable foundation:** stable player controller, camera follow, touch controls, collision, and a small test area.
2. **World blockout:** roads, paths, terrain, buildings, landmarks, and a simple minimap-ready coordinate layout.
3. **Core gameplay:** interaction system, dialogue, mission objectives, checkpoints, and save/load.
4. **Vehicles:** enter/exit, arcade driving, camera behavior, and mobile driving controls.
5. **Living world:** original NPCs, simple schedules, traffic, ambient events, and shops.
6. **Art and sound:** original stylized assets, materials, lighting, music, and sound effects.
7. **Android optimization and release:** performance budgets, touch UX, export presets, testing, and web-playable build evaluation.

## Quality rules
- Build and test one small feature at a time.
- Prefer low-poly geometry and mobile-friendly materials before adding expensive effects.
- Keep touch controls usable on narrow phone screens.
- Do not copy GTA San Andreas source code, maps, characters, missions, logos, audio, or extracted assets. Use it only as a high-level reference for genre systems.
- Do not claim a feature works until it has been run and tested in Godot.
- Record known issues and test instructions in this document as the project evolves.

## Immediate next implementation
Replace the single large prototype script with separate player, camera, and mobile-input components while preserving a minimal playable test scene. Validate the result in Godot before adding vehicles or mission systems.
