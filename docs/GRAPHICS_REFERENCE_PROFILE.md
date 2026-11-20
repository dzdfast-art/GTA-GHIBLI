# GTA GHIBLI — San Andreas Mobile visual reference profile

Reference checked: user-supplied `1000208059.mp4` (127 seconds, 1280×644).
Engine: Godot 4.7, Android-focused GL Compatibility renderer.

## Visual direction

This is an original, mobile-friendly recreation of the reference's broad visual language, not a copy of Rockstar's proprietary game assets:
- warm, lightly muted outdoor daylight with restrained contrast and no modern bloom glow;
- a close behind-the-player camera on foot, with an automatic pull-back while riding vehicles;
- a compact male low-poly protagonist silhouette with white sleeveless top, blue denim, dark shoes and visible rear clothing details;
- narrow residential asphalt lane, raised sidewalks/curbs, stone/plaster boundary walls and warm street lamps;
- low-rise stucco houses with terracotta roofs, blue/gray windows, original OBJ material groups and street mesh details;
- original willow trees, street props and varied blue/gray/red/dark sedans with body trim, wheel hubs and rotating wheels;
- opening time starts at 06:51 to echo the morning scene in the reference clip.

## Implemented on the repair branch

- `scripts/player/humanoid_visual.gd`: refined mobile low-poly player proportions, clothing palette, back pockets, belt/buckle, sideburns and shoe soles.
- `scenes/player/player.tscn` and `scripts/camera/third_person_camera.gd`: 3.6 m on-foot follow distance, FOV 65, and a smooth pull-back to 5.2 m while riding a vehicle/bicycle.
- `scripts/world/willow_village.gd`: reference residential alley, sidewalk/curb/wall details, imported original willow/market/bench/barrel/crate/sign/lamps and shared asphalt/paving/plaster/terracotta textures.
- `scripts/world/open_world_regions.gd`: Harbor City uses the original 4×4 low-rise house OBJ set (16 homes), separate aligned collision envelopes and original street/sidewalk OBJ network; other three districts preserve their current blockout.
- `scripts/world/ambient_traffic_car.gd` and `ambient_traffic_director.gd`: four traffic sedans with varied paint and more visible wheels, hubs, mirrors, grille, door details and number plates.
- `scripts/vehicles/driveable_car.gd`: starter sedan receives blue paint, side glass, mirrors, grille, plates, door details and hubs.
- `main.gd`: warmer outdoor lighting and bloom disabled.
- `scripts/world/world_clock.gd`: opening clock 06:51.
- `tests/graphics_reference_profile_test.gd`: checks the opening visual baseline, imported meshes, camera values and dynamic camera transition, texture usage, traffic parts, lighting and starting time.
- `tests/open_world_regions_test.gd`: checks 16 Harbor houses and the original road/sidewalk collection in addition to district/navmesh tests.

## Acceptance gate

1. Godot 4.7 imports every original OBJ and SVG without missing resource or parser errors.
2. The graphics reference test passes on the same commit as the APK.
3. The private Web/Chromium scene smoke test reaches gameplay and reports no runtime rendering/resource errors. It is a diagnostic, not a substitute for Android.
4. Review actual screenshots from the running scene against reference frames for character scale, camera angle, wall/road framing, lighting, model proportions and HUD composition.
5. Verify the Android ARM64 debug package builds; test the exported package on a physical Android device for real visual quality, frame time, memory and heat before calling the graphics accepted.

No claim of exact visual parity is made until rendered screenshots have been compared. Current assets are intentionally original and lightweight; remaining work includes properly rigged/animated character models, expanded architectural variation, better terrain silhouette/road connections, pedestrian variety, LOD/material tuning and device-side screenshot/performance review.
