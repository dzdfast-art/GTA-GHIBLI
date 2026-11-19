# Adaptive Mobile Controls and Gameplay HUD

## Design direction

GTA GHIBLI uses its own original touch interface while reproducing the useful interaction patterns shown in the supplied gameplay reference. The existing `MobileControls` CanvasLayer owns the touch controls; the gameplay status overlay is a sibling layer so control opacity/scale settings do not fade the radar or player status.

## Current implementation

- **On foot:** lower-left analog movement stick, contextual interaction, and RUN.
- **Bicycle:** mount/dismount, PEDAL, BRAKE / REVERSE, and selectable ANALOG, BUTTONS, or FLICK steering. The choice is saved in the existing Options settings.
- **Car:** contextual enter/exit, steering input, and brake control are shown by the existing vehicle mode.
- Held touch actions are released on button-up, mode transitions, and HUD teardown.
- The player camera remains a separate touch-look input and is covered by the mobile-control regression tests.
- The live gameplay overlay includes a mini-radar, world clock, wallet balance, health value/bar, and unarmed-fist icon. It reads the existing world clock and wallet rather than maintaining duplicate values.
- The pause menu still owns the full-screen world map; the live mini-radar is a separate in-game display.

## State-transition contract

The control profile is selected by gameplay systems and must:
1. Hide controls irrelevant to the active state.
2. Show only actions supported by the current controller.
3. Release held input before switching profiles.
4. Preserve safe touch zones and avoid overlapping camera look.
5. Return to on-foot controls after exiting a vehicle.
6. Keep control opacity/scale preferences separate from the mini-radar/status overlay.

## Remaining boundaries

- Motorcycle, truck/bus, boat, aircraft and weapon-specific profiles are not implemented.
- The health component and display exist, but damage sources across the world still need gameplay integration.
- The HUD has automated/headless integration coverage; it has not been visually or touch-tested on a physical Android phone.
- The video’s complete guided route/tutorial, road traffic and final animated character model are follow-on implementation tasks, not implied by this HUD layer.
