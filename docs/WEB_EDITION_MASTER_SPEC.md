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

---

## Implementation snapshot — road-graph GPS increment (PR #40 candidate)

The first navigable graph increment for the Web Edition is now authored on the PR #40 stack:

- The world builder describes the existing east-west starter road as connected bidirectional graph edges.
- Six registered points of interest receive access-spur edges and matching simple road-surface meshes.
- An A* planner validates graph nodes/edges, snaps start and destination to the nearest graph node only within a bounded distance, calculates graph distance, reconstructs route geometry and returns an explicit unreachable result when no valid snap/path exists.
- Selecting a point of interest updates the route shown on the world map and minimap. The route is recalculated periodically as the player moves.
- This is an early road-network prototype, not a full GPS system. It does not yet model street grids, complex intersections, one-way restrictions, road closures, dynamic obstacles, walking paths, turn-by-turn prompts or voice guidance.
- Automated regression coverage has been added for all six current point-of-interest routes, out-of-range snap rejection, road-distance calculation and map/minimap route propagation. These tests remain pending the PR #40 CI result.

### Build-output handling
Web CI continues to export and measure the Web package, but the PR #40 workflow removes the upload-artifact step and deletes the temporary build directory after measurement. This policy prevents future PR runs from leaving downloadable Actions ZIP artifacts. It does not delete the earlier PR #39 artifact already created; that artifact and its expiry are recorded in the status ledger.
---

## Implementation snapshot — starter-road GPS maneuvers (PR #41 candidate)

- A* route results now include left/right bend instructions derived from consecutive route points in the map plane. Straight and near-180-degree reversal segments are not presented as turns.
- The gameplay HUD shows the next route maneuver and Euclidean distance from the player to that maneuver. The instruction is recalculated with the route as the player moves.
- The tests exercise both left and right cases on a controlled graph, verify the lighthouse route's right-turn instruction and check HUD delivery.
- PR #40 road-graph routing is verified by CI run 45229951546; PR #41 maneuver changes are pending their own Godot/Web/Chromium and security checks.
- This remains prototype guidance over the east-west starter corridor and six access spurs. It is not a complete turn-by-turn navigation system.
---

## Implementation snapshot — one-way edges and road closures (PR #42 candidate)

- Road graph edges accept a direction policy: bidirectional (default), forward-only or reverse-only. Duplicate edge IDs, self-loops, invalid endpoints, non-positive costs and unsupported direction values are rejected during configuration.
- The A* planner can block/unblock a known edge at runtime. Closed edges are ignored during expansion; the active route is recalculated when the game root receives an edge-state update.
- Regression cases cover route choice before and after a synthetic closure, alternate-path selection, no-path reporting when all alternatives close, reopening recovery, live HUD/map route clearing/restoration, unknown edge handling and one-way direction enforcement.
- PR #41 turn-guidance baseline passed branch-head CI run 45230635607 and Security Audit run 45230669321.
- PR #42 is still pending Godot/Web/Chromium and security validation. The live blockout world has not yet gained a real alternate street grid; alternate route selection is tested on a controlled graph.

---

## Implementation snapshot — durable save slots and recovery (PR #105)

The Web Edition now has a local save-slot service at `user://gta_ghibli_web_saves`. The service writes versioned JSON envelopes, calculates a SHA-256 checksum for the serialized payload, validates slot IDs, rejects negative timestamps, writes through a temporary file, preserves a previous valid save as a backup, recovers from a corrupt primary file, and migrates version-zero payloads to schema version one.

Regression coverage verifies deep-copy isolation, metadata round-tripping, backup recovery after a corrupt current save, invalid JSON payload rejection even when its checksum matches, valid empty-dictionary payloads, path-traversal rejection, deletion, version migration and data recovery in a separate Godot process. CI also rejects any Godot `ERROR:` log output; malformed-save tests use the non-logging `JSON.parse()` result path rather than emitting a deliberate parser error.

**Important integration boundary:** the live game currently writes only Mission 001 stage and wallet to the `autosave` slot when the wallet changes. The generic backend and two-process fixture can store player, mission, inventory, vehicle, world and activity dictionaries, but those fixtures do not prove those live gameplay systems are wired to save/restore. Player transform/vitals, complete Mission 001–004 progress, inventory, NPCs, active vehicles, activities, unlocks and world time/weather remain to be integrated and tested.

**Web persistence is not yet verified across a browser reload.** The two-process regression runs on the native Godot CI runner. Godot 4.7 documents that Web `user://` persistence relies on browser IndexedDB being allowed; private browsing or blocked storage prevents persistence, and `OS.is_userfs_persistent()` can return false positives. A Chromium page-reload test with persistent storage enabled and a blocked-storage negative case remains a required follow-up: https://docs.godotengine.org/en/4.7/tutorials/export/exporting_for_web.html#using-cookies-for-data-persistence

This snapshot documents an incremental save foundation, not a completed whole-game persistence system.


## Browser persistence acceptance — 2026-11-25

The save backend is accepted only after both native process-restart coverage and a real browser page-reload test. The Chromium test scene instantiates the actual playable main scene, writes deterministic live player, mission, vehicle, inventory, NPC, activity, landmark, world and language state through the production save service, reloads the document at the same localhost origin, and verifies the restored game state. The probe uses the same Godot `user://` storage path as the game.

The browser probe scene and scripts are CI-only test material and must be excluded from the normal Web delivery package. The CI workflow may temporarily select the probe scene and include test resources for its dedicated export, but it must restore the production project and export preset before measuring the main-game package and must delete both temporary exports after validation.

A successful Chromium reload proves persistence only in the tested IndexedDB-enabled Chromium context. Private browsing, blocked storage, quota exhaustion, browser-process restart, Firefox and Safari remain separate acceptance gates until directly tested. Do not use `OS.is_userfs_persistent()` as sole proof of durability; Godot 4.7 documents that this check can be a false positive.


## Browser save persistence and user-visible fallback

The Web Edition must keep save slots under Godot's `user://` directory. In Web exports, Godot maps this virtual filesystem to browser-managed IndexedDB storage. This storage is local to the browser origin and must not be described as cloud or account-synced storage.

The live HUD must show an explicit status rather than silently implying that every successful file write will survive a browser restart:

- If `OS.is_userfs_persistent()` reports persistent storage, show that browser storage is available but may still be cleared by the browser.
- If it reports non-persistent storage, show a session-only warning and tell the player to allow browser storage.
- If a save write fails, show a visible save error.
- Provide Arabic and English status messages.

Important limitation: Godot documents that `OS.is_userfs_persistent()` can return false positives. It is a status hint, not the sole acceptance proof. A real browser test must save state through the actual game scene, reload the page at the same origin, and verify that the saved gameplay state is restored. The current Chromium gate does this for selected live-game fields in one persistent browser context. It does not prove a full browser close/reopen, a new browser profile, private browsing, blocked IndexedDB, storage-quota behavior, browser eviction, Firefox, or Safari.

Godot's Web export documentation states that IndexedDB must be allowed for `user://` persistence; private browsing or blocked storage prevents persistence. If the game is embedded in an iframe, third-party storage restrictions may also apply. See [Godot 4.7 — Using cookies for data persistence](https://docs.godotengine.org/en/4.7/tutorials/export/exporting_for_web.html#using-cookies-for-data-persistence).

The browser save status and page-reload probe are implemented in the current PR #111 review stack. Do not mark full save-system completion: the serializer covers multiple gameplay registries, but each live system still needs its own restore assertion, and the current browser probe verifies only selected state.


## Preserved original gameplay, HUD and presentation requirements

This section records the specific presentation and interaction requirements established in the earlier GTA GHIBLI brief. They remain requirements for the finished game even though the current delivery is Web-only. Where an earlier mobile control concept conflicts with the current Web keyboard/mouse acceptance scope, the control concept is retained as a deferred design requirement, not as a current test gate.

### Title and pause menu

- The in-game identity and title treatment must read **GTA GHIBLI**. Do not leave GTA San Andreas branding, copied logos, or stray franchise-title text in the finished interface.
- The pause menu order is fixed: **RESUME → START NEW GAME → MAP → STATS → BRIEF → OPTIONS → QUIT GAME**.
- Pause-menu visual treatment: black/dark background, gold typography, and a clearly visible white selection indicator.
- The dialogue panel must use a yellow-gold treatment and integrate with the gameplay HUD rather than appearing as an unrelated debug overlay.

### Gameplay HUD information hierarchy

The supplied gameplay reference establishes the following information hierarchy, which must be preserved in the final responsive Web HUD even if exact anchoring changes during visual QA:

- A readable minimap with player marker/heading, destination and mission markers, and road-following GPS route information.
- World time and player wallet, with the initial wallet value of **$350**.
- A red health indicator and a clear equipped-item/weapon indicator, including the unarmed/fist state.
- Mission objective, contextual interaction prompt, current region/location and dialogue/notification feedback.
- Vehicle state and vehicle-specific status while driving; irrelevant on-foot or weapon prompts must not remain visible.

The earlier reference placed the minimap in the upper-left and time/money/health/equipped-item information in the upper-right. The current Web HUD is still subject to visual review; do not call the reference layout matched until a screenshot-based review confirms it.

### Player, camera and contextual controls

- Use a third-person camera that follows behind the playable character, with camera-relative movement.
- In the current Web phase, keyboard/mouse controls are the acceptance target: WASD movement, Shift sprint, Space jump, E interaction, right-mouse camera orbit and mouse-wheel zoom; M toggles the map.
- Camera look input must be isolated from locomotion input. Pressing movement keys must not cause unintended camera rotation or drift. Camera orbit/zoom must respond only to the intended look/zoom inputs, and camera collision/obstruction handling must prevent the camera entering walls or geometry.
- Contextual prompts must reflect the player's current state: on foot, riding a bicycle, driving each vehicle class, or using a weapon/item. Show only actions that are valid in that state, including the correct enter/exit and vehicle-control prompts.
- A generic character-outfit reference from the supplied gameplay clip was a light sleeveless top, blue trousers and dark shoes. Treat this only as a broad clothing/color reference for an original Leo Bennett design; do not recreate a protected character or copy Rockstar character assets.

### Deferred touch-control design

The earlier design brief also named vehicle-steering choices **ANALOG / BUTTONS / FLICK** and required the selected choice to persist. Preserve this as a future optional browser-touch control feature. It is not a current Web acceptance gate, does not require a physical phone, and must not reintroduce Android/APK or real-device testing into the current phase. Keyboard/mouse remains the required control path for this delivery.

### World interaction and activity breadth

The finished game must provide a coherent open-world activity loop rather than repeated decorative scenes: characters and mission interactions; multiple original mission types; cars and other supported vehicle classes; gangs/factions and territories; shops and services; enterable interiors; police/wanted response; side activities and collectibles; and meaningful interactions with vehicles, people, nature, food and world objects. These systems must use persistent, testable gameplay state. A static prop, label or menu entry alone does not count as a functional interaction.

### Arabic performance and environmental audio

- Important dialogue must be voiced in Arabic, not delivered only as written Arabic text. Main characters need consistent voice identities and expressive performance across joy, sadness, fear, anger, surprise and tenderness.
- Dialogue, subtitles and localization must remain synchronized and support correct Arabic shaping and RTL layout.
- Environmental sound must respond to time and region, including sunrise/morning ambience, realistic nature and everyday-life ambience, and distinct night ambience. Add original/appropriately licensed effects for vehicles, footsteps, doors, interactions, missions and UI.
- Synthetic speech must be identified as synthetic; it must not be presented as human voice acting. No silent or empty audio placeholder counts as completed dubbing.

These are final-game requirements, not claims that the current Web foundation already implements them. Their implementation and verification status must remain explicit in `docs/WEB_EDITION_STATUS.md`.

## Web save persistence and degraded-storage acceptance

The Web edition must distinguish durable browser storage from a save that exists only for the current page session. Godot's `user://` filesystem on Web is browser-managed and uses IndexedDB for persistence; `OS.is_userfs_persistent()` reports whether Godot considers that filesystem persistent, but the flag alone is not proof that a save survives a reload. See the [Godot Web data-path documentation](https://docs.godotengine.org/en/4.7/tutorials/io/data_paths.html) and [OS API documentation](https://docs.godotengine.org/en/4.7/classes/class_os.html#class-os-method-is-userfs-persistent).

Required runtime behavior:

1. If the browser-backed filesystem is available and a write succeeds, the HUD may describe browser storage as available but must warn that the browser can still clear it.
2. If the filesystem is non-persistent but a write succeeds, the HUD must clearly say that the save is **session-only**. The game may read the save again during the current page session, but it must not claim that the save will survive reload or a new browser session.
3. If a write fails, the HUD must display an explicit save-failure message. It must not report a successful session-only or durable save.
4. The status must be available in Arabic and English and must be refreshed after save attempts.

Required Web CI coverage:

- Keep the normal Chromium same-origin page-reload test for selected live gameplay state. This is separate from checking Godot's persistence flag.
- Run a second Chromium context with the IndexedDB API unavailable **before** the Godot Web runtime initializes.
- Verify that the WebGL 2 game still starts, `OS.is_userfs_persistent()` reports non-persistent storage, and the HUD does not claim durable browser storage.
- If a save succeeds in the degraded context, verify that it can be read during the same active page session and that the HUD says session-only. If it fails, verify that the HUD explicitly says save failed.
- Require no external network requests and no browser runtime errors in both tests.
- Keep CI-only save-probe scenes/scripts excluded from the normal game PCK. Export probes only in the temporary runner workspace and delete the export/package after measurement.

A Chromium test that removes `window.indexedDB` is a controlled API-unavailable simulation. It does not establish behavior for every private-browsing mode, storage quota exhaustion, enterprise browser policy, browser shutdown/reopen, Firefox or Safari. Those cases remain separate acceptance gates until tested.

## Original campaign and Harbor Market implementation slice — Missions 001–003

The opening campaign must remain original and provisional until the maintainer approves the full story outline. The first three playable mission slices establish this testable progression contract:

- **Mission 001 — رسالة عند المرسى:** speak to Claire Bennett, meet Nora Blake at the lighthouse, receive $250.
- **Mission 002 — إشعار السوق:** after Mission 001, speak to Nora again, inspect the physical Harbor Market noticeboard, return to Nora, receive $300.
- **Mission 003 — مؤونة الطريق:** after Mission 002, speak to Nora, enter the physical Harbor Market interior, buy one bottle of water through the shop transaction UI, deliver it to Claire Bennett, receive $150.
- The mission state machine uses stages 0–8, with explicit step-completed and mission-completed signals. Objective progress, prerequisite completion, reward settlement, mission GPS targets, wallet changes and save restoration must remain synchronized.
- The noticeboard, market entry, market exit and shop counter must be real in-world interactables. The shop interior requires floor and wall collision, a navigable entrance, visible counter/shelf/stock props and an exit interaction; a HUD-only shop or teleport-only mockup is not sufficient.
- The shop catalog must have bounded stock and stable item prices. Buying reduces wallet and stock and increases player inventory. Selling requires owned inventory, increases stock and returns a defined resale value. Failed trades (unknown item, out of stock, insufficient funds, not owned, full stock) must not partially mutate state.
- Mission 003 requires a real `bottled_water` inventory item. The game root must reject delivery if the item is absent and prevent selling the mission item before delivery. Completing Mission 003 must settle its $150 reward once only.
- Shop stock, player inventory, wallet, economy ledger, mission stage, objective progress and reward/prerequisite records must be captured in the versioned `user://` save payload. Restore must validate saved item IDs and prices against the current catalog before applying quantities; an invalid shop snapshot must not inject items or alter catalog prices.
- Browser reload and a separate Godot process restart must restore purchased inventory and remaining shop stock, not only the displayed wallet. When IndexedDB is unavailable, the existing session-only save behavior remains explicit.
- Legacy save stage values must be clamped only to the expanded valid range, not silently collapsed to Mission 001. Missing shop data in older saves must initialize the current default stock without failing the whole save.
- Mission 001–003 dialogue remains text-only and the story remains a provisional original proposal. Expressive Arabic voice performance, fail/retry branches, cinematic presentation and the full campaign remain separate requirements and must not be marked complete.
