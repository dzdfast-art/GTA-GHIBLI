# GTA GHIBLI — Browser / Web Edition

The delivery target for this branch is the Godot 4.7 Web export. Android APK export has been removed from the active delivery workflow.

## Build output

GitHub Actions workflow: **GTA GHIBLI Web Build**

Successful runs publish a downloadable artifact named **GTA-GHIBLI-Web** containing:
- `GTA-GHIBLI-Web.zip`: the complete static browser game bundle.
- `web-size.txt`: exact ZIP size, uncompressed export folder size, file count, and SHA-256.

The bundle includes `index.html`, the JavaScript loader, WebAssembly runtime, game pack, and a short hosting note.

## Running / hosting

Do not open `index.html` through `file://`. Upload the contents of the exported folder to a static web host and open it through HTTP or HTTPS. The server must return:
- `.wasm` as `application/wasm`
- `.pck` as `application/octet-stream`

The export uses the single-threaded Web path. It does not depend on `SharedArrayBuffer` or cross-origin isolation headers. It still requires a modern browser with WebAssembly and WebGL 2.

## Verification

A successful Web release run must complete:
1. Project and resource import.
2. Device-data and Web dialogue privacy audits.
3. Original OBJ asset checks.
4. Graphics-reference, gameplay HUD, and tutorial regression tests.
5. Web export file checks.
6. Private Chromium runtime smoke test with WebGL 2, no JavaScript/runtime errors, and no external network requests.
7. Exact bundle size and SHA-256 recording.

## Publication

The workflow creates a private GitHub Actions artifact. It does not publish a public website or GitHub Pages site automatically. Public hosting is a separate owner-controlled decision.
