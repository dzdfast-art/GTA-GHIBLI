# GTA GHIBLI — Master Requirements Alignment

**Status:** requirements baseline and discrepancy register  
**Primary source:** `GTA_GHIBLI_FULL_PROMPT.txt`  
**Engine in the current prototype:** Godot 4.7 (headless CI validation)  
**Target:** Android, with the Infinix SMART 8 / Unisoc T606 / 4 GB physical RAM as the baseline test device  
**Content target:** approximately 4 GiB of genuine, useful assets; not a runtime RAM target

This document turns the supplied master prompt and the current repository evidence into one controlled implementation baseline. It does not claim that planned systems already exist.

## 1. Authority and project identity

1. `GTA_GHIBLI_FULL_PROMPT.txt` is the governing product specification. Preserve its requirements and named entities.
2. The GitHub repository is evidence of implementation only. A file or design note is not proof of a working feature.
3. GTA San Andreas is a reference for breadth and systemic gameplay. GTA GHIBLI must use original maps, characters, missions, dialogue, UI artwork, music, models, and other assets.
4. Do not silently replace the master specification with prototype names or prototype content.
5. Do not delete the current prototype or claim it is the final game's foundation until a safe migration/new-project decision has been documented.

## 2. Canonical world and cast from the master prompt

### Required regions and location

- Harbor City
- Sapphire Coast
- Pine Highlands
- Amber Valley
- Marsa Al-Noor — a named, meaningful location whose exact placement must be defined on the world map.

### Required named characters

- Leo Bennett — main protagonist
- Claire Bennett — Leo's mother
- Mia Bennett — Leo's sister
- Nora Blake — established named character

Do not invent agreed ages, biographies, precise relationships beyond those stated, or character arcs. Develop missing details as proposals and record them as such.

## 3. Prototype-to-specification discrepancies

| Area | Current repository prototype | Master requirement | Treatment |
|---|---|---|---|
| World | Green Valley: Willow Village, Sunmeadow Fields, Old Mill Road, Mistwood Edge | Harbor City, Sapphire Coast, Pine Highlands, Amber Valley, plus Marsa Al-Noor | Keep prototype data identifiable as prototype; do not silently rename canonical regions |
| Cast | Mira caretaker prototype | Leo Bennett, Claire Bennett, Mia Bennett, Nora Blake and a larger original cast | Preserve Mira as a prototype/test NPC; do not replace or erase the required cast |
| Player | Capsule placeholder and basic third-person movement | Finished original character, rig, animations, interactions and state handling | Placeholder only |
| Dialogue | Arabic text and emotion metadata for Mira | Real expressive Arabic voice acting, consistent character voices, subtitles and synchronized presentation | Audio status remains pending until real audio is integrated and tested |
| Missions | One tutorial flow: square → Mira → garden | Main story, side missions, jobs, dynamic encounters and varied activities | Current mission is a small prototype, not the campaign |
| Vehicles | No implemented drivable vehicle confirmed | Cars, motorcycles, bicycles, vans, trucks, heavy vehicles, boats, aircraft, helicopters and other suitable transport | Build reusable vehicle classes and category-specific controls |
| Interaction | Mira proximity and TALK action | Reusable interactions with people, objects, buildings, food, nature and vehicles | General interaction framework remains to be implemented |
| Save | Local persistence for the first mission flags | Versioned game-wide progress including missions, player, inventory, settings and relevant vehicle/world state | Current save is mission-only |
| Platform | Godot headless CI | Android export, install, launch and physical-device testing | Not yet verified on device |

The master prompt also says the final project should be a genuinely new project from an empty directory and should not depend on old B1–B16 prototypes. The current repository contains a working starter prototype. This is a production decision that must be handled explicitly: preserve the current work as a prototype/history, and establish a clean production project separately if required by the specification. Do not destructively overwrite the existing project or mislabel it as the final clean-start build.

## 4. Required gameplay pillars

### 4.1 Physics and object interaction

The interaction design must support, when appropriate:
- Pick up, carry, drop, inspect, collect, push, pull, move, open, close, use and activate.
- Doors, gates, drawers, switches, furniture, tools, containers and mission objects.
- Object-specific collision, mass/weight behavior, gravity, friction, impact and breakability.
- Contextual prompts and animations; actions must be real and testable, not decorative buttons.
- Sensible limits for mobile performance. Not every tiny prop needs a fully simulated rigid body.

### 4.2 People and living world

- A larger original cast with distinct identities, roles, appearances, voices and motivations.
- Named story characters separated from generic pedestrians and background population.
- NPC routines, conversations, reactions, relationships, work roles and mission-specific behavior.
- Arabic voice dialogue with emotion/performance direction, subtitles and consistent voice identity.
- Ambient population and traffic scaled by distance and device performance.

### 4.3 Nature, food and daily activities

- Interactions with plants, trees, flowers, crops, water, weather and suitable wildlife.
- Gathering, farming, fishing and animal care where they support the world and story.
- Food and drink, shops, cafés, restaurants, cooking and useful player-state effects.
- Sleep/rest and other needs only where they create meaningful gameplay rather than busywork.

### 4.4 Vehicles and transport

Vehicle categories must not be treated as interchangeable static models:
- Road: cars, sedans, sports cars, vans, utility vehicles, buses, trucks and heavy vehicles.
- Two-wheel: motorcycles and bicycles.
- Marine: boats and other suitable watercraft.
- Air: airplanes and helicopters where performance and design justify them.
- Other: carts, trailers and special transport where useful.

Each implemented category needs real entry/exit, collision, movement, handling, camera behavior, sound, animations where required, and an appropriate mobile HUD. Cars/trucks, motorcycles, boats and aircraft require different control profiles. A static model does not count as a drivable vehicle.

### 4.5 Characters, missions and variety

- Main story missions, character side stories, jobs, delivery, driving, exploration, rescue, investigation, races, environmental tasks, challenges and optional encounters.
- Every mission needs a start condition, objective logic, success/failure handling where relevant, rewards/progression, dialogue and save behavior.
- Every important character needs a meaningful role; avoid adding near-duplicate characters solely to inflate population.
- Reduce excessive repetition: compare mission mechanics, locations, dialogue, rewards and narrative purpose before adding content. Reuse a mechanic only when the context or challenge changes meaningfully.
- Repeated everyday objects (roads, trees, shops) are acceptable when natural; repeated filler content is not.

## 5. Mobile controls and performance

- Context-sensitive HUD states: on-foot, interacting, weapon use, nearby vehicle, car/truck, motorcycle, boat, airplane and helicopter.
- Keep only relevant controls visible for the current state.
- Touch targets, safe areas and landscape layout must work across Android screen sizes.
- Optimize for the target device's **4 GB physical RAM**. Virtual RAM expansion is not equivalent to physical RAM.
- Use LOD, instancing, culling, simple collision, distance-based AI and region streaming.
- The **4 GiB content target is storage/content**, not permission to consume 4 GiB of RAM. Track source, imported, download and installed sizes separately.

## 6. Current verified implementation snapshot

Repository inspection confirms:
- Godot project and main scene exist.
- Third-person capsule placeholder, camera-relative movement and touch-orbit camera exist.
- On-screen movement controls and a TALK action exist.
- Willow Village is a procedural greybox.
- Mira has proximity interaction, Arabic dialogue text and emotion metadata.
- Mira's audio asset is still marked `pending_generation`; no real integrated Arabic voice file is verified.
- The first mission reads JSON objectives, tracks the square/Mira/garden sequence and saves/restores those mission flags locally.
- The mission reward is displayed as prototype information; it is not a real currency/inventory system.
- No working drivable vehicle, full physics interaction system, complete NPC population, campaign, Android package or physical-device test is verified.

GitHub Actions run **43513899542** completed successfully: JSON validation, Godot 4.7 import, gameplay-script parsing, first-mission flow test and 180-frame main-scene smoke test all passed. This is a headless CI result, not Android/device validation.

## 7. Production order and acceptance gates

1. Resolve the clean-production-project versus existing-prototype boundary without losing history.
2. Establish canonical world/cast data from the master prompt.
3. Build a reusable interaction contract and contextual interaction manager.
4. Make one representative object interaction and one NPC interaction pass end-to-end tests.
5. Add the first real vehicle with entry/exit, handling, collision and mobile HUD state; test transitions.
6. Expand the mission framework with distinct mission templates and a repetition audit.
7. Add the living-world, nature, food, shops, traffic and broader vehicle classes incrementally.
8. Integrate actual Arabic voice assets and verify playback/subtitle timing.
9. Build and test the Android export on the target phone.
10. Expand unique assets and regions against the auditable 4 GiB content budget.

A gate passes only when its implementation and tests exist. Keep **implemented**, **planned**, **blocked**, and **tested** statuses separate.
