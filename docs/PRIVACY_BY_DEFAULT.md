# GTA GHIBLI — Privacy by Default

**Product decision:** GTA GHIBLI does not need access to a player's personal photos, videos, messages, contacts, microphone, camera, or general file storage to play the game. These are not game features and must not be added as background collection.

## Binding development rules

1. Do not request Android permissions for camera, microphone/audio recording, photos/media, broad or legacy storage, contacts, location, SMS, call logs, or phone state.
2. Do not scan, index, upload, back up, or inspect the player's personal files or media.
3. Do not add background file watchers or automatic device discovery.
4. Do not access the camera or microphone. If a genuinely necessary future feature is proposed, it must be optional, clearly explained, user-initiated, and separately reviewed before implementation.
5. Keep saves in the app's private Godot user-data directory (for example, `user://`). Do not export saves or diagnostics without the player's explicit action.
6. Do not add analytics, advertising SDKs, telemetry, or third-party plugins that collect personal/device data without a separately reviewed privacy decision and clear disclosure.
7. Never put personal files, credentials, signing keys, or private tokens in the public GitHub repository.
8. Any future import feature must use Android's system document picker / Storage Access Framework so the player selects the exact file. No broad media-library permission and no automatic folder scan.

## Current project status

- The checked-in `project.godot` contains no Android permission declarations.
- There is currently no checked-in Android export preset or custom Android manifest.
- A CI privacy audit checks the repository-side project/export/manifest configuration for sensitive permission declarations.
- This source-level check is not proof about a future APK. Godot export templates and Android plugins can contribute permissions during packaging.

## Mandatory release gate for Android

Before sharing any APK/AAB:
- Inspect the **merged manifest inside the actual build** (including permissions added by Godot and every plugin).
- Confirm it contains no camera, record-audio, photo/video/media, broad storage, contacts, location, SMS, call-log, or phone-state permissions.
- Review every third-party Android plugin and its manifest.
- Install on a test device and verify Android Settings → Apps → GTA GHIBLI → Permissions shows no unnecessary permissions.
- If an unexpected permission appears, stop release and remove its source before distributing the build.

## Honest limitation

This policy and CI check reduce the risk of accidental permission requests. They do not prove that a future third-party plugin or exported build is safe; every release must pass the merged-manifest review. The game does not have permission to inspect a phone merely because it is installed.
