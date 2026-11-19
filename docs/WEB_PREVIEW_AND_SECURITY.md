# GTA GHIBLI — Web Preview and Security Boundary

## Purpose

The Web Preview is a second export of the same Godot project. It is **not** an APK-to-HTML converter and it does not replace Android. The existing Android ARM64 preset remains in place; this branch adds a separate `Web Preview` preset and an isolated browser-preview workflow.

## Branch boundary

- The work lives on `web-preview` only.
- `main` is not modified by this preview setup.
- The Android export preset and Android build workflow are retained.
- Web builds are generated as workflow artifacts when this branch is pushed.
- GitHub Pages deployment is **manual only**. A workflow run must be started from `web-preview` and the `deploy_pages` input must be set to `true`.
- No pull-request event is allowed to deploy the public preview.

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

## Public publishing and ownership limits

This repository is intentionally public. A GitHub Pages deployment of this game will also be public to anyone who has its URL. A Web export is downloadable/inspectable by visitors; it cannot hide client-side game data or guarantee prevention of copying, reverse engineering, or modified builds. Copyright notices and the ownership register remain important evidence, but they are not technical copy protection.

Do not put secrets, private signing material, personal data, or unreleased material that must remain confidential into a public Web export. The Web preview is for testing, not a private beta.

For a stricter approval gate, the repository owner should configure required reviewers for the `github-pages` environment in GitHub Settings → Environments before enabling deployment. The Actions workflow grants `pages: write` and `id-token: write` only to the deployment job; the build job receives only `contents: read`.

## What the automated workflow verifies

1. Repository-side Android privacy configuration.
2. Web-specific static privacy rules.
3. Godot 4.7 resource import.
4. Existing mobile-control and ambient-audio regression tests in headless mode.
5. Creation of a Web export containing a non-empty `index.html`, WebAssembly binary, and PCK.
6. Upload of the preview as a short-retention GitHub Actions artifact.

A passing headless build does not prove browser rendering, browser audio behavior, or real Android touchscreen performance. Those require an actual browser run and physical-device testing.

## Enable GitHub Pages once

The owner must set the repository's Pages publishing source to **GitHub Actions**. Until that is configured, artifact-only preview builds can still run. Deployment remains disabled unless manually requested through the workflow input.

## Related security records

- [Security policy](../SECURITY.md)
- [Public repository hardening](REPOSITORY_HARDENING.md)
- [Privacy by default](PRIVACY_BY_DEFAULT.md)
- [Ownership and asset register](OWNERSHIP_AND_ASSET_REGISTER.md)
