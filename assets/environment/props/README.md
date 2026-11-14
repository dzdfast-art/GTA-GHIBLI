# GTA GHIBLI — Low-poly Environment Prop Set 01

Original, engine-neutral OBJ props created for the GTA GHIBLI prototype.
These are reusable blockout-to-art-pass meshes, not final photorealistic assets.

## Included
- `tree_pine_lowpoly.obj`
- `tree_willow_lowpoly.obj`
- `rock_cluster_lowpoly.obj`
- `street_lamp_lowpoly.obj`
- `park_bench_lowpoly.obj`
- `wood_crate_lowpoly.obj`
- `market_stall_lowpoly.obj`
- `road_bollard_lowpoly.obj`
- `barrel_lowpoly.obj`
- `direction_sign_lowpoly.obj`

## Import into Godot 4
1. Keep the OBJ and `environment_props.mtl` together in this folder.
2. Let Godot import each OBJ.
3. Instance the imported mesh scene where appropriate.
4. Add/adjust collision shapes separately in gameplay scenes.
5. Replace or refine materials with project shaders as the art direction matures.

All assets use simple low-poly geometry and shared named materials. Dimensions are in approximate metres. The current pack is visual-only: no collision, LODs, lightmaps, or animation are included.
