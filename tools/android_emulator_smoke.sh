#!/usr/bin/env bash
# Runs as one Bash process inside reactivecircus/android-emulator-runner.
# Keep shell variables and compound tests inside this file rather than inline
# workflow script lines, which the action dispatches as separate commands.
set -euo pipefail

mkdir -p build
adb wait-for-device
test -s build/apk-badging.txt
test -s build/GTA-GHIBLI-debug.apk

package_name="$(awk -F"'" '/^package: name=/ { print $2; exit }' build/apk-badging.txt)"
if [[ -z "$package_name" ]]; then
  echo "Could not parse Android package name from build/apk-badging.txt:"
  head -n 5 build/apk-badging.txt
  exit 1
fi
echo "Installing and launching Android package: $package_name"

adb install -r build/GTA-GHIBLI-debug.apk
adb shell monkey -p "$package_name" -c android.intent.category.LAUNCHER 1
sleep 8

# Android 15 may show its first-run immersive-mode confirmation above the app.
# Read the emulator's actual resolution instead of assuming fixed coordinates.
screen_size="$(adb shell wm size | tr -d '\r' | awk '
  match($0, /[0-9]+x[0-9]+/) {
    size = substr($0, RSTART, RLENGTH)
    split(size, dimensions, "x")
    if (dimensions[1] > 0 && dimensions[2] > 0) {
      print dimensions[1], dimensions[2]
    }
  }
' | tail -n 1)"
if [[ -z "$screen_size" ]]; then
  echo "Could not determine Android emulator display size."
  exit 1
fi
read -r screen_width screen_height <<< "$screen_size"
if (( screen_width < 1 || screen_height < 1 )); then
  echo "Android emulator reported invalid display dimensions: $screen_size"
  exit 1
fi
tap_x=$((screen_width * 7 / 8))
tap_y=$((screen_height / 2))
echo "Attempting to dismiss any first-run system prompt at $tap_x,$tap_y on ${screen_width}x${screen_height} display."
# Dismissing the Android first-run prompt is best-effort.
if ! adb shell input tap "$tap_x" "$tap_y"; then
  echo "WARNING: emulator rejected the optional first-run prompt tap; continuing with process verification."
fi
sleep 5

capture_failure_diagnostics() {
  local reason="$1"
  echo "ERROR: $reason" >&2
  {
    echo "=== Failure reason ==="
    echo "$reason"
    echo
    echo "=== adb devices -l ==="
    adb devices -l || true
    echo
    echo "=== adb get-state ==="
    adb get-state || true
    echo
    echo "=== Game process ==="
    adb shell pidof "$package_name" || true
    echo
    echo "=== Full Android logcat ==="
    adb logcat -d -v brief || true
    echo
    echo "=== Activity state ==="
    adb shell dumpsys activity activities || true
  } > build/emulator-diagnostics-on-failure.txt 2>&1 || true
}

# adb can briefly return 255 while the emulator transport is reconnecting.
# Retry process discovery, but do not turn a missing game process into success.
app_pid=""
for attempt in 1 2 3 4 5; do
  app_pid="$(adb shell pidof "$package_name" 2>/dev/null | tr -d '\r' | awk '{ print $1 }' || true)"
  if [[ -n "$app_pid" ]]; then
    break
  fi
  echo "Game process not visible through adb yet (attempt $attempt/5)."
  sleep 2
done
if [[ -z "$app_pid" ]]; then
  capture_failure_diagnostics "The game process was not found after five adb checks."
  exit 1
fi
printf '%s\n' "$app_pid" > build/emulator-app-pid.txt

if ! adb shell dumpsys activity activities > build/emulator-activities.txt; then
  capture_failure_diagnostics "Could not read Android activity state after launch."
  exit 1
fi
if ! adb shell dumpsys meminfo "$package_name" > build/emulator-meminfo.txt; then
  capture_failure_diagnostics "Could not read Android process memory after launch."
  exit 1
fi
if ! adb shell screencap -p /sdcard/gta-ghibli-smoke.png; then
  capture_failure_diagnostics "Android screenshot capture command failed."
  exit 1
fi
if ! adb pull /sdcard/gta-ghibli-smoke.png build/emulator-screenshot.png; then
  capture_failure_diagnostics "Could not pull the emulator screenshot."
  exit 1
fi
if ! adb logcat -d --pid="$app_pid" -v brief > build/emulator-logcat.txt; then
  capture_failure_diagnostics "Could not collect the game process logcat."
  exit 1
fi
# Preserve system logs too: immersive-mode UI belongs to SystemUI, not the app PID.
if ! adb logcat -d -v brief > build/emulator-logcat-full.txt; then
  capture_failure_diagnostics "Could not collect the full Android logcat."
  exit 1
fi

if grep -Eiq 'FATAL EXCEPTION|SIGSEGV|Fatal signal' build/emulator-logcat.txt; then
  capture_failure_diagnostics "Android logcat contains a fatal game-process error."
  exit 1
fi
if [[ ! -s build/emulator-screenshot.png ]]; then
  capture_failure_diagnostics "Android emulator screenshot is missing or empty."
  exit 1
fi
read -r png_width png_height < <(od -An -t u4 -j 16 -N 8 --endian=big build/emulator-screenshot.png)
if (( png_width < 1 || png_height < 1 )); then
  capture_failure_diagnostics "Android emulator screenshot has invalid PNG dimensions: ${png_width}x${png_height}"
  exit 1
fi

# Confirm the process still exists after evidence collection.
final_pid="$(adb shell pidof "$package_name" 2>/dev/null | tr -d '\r' | awk '{ print $1 }' || true)"
if [[ -z "$final_pid" ]]; then
  capture_failure_diagnostics "The game process exited before the smoke test finished."
  exit 1
fi

echo "Screenshot verified: ${png_width}x${png_height} pixels."
echo "PASS: APK installed, launched, remained alive, and produced a valid screenshot plus app/system runtime evidence."
