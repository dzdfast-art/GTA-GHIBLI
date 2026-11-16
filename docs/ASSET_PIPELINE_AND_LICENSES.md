# GTA GHIBLI — Asset Pipeline & License Register

This document records candidate sources researched for the human character, animations, modular streets and PBR environment. A source being listed here does **not** mean its binary files have been downloaded or integrated.

## Approved candidate sources

| Asset group | Source | Formats / details | License stated by source | Intended use |
|---|---|---|---|---|
| Humanoid base characters | [Quaternius — Universal Base Characters](https://quaternius.com/packs/universalbasecharacters.html) | 6 rigged humanoid bases, male/female proportions, 20 hairstyles, FBX/OBJ/Blend/glTF, about 13k triangles per model | CC0; free for personal, educational and commercial projects | Player and NPC base meshes |
| Humanoid animations | [Quaternius — Universal Animation Library 2](https://quaternius.com/packs/universalanimationlibrary2.html) | 130+ humanoid animations, FBX/GLB/Blend; compatible with Godot and ready for retargeting | CC0; free for personal, educational and commercial projects | Walk/run/idle, combat, parkour and activity animation candidates |
| Modular road pieces | [Quaternius — Modular Streets Pack](https://quaternius.com/packs/modularstreets.html) | 25 modular road assets, FBX/OBJ/Blend | CC0; free for personal and commercial projects | Replace the primitive road blockout with modular streets |
| PBR textures, HDRIs and models | [Poly Haven](https://polyhaven.com/) | Downloadable textures, HDRIs and 3D models | CC0; commercial use and redistribution permitted | Ground, walls, foliage, lighting and environment materials |

## Secondary animation source
[Adobe Mixamo](https://www.mixamo.com/) offers auto-rigging and motion-captured character animations with game-engine export formats. Before shipping any downloaded Mixamo asset, check the current Adobe/Mixamo terms and retain the applicable license/terms evidence with the asset. No Mixamo file is currently included by this register.

## Integration requirements
1. Prefer GLB/glTF for Godot runtime import. Keep source FBX/Blend files outside Android export unless needed for authoring.
2. Create a dedicated `CharacterVisual` scene with a Humanoid skeleton and AnimationTree. Do not replace the player physics/controller root.
3. Retarget the selected animations to the chosen humanoid skeleton. Verify root-motion policy: movement remains owned by the existing CharacterBody3D controller unless a tested migration is approved.
4. Player state machine minimum: idle, walk, run, turn-in-place, jump/fall/land, interact, enter/exit vehicle, bicycle mount/ride/dismount.
5. Mira needs a separate visual scene and dialogue/voice playback layer; do not replace her dialogue data with generated audio metadata.
6. Bicycle rider must remain visible while mounted. Use a rider visual attachment/seat pose; do not hide the player visual as the final behavior.
7. Build a small vertical slice first: one street segment, one player, one NPC, one bicycle, one car, one mission marker. Test scale, collisions, materials, LOD and Android frame time before expanding.
8. Keep texture resolutions and mesh triangle counts within mobile budgets. Use texture atlases, compressed textures, LOD and occlusion where appropriate.
9. Store each asset's source URL, author, license, download date, original filename and any required attribution in an adjacent `LICENSE.txt` or this register.
10. Do not add duplicate archives, empty filler files or unreferenced assets merely to increase APK size.

## Current status (2026-11-17)
- Research and license-page verification: done for the listed Quaternius and Poly Haven sources.
- Binary asset downloads: not yet completed.
- Godot import/retarget validation of these candidate assets: not yet run.
- Player/Mira model replacement and rider animation: not yet implemented.
- This register is documentation, not evidence that the game now contains these assets.
