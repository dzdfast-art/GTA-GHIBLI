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
- **M** — open or close the interactive world map.
- **Map** — click a point-of-interest marker to set a waypoint; use the mouse wheel to zoom and right-drag to pan.
- **Ctrl** — brake the starter sedan.

For a Web export, select the `Web` preset and export to `build/web/index.html`. Serve the exported folder over HTTP(S); do not launch it through `file://`.

## Current playable foundation

- Four named region blockouts connected by one continuous ground strip and a main road corridor.
- Provisional Marsa Al-Noor lighthouse landmark in Harbor City.
- Original temporary placeholder representations for Leo, Claire, Mia and Nora.
- A first text-only mission with two interactive stages, a $250 reward and a local save file.
- A first functional sedan with basic acceleration, steering, reverse and braking.
- Gameplay HUD, region label, live minimap and interactive world map with six original points of interest. A starter road graph connects the main corridor to these locations; A* produces a road-following route and route distance for the HUD, full map and minimap. The HUD also shows the next left/right turn and its remaining distance when a turn exists on the current route.

## Important limitations

The region geometry and character/vehicle models are blockout placeholders, not finished art. The current A* GPS graph is an early prototype: it models the east-west starter corridor plus six short access spurs to the registered points of interest. It does not yet model a complete street network, complex intersections, one-way roads, closures, turn restrictions, pedestrian-only paths, route recalculation around blockages, step-by-step instructions for every segment or voice prompts. The nearest-node snap is bounded; destinations outside that bound are reported as unreachable. This milestone does not yet contain the full open world, a complete road/GPS network, detailed interiors, a final rig/animation set, weapon combat, traffic/police simulation, all vehicle classes, a complete mission campaign, weather, original music or verified Arabic voice performances. Those requirements are tracked in `../docs/WEB_EDITION_MASTER_SPEC.md` and `../docs/WEB_EDITION_STATUS.md`.

CI exports the Web build, records its exact size and SHA-256 in the job log, then deletes the temporary build directory. It does not upload or retain a downloadable Actions artifact.
