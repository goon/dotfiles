#!/bin/bash

for app in imagemagick; do
  if ! pacman -Q $app >/dev/null 2>&1; then
    dunstify "Missing package" "Please install the $app package to continue" -u critical
    exit 1
  fi
done

# Set some variables
WALL_DIR="/home/michael/Pictures/"
CACHE_DIR="$HOME/.config/rofi/cache/wallselect_icons/"
ROFI_EXECUTE="rofi -dmenu -theme ${HOME}/.config/rofi/wallselect.rasi -theme-str ${ROFI_OVERRIDE}"
TRACKING_FILE="$HOME/.config/rofi/cache/Trackers/wallTracker.txt"
ROFI_DIR="$HOME/.config/rofi/cache/menu_icon/rofi.png"
LOCKSCREEN_DIR="$HOME/.config/rofi/cache/lockscreen_images/lock.png"
WALLPAPER_CACHE="$HOME/.config/rofi/cache/wallpaper_icon"
MOITOR_RES=$(hyprctl monitors | grep -m1 "res: " | awk '{print $4}' | cut -d 'x' -f1)
MONITOR_SCALE=$(hyprctl monitors | grep -m1 "scale: " | awk '{print $2}')
MOITOR_RES=$((MOITOR_RES * 17 / MONITOR_SCALE))
ROFI_OVERRIDE="element-icon{size:${MOITOR_RES}px;border-radius:0px;}"

# Create cache dir if not exists
if [ ! -d "${CACHE_DIR}" ]; then
  mkdir -p "${CACHE_DIR}"
fi

# Convert images in directory and save to cache dir
for image in "$WALL_DIR"/*.{jpg,jpeg,png,webp}; do
  [ -f "$image" ] || continue
  rofi_icon=$(basename "$image")
  [ -f "${CACHE_DIR}/${rofi_icon}" ] || magick "$image" -resize 500x500^ -gravity center -extent 500x500 "${CACHE_DIR}/${rofi_icon}"
done

# Launch rofi
SELECTION=$(find "${WALL_DIR}" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) -exec basename {} \; | sort | while read -r A; do echo -en "$A\x00icon\x1f""${CACHE_DIR}"/"$A\n"; done | $ROFI_EXECUTE)
BASENAME=$(basename "$SELECTION")

if [[ -n "$SELECTION" ]]; then

  # Set wallpaper
  swww query || swww init

  # Save the current wallpaper name
  echo "$BASENAME" >"$TRACKING_FILE"

  # Change the wallpaper using swww with the specified transition parameters
  if swww img "${WALL_DIR}${BASENAME}" --transition-bezier .43,1.19,1,.4 --transition-fps 144 \
    --transition-type grow --transition-duration 1 --transition-pos 0.680,1; then
    magick "${WALL_DIR}${BASENAME}" -resize 500x500^ -gravity center -extent 500x500 \
      "$WALLPAPER_CACHE/wall.png"
  fi

  # Update rofi_icon and lockscreen wallpaper
  cp "${WALL_DIR}${BASENAME}" "$ROFI_DIR"
  cp "${WALL_DIR}${BASENAME}" "$LOCKSCREEN_DIR"
else
  echo "No selection made in Rofi."
fi
