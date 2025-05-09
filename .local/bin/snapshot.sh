#!/usr/bin/env bash
# snapshot.sh  –  area (default)  |  screen  |  output  |  active
set -euo pipefail

# 1️⃣ what to grab ────────────────────────────────────────────────
mode="${1:-area}" # Print → area     Super+Print → screen
case "$mode" in
area | screen | output | active) ;;
*)
  echo "Usage: $0  [area|screen|output|active]" >&2
  exit 1
  ;;
esac

# 2️⃣ file-name & folder ─────────────────────────────────────────
dir="$HOME/Pictures/Screenshots"
mkdir -p "$dir"
path="$dir/GB-$(date +%F-%H-%M-%S).png"

# 3️⃣ shoot ──────────────────────────────────────────────────────
export GRIMBLAST_HIDE_CURSOR=1 # only hides the cross-hair
grimblast --freeze copysave "$mode" "$path"

# 4️⃣ clipboard + desktop notification ───────────────────────────
command -v wl-copy >/dev/null && wl-copy <"$path" || true

notify-send "Screenshot Captured!" "${path##*/}" -i "$path" -t 7000 \
  --action="scriptAction:-xdg-open $(dirname "$path")=Open Directory" \
  --action="scriptAction:-xdg-open \"$path\"=Open Screenshot"
