# GTA GHIBLI — First Vehicle Milestone

## Scope

The first road-vehicle slice adds an original starter car to Willow Village. Its current
procedural meshes are placeholders for gameplay validation, not final vehicle art.

## Implemented in this milestone

- A reusable CharacterBody3D car controller with forward/reverse acceleration, steering,
  gravity, and braking.
- Procedural body, cabin, glass, bumper, headlight, and four-wheel placeholder meshes.
- Proximity interaction to enter and exit the car.
- Player movement is suspended while driving; the player visual is hidden and collision
  disabled, then restored on exit.
- The existing mobile joystick steers and controls throttle/reverse.
- A contextual BRAKE button appears while driving; USE becomes EXIT.
- A headless regression test covers enter, forward movement, exit, and visual restoration.

## Controls

- Joystick up: accelerate forward.
- Joystick down: reverse.
- Joystick left/right: steer.
- BRAKE: slow down.
- USE / EXIT: enter or leave the vehicle in interaction range.

## Known limitations

No suspension, tire friction simulation, damage, repair, fuel, vehicle audio, passenger seats,
traffic AI, or final vehicle art are included yet. Camera smoothing, collision tuning, real touch
feel, frame rate, and target-device performance still require physical Android testing.

## Acceptance gate

Do not mark this milestone fully accepted until Godot CI passes and the exported APK is installed
and tested on a physical Android device for entry/exit, steering, forward/reverse, braking, and
camera behavior.
