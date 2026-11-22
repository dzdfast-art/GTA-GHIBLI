# Adaptive Mobile Controls and Video-Reference Gameplay

## Design direction

GTA GHIBLI uses original project-owned visuals and code while recreating the useful Android open-world gameplay patterns visible in the supplied reference. The existing `MobileControls` CanvasLayer owns touch input. The gameplay status overlay is a separate sibling layer so touch-control opacity settings do not fade the radar or player status.

## Implemented in this feature branch

- **On foot:** lower-left analog movement stick, right-side camera-look zone, contextual interaction and RUN controls.
- **Player model:** the temporary capsule is replaced by an original lightweight low-poly humanoid with a white sleeveless-style shirt, blue pants, dark shoes, head/hair, and simple walk-cycle arm/leg movement.
- **Live HUD:** mini-radar, actual village and district road lines, player direction arrow, nearby vehicle/bicycle/landmark/house markers, active objective marker, world clock, wallet cash, health value/bar and an unarmed fist icon.
- **Bike tutorial:** a blue marker appears above the bicycle. The optional guided sequence asks the player to mount it, ride to the red bridge, dismount, follow the red house marker and enter the house. This is separate from the existing Mira/village mission.
- **Bicycle:** mount/dismount, PEDAL, BRAKE / REVERSE, plus saved ANALOG, BUTTONS or FLICK steering preferences.
- **Car:** the existing starter car's contextual enter/exit and driving controls remain in place.
- **Ambient traffic:** four lightweight original cars move along the village's cross-streets and appear as vehicle markers on the mini-radar.
- Existing wallet and world-clock services remain the sources of truth; the new HUD does not maintain duplicate money or time state.

## Important implementation boundaries

- The mini-radar is a stylized live radar with actual road lines and nearby markers, not an exact reproduction of the reference game's detailed map artwork.
- The four ambient cars are decorative moving traffic for atmosphere and route context. They do not yet implement traffic collision, lane-changing, traffic lights, pedestrian avoidance or full vehicle AI.
- The player is a procedural low-poly character with a simple walk cycle, not a high-detail rigged/face-animated character.
- The health component and HUD are connected; damage sources across combat, falls and traffic still need broader gameplay integration.
- The complete guided bike-to-bridge-to-house sequence has an automated regression test, but it has not yet been visually or touch-tested on a physical Android phone.
- Motorcycle, truck/bus, boat, aircraft and weapon-specific control profiles remain outside this implementation.
- The existing pause menu still owns the full-screen world map. The live mini-radar is a separate gameplay display.

## State-transition contract

The existing mobile controls continue to change based on player state. They must release held inputs before switching profiles, show only actions supported by the current controller, preserve camera-look separation and return to the on-foot profile after dismounting or exiting a vehicle.
