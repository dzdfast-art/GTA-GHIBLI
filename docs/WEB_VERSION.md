# GTA GHIBLI — Web Edition

## Current delivery target

The active delivery target is **Godot 4.7 Web**, running in a modern desktop browser. Android, APK creation, physical phones, device installation and phone-specific performance measurements are outside the current scope and are not acceptance gates.

The Web export uses the **Web Preview** preset in export_presets.cfg. It is configured for the single-threaded WebAssembly path and the Compatibility renderer (WebGL 2). It does not require SharedArrayBuffer or cross-origin isolation headers.

## Browser controls

- **W / A / S / D** — move on foot.
- **Right mouse button + pointer drag** — orbit the third-person camera.
- **E** — interact with the nearest eligible object or character.
- **Shift** — sprint.
- Click the game canvas once before using keyboard controls if the browser has not yet focused it.

The same gameplay actions remain shared with the existing contextual vehicle/bicycle controls. Touch-specific controls may remain in the code for input compatibility, but a physical touchscreen is not required to build, test or accept the Web version.

## Build and verification

The private Web verification is performed by these GitHub Actions workflows:

- .github/workflows/web-build.yml
- .github/workflows/web-repair-validation.yml

A successful Web validation must complete:

1. Godot 4.7 resource import and impacted GDScript/regression tests.
2. Web privacy and offline-dialogue audits.
3. OBJ surface/material-reference checks for selected assets.
4. Godot Web export, including non-empty index.html, JavaScript loader, .wasm and .pck.
5. A local HTTP server bound only to 127.0.0.1 / localhost.
6. Chromium startup with WebGL 2, keyboard input and right-mouse camera input.
7. No JavaScript/runtime errors and no external network requests from the game preview.
8. Temporary export and temporary ZIP size/hash measurement.

A Chromium smoke test proves browser startup and the tested input path only. It is not proof that every mission, vehicle, scene, visual effect, audio line or gameplay system is complete.

## Temporary export and privacy

The Web export exists only on an ephemeral GitHub Actions runner for validation. The workflow may create a temporary ZIP to calculate exact bytes and SHA-256, but it prints measurements to the Actions log and deletes the export and ZIP before the job ends.

**The workflow does not upload a downloadable Web artifact.** It does not publish a public website, use GitHub Pages, create a public download URL, or deploy through Vercel/another host. The cleanup step removes older public artifacts named GTA-GHIBLI-Web where the workflow has repository permissions; cleanup is not publication.

Do not open the export through file://. For local testing, serve it over HTTP with:
- .wasm as application/wasm
- .pck as application/octet-stream

## Current scope exclusions

- Android APK builds and physical-device testing are not part of the current Web acceptance process.
- The legacy Android workflow is retained in the repository for historical reversibility but is manual-only and is not a required check.
- No human Arabic dubbing is claimed complete until actual licensed local audio clips are present, loaded offline and tested.
- No public hosting or release is authorized by this document. Public release requires a separate explicit owner decision.
