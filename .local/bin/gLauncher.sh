#!/bin/bash
#
# steam-launcher.sh — pick & launch Steam games with rofi + cover art
# Inspired by Michael’s wallswitcher.sh
#

# ── dependencies ──────────────────────────────────────────────────────────────
for app in rofi grep sed awk xdg-open magick; do
  command -v "$app" &>/dev/null || {
    dunstify "Missing package" "Please install: $app" -u critical
    exit 1
  }
done

# ── paths & theme ─────────────────────────────────────────────────────────────
STEAM_ROOT="$HOME/.local/share/Steam"
LIB_CACHE="$STEAM_ROOT/appcache/librarycache"         # cover art folders
ROFI_THEME="$HOME/.config/rofi/gLauncher.rasi"        # your uploaded theme
CACHE_DIR="$HOME/.config/rofi/cache/steam_thumbnails" # square thumbnails
mkdir -p "$CACHE_DIR"

# ── create (or fetch) a 500×500 png thumbnail ────────────────────────────────
create_icon() {
  local id="$1" src dst
  dst="$CACHE_DIR/${id}.png"

  # already converted?
  [[ -s $dst ]] && {
    printf '%s' "$dst"
    return
  }

  # 1 — flat layout
  if [[ -f "$LIB_CACHE/${id}/library_600x900.jpg" ]]; then
    src="$LIB_CACHE/${id}/library_600x900.jpg"

  # 2 — hashed sub-folder layout
  else
    shopt -s nullglob
    for f in "$LIB_CACHE/${id}"/*/library_600x900.jpg; do
      src="$f"
      break
    done
    shopt -u nullglob
  fi

  # fallback
  [[ -z $src ]] && return 1

  # convert and remove metadata
  magick "$src" \
    -strip "$dst" || return 1

  printf '%s' "$dst"
}

# ── locate every Steam library folder ────────────────────────────────────────
declare -a LIB_DIRS
LIB_DIRS+=("$STEAM_ROOT/steamapps") # default library

lf="$STEAM_ROOT/steamapps/libraryfolders.vdf"
if [[ -f "$lf" ]]; then
  while read -r p; do LIB_DIRS+=("$p/steamapps"); done \
    < <(grep -Po '"path"\s+"?\K[^"]+' "$lf")
fi

# ── collect installed games (IDS[] NAMES[] ICONS[]) ──────────────────────────
declare -a IDS NAMES ICONS

for dir in "${LIB_DIRS[@]}"; do
  [[ -d "$dir" ]] || continue
  while IFS= read -r acf; do
    id=$(grep -Po '"appid"\s+"?\K[0-9]+' "$acf" | head -n1)
    name=$(grep -Po '"name"\s+"?\K[^"]+' "$acf" | head -n1)
    [[ -z $id || -z $name ]] && continue
    icon=$(create_icon "$id") || continue

    IDS+=("$id") NAMES+=("$name") ICONS+=("$icon")
  done < <(find "$dir" -maxdepth 1 -type f -name '*.acf' 2>/dev/null)
done

((${#IDS[@]})) || {
  dunstify "Steam launcher" "No games found."
  exit 0
}

# ── sort games alphabetically (case-insensitive) ─────────────────────────────
readarray -t ORDER < <(
  for i in "${!NAMES[@]}"; do
    printf '%s\t%d\n' "${NAMES[$i],,}" "$i"
  done | sort -k1,1f | cut -f2
)

# ── build the rofi list in that order ────────────────────────────────────────
list=""
for i in "${ORDER[@]}"; do
  list+="${NAMES[$i]}\0icon\x1f${ICONS[$i]}\n"
done

# ── show rofi and capture the row number the user clicks on ──────────────────
sel=$(printf "%b" "$list" | rofi -dmenu -i -format i -p "Search..." -theme "$ROFI_THEME")
[[ $sel =~ ^[0-9]+$ ]] || exit 0

# rofi returns the row number in the *sorted* list; map it back
idx=${ORDER[$sel]}

# ── launch the chosen game ───────────────────────────────────────────────────
xdg-open "steam://rungameid/${IDS[$idx]}" &>/dev/null &
