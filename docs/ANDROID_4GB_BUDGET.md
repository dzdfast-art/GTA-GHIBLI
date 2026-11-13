# GTA GHIBLI — Android Content Budget (4 GiB Target)

## Target definition

The current planning target is **4,096 MiB (4 GiB) of total installed game content**.
This is a design budget, not a measured build size or a promise that the current prototype
is already close to this size.

The eventual download size, installer size, installed size, temporary patch space, and
optional downloaded region packs are different measurements. They must be measured
separately after real assets are imported and Android exports are produced.

## Proposed content allocation

| Content category | Budget (MiB) | Rules |
|---|---:|---|
| Engine, boot flow, shared core | 180 | Keep plugins and unused engine features out of release builds |
| Terrain, roads, world meshes, LODs, collision | 520 | Reuse modular pieces; collision meshes stay simple |
| Environment textures and materials | 760 | Reuse atlases and materials; avoid duplicate texture variants |
| Buildings, props, vegetation | 500 | Use modular sets, instancing, and distance-based visibility |
| Characters, rigs, and animations | 420 | Reuse rigs and animation clips where suitable |
| Vehicles | 220 | Shared materials, compact meshes, limited unique interiors |
| Music, ambience, voices, sound effects | 400 | Stream long music/dialogue; compress and limit simultaneous voices |
| Cinematic sequences | 420 | Prefer in-engine scenes; compress any prerendered video carefully |
| UI, fonts, localization, shaders, metadata | 96 | Keep interface assets vector/simple where practical |
| Additional region and mission packs | 400 | Optional packs should not duplicate shared core assets |
| Patch and growth reserve | 180 | Do not spend this reserve during early production |
| **Total** | **4,096** | **4 GiB planning envelope** |

## Non-negotiable production rules

1. Do not create large placeholder files merely to reach 4 GiB. The target must come from real,
   original, useful game content.
2. Track both source-asset size and final exported/installed size. They are not interchangeable.
3. Keep a size ledger for every region and every release candidate.
4. Reuse materials, meshes, rigs, and audio banks where quality permits.
5. Use level of detail, visibility ranges, occlusion, and region-based loading before expanding
   the playable world.
6. Keep high-resolution source textures outside mobile builds unless the game actually needs them.
7. Test texture compression and visual quality on representative Android devices.
8. Keep optional regions and large audio/cinematic content separable where the chosen distribution
   channel supports it.
9. Never assume a web build can comfortably download or run the full 4 GiB content set. A web
   version needs a separately measured, smaller initial payload and staged loading.

## Measurement gates

- **Gate A — Prototype:** measure project/source footprint; do not target 4 GiB.
- **Gate B — First playable slice:** record imported asset size and Android export size.
- **Gate C — Content-complete alpha:** compare every category with this ledger and remove waste.
- **Gate D — Release candidate:** measure clean install size, first-run download, update size,
  peak temporary storage, RAM, and frame rate on actual devices.

No category is allowed to exceed its allocation without a documented trade-off and a revised
overall budget.
