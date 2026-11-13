# GTA GHIBLI — Core Gameplay Systems

## Design principles
- Original setting, cast, missions, dialogue, names, and art.
- Third-person exploration first; add complexity only after the movement prototype is validated.
- Mobile-first controls with large touch targets and optional controller/keyboard support.
- Small, testable systems rather than one monolithic script.

## Player
- Third-person character with walking and running.
- Collision-aware movement and gravity.
- Camera-relative movement once the camera rig is finalized.
- Interaction prompt when close to a usable object or character.

## Interaction
Every interactable object should expose a stable ID, a short display name, an interaction type, and an action.
Initial interaction types: talk, inspect, collect, open, and use.
Interactions must be triggered by a dedicated button on touch screens.

## Missions
Missions are data-driven. Each mission has:
- A unique ID and title.
- A start condition and region.
- Ordered or explicitly parallel objectives.
- Completion conditions and rewards.
- A status such as design_only, available, active, completed, or locked.

The first tutorial mission is recorded in `data/missions/mission_001.json`. It is design data only until a mission manager is implemented and tested.

## World
The first playable slice is Green Valley:
- Willow Village: player start, central square, and starter characters.
- Sunmeadow Fields: open exploration and collectibles.
- Old Mill Road: connecting route and future vehicle test.
- Mistwood Edge: forest exploration and future expansion.

The region catalogue is stored in `data/world/regions.json`. Coordinates, collision geometry, navigation, and final art are not yet implemented.

## Vehicles
Planned after the player controller is validated:
- Enter/exit at designated interaction points.
- Arcade steering and braking.
- Separate on-foot and driving camera behavior.
- Touch driving controls with configurable layout.

## Save system
Save only stable gameplay state: player position, unlocked regions, mission states, inventory, and settings. Use versioned save data and handle missing fields safely.

## Performance targets
- Prioritize the mobile renderer and low-cost materials.
- Keep physics bodies simple.
- Use level-of-detail and visibility ranges for larger scenes.
- Profile on a real Android device before increasing world density.

## Current implementation status
The repository currently contains a procedural test scene and a basic movement prototype. The systems above are design specifications, not claims that these features are already playable.
