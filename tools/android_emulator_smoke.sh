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
# Dismiss it so the retained screenshot records the game, not the OS dialog.
adb shell input tap 1680 516
sleep 5

app_pid="$(adb shell pidof "$package_name" | tr -d '\r' | awk '{ print $1 }')"
if [[ -z "$app_pid" ]]; then
  echo "The game process did not remain alive after launch."
  adb logcat -d -v brief > build/emulator-logcat-failure.txt
  exit 1
fi
printf '%s\n' "$app_pid" > build/emulator-app-pid.txt

adb shell dumpsys activity activities > build/emulator-activities.txt
adb shell dumpsys meminfo "$package_name" > build/emulator-meminfo.txt
adb shell screencap -p /sdcard/gta-ghibli-smoke.png
adb pull /sdcard/gta-ghibli-smoke.png build/emulator-screenshot.png
adb logcat -d --pid="$app_pid" -v brief > build/emulator-logcat.txt

if grep -Eiq 'FATAL EXCEPTION|SIGSEGV|Fatal signal' build/emulator-logcat.txt; then
  echo "Android emulator reported a fatal game-process error."
  exit 1
fi

if grep -Eiq 'Viewing full screen|To exit, swipe down' build/emulator-logcat.txt; then
  echo "Unexpected OS immersive-mode prompt remains in app log."
  exit 1
fi

echo "PASS: APK installed, launched, immersive-mode prompt dismissed, remained alive, and produced post-launch screenshot/runtime evidence."
