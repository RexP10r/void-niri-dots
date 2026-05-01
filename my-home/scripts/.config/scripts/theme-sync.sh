#!/usr/bin/env bash
set -euo pipefail

if ! command -v wallust &>/dev/null; then
    export PATH="$HOME/.cargo/bin:$PATH"
fi

while [[ $# -gt 0 ]]; do
	case $1 in
		--wall-path)
			WALL_PATH="$2"
			shift 2
			;;
		*)
			shift
			;;
	esac
done


log_info()  { echo -e "\033[1;34m[$(date '+%Y-%m-%d %H:%M:%S')] INFO: $*\033[0m" >&2; }
log_error() { echo -e "\033[1;31m[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $*\033[0m" >&2; }
log_success(){ echo -e "\033[1;32m[$(date '+%Y-%m-%d %H:%M:%S')] SUCCESS: $*\033[0m" >&2; }
log_warn()  { echo -e "\033[1;33m[$(date '+%Y-%m-%d %H:%M:%S')] WARN: $*\033[0m" >&2; }
die() { log_error "$*"; exit 1; }

readonly NIRI_CFG="$HOME/.config/niri/config.kdl"
readonly WALLUST_CACHE="$HOME/.cache/wallust"

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

run_wallust() {
  local -r wp="$1"
  log_info "Generating colors from: $(basename "$wp")"
  
  if wallust run "$wp" 2>&1; then
    log_success "Wallust generation complete"
    return 0
  else
    log_warn "Wallust failed to generate colors"
    return 1
  fi
}

reload_alacritty() {
  if pgrep -x alacritty > /dev/null; then
    log_info "Reloading Alacritty config..."
    touch ~/.config/alacritty/alacritty.toml
    log_success "Alacritty reloaded"
  else
    log_info "No running Alacritty instances found"
  fi
}

_get_wallust_color() {
  local file="$1" key="$2"
  local color=""

  color=$(jq -r ".\"$key\" // empty" "$file" 2>/dev/null)

  if [[ -z "$color" ]]; then
    color=$(grep -i "\"$key\"" "$file" 2>/dev/null | grep -o '#[0-9a-fA-F]\{6\}' | head -n1)
  fi

  if [[ -z "$color" || ! "$color" =~ ^#[0-9a-fA-F]{6}$ ]]; then
    return 1
  fi
  echo "$color"
}

update_niri_config() {
  local -r niri_config_file="$HOME/.config/niri/config.kdl"
  local -r palette_file="$HOME/.cache/wallust/colors.json"

  if [[ ! -f "$palette_file" ]]; then
    log_warn "Wallust color cache not found, skipping niri config update"
    return
  fi

  local urgent_color focus_color insert_color border_color
  urgent_color=$(_get_wallust_color "$palette_file" "color6") || { log_warn "Missing: color3"; return 1; }
  focus_color=$(_get_wallust_color "$palette_file" "color5") || { log_warn "Missing: color4"; return 1; }
  insert_color=$(_get_wallust_color "$palette_file" "color4") || { log_warn "Missing: color5"; return 1; }
  border_color=$(_get_wallust_color "$palette_file" "color3") || { log_warn "Missing: color6"; return 1; }

  sed -i "/border {/,/}/ s/active-color \".*\"/active-color \"$focus_color\"/" "$niri_config_file"
  sed -i "/border {/,/}/ s/inactive-color \".*\"/inactive-color \"$border_color\"/" "$niri_config_file"
  sed -i "/border {/,/}/ s/urgent-color \"[^\"]*\"/urgent-color \"$urgent_color\"/" "$niri_config_file"
  sed -i "/insert-hint {/,/}/ s/color \".*\"/color \"$insert_color\"/" "$niri_config_file"

  log_success "Niri config updated successfully"
}

send_notification() {
  command -v notify-send >/dev/null 2>&1 && \
    notify-send -t 2000 -u low "Theme Synced" "Colors updated from wallpaper" 2>/dev/null || true
}

main() {
  log_info "Starting theme sync..."
  validate_deps "swww" "wallust"

  local wp
  wp=$(get_current_wallpaper)
  if [[ -z "$wp" ]]; then
    die "Could not detect current wallpaper. Is swww-daemon running?"
  fi
  [[ -f "$wp" ]] || die "Wallpaper file not found: $wp"

  log_info "Wallpaper: $wp"

  run_wallust "$wp"
  reload_alacritty
  update_niri_config
  send_notification

  log_success "Theme synchronization complete"
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main "$@"
