# GTA GHIBLI — Initial Quality Audit

Audit date: 2026-11-13  
Audited branch: `main`

## Repository facts

- The repository is public and the default branch is `main`.
- The project configuration points to `res://main.tscn`.
- The main scene points to `res://main.gd`.
- The project uses Godot 4 configuration format 5 and the Compatibility renderer.
- The current world is a generated flat test floor; the character is a capsule.
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

These changes are source-level implementation only. They have **not** been launched in the Godot editor
or on an Android device in this workflow, so runtime correctness and frame rate remain unverified.

## Next acceptance gates

1. Open the project in Godot 4 and run the main scene.
2. Confirm movement in all four directions and confirm that forward follows the camera.
3. Drag on the right half of the touch screen and confirm camera orbit.
4. Walk close to a wall and confirm that the spring arm prevents camera clipping.
5. Test button release after lifting a finger or moving a finger away from a button.
6. Test on the target Android device in landscape orientation.
7. Only then connect mission data and add the first original world props.
