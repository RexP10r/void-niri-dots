#!/usr/bin/env bash
set -euo pipefail

if ! command -v wallust &>/dev/null; then
    export PATH="$HOME/.cargo/bin:$PATH"
fi

FORCE=false
WALL_PATH=""
while [[ $# -gt 0 ]]; do
	case $1 in
		--wall-path) WALL_PATH="$2"; shift 2 ;;
		--force) FORCE=true; shift ;;
		*) shift ;;
	esac
done

log_info()  { echo -e "\033[1;34m[$(date '+%Y-%m-%d %H:%M:%S')] INFO: $*\033[0m" >&2; }
log_error() { echo -e "\033[1;31m[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $*\033[0m" >&2; }
log_success(){ echo -e "\033[1;32m[$(date '+%Y-%m-%d %H:%M:%S')] SUCCESS: $*\033[0m" >&2; }
log_warn()  { echo -e "\033[1;33m[$(date '+%Y-%m-%d %H:%M:%S')] WARN: $*\033[0m" >&2; }
die() { log_error "$*"; exit 1; }

readonly NIRI_CFG="$HOME/.config/niri/config.kdl"
readonly THEME_STATE_FILE="$HOME/.cache/theme-sync-state"

validate_deps() {
  local missing=()
  for cmd in "$@"; do
    command -v "$cmd" >/dev/null 2>&1 || missing+=("$cmd")
  done
  [[ ${#missing[@]} -eq 0 ]] || die "Missing dependencies: ${missing[*]}"
}

get_current_wallpaper() {
  if [[ -n "$WALL_PATH" && -f "$WALL_PATH" ]]; then
    echo "$WALL_PATH"
    return 0
  fi
  local output
  output=$(swww query 2>/dev/null) || true
  [[ -z "$output" ]] && return 1
  echo "$output" | sed -n 's/.*image: //p' | head -n1 | tr -d '\r\n'
}

detect_theme_from_wallpaper() {
  local wallpaper_path="$1"
  [[ -f "$wallpaper_path" ]] || die "Wallpaper not found: $wallpaper_path"

  local theme_dir parent_dir theme_name variation
  theme_dir=$(dirname "$wallpaper_path")
  parent_dir=$(dirname "$theme_dir")

  theme_name=$(basename "$parent_dir" | tr '[:upper:]' '[:lower:]')
  variation=$(basename "$theme_dir" | tr '[:upper:]' '[:lower:]')

  # Handle flat directories
  if [[ "$theme_name" == ".config" || "$theme_name" == "pictures" || "$variation" == "wallpapers" ]]; then
    theme_name="random"
    variation="dark"
  fi

  WALLPAPER_PATH="$wallpaper_path"
  WALLPAPER_VARIATION="$variation"
  DETECTED_THEME="$theme_name"
}

check_theme_changed() {
  mkdir -p "$(dirname "$THEME_STATE_FILE")"
  [[ ! -f "$THEME_STATE_FILE" ]] && return 0

  local previous_theme previous_variation
  read -r previous_theme previous_variation < "$THEME_STATE_FILE"

  [[ "$1" == "$previous_theme" && "$2" == "$previous_variation" ]] && return 1
  return 0
}

save_theme_state() {
  mkdir -p "$(dirname "$THEME_STATE_FILE")"
  echo "$1 $2" > "$THEME_STATE_FILE"
}

map_to_wallust_theme() {
  case "$1" in
    "catppuccin")  [[ "$2" == "light" ]] && echo "Catppuccin-Latte" || echo "Catppuccin-Mocha" ;;
    "everforest")  [[ "$2" == "light" ]] && echo "Everforest-Light-Medium" || echo "Everforest-Dark-Medium" ;;
    "gruvbox")     [[ "$2" == "light" ]] && echo "Gruvbox" || echo "Gruvbox-Dark" ;;
    "nord")        [[ "$2" == "light" ]] && echo "Nord-Light" || echo "Nord" ;;
    "solarized")   [[ "$2" == "light" ]] && echo "Solarized-Light" || echo "Solarized-Dark" ;;
    "tokyo-night") [[ "$2" == "light" ]] && echo "Tokyo-Night-Light" || echo "Tokyo-Night" ;;
    *) echo "random" ;;
  esac
}

run_wallust() {
  local wallust_theme="$1" wallpaper_path="$2"
  
  if [[ "$wallust_theme" == "random" ]]; then
    log_info "Generating colors from wallpaper..."
    wallust run "$wallpaper_path" 2>&1
  else
    log_info "Applying theme: $wallust_theme"
    if ! wallust theme "$wallust_theme" 2>&1; then
      log_warn "Theme failed, falling back to auto-generation..."
      wallust run "$wallpaper_path" 2>&1
    fi
  fi
  log_success "Colors generated"
}

reload_alacritty() {
  if pgrep -x alacritty > /dev/null; then
    touch ~/.config/alacritty/alacritty.toml
    log_success "Alacritty reloaded"
  fi
}

_get_wallust_color() {
  local file="$1" key="$2"
  local color
  color=$(jq -r ".\"$key\" // empty" "$file" 2>/dev/null)
  [[ -z "$color" || ! "$color" =~ ^#[0-9a-fA-F]{6}$ ]] && return 1
  echo "$color"
}

update_niri_config() {
  local palette_file="$HOME/.cache/wallust/colors.json"
  [[ ! -f "$palette_file" ]] && return 0

  local urgent_color focus_color insert_color border_color background_color
  urgent_color=$(_get_wallust_color "$palette_file" "color6") || true
  focus_color=$(_get_wallust_color "$palette_file" "color5") || true
  insert_color=$(_get_wallust_color "$palette_file" "color4") || true
  border_color=$(_get_wallust_color "$palette_file" "color3") || true
  background_color=$(jq -r '.special.background // empty' "$palette_file" 2>/dev/null)

  [[ -n "$focus_color" ]] && sed -i "/border {/,/}/ s/active-color \".*\"/active-color \"$focus_color\"/" "$NIRI_CFG"
  [[ -n "$border_color" ]] && sed -i "/border {/,/}/ s/inactive-color \".*\"/inactive-color \"$border_color\"/" "$NIRI_CFG"
  [[ -n "$urgent_color" ]] && sed -i "/border {/,/}/ s/urgent-color \"[^\"]*\"/urgent-color \"$urgent_color\"/" "$NIRI_CFG"
  [[ -n "$insert_color" ]] && sed -i "/insert-hint {/,/}/ s/color \".*\"/color \"$insert_color\"/" "$NIRI_CFG"
  [[ -n "$background_color" ]] && sed -i "/focus-ring {/,/}/ s/active-color \".*\"/active-color \"$background_color\"/" "$NIRI_CFG"

  log_success "Niri config updated"
}

send_notification() {
  command -v notify-send >/dev/null 2>&1 && \
    notify-send -t 2000 -u low "Theme Synced" "Colors updated" 2>/dev/null || true
}

main() {
  log_info "Starting theme sync..."
  validate_deps "swww" "wallust" "jq"

  local wp
  wp=$(get_current_wallpaper)
  [[ -z "$wp" ]] && die "Could not detect wallpaper. Is swww-daemon running?"
  [[ -f "$wp" ]] || die "Wallpaper not found: $wp"

  log_info "Wallpaper: $wp"

  detect_theme_from_wallpaper "$wp"
  local detected_theme="${DETECTED_THEME:-random}"
  local wallpaper_variation="${WALLPAPER_VARIATION:-dark}"

  log_info "Theme: $detected_theme ($wallpaper_variation)"

  local theme_changed=0
  if [[ "$FORCE" == true ]] || check_theme_changed "$detected_theme" "$wallpaper_variation"; then
    theme_changed=1
  fi

  local wallust_theme
  wallust_theme=$(map_to_wallust_theme "$detected_theme" "$wallpaper_variation")

  if [[ $theme_changed -eq 1 ]]; then
    run_wallust "$wallust_theme" "$wp"
    reload_alacritty
    update_niri_config
    save_theme_state "$detected_theme" "$wallpaper_variation"
    send_notification
    log_success "Theme sync complete"
  else
    log_info "Theme unchanged, skipping updates"
    run_wallust "$wallust_theme" "$wp"
    reload_alacritty
    update_niri_config
    send_notification
    log_success "Theme sync complete (no change)"
  fi
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main "$@"
