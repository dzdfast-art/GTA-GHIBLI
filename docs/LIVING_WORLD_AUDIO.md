# GTA GHIBLI — Living World Audio

## Prototype implementation
- A procedural ambient-audio controller starts with the main scene.
- One in-game day lasts 15 real-time minutes and begins at 05:00.
- Dawn/day increase bird-like calls; dusk softens them; night brings cricket-like tones and rare, quiet owl-like calls.
- Continuous wind gently changes with the time and biome.
- Rain and storm ambience can be selected through the controller API.
- Biome presets: village, forest, fields, river, coast and highlands.
- Audio is synthesized locally. It does not use the microphone, inspect personal files, or require Android permissions.

## Sound quality and remaining work
These are synthesized prototype sound layers, not authentic field recordings. They make the day/night system audible and testable without bundling unlicensed recordings. Production audio should replace or layer them with original or properly licensed recordings: birds, insects, frogs, flowing water, leaves, wind, rain, thunder and region-specific wildlife. Character dialogue and cinematic sound remain separate systems.

## Integration API
The node is available as `/root/NatureAmbience`.
- `set_biome("forest")`, `set_biome("river")`, `set_biome("coast")`, etc.
- `set_weather("clear")`, `set_weather("rain")`, or `set_weather("storm")`.
- `set_master_gain(0.0..0.6)`.
- `get_game_hour()` returns the current in-game hour.

Future world streaming and weather systems should update biome/weather when the player crosses region boundaries. Water ambience is enabled only for river/coast presets; this does not mean water geometry or simulation is already complete.

## Acceptance checks
Project import, script parsing and main-scene smoke test are run in GitHub Actions. Listening on Android is still required to assess speaker quality, clipping, battery use and naturalness.
