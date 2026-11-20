# GTA GHIBLI — Comprehensive Repair Candidate

Date: 2026-11-20
Repository: `dzdfast-art/GTA-GHIBLI`
Base commit: `c9fc82936a43b80af0e3c25eef41c9fee59e47b7`
Branch: `fix/comprehensive-stability-2026-11-20`
Pull request: #31 (Draft, open, not merged)
Status: repair candidate; no changes to `main`, no public Web deployment.

## Repairs included on this branch

| Area | Implementation | Verification |
|---|---|---|
| RUN sprint | Sprint multiplier 1.6 applied while the on-foot sprint action is held | Existing Godot regression suite; final branch run pending |
| Wallet rewards | Versioned wallet ledger rejects duplicate reward transaction IDs | Existing wallet and mission regression tests; final branch run pending |
| Missions 001–004 | Completion rewards are credited through unique wallet transaction IDs | Existing mission tests; final branch run pending |
| STATS / BRIEF | Data-driven reports use live wallet, health, needs, time, regions and mission snapshots | Existing pause menu/report tests; final branch run pending |
| Terrain streaming | Preserves the 72-mesh catalog; near-load radius 72, far-unload radius 96, up to six active tiles and two loads per 0.35-second refresh | Existing terrain lifecycle regression; final branch run pending |
| District navigation | Four prototype districts receive lightweight authored navigation grids made from walkable cells around the six building footprints | New path-query checks in `open_world_regions_test.gd`; final branch run pending |
| NPC movement | NPC brains create NavigationAgent3D and use a live navigation map for wandering, schedules and fleeing; legacy direct movement remains a fallback only where no navigation region exists | Existing NPC tests plus district path-query checks; final branch run pending |
| Vehicle condition | Vehicle health, collision-impact damage, disabled state, repairs, speed degradation and a serializable condition snapshot | New `vehicle_damage_repair_test.gd`; final branch run pending |
| Vehicle visuals | Rear brake lights and animated wheel meshes | New vehicle visual regression; final branch run pending |
| Unified local save | Versioned local save coordinator captures player transform, world clock, player components, mission snapshots, NPC relationships, vehicle state and copies existing per-system JSON/CFG save files into one compatibility section | New `game_save_manager_test.gd`; final branch run pending |
| Save recovery | Writes a temporary file, validates its JSON/schema, preserves a previous backup and then replaces the active local save | Included in unified save manager; final branch run pending |
| Web dialogue privacy | Prevents Mira and world NPC dialogue from requesting remote audio when running as a Web build; bundled and cached clips remain eligible | New `web_dialogue_privacy_audit.py`; final branch run pending |
| Application icon | Adds an original SVG icon and connects it in project settings | Previous Godot import and APK build passed on earlier stable candidate commit |
| Marsa Al-Noor | Candidate Harbor City landmark and map marker; position is explicitly documented as a story/design proposal | Previous canonical-world regression passed; owner/story approval still required |

## Technical evidence retained from earlier successful commit

The earlier candidate commit `518205b8b73e8741dcc373ff818687b3a110af36` passed:
- Godot validation run #677: https://github.com/dzdfast-art/GTA-GHIBLI/actions/runs/44640989501
- Android ARM64 Debug APK run #447: https://github.com/dzdfast-art/GTA-GHIBLI/actions/runs/44640989559
- Repository secret scan: https://github.com/dzdfast-art/GTA-GHIBLI/actions/runs/44640989613

That APK was measured at 250,755,028 bytes (250.76 MB decimal / 239.14 MiB). It is an earlier Debug APK, not an artifact from the latest repair commits. Do not claim that size for the newest branch head until the latest Android workflow finishes.

The separate private Web Preview Chromium smoke test passed on `web-preview`, not on this repair branch:
https://github.com/dzdfast-art/GTA-GHIBLI/actions/runs/44633964747

## Still incomplete or constrained

- The 25 Arabic dialogue lines have existing or cached clips, but all are still flagged for expressive performance retakes. The new Web guard does not create new recordings and does not make Android dialogue fully offline.
- No physical Android device is connected. Touch feel, real-device FPS, RAM, thermal behavior, speaker output and installation cannot be certified from headless CI.
- Navigation grids are currently authored for four prototype districts. The village slice and wider roads are not yet one continuous world-wide NavMesh; disconnected areas continue to use the prototype fallback.
- NPC avoidance, obstacle-aware combat reactions, advanced car suspension/tire dynamics, complete damage model, broad traffic AI and remaining vehicle categories are not finished.
- Unified saves now combine and snapshot the current major systems, but world object destruction/spawn state, every collectible, all NPC transforms and all future systems still need to adopt the snapshot contract before calling the entire world persistence complete.
- Marsa Al-Noor remains a proposal requiring owner/story approval.
- Android output is Debug ARM64. A production release needs a separately protected signing key and device validation.
- The 300 MB target has not been achieved by the latest confirmed APK. Add only original, licensed, useful content; do not pad the package.

## Release gate

Do not merge this Draft PR, label the game release-ready, publish a Web page or produce a public Web bundle until the owner reviews the PR, the latest Godot/Android/security/Web tests pass, and device/release prerequisites are addressed.
