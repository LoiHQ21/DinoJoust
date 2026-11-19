#!/usr/bin/env bash
set -euo pipefail

apk=builds/android/Crownfall-Playtest.apk
package=org.crownfall.joust.playtest.duel
adb install -r "$apk"
mkdir -p builds/android/screens
adb shell settings put secure immersive_mode_confirmations confirmed
adb shell wm size 720x1280
adb shell wm density 240
adb logcat -c
activity=$(adb shell cmd package resolve-activity --brief -a android.intent.action.MAIN -c android.intent.category.LAUNCHER "$package" | tail -1 | tr -d '\r')
adb shell am start -W -n "$activity"

# Read the actual rendered HUD, then tap the same control a phone user sees.
wait_for_label() {
  local label=$1
  local screen="builds/android/screens/$2.png"
  local region=$3
  echo "Waiting for $label"
  for attempt in {1..40}; do
    adb exec-out screencap -p > "$screen"
    convert "$screen" -crop "$region" +repage "$RUNNER_TEMP/crownfall-button.png"
    if tesseract "$RUNNER_TEMP/crownfall-button.png" stdout --psm 7 2>/dev/null | grep -iq "$label"; then
      return 0
    fi
    sleep 2
  done
  adb logcat -d -s godot AndroidRuntime
  return 1
}
wait_for_label 'Enter the lists' lists 305x44+82+534
adb shell input tap 242 556
# The left and right gestures both start away from the shield and old fixed pad.
adb shell input swipe 345 425 345 370 450
aim_from_right() {
  adb shell 'input motionevent DOWN 1070 510 && input motionevent MOVE 1070 480'
}
aim_from_right
adb exec-out screencap -p > builds/android/screens/riding.png
wait_for_label 'Next pass' result 245x45+436+547
adb shell input motionevent UP 1070 480
adb shell input tap 548 569
aim_from_right
wait_for_label 'Ride again' finish 245x45+436+547
adb shell input motionevent UP 1070 480
adb shell pidof "$package"
