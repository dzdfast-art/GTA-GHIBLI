# GTA GHIBLI — Web Preview and Security Boundary

## Purpose

The Web Preview is a second export of the same Godot project. It is **not** an APK-to-HTML converter and it does not replace Android. The existing Android ARM64 preset remains in place; this branch adds a separate `Web Preview` preset and an isolated browser-preview workflow.

## Branch boundary

- The work lives on `web-preview` only.
- `main` is not modified by this preview setup.
- The Android export preset and Android build workflow are retained.
- Web builds are generated only inside a temporary GitHub-hosted runner for validation.
- The workflow does not upload the Web build as an artifact and does not create a downloadable build link.
- There is no GitHub Pages deployment job, deployment input, or publishing step.
- Manual workflow dispatch is limited to building and checking; it cannot publish the game.
- A narrowly scoped cleanup job deletes any earlier `GTA-GHIBLI-Web-Preview` workflow artifacts; only that cleanup job receives `actions: write`.

## Web export security choices

- Godot Web uses the Compatibility renderer already configured by the project.
- Thread Support and GDExtension Support are disabled. This avoids requiring `SharedArrayBuffer` and cross-origin isolation headers for the initial preview.
- Progressive Web App/offline caching is disabled until cache behavior and storage handling are separately tested.
- The browser preview skips the native procedural `AudioStreamGenerator` and uses the imported ambience-loop audio assets instead; Android keeps its existing procedural ambience path.
- The workflow checks the Android privacy audit and a Web-specific static audit before export.
- The Web-specific audit rejects browser JavaScript bridges, camera/microphone capture APIs, shell/process execution, and unreviewed HTTP request code.
- The two existing NPC voice-download call sites are explicitly blocked when Godot reports the `web` feature. Local bundled audio or browser-local cache may still play; remote voice-host fallback is not used by the Web preview.
- The build uses no repository secrets, personal access tokens, signing keys, or external service credentials.
- Git checkout does not fetch Git LFS objects. Editable master audio sources are excluded from Godot imports by `audio/ambience/source_master/.gdignore`.

## User privacy

- The Web preview must not ask for photos, videos, files, camera, microphone, contacts, location, or other personal-device access.
- The preview does not add analytics, advertising, telemetry, file upload, or a third-party JavaScript SDK.
- Godot `user://` saves in a browser build are browser-origin local data. They are not uploaded by this workflow.
- Browser sandboxing limits access to arbitrary device files; any future file-import feature would require a separate review and explicit user selection.
- The audit is a guardrail, not a mathematical guarantee. Every new browser bridge, network call, plugin, import feature, or permission request must be reviewed before merging.

## Public source repository and Web-output boundary

The GitHub repository remains intentionally **Public**. Therefore, source code and files committed on `web-preview` can still be viewed or forked by people who can access the public repository. This CI-only decision does **not** make the source repository private and does not provide anti-copy protection for source assets.

The generated Web bundle is different: it is built only on a temporary GitHub-hosted runner, is not uploaded as a workflow artifact, has no public download link, and is not deployed to GitHub Pages. No public browser game URL is created.

Never commit secrets, private signing material, personal data, or unreleased material that must remain confidential to a public repository. Copyright notices and the ownership register are evidence-management measures, not technical copy protection.

## What the automated workflow verifies

1. Repository-side Android privacy configuration.
2. Web-specific static privacy rules.
3. Godot 4.7 resource import.
4. Existing mobile-control and ambient-audio regression tests in headless mode.
5. Creation of a Web export containing a non-empty `index.html`, WebAssembly binary, and PCK.
6. A private Chromium smoke test served only from `127.0.0.1` on the temporary runner; it checks canvas startup, WebGL 2 availability, browser runtime errors, input delivery, and absence of external network requests.
7. Confirmation that the generated files stay on the temporary runner; no artifact is uploaded or shared.

The Chromium smoke test is a startup check, not a full gameplay or visual-quality certification. Long play sessions, touch behavior on real phones, sustained frame rate, audio quality and Android device compatibility still need dedicated testing.

## Publishing remains disabled

Do not configure GitHub Pages for this preview branch. Keep the Web export confined to the temporary CI runner. Any future public or private distribution proposal must receive a separate security and ownership review first.

## Related security records

- [Security policy](../SECURITY.md)
- [Public repository hardening](REPOSITORY_HARDENING.md)
- [Privacy by default](PRIVACY_BY_DEFAULT.md)
- [Ownership and asset register](OWNERSHIP_AND_ASSET_REGISTER.md)
