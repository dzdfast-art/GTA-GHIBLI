# High-detail terrain source meshes

The `high_detail` folder contains original 112 x 112 vertex-grid OBJ source tiles, each covering 222 x 222 world units at 2-unit vertex spacing. They provide distinct source shapes for ridges, coast, marsh, valley, orchard, badlands, meadow, forest, canyon and urban green areas. The low-resolution 96 x 96 tiles remain available for lightweight prototyping.

All OBJ files reference `high_detail_terrain.mtl` in this same folder via the OBJ material library declaration. Import the OBJ in Godot 4 and verify the material library is resolved. These high-detail meshes are source assets; they are not placed in playable scenes yet. Before Android deployment, create distance-based LOD meshes, collision proxies and terrain chunk streaming rather than rendering every source tile at full detail simultaneously.

## Additional source tile

- `urban_canal_greenway_112.obj`: 222 x 222-unit urban canal corridor with a winding recessed channel, raised grassy banks and towpath strips. It is a source mesh only; it has not been placed in a playable scene. Use the shared material library and build a simplified collision/LOD version before Android deployment.


## District high-detail extension

Four additional original 112 x 112 terrain meshes are included and connected to the proximity-based runtime catalog:

- `harbor_breakwater_112.obj`: low harbor flats, recessed tidal channel and raised breakwater ridges.
- `pine_granite_spur_112.obj`: steep granite spine, rocky shoulder and forested lower slopes.
- `amber_vineyard_terraces_112.obj`: stepped agricultural benches with drainage cuts and crop/soil material bands.
- `sapphire_tidepool_rim_112.obj`: coastal shelf, tide pools, sandy margins and exposed rocky rim.

Each tile spans 222 x 222 source units and shares the local `high_detail_terrain.mtl` library. They are streamed only as the player approaches their district-edge location; the runtime's six-tile active budget and distance unloading remain in force. These are higher-detail source meshes, not a claim of finished LOD or device-side performance validation.
