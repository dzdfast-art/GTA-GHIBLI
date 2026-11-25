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
# The opening world is created at runtime; allow Android time to finish its first render.
sleep 20

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

# Reject Android system/application ANR overlays instead of treating them as a game screenshot.
if ! adb shell uiautomator dump /sdcard/gta-ghibli-ui.xml >/dev/null 2>&1; then
  capture_failure_diagnostics "Could not inspect the Android foreground UI hierarchy."
  exit 1
fi
if ! adb pull /sdcard/gta-ghibli-ui.xml build/emulator-ui-hierarchy.xml >/dev/null; then
  capture_failure_diagnostics "Could not retrieve the Android foreground UI hierarchy."
  exit 1
fi
if grep -Eiq "isn't responding|is not responding|Application Not Responding" build/emulator-ui-hierarchy.xml; then
  capture_failure_diagnostics "Android displayed a not-responding dialog; the captured frame is not valid gameplay evidence."
  exit 1
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
if ! grep -Eq "Resumed: ActivityRecord.*${package_name}" build/emulator-activities.txt; then
  capture_failure_diagnostics "The GTA GHIBLI activity is not the resumed foreground activity."
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

# Fail on a Vulkan presentation failure; process liveness alone is not a rendering test.
if grep -Eiq "Couldn't present to Vulkan queue|VK_ERROR_DEVICE_LOST|VK_ERROR_OUT_OF_DATE_KHR" build/emulator-logcat.txt; then
  capture_failure_diagnostics "Godot failed to present a Vulkan frame on the Android emulator."
  exit 1
fi
if ! grep -Eiq 'Vulkan .*Forward Mobile|OpenGL ES .*Compatibility' build/emulator-logcat.txt; then
  capture_failure_diagnostics "The game did not report a successfully initialized Android renderer."
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

# Decode the PNG and reject a black/near-black frame. The app must render the world,
# not merely stay alive and return a valid PNG header.
python3 - "$PWD/build/emulator-screenshot.png" <<'PY'
import struct
import sys
import zlib

path = sys.argv[1]
data = open(path, "rb").read()
if data[:8] != b"\x89PNG\r\n\x1a\n":
    raise SystemExit("FAIL: screenshot is not a PNG")
pos = 8
compressed = bytearray()
width = height = bit_depth = color_type = None
while pos < len(data):
    length = struct.unpack(">I", data[pos:pos + 4])[0]
    kind = data[pos + 4:pos + 8]
    payload = data[pos + 8:pos + 8 + length]
    pos += 12 + length
    if kind == b"IHDR":
        width, height, bit_depth, color_type, compression, filtering, interlace = struct.unpack(">IIBBBBB", payload)
        if bit_depth != 8 or color_type not in (2, 6) or interlace != 0:
            raise SystemExit(f"FAIL: unsupported screenshot PNG format: depth={bit_depth}, color={color_type}, interlace={interlace}")
    elif kind == b"IDAT":
        compressed.extend(payload)
    elif kind == b"IEND":
        break
if not width or not height:
    raise SystemExit("FAIL: screenshot PNG has no valid dimensions")
channels = 4 if color_type == 6 else 3
stride = width * channels
raw = zlib.decompress(compressed)
previous = bytearray(stride)
offset = 0
visible = 0
sum_luma = 0
sum_luma_sq = 0
pixels = width * height

def paeth(a, b, c):
    p = a + b - c
    pa, pb, pc = abs(p-a), abs(p-b), abs(p-c)
    return a if pa <= pb and pa <= pc else (b if pb <= pc else c)

for _ in range(height):
    filt = raw[offset]
    scan = raw[offset + 1:offset + 1 + stride]
    offset += stride + 1
    row = bytearray(stride)
    for i, value in enumerate(scan):
        left = row[i - channels] if i >= channels else 0
        up = previous[i]
        upper_left = previous[i - channels] if i >= channels else 0
        if filt == 0:
            predictor = 0
        elif filt == 1:
            predictor = left
        elif filt == 2:
            predictor = up
        elif filt == 3:
            predictor = (left + up) // 2
        elif filt == 4:
            predictor = paeth(left, up, upper_left)
        else:
            raise SystemExit(f"FAIL: unsupported PNG filter {filt}")
        row[i] = (value + predictor) & 255
    for i in range(0, stride, channels):
        r, g, b = row[i], row[i + 1], row[i + 2]
        luma = (r * 2126 + g * 7152 + b * 722) // 10000
        sum_luma += luma
        sum_luma_sq += luma * luma
        if luma > 22:
            visible += 1
    previous = row
mean = sum_luma / pixels
variance = max(0.0, sum_luma_sq / pixels - mean * mean)
ratio = visible / pixels
print(f"Rendered-frame analysis: {width}x{height}, visible_pixels={ratio:.1%}, luminance_stddev={variance ** 0.5:.1f}")
if ratio < 0.05 or variance ** 0.5 < 8.0:
    raise SystemExit("FAIL: Android screenshot is black/near-black; gameplay frame was not rendered")
PY

# Confirm the process remains alive after screenshot and log collection.
final_pid="$(adb shell pidof "$package_name" 2>/dev/null | tr -d '\r' | awk '{ print $1 }' || true)"
if [[ -z "$final_pid" ]]; then
  capture_failure_diagnostics "The game process exited before the smoke test finished."
  exit 1
fi

echo "Screenshot verified: $png_width x $png_height pixels."
echo "PASS: APK installed, immersive prompt dismissed, game process remained alive, and screenshot/runtime evidence collected."
