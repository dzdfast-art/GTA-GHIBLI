# Android debug test build

This workflow creates an **ARM64 debug APK** for installing the current prototype on a compatible Android device. It is a development build, not a store-ready release.

## Automated build

- Workflow: [Android debug APK](../.github/workflows/android-debug-apk.yml)
- Runs automatically when relevant game files or the Android export configuration change on `main`.
- Can also be started manually from GitHub Actions using **Run workflow**.
- Uses Godot 4.7, Android SDK Platform 35, Build Tools 35.0.1 and Java 17.
- Exports the `Android Debug (ARM64)` preset.
- Checks the APK archive and package metadata, and inspects the packaged Android permissions.
- Uploads the APK and audit reports as the `GTA-GHIBLI-Android-debug-APK` workflow artifact for 14 days.

## Downloading on Android

After a successful workflow run:

1. Open the workflow run linked above.
2. Scroll to **Artifacts**.
3. Download `GTA-GHIBLI-Android-debug-APK`.
4. Extract the ZIP and install `GTA-GHIBLI-debug.apk` on an ARM64 Android device.

The APK is debug-signed for testing. It is not the permanent release-signing build and should not be used for Play Store distribution. Future production releases need a separately managed private signing key stored only in GitHub Actions secrets or another secure signing service.

## Important limitations

A successful export and APK inspection prove that an installable package was produced; they do **not** prove that gameplay works correctly on a physical phone. Touch input, camera behavior, frame rate, audio, crashes and device compatibility still need real-device testing. The current game remains an early prototype.

The workflow checks the merged APK permission list for sensitive permissions. Review the report attached to every build; do not infer that the repository-side privacy scan alone proves the final APK is permission-free.
