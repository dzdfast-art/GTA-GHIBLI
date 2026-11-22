# GTA GHIBLI — Web Edition Master Specification

## Authoritative platform decision

The current delivery target is **a standalone Godot 4.7 Web game**. The user explicitly changed the immediate target to a Web version and said not to depend on a phone. Therefore:
- Do not require or request a physical phone.
- Do not use APK size, Android export, Android permissions, Android installation, touch feel, phone RAM, phone FPS or phone temperature as Web acceptance gates.
- Keep the Web experience playable by keyboard and mouse.
- Browser-based touch support may be considered later, but no physical-device test is required.
- Do not deploy publicly or create a public download URL without a separate explicit instruction.

## Clean-start rule

The new game project lives in `web-edition/`, a self-contained Godot project created as a new empty project directory on a branch based directly on `main`. Its scenes, scripts, data and project settings are authored specifically for this Web edition. It must not copy, import, depend on or reuse old prototype/B1–B16 files, assets, add-ons or scene hierarchies. The historical project may be inspected for requirements only.

## Project identity and creative direction

- Name: GTA GHIBLI.
- Genre: third-person open-world action-adventure, driving, exploration and mission-based gameplay.
- Art direction: original anime-inspired, cinematic, painterly 3D world with coherent lighting, color, weather, vegetation, architecture, roads, characters and vehicles.
- GTA San Andreas is a breadth and gameplay reference only. Never reproduce its map, missions, dialogue, characters, music, art or proprietary resources.
- Only original or properly licensed assets may enter the new project.

## Required world

Preserve these four region names:
1. Harbor City
2. Sapphire Coast
3. Pine Highlands
4. Amber Valley

Preserve Marsa Al-Noor as a key named location. The current approximate coordinate in the Web blockout is provisional, not a final geographic or story decision.

The finished world must become one coherent space with connected roads, highways, local streets, bridges, tunnels where useful, walkable spaces, vehicle routes, boundaries, transitions, streaming, collision and functional points of interest. Buildings need appropriate collision, entrances/interiors where required and gameplay roles. Decorative geometry must not be misrepresented as a finished interactive world.

## Characters and narrative

Preserve:
- Leo Bennett — playable protagonist.
- Claire Bennett — Leo's mother.
- Mia Bennett — Leo's sister.
- Nora Blake — established named character; other relationships are not yet confirmed.

Develop original biographies and story arcs without inventing previously approved facts. The story needs a meaningful beginning, conflict, supporting cast, character development, main and side stories, decisions where practical, cinematic moments and a satisfying conclusion.

The current first mission is a provisional original story proposal. The full story and campaign are not yet complete.

## Gameplay requirements

### Player
Walking, running, sprinting, turning, jumping, ground detection, collision, camera-relative movement, interaction, character/object interaction, vehicle entry/exit, weapon interaction and animation transitions.

### Missions
Every mission must have activation conditions, a marker, objectives, tracking, dialogue, failure/completion conditions where relevant, rewards, progression and save/reload behavior. A mission name or JSON record alone is not a functional mission.

### Vehicles
The target game scope includes cars, utility vehicles, vans, trucks, motorcycles, boats, aircraft, helicopters, carts and trailers where suitable. Each supported drivable class must have working controls, physics/handling, braking, steering, collision, camera behavior, entry/exit, sound and contextual HUD. Static models do not count as drivable vehicles. Aircraft and marine craft require distinct handling and control systems rather than car controls.

### Combat
When weapons are added, implement a real inventory, selection, aiming, firing, reload/ammunition, recoil, hit detection, animations, feedback and audio. Contextual HUD must show only controls relevant to the equipped item and current state.

### World life
Pedestrians, NPC movement, idle behavior, route navigation, interactions, reactions, traffic following the road network, vehicle avoidance and police/pursuit behavior are required in the finished game. Static NPCs do not count as finished AI.

### Time and weather
Day/night progression, sunrise/sunset, lighting transitions, street lights and appropriate weather/precipitation/clouds are required where performance allows.

## Navigation and UI

The full navigation system must eventually include:
- Full-screen world map and in-game minimap.
- Player marker and direction.
- Mission and point-of-interest markers.
- Destination selection, zoom and panning.
- GPS routes and route guidance tied to real drivable roads and walkable paths.

The finished interface requires title screen, new/continue game, settings, graphics/audio/control settings, pause menu, HUD, minimap, full map, mission information, mission success/failure, character status, vehicle/weapon HUD, loading and save/load UI. Arabic text requires correct shaping, direction, font and sizing.

The existing Figma concept is a visual reference only: https://www.figma.com/design/tqEx1FIUB4dacI2OjIxHox . It is not a game implementation or proof of completed UI.

## Audio

Audio is a required part of the finished game:
- Original music, ambience, city/coast/forest soundscapes, engines, brakes, horns, footsteps, doors, combat sounds, mission cues and UI feedback.
- Arabic dialogue for main characters, important scenes, missions and relevant NPC interactions.
- Consistent character voice identities and expressive delivery.
- AI synthesis must be disclosed as synthetic and must not be called human voice acting.
- Empty, silent, placeholder or remote-only clips do not count as completed dubbing.
- Web audio must be bundled/local and must not rely on external network requests during gameplay.

No completed Arabic human dubbing is claimed in the current foundation.

## Content size and asset integrity

The long-term target is approximately **4 GB of real, useful, unique game content in the Web delivery package**, not file padding. Grow in stages and report actual measured amounts. Never use duplicate files, empty data, random filler or unused assets to inflate size.

Track these separately:
1. Tracked source project and unique asset bytes.
2. Uncompressed Web export folder bytes.
3. Compressed Web delivery archive bytes and SHA-256.

There is no APK delivery measurement in the current Web phase. A 4 GB browser download has substantial loading/storage implications; do not promise browser compatibility or fast loading without actual tests. Use streaming/chunked loading, compressed formats, LOD, culling and memory-conscious scene management.

## Performance and compatibility

- Use Godot 4.7 Compatibility renderer and WebGL 2.
- Target modern browsers with WebAssembly and WebGL 2.
- Use LOD, culling, instancing, compressed textures/audio, bounded NPC/traffic simulation and region streaming.
- Measure browser startup, load time, memory where available, frame time and runtime errors in repeatable browser tests.
- Do not claim a particular frame rate, memory ceiling or cross-browser compatibility without measurements.
- CI browser validation currently targets Chromium; Firefox, Safari and other browsers remain unverified until separate jobs are added.

## Quality, privacy and delivery

- Every production feature needs a regression test and evidence.
- Verify Godot import, script parsing, JSON, mission tests, scene startup, Web export, browser runtime, input, no runtime errors and no unwanted external network requests.
- Keep source/license provenance for all assets.
- No secrets or signing keys in the public repository.
- Web artifacts are ephemeral CI outputs: measure and hash them, then delete them. Do not upload public GitHub Actions artifacts, GitHub Pages, Vercel deployments or another public host unless explicitly authorized.
- Never label a proposed feature as implemented or a passing smoke test as full-game acceptance.
- Keep a versioned progress record with exact branch/commit/run references.

## Current milestone boundary

The current milestone is a fresh playable foundation: four named blockout districts with a connected starter corridor, basic player movement/camera, interaction, one text-only mission, one basic drivable sedan and a preliminary HUD/map. Models and environment are primitive placeholders. The full world, polished assets, mission campaign, combat, vehicle classes, advanced NPC/traffic/police behavior, GPS, weather, final UI, music and expressive Arabic voice acting remain incomplete.
