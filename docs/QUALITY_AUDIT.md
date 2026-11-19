# GTA GHIBLI — Initial Quality Audit

Audit date: 2026-11-13  
Audited branch: `main`

## Repository facts

- The repository is public and the default branch is `main`.
- The project configuration points to `res://main.tscn`.
- The main scene points to `res://main.gd`.
- The project uses Godot 4 configuration format 5 and the Compatibility renderer.
- The player remains a capsule. The main scene now loads a procedural Willow Village blockout containing a square, paths, four placeholder houses, a fenced garden, trees, a well, and a sign.
- The region catalogue and first mission are JSON design records. They are not loaded by
  runtime gameplay systems yet.
- There are no imported 3D environment assets, finished character assets, vehicle assets,
  music banks, Android export presets, or automated Godot test workflow in the audited tree.

## Issues found before this implementation

| Priority | Finding | Impact | Action |
|---|---|---|---|
| P0 | One large script creates world, player, camera, and UI | Hard to test and extend safely | Split player, camera, and mobile UI into separate components |
| P0 | Camera does not support touch orbit | Poor third-person usability on phones | Add right-side drag camera input |
| P0 | Movement uses fixed world axes | Character movement does not follow camera direction | Make movement camera-relative |
| P1 | Camera has no collision-aware arm | Camera may pass through nearby geometry | Use SpringArm3D and exclude the player body |
| P1 | Mobile and keyboard movement are separate booleans | Input paths can drift apart | Reuse Godot ui_* input actions |
| P1 | Data files are not connected to runtime managers | Mission and region records do not create gameplay | Add validated data loading in a later milestone |
| P1 | No explicit 4 GiB content accounting | Final size could grow unpredictably | Add the Android content budget ledger |
| P2 | No automated parser/import/export checks | Regressions can go unnoticed | Add Godot headless validation when a Godot runner is available |

## Implementation status after this commit

The repository now has:
- A reusable player scene.
- A camera-relative movement controller.
- A touch-orbit camera rig using a SpringArm3D.
- On-screen directional buttons that simulate the same input actions used by the keyboard.
- A documented 4 GiB content budget and measurement gates.

GitHub Actions run #9 passed with Godot 4.7. It imported the project, parsed all four gameplay scripts,
  and ran the main scene for 180 headless frames without a failed step. This confirms scene startup and
  headless runtime execution. It does **not** validate rendered visuals, touch gestures, sustained play,
  frame rate, or Android export on a physical phone.

## Next acceptance gates

1. Open the project in Godot 4 and inspect the village composition visually.
2. Confirm movement in all four directions and confirm that forward follows the camera.
3. Drag on the right half of the touch screen and confirm camera orbit.
4. Walk close to a house and confirm that the spring arm prevents camera clipping.
5. Test button release after lifting a finger or moving a finger away from a button.
6. Test on the target Android device in landscape orientation.
7. Add the first villager, interaction prompt, and mission objective tracker.

## Repair candidate addendum — 2026-11-20

**Audited candidate branch:** `fix/comprehensive-stability-2026-11-20`  
**Base:** `main` at `c9fc82936a43b80af0e3c25eef41c9fee59e47b7`  
**Merge status:** not merged; `main` remains unchanged.

Candidate changes (not yet CI-verified at the time this addendum was written):
- Added real sprint speed handling and a regression assertion for the mobile RUN action.
- Added one-time wallet reward transactions and connected mission completion rewards for missions 001–004.
- Replaced STATS/BRIEF placeholder copy with live wallet/player/world/mission data reads.
- Added a pause-menu regression test for the required button order and live page content.
- Replaced eager loading of the full 72-tile terrain set with bounded proximity streaming and a lifecycle/collision regression test.
- Added a project application icon and configured the Godot icon property.
- Added Marsa Al-Noor as a proposed Harbor City landmark, canonical metadata entry, world-map marker and scene/data coordinate test.

Verified separately on `web-preview`, not this candidate branch:
- Web export and private Chromium smoke test succeeded in [Web Preview run #14](https://github.com/dzdfast-art/GTA-GHIBLI/actions/runs/44633964747).
- Chromium launched under Ubuntu 24.04 with Playwright 1.55; the test observed a Godot canvas, WebGL 2, browser input delivery without runtime errors and no external network requests.
- This is a browser startup/input smoke test, not complete visual gameplay validation.

Known blockers / limits that remain:
- All 25 dialogue lines in `data/characters/world_dialogue_ar.json` remain marked as needing expressive voice retakes; no new actual performance recordings are included by this candidate.
- No physical Android device is connected to this testing session; touchscreen feel, sustained FPS, RAM, temperature, audio audibility and install/launch on the target phone remain NOT VERIFIED.
- NPC movement remains simple direct movement rather than a fully obstacle-aware NavMesh system.
- Advanced car physics, all additional vehicle classes, broad damage integration, and a centralized game-wide save/migration system remain incomplete.
- Asset provenance register still needs per-asset evidence review before a release.
- Android output is a debug ARM64 test build, not a signed production release.
- `main` still contains the capsule player, old STATS/BRIEF placeholder and eager terrain loading; candidate branch changes must pass CI and owner review before any merge decision.

No public Web deployment or Pages publishing was performed.
