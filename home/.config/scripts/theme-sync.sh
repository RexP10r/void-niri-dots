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
readonly BTOP_DIR="$HOME/.config/btop"
readonly OBSIDIAN_APPEARANCE="$HOME/shaitan/knowledge/.obsidian/appearance.json"

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

  local theme_dir theme_name
  theme_dir=$(dirname "$wallpaper_path")
  theme_name=$(basename "$theme_dir" | tr '[:upper:]' '[:lower:]')

  # Handle generic parent directories (fallback to random theme)
  if [[ "$theme_name" == ".config" || "$theme_name" == "pictures" || "$theme_name" == "wallpapers" ]]; then
    theme_name="random"
  fi

  WALLPAPER_PATH="$wallpaper_path"
  DETECTED_THEME="$theme_name"
}

check_theme_changed() {
  mkdir -p "$(dirname "$THEME_STATE_FILE")"
  [[ ! -f "$THEME_STATE_FILE" ]] && return 0

  local previous_theme
  read -r previous_theme < "$THEME_STATE_FILE"

  [[ "$1" == "$previous_theme" ]] && return 1
  return 0
}

save_theme_state() {
  mkdir -p "$(dirname "$THEME_STATE_FILE")"
  echo "$1" > "$THEME_STATE_FILE"
}

map_to_wallust_theme() {
  case "$1" in
    "catppuccin")  echo "Catppuccin-Mocha" ;;
    "everforest")  echo "Everforest-Dark-Medium" ;;
    "gruvbox")     echo "Gruvbox-Dark" ;;
    "nord")        echo "Nord" ;;
    "solarized"|"osaka")   echo "Solarized-Dark" ;;
    "tokyo-night") echo "Tokyo-Night" ;;
    *) echo "random" ;;
  esac
}

map_to_btop_theme() {
  case "$1" in
    "catppuccin")  echo "catppuccin_mocha.theme" ;;
    "everforest")  echo "everforest-dark-medium.theme" ;;
    "gruvbox")     echo "gruvbox_dark.theme" ;;
    "nord")        echo "nord.theme" ;;
    "solarized"|"osaka")   echo "solarized_dark.theme" ;;
    "tokyo-night") echo "tokyo-night.theme" ;;
    *) echo "solarized_dark.theme" ;;
  esac
}

map_to_obsidian_theme() {
  case "$1" in
    "catppuccin")  echo "Catppuccin" ;;
    "everforest")  echo "Everforest Spruce" ;;
    "gruvbox")     echo "Obsidian gruvbox" ;;
    "nord")        echo "Obsidian Nord" ;;
    "solarized"|"osaka")   echo "Solarized" ;;
    "tokyo-night") echo "Tokyo Night" ;;
    *) echo "" ;;
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

update_btop_config() {
  local theme="$1"
  local btop_conf="$BTOP_DIR/btop.conf"
  [[ ! -f "$btop_conf" ]] && return 0

  local btop_theme
  btop_theme="$BTOP_DIR/themes/$(map_to_btop_theme "$theme")"
  
  sed -i "s|^color_theme = .*|color_theme = \"$btop_theme\"|" "$btop_conf"
  
  log_success "btop config updated to $btop_theme"
}

update_obsidian_theme() {
  local theme="$1"
  [[ ! -f "$OBSIDIAN_APPEARANCE" ]] && return 0

  local obsidian_theme
  obsidian_theme=$(map_to_obsidian_theme "$theme")
  
  if [[ -z "$obsidian_theme" ]]; then
    jq '.cssTheme = "" | .theme = "obsidian"' "$OBSIDIAN_APPEARANCE" > "${OBSIDIAN_APPEARANCE}.tmp" && \
      mv "${OBSIDIAN_APPEARANCE}.tmp" "$OBSIDIAN_APPEARANCE"
  else
    jq --arg theme "$obsidian_theme" '.cssTheme = $theme | .theme = "obsidian"' "$OBSIDIAN_APPEARANCE" > "${OBSIDIAN_APPEARANCE}.tmp" && \
      mv "${OBSIDIAN_APPEARANCE}.tmp" "$OBSIDIAN_APPEARANCE"
  fi
  
  log_success "Obsidian theme updated to: ${obsidian_theme:-default}"
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

  log_info "Theme: $detected_theme"

  local theme_changed=0
  if [[ "$FORCE" == true ]] || check_theme_changed "$detected_theme"; then
    theme_changed=1
  fi

  local wallust_theme
  wallust_theme=$(map_to_wallust_theme "$detected_theme")

  if [[ $theme_changed -eq 1 ]]; then
    run_wallust "$wallust_theme" "$wp"
    reload_alacritty
    save_theme_state "$detected_theme"
    update_btop_config "$detected_theme"
	update_obsidian_theme "$detected_theme"
    send_notification
    log_success "Theme sync complete"
  else
    log_info "Theme unchanged, skipping updates"
    run_wallust "$wallust_theme" "$wp"
    reload_alacritty
    update_btop_config "$detected_theme"
	update_obsidian_theme "$detected_theme"
    send_notification
    log_success "Theme sync complete (no change)"
  fi
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main "$@"
