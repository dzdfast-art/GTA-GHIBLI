# GTA GHIBLI — Asset Production Pipeline

This pipeline separates assets that are actually shipped from assets that are only being researched.

## Current integrated asset

| Asset | Status | License | In-game role |
|---|---|---|---|
| Quaternius Superhero Male GLB | Proposed integration in PR #20 (pending CI and review) | CC0 1.0 | First rigged player visual and procedural pose source |

The original license is stored at `assets/characters/QUATERNIUS-LICENSE.txt`. The imported GLB contains a humanoid skeleton; the current movement and vehicle poses are procedural Godot bone poses, not authored animation clips.

## Integrated free animation packs

| Asset | Free Standard content | License | Runtime role |
|---|---:|---|---|
| Quaternius Universal Animation Library Standard (UAL1) | 43 clips | CC0 1.0 | Idle, walk, jog, sprint and driving base motions |
| Quaternius Universal Animation Library 2 Standard (UAL2) | 43 complementary clips | CC0 1.0 | Harvesting, chopping, combat, parkour and emotes |

The two GLBs are acquired by `tools/fetch_quaternius_animation_packs.py` from the official anonymous itch.io download flow. The script verifies the published ZIP byte lengths and SHA-256 values, checks the ZIP archives, extracts only the Godot/Unreal GLB and the original `License.txt`, and validates the GLB headers before Godot import. No account, payment or personal data is used.

The free Standard archives contain 43 clips each. They are not the separate full 130+ Source/Pro collection. Never label the free Standard packages as the paid full collection.

For a local source checkout, run:
```bash
python tools/fetch_quaternius_animation_packs.py
```
GitHub Actions runs the same pinned acquisition step before Godot import and Android export, so the resulting APK contains the actual verified animation resources.

## Research queue (not shipped)

- [Universal Animation Library 2 full Source/Pro collection](https://quaternius.itch.io/universal-animation-library-2): paid tier; do not download or claim its full 130+ clip count as part of the free Standard packs.
- [Modular Streets Pack](https://quaternius.com/packs/modularstreets.html): inspect modular road pieces and collision meshes, then build a connected road test scene.
- [Cars Pack](https://quaternius.com/packs/cars.html): inspect model topology, wheel pivots and license before creating Godot vehicle scenes.
- [Downtown City MegaKit](https://quaternius.com/packs/downtowncitymegakit.html): confirm free-tier contents and exact license before importing.

Research links are not proof of integration. An asset is considered shipped only when its files, license, manifest entry, Godot import and runtime use are all present.

## Tool responsibilities

- Figma: editable source of truth for HUD and pause-menu layout. The existing design file already contains a landscape gameplay HUD frame. The Figma MCP currently reports its Starter-plan tool-call limit, so no further Figma edits are claimed in this commit.
- Canva: editable UI handoff presentation requested for gameplay HUD, vehicle controls and pause menu.
- Firecrawl and TinyFish: cross-check asset pages, file formats and license statements.
- fal: optional asset generation only after a model is selected and its input requirements and cost are understood. No generated model is included by this commit.
- Claude: independent code review only when a real Claude connection or a user-supplied review is available. A `CLAUDE.md` instruction file is not evidence of a Claude review.
- Godot 4.7 / GitHub Actions: import, script parse, gameplay tests and Android export.

## CI gate

`tools/validate_asset_manifest.py` verifies that each integrated asset exists, is non-empty, has an allowed explicit license and adjacent license text, and (for GLB) has a valid GLB v2 header and matching byte length. Research-only candidates are intentionally not counted as shipped content.

## Acceptance before growing APK size

1. The archive source and license are recorded.
2. The imported asset is referenced by a scene or runtime loader.
3. The game uses it in an observable gameplay path.
4. Godot headless import and the relevant smoke test pass.
5. Android export succeeds and the artifact size is measured.
6. No asset is added solely to inflate APK size.
