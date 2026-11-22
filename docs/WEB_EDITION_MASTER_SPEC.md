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



---

##  Research-driven scope expansion — San Andreas systems reference

This addendum turns the supplied forensic research brief into a formal requirement for the **independent Web game**. San Andreas is a comparative design and production reference only. GTA GHIBLI must use original names, characters, locations, writing, missions, visual assets, music, radio, voices and data.

### A. Evidence and source discipline

Every research statement about the 2004 title must identify its evidence class:
- `[CONFIRMED]`: directly attributable evidence, with source ID.
- `[OBSERVED]`: measured or seen in an identifiable build/setup.
- `[SECONDARY]`: documented by an attributable secondary source.
- `[INFERRED]`: consistent technical interpretation, not proof.
- `[PROPOSED]`: original GTA GHIBLI design/code decision.
- `[UNKNOWN]`: not established by currently accessible evidence.

The original PS2 retail-era manual inspected in this research pass identifies an NTSC U/C scope. Exact disc build/revision and executable hash remain unknown. PC, Xbox, mobile and later remaster behavior must have their own version records and must not be silently merged with PS2 claims. Source metadata must include stable ID, title, author/publisher, publication date where known, URL, access status, page/section/timestamp and build/version scope. Distinguish opened material from search-index-only, inaccessible and cited-through sources.

### B. Required research registries and explicit completion gate

The research package uses stable IDs and machine-readable JSON:
- Core: `CORE-01.01` to `CORE-50.45`, 50 parent details × 45 elements.
- Graphics: `GFX-01.01` to `GFX-50.45`, 50 parent details × 45 elements.
- Overlooked details: `EXTRA-D-001` to `EXTRA-D-100`.
- Overlooked elements: `EXTRA-E-001` to `EXTRA-E-100`.
- Physics: `PHY-<SYSTEM>-<NUMBER>`.
- Characters: `CHAR-<CLASS>-<NUMBER>`.
- Verified overflow: `OVER-<DOMAIN>-<NUMBER>`.

Do not count parent headings, cross-links, duplicates, empty placeholders or unsupported assertions as substantive elements. If coverage is incomplete, preserve numbering and list exact missing ID ranges. Structural validation cannot decide whether two researched statements are semantically distinct; that remains an editorial review task. The research handbook and registry JSON must always print both REQUIRED and ACTUAL totals.

### C. Full original Web game system requirements

The final game is a genuinely playable third-person open-world action-adventure, not a website, static illustration, mockup, menu-only build or tiny demo passed off as complete.

The final Web game must include:

1. **World and geography:** four connected original regions, distinct district identities, streets, roads, highways, bridges, tunnels where appropriate, shorelines, countryside, terrain, landmarks, functional points of interest and traversal boundaries. Sector streaming must keep gameplay-critical dependencies resident and release unused assets safely.
2. **Navigation:** one authoritative world-coordinate service for full map, minimap, mission markers and GPS. Destination selection must snap to reachable graph nodes; route planning must follow actual road/path edges, account for direction/closures, recalculate when blocked and report unreachable destinations honestly.
3. **Interiors:** real entry conditions, portals, interior scene ownership, return transforms, collision transitions, streaming and save-safe transition tickets. Decorative door meshes do not count as functional interiors.
4. **Player and camera:** walking, running, sprinting, turning, jumping, slopes, stairs, interaction, camera-relative movement, obstruction-aware orbit/zoom, aiming modes, locomotion animation handoffs and context-specific input maps.
5. **Vehicles:** cars, utility vehicles, vans, heavy trucks, motorcycles, bicycles, boats, aircraft, helicopters, carts and trailers as appropriate. Each class needs its own tested handling/control mode, collision, suspension or appropriate buoyancy/lift/rail constraints, camera, entry/exit, sound, damage state and contextual HUD. A static mesh is not a completed vehicle.
6. **World population:** pedestrians, civilians, schedules, traffic lanes, intersections, obstacle avoidance, driver reactions, faction behavior, police/pursuit and mission-controlled actors. Ambient simulation must be bounded by sector budgets; mission-critical actors must hold residency/ownership leases.
7. **Missions and story:** original campaign and side missions with activation, prerequisites, character/location links, objectives, dialogue, failure/success/retry, cleanup, one-time reward transactions, persistent world changes, checkpoints and save/reload. Include a mission dependency graph and mission-to-character index.
8. **Combat and inventory:** original fictional equipment classes, inventory, aim/fire/reload, hit detection, recoil, animations, audio, damage feedback and contextual controls. These systems must be safe, age-appropriate and fictional gameplay, not real-world weapon instruction.
9. **Progression and economy:** skills, status, appearance customization, money, shops, properties, services, optional activities, races, collectibles, statistics and completion categories with unique IDs and idempotent reward transactions.
10. **Time and environment:** authoritative world clock, sunrise/sunset, day/night lighting, local weather, precipitation, visibility, wetness and environmental audio driven by the same state.
11. **Audio and localization:** original or licensed music and radio, local bundled ambience and effects, character-specific Arabic dialogue with emotion/performance metadata, subtitles, correct Arabic shaping/RTL and explicit voice provenance. Synthetic speech must be labeled synthetic; silent/empty placeholders do not count as dubbing.
12. **UI and accessibility:** title/new/continue, pause/settings, graphics/audio/controls, map, mission status, inventory, vehicle/weapon HUD, dialogue, notifications, loading/save UI, scalable text, remappable keyboard/mouse controls, reduced-flash/reduced-motion options and readable context prompts.
13. **Persistence:** versioned save schema, migrations, checksums, atomic writes/recovery, player/world/vehicle/mission/economy/unlock/appearance/time/weather states and safe handling of interrupted transitions.
14. **Quality and browser delivery:** WebAssembly + WebGL2 build, local-only smoke testing, no external gameplay network dependency, no secrets, no public hosting unless separately authorized. Measure startup/load time, frame-time percentiles, sector memory estimates, active actors, draw calls and asset residency under repeatable routes.

### D. Production and asset pipeline

Maintain asset provenance for model, mesh, texture, material, rig, animation, collision, navigation, audio, dialogue, mission, UI and world-data records. Each distributable asset must carry a stable asset ID, source/author, licence, attribution requirements, modification history, import settings and content hash. No Rockstar proprietary content is to be copied or redistributed.

Use this proposed original pipeline:
`creative brief → source/licence approval → DCC authoring → export/validation → Godot import → sector/data integration → Web export → browser QA → measured package → ephemeral cleanup`.
This is a GTA GHIBLI proposal, not a claim about Rockstar's internal tools.

### E. Required integration invariants

- Mission-owned actors and sectors cannot be removed by ambient distance despawn.
- A mission finishing while the player drives must not change the player out of vehicle mode or clear the vehicle owner.
- Vehicle exit must reserve and validate a collision-free exit transform; if both sides are blocked, the player remains seated.
- Saves during cinematics or transitions must defer or use a consistent transition ticket.
- Loading a save supersedes stale HUD objectives only after gameplay owners apply the loaded authoritative state.
- Mission retry releases prior actor leases and transient markers and cannot duplicate actors or rewards.
- Traffic density is budgeted; ambient AI may degrade gracefully without disabling mission-owned vehicles.
- An ambient NPC can become mission-owned and later return to its saved ambient schedule through an explicit ownership lease.

### F. Web acceptance plan and scope boundary

Every system follows the status vocabulary used in `docs/WEB_EDITION_STATUS.md`. A feature is `TESTED` only after a repeatable automated or documented manual test. The first browser gate remains Chromium/WebGL2; Firefox and Safari are separate unverified gates until runners and actual jobs exist. A green foundation CI run never means that the full open world, every feature, final art, complete character census or complete historical encyclopedia is finished.

The long-term target for the Web package is real, unique, useful content approaching the requested 4 GB milestone. Track source bytes, uncompressed Web export bytes, and compressed package bytes separately. No duplicate or filler data. Large packages require staged/streamed loading and measured browser compatibility; do not claim 4 GB reached until actual authored content and export measurements prove it.
