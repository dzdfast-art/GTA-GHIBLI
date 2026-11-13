# GTA GHIBLI — Project Blueprint

## Vision

An original third-person 3D open-world adventure for Android, combining the freedom and systemic
gameplay of classic open-world games with a warm, hand-painted fantasy atmosphere. The project
must use original characters, locations, missions, dialogue, music, and assets.

## Targets

- Primary platform: Android.
- Engine: Godot 4.
- Camera: third-person, touch-orbit, collision-aware.
- Art direction: original stylized 3D with a hand-painted look.
- Installed content planning target: 4,096 MiB (4 GiB), measured at release-candidate stages.
- Initial playable world: one small, optimized countryside slice.
- A future web version must be a separately optimized build with a much smaller initial payload.

## Current verified repository baseline

- Godot project configuration exists at the repository root and points to main.tscn.
- main.tscn points to main.gd.
- The Compatibility renderer is configured as the mobile-oriented baseline.
- main.gd now acts as a bootstrapper that creates the test environment and instantiates the player
  and mobile controls.
- scenes/player/player.tscn contains the reusable player body, collision, camera pivot, spring arm,
  and camera.
- scripts/player/player_controller.gd implements camera-relative movement.
- scripts/camera/third_person_camera.gd implements right-side touch drag and desktop right-mouse
  camera orbit; SpringArm3D is configured to keep the camera from passing through nearby geometry.
- scripts/ui/mobile_controls.gd creates the on-screen directional pad and simulates Godot UI input
  actions.
- The four Green Valley regions and first tutorial mission remain structured design data. They are
  not loaded by runtime managers.
- The repository has not yet been launched in the Godot editor or tested on Android in this workflow.
  Runtime behavior, import success, and performance are therefore not confirmed.

## Current architecture

    res://
      project.godot
      main.tscn
      main.gd
      scenes/
        player/
          player.tscn
      scripts/
        player/
          player_controller.gd
        camera/
          third_person_camera.gd
        ui/
          mobile_controls.gd
      data/
        missions/
        world/
      docs/
      .gitignore

Future systems should be added by responsibility rather than returning to a single large script:

    scenes/
      world/
      vehicles/
      characters/
      ui/
    scripts/
      world/
      vehicles/
      characters/
      missions/
      systems/
    assets/
      models/
      materials/
      textures/
      audio/
      fonts/

## First world slice: Green Valley

- **Willow Village:** player start, central square, and starter characters.
- **Sunmeadow Fields:** open exploration, paths, orchards, and collectibles.
- **Old Mill Road:** connecting route and future vehicle test.
- **Mistwood Edge:** forest exploration, gathering, and future expansion.

The region catalogue is in data/world/regions.json. Final geometry, navigation, landmarks, and art
remain to be implemented.

## Development phases

1. **Validate the movement foundation:** open and run the scene in Godot; confirm keyboard, touch
   movement, camera orbit, floor collision, and camera collision.
2. **World blockout:** terrain, paths, roads, a village square, simple buildings, and landmarks.
3. **Interaction and missions:** reusable interactables, dialogue, objective tracking, checkpoints,
   and the first playable tutorial mission.
4. **Save/load and inventory:** versioned save data, safe defaults, and migration rules.
5. **Vehicles:** enter/exit, arcade handling, driving camera, and touch driving controls.
6. **Living world:** original NPCs, simple schedules, wildlife, traffic, ambient events, and shops.
7. **Art and sound:** original optimized assets, animation, materials, lighting, music, and effects.
8. **Android and web release tracks:** profile real devices, optimize package size, and separately
   test the web build and its initial download.

## 4 GiB content policy

The 4 GiB target is a content budget, not a requirement to inflate the prototype. Every asset must
serve the game. Track source size, imported size, download size, installed size, and update size
separately. Follow docs/ANDROID_4GB_BUDGET.md; reserve space for patches and avoid duplicating
shared assets across regions.

## Quality rules

- Build and test one small feature at a time.
- Prefer modular geometry, low-cost materials, LOD, and region-based loading.
- Keep touch targets large and support different phone aspect ratios.
- Profile on the actual Android target before increasing scene density.
- Do not copy GTA San Andreas source code, maps, characters, missions, logos, audio, or extracted
  assets. Use it only as a high-level reference for genre systems.
- Do not claim a feature works until it has been run and tested.
- Record known issues and test instructions in docs/QUALITY_AUDIT.md.

## Next implementation

After the movement foundation is verified in Godot, connect the existing region and mission JSON
to small, testable runtime managers. Do not add vehicles or large world content before this gate.
