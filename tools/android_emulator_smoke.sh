#!/usr/bin/env bash
# Runs as one Bash process inside reactivecircus/android-emulator-runner.
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
    echo
    echo "=== Window state ==="
    adb shell dumpsys window windows || true
  } > build/emulator-diagnostics-on-failure.txt 2>&1 || true
}

# The immersive confirmation uses the current landscape framebuffer.
# wm size may still report portrait physical dimensions, so read a PNG first.
if adb shell dumpsys window windows 2>/dev/null | grep -q 'ImmersiveModeConfirmation'; then
  if ! adb shell screencap -p /sdcard/gta-ghibli-system-prompt.png; then
    capture_failure_diagnostics "Could not capture Android immersive-mode prompt."
    exit 1
  fi
  if ! adb pull /sdcard/gta-ghibli-system-prompt.png build/emulator-screenshot-initial.png; then
    capture_failure_diagnostics "Could not pull the initial Android prompt screenshot."
    exit 1
  fi
  read -r prompt_width prompt_height < <(od -An -t u4 -j 16 -N 8 --endian=big build/emulator-screenshot-initial.png)
  if (( prompt_width < 1 || prompt_height < 1 )); then
    capture_failure_diagnostics "Initial screenshot has invalid dimensions: $prompt_width x $prompt_height"
    exit 1
  fi
  # The landscape Android 15 prompt places the Got it button near 73%,48%.
  tap_x=$((prompt_width * 73 / 100))
  tap_y=$((prompt_height * 48 / 100))
  echo "Dismissing immersive confirmation at $tap_x,$tap_y on $prompt_width x $prompt_height framebuffer."
  if ! adb shell input tap "$tap_x" "$tap_y"; then
    echo "WARNING: Android rejected the prompt tap; verifying prompt state."
  fi
  sleep 3
fi

if ! adb shell dumpsys window windows > build/emulator-window-state.txt; then
  capture_failure_diagnostics "Could not read Android window state after attempting to dismiss the immersive prompt."
  exit 1
fi
if grep -q 'ImmersiveModeConfirmation' build/emulator-window-state.txt; then
  capture_failure_diagnostics "Android immersive-mode confirmation still covers the game screen."
  exit 1
fi

# adb can briefly return 255 while the emulator transport is reconnecting.
# Retry process discovery without turning a missing process into success.
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
if ! adb logcat -d -v brief > build/emulator-logcat-full.txt; then
  capture_failure_diagnostics "Could not collect the full Android logcat."
  exit 1
fi

# Reject the known GLES3 shader-limit error instead of accepting a bad render.
if grep -Eiq 'Fragment shader active uniforms exceed GL_MAX_FRAGMENT_UNIFORM_VECTORS|SceneShaderGLES3: Program linking failed' build/emulator-logcat.txt; then
  capture_failure_diagnostics "Godot emitted a GLES3 scene-shader compilation failure."
  exit 1
fi
if [[ ! -s build/emulator-screenshot.png ]]; then
  capture_failure_diagnostics "Android screenshot is missing or empty."
  exit 1
fi
read -r png_width png_height < <(od -An -t u4 -j 16 -N 8 --endian=big build/emulator-screenshot.png)
if (( png_width < 1 || png_height < 1 )); then
  capture_failure_diagnostics "Android screenshot has invalid dimensions: $png_width x $png_height"
  exit 1
fi

# Confirm the process remains alive after screenshot and log collection.
final_pid="$(adb shell pidof "$package_name" 2>/dev/null | tr -d '\r' | awk '{ print $1 }' || true)"
if [[ -z "$final_pid" ]]; then
  capture_failure_diagnostics "The game process exited before the smoke test finished."
  exit 1
fi

echo "Screenshot verified: $png_width x $png_height pixels."
echo "PASS: APK installed, immersive prompt dismissed, game process remained alive, and screenshot/runtime evidence collected."
