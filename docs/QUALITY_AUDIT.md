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
- NPCs use NavigationAgent3D when a live map exists in the four prototype districts; avoidance remains disabled, the village/road network is not one connected NavMesh, and direct movement remains the fallback where no map is available.
- Advanced car physics and additional vehicle classes remain incomplete. A first-pass unified save coordinator exists on the candidate branch, but complete legacy-format migration and persistence of every world entity remain incomplete.
- Asset provenance register still needs per-asset evidence review before a release. No new asset was added in the save-safety/CI repair run.
- Android output is a debug ARM64 test build, not a signed production release.
- `main` still contains the capsule player, old STATS/BRIEF placeholder and eager terrain loading; candidate branch changes must pass CI and owner review before any merge decision.

No public Web deployment or Pages publishing was performed.


## Repair branch follow-up — 2026-11-20

- `main` remains at `c9fc82936a43b80af0e3c25eef41c9fee59e47b7`; all work remains isolated in Draft PR #31.
- The branch's Android ARM64 Debug workflow had been removed in its earlier diff. It has now been restored from the exact current `main` workflow; the new Android run is pending, not yet a successful build.
- The unified save restore routine now uses an explicit allowlist: the known legacy save paths plus one flat, safe-ID JSON file per NPC relationship. Unrelated `user://` paths, path traversal, and legacy records larger than 2 MiB are rejected.
- `game_save_manager_test.gd` now verifies a real legacy NPC relationship file round-trip, keeps an unrelated sentinel file unchanged, and rejects a traversal write. The result is pending the current Godot CI run.
- Four district navigation grids and NavigationAgent3D use are present, but avoidance is disabled and there is no continuous world-wide NavMesh. Classify this as PARTIALLY IMPLEMENTED, not complete.
- All 25 expressive Arabic dialogue lines, physical-device testing, real FPS/RAM/thermal/audio measurements and release signing remain BLOCKED or NOT VERIFIED as applicable.
- There is no fixed final content-size ceiling. Only original/licensed assets and meaningful playable systems qualify as growth; APK, Web export and tracked-source bytes must be measured separately.
- Current Godot, Android, private Web/Chromium and security runs are pending. The earlier successful APK size must not be reused as the size of the current branch head.


## Public drinking fountain integration — 2026-11-20

- The repair branch now adds an original low-poly OBJ/MTL public drinking fountain to Harbor City's plaza. The scene is wired into `open_world_regions.gd`, uses the shared player interaction contract, and restores thirst through the existing `PlayerNeeds.drink()` API.
- The standalone `tests/public_drinking_fountain_test.gd` checks imported model surfaces, proximity eligibility, restored thirst, cooldown and full-thirst handling. The district integration test also checks that Harbor City instantiates the fountain and registers its interaction area.
- The new model is documented in `OWNERSHIP_AND_ASSET_REGISTER.md` as original project-authored geometry. It has not been externally sourced.
- These tests are **implemented but not yet verified** until the current repair-branch Godot workflow completes. No Android device profiling has been performed for the fountain; frame time, memory and visual scale on Unisoc T606 remain NOT VERIFIED.
- `main` remains unchanged; this work is on Draft PR #31 only.


## Seafood market content — 2026-11-20

- **IMPLEMENTED (source):** A functional Sapphire Coast market reuses the existing `market_stall_lowpoly.obj` and adds an original six-material seafood display OBJ/MTL. The market scene is attached to the Sapphire Coast district.
- **IMPLEMENTED (source):** Grilled sardines, seafood stew and red mullet plate are valid consumable foods. Purchases debit the wallet and add food inventory; consuming the foods uses the current player-needs API.
- **TEST PENDING:** The dedicated seafood-market test and district integration assertions are wired into Godot 4.7 validation. Do not classify the change as TESTED until the current-head run passes.
- **NOT VERIFIED:** Physical-device install, visual quality, FPS, RAM, heat, and touch response on Unisoc T606 / 4 GB.
- All changes remain on Draft PR #31; `main` has not been modified.


## Repair-candidate quality audit — 2026-11-21

Audited head: ab9e707abed1863141418a8a17caa77cf9a1fe66 on fix/comprehensive-stability-2026-11-20; base main remains c9fc82936a43b80af0e3c25eef41c9fee59e47b7.

- **Unified save migration — PARTIALLY IMPLEMENTED.** First-launch migration of allowlisted legacy wallet/needs/NPC records is implemented. The regression verifies reward ledger preservation and that current versioned snapshots override stale legacy files. Mission 001–004, every side activity, all world entities and all vehicle conditions still need complete restore/restart coverage.
- **NPC navigation attachment — IMPLEMENTED; latest clean runtime verification pending.** NavigationAgent3D attachment is deferred until the owning Node3D has finished adding children; the navigation map is resolved through that Node3D owner. Regression coverage now includes pre-parented NPCs, multiple brains in a test actor and world-clock schedules. The latest head's Godot run #798 is in progress; earlier run #797 passed the test steps but exposed callback/test-world errors that the current head corrects.
- **Private Web input — TESTED on prior candidate commit.** The viewport-coordinate mouse input passed Chromium input checks and the preview emitted no external network requests on commit 9005973907dbe56392d2571f6bf4fe8ef84e8aca; current-head rerun #190 is in progress.
- **Security — TESTED.** Repository security audit #742 passed on the current head. This does not replace a physical-device or production-signing audit.
- **Build size — NOT CURRENT-HEAD VERIFIED.** The last raw APK measurement is 254,227,979 bytes on commit 9005973; current-head Android run #561 is in progress. Git-tree blob totals are 350,450,243 bytes for the candidate and 346,596,568 bytes for main.
- **Physical performance — NOT VERIFIED.** No target phone/cloud device was attached. No FPS, peak RAM, thermal, touch, battery or device audio measurements are claimed.
- **Voice — BLOCKED.** No claim of completed human Arabic dubbing is made. AI TTS and human-performed clips must remain separately catalogued.

The Godot test suite's earlier successful run #797 still printed runtime errors before the current correction; a green workflow conclusion alone is not treated as proof of a clean log. Review #798's complete log before promoting navigation status beyond PARTIALLY IMPLEMENTED.


## Verification correction — 2026-11-21

Godot validation #798 and Android Debug APK #561 passed on game-code head ab9e707abed1863141418a8a17caa77cf9a1fe66. The later documentation head 1c8da7dddc07a707dc5b6a0518922bfd1c934135 changes only five documentation files. The Godot log no longer shows the previous NavigationAgent3D get_world_3d callback error, the busy-parent add_child error, or the root-viewport null-scenario error. It still contains non-fatal OBJ ambient-light warnings and ObjectDB/resource teardown warnings from several headless test scripts. Android raw APK size on the verified game-code head is 254,232,075 bytes (254.232 MB / 242.455 MiB); the artifact ZIP is 252,475,148 bytes (252.475 MB / 240.780 MiB). Security audit #743 passed on the documentation head. Web Build #94 and private Chromium #192 were still in progress at the time of this update.
