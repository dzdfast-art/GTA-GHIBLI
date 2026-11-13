# Adaptive Mobile Controls

## Design direction

The mobile HUD follows a contextual, state-driven design: controls are shown only when the player can use them. The supplied reference images are visual guidance for a left analog movement stick and a compact right-side action cluster; GTA GHIBLI uses its own original visual treatment.

## Current implementation

- The on-foot HUD now uses a draggable analog virtual joystick at the lower left.
- The joystick drives the same `ui_left`, `ui_right`, `ui_up` and `ui_down` input actions as desktop movement.
- A large contextual `USE` button drives the shared `interact` action.
- Touch release and HUD teardown release held input actions to avoid a stuck movement/action state.
- The HUD uses circular, high-contrast controls with a soft dark outline and shadow, sized for touch.

## Context profiles to implement with their gameplay systems

| Player state | HUD controls |
|---|---|
| On foot | Movement joystick, context interaction; later jump/sprint/attack when those actions are implemented |
| Bicycle | Steering/balance, pedal or accelerate, brake, dismount |
| Motorcycle | Steering/lean, throttle, brake, handbrake where appropriate, dismount |
| Car | Steering, accelerator, brake/reverse, handbrake, horn, exit |
| Truck/bus | Steering, accelerator, brake/reverse, parking brake, horn, exit |
| Boat | Steering, throttle, reverse/decelerate, exit |
| Aircraft/helicopter | Pitch, roll, yaw, throttle, climb/descent, landing and exit controls |
| Armed on foot | Aim, fire, reload, weapon switch and contextual interaction, based on weapon capabilities |

## State-transition contract

The future HUD controller must receive explicit player-state, vehicle-category and equipped-weapon changes from gameplay systems. It must:
1. Hide controls irrelevant to the active state.
2. Show only actions supported by the current controller and equipped item.
3. Release all held actions before switching profiles.
4. Preserve safe touch zones and avoid overlapping the camera-look area.
5. Return to the on-foot profile after dismounting or exiting a vehicle.
6. Provide accessible button sizes and configurable opacity/position.

## Honest implementation boundary

Only the analog on-foot movement stick and shared interaction button are implemented in this change. Vehicle driving, weapon handling, jump, sprint and their HUD profiles remain unimplemented until the corresponding gameplay systems exist. Do not display placeholder controls as if they work. The new HUD has not yet been visually or touch-tested on a physical Android device.
