#!/usr/bin/env bash
set -euo pipefail

apk=builds/android/Crownfall-Playtest.apk
package=org.crownfall.joust.playtest
adb install -r "$apk"
adb shell wm size 720x1280
adb shell wm density 240
adb logcat -c
activity=$(adb shell cmd package resolve-activity --brief -a android.intent.action.MAIN -c android.intent.category.LAUNCHER "$package" | tail -1 | tr -d '\r')
adb shell am start -W -n "$activity"

# Read the actual rendered HUD, then tap the same control a phone user sees.
wait_for_label() {
  local label=$1
  for attempt in {1..40}; do
    adb exec-out screencap -p > "$RUNNER_TEMP/crownfall-screen.png"
    if tesseract "$RUNNER_TEMP/crownfall-screen.png" stdout 2>/dev/null | grep -iq "$label"; then
      return 0
    fi
    sleep 2
  done
  adb logcat -d -s godot AndroidRuntime
  return 1
}
wait_for_label 'Enter the lists'
adb shell input tap 242 556
wait_for_label 'Next pass'
adb shell pidof "$package"
