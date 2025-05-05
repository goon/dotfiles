#!/bin/bash

# === Check Dependencies ===
for app in imagemagick; do
  if ! pacman -Q $app >/dev/null 2>&1; then
    dunstify "Missing package" "Please install the $app package to continue" -u critical
    exit 1
  fi
done

# === Config Paths ===
WALL_DIR="$HOME/Pictures/"
CACHE_DIR="$HOME/.config/rofi/cache/wallselect_icons/"
TRACKING_FILE="$HOME/.config/rofi/cache/Trackers/wallTracker.txt"
ROFI_THEME="$HOME/.config/rofi/wallselect.rasi"

# === Ensure Directories Exist ===
mkdir -p "$CACHE_DIR"
mkdir -p "$(dirname "$TRACKING_FILE")"

# === Get Monitor Resolution & Scale ===
MONITOR_RES=$(hyprctl monitors | grep -m1 "res: " | awk '{print $4}' | cut -d 'x' -f1)
MONITOR_SCALE=$(hyprctl monitors | grep -m1 "scale: " | awk '{print $2}')
MONITOR_RES=$((MONITOR_RES * 17 / MONITOR_SCALE))

# === Rofi Theme Settings ===
ROFI_EXECUTE="rofi -dmenu -theme ${ROFI_THEME} -theme-str ${ROFI_OVERRIDE}"

# === Generate Rofi Menu ===
SELECTION=$(find "$WALL_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) |
  shuf | head -n 30 | while read -r image; do
  [ -e "$image" ] || continue
  A=$(basename "$image")
  ICON_NAME="${A%.*}.png"

  # Generate icon if missing
  if [ ! -f "${CACHE_DIR}/${ICON_NAME}" ]; then
    magick "$image" -resize 500x500^ -gravity center -extent 500x500 "${CACHE_DIR}/${ICON_NAME}"
  fi

  echo -en "$A\x00icon\x1f${CACHE_DIR}/${ICON_NAME}\n"
done | $ROFI_EXECUTE)

# === Set Selected Wallpaper ===
if [ -n "$SELECTION" ]; then
  SELECTED_IMAGE="${WALL_DIR}/${SELECTION}"
  echo "$SELECTED_IMAGE" >"$TRACKING_FILE"
  swww img "$SELECTED_IMAGE" \
    --transition-bezier .43,1.19,1,.4 \
    --transition-fps 144 \
    --transition-type grow \
    --transition-duration 1 \
    --transition-pos 0.680,1
fi
