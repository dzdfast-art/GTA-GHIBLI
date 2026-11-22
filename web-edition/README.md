# GTA GHIBLI — Fresh Web Edition

This is a **new, independent Godot 4.7 project** rooted in this directory. It is not copied from the older project/prototype files in the repository. It currently contains only original source written for this clean Web foundation; no legacy scenes, scripts, imported assets or add-ons are referenced.

## Current target

- Godot 4.7.
- WebAssembly export, single-threaded.
- Compatibility renderer / WebGL 2.
- Modern desktop browser with WebAssembly and WebGL 2.
- Keyboard and mouse controls; no phone, APK or physical-device test is required for this delivery.

## Run locally

Open this directory as a project in Godot 4.7, then run the main scene.

Controls:
- **W / A / S / D** — walk and steer.
- **Shift** — sprint.
- **Space** — jump.
- **E** — interact / enter or exit the starter sedan.
- **Right mouse button + drag** — orbit the third-person camera.
- **Mouse wheel** — zoom camera.
- **M** — open or close the map overlay.
- **Ctrl** — brake the starter sedan.

For a Web export, select the `Web` preset and export to `build/web/index.html`. Serve the exported folder over HTTP(S); do not launch it through `file://`.

## Current playable foundation

- Four named region blockouts connected by one continuous ground strip and a main road corridor.
- Provisional Marsa Al-Noor lighthouse landmark in Harbor City.
- Original temporary placeholder representations for Leo, Claire, Mia and Nora.
- A first text-only mission with two interactive stages, a $250 reward and a local save file.
- A first functional sedan with basic acceleration, steering, reverse and braking.
- Basic HUD, region label and a preliminary map overlay.

## Important limitations

The region geometry and character/vehicle models are blockout placeholders, not finished art. This milestone does not yet contain the full open world, a complete road/GPS network, detailed interiors, a final rig/animation set, weapon combat, traffic/police simulation, all vehicle classes, a complete mission campaign, weather, original music or verified Arabic voice performances. Those requirements are tracked in `../docs/WEB_EDITION_MASTER_SPEC.md` and `../docs/WEB_EDITION_STATUS.md`.

CI builds and tests the Web export, then retains a downloadable `GTA-GHIBLI-Web-Edition` Actions artifact for 14 days. The artifact is available to repository users with Actions access; this does not publish or host the game publicly.
