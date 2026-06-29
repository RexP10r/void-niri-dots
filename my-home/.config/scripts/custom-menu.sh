#!/usr/bin/env bash
set -euo pipefail

# Configuration
ROFI_CMD="rofi -config ~/.config/rofi/default/config.rasi -dmenu -i -p"
WALLPAPER_DIR="$HOME/.config/wallpapers"
BGSELECTOR="$HOME/.config/scripts/bgselect.sh"

THEMES=("Catppuccin" "Nord" "Everforest" "Gruvbox", "Osaka")

# --- Menu Functions ---

show_menu() {
    local prompt="$1"
    shift
    printf '%s\n' "$@" | $ROFI_CMD "$prompt"
}

main_menu() {
    local choice
    choice=$(show_menu "Settings" "Window rounding" "Change wallpaper")
    
    case "$choice" in
        "Window rounding") window_rounding_menu ;;
        "Change wallpaper") wallpaper_theme_menu ;;
        "") exit 0 ;;
    esac
}

window_rounding_menu() {
    local choice
    choice=$(show_menu "Window rounding" "On (8px)" "Off (0px)" "Custom")
    
    case "$choice" in
        "On (8px)")
            "$HOME/.config/scripts/rounding.sh" 8
            ;;
        "Off (0px)")
            "$HOME/.config/scripts/rounding.sh" 0
            ;;
        "Custom")
            local custom
            custom=$(echo "" | rofi -dmenu -p "Enter radius value")
            if [[ -n "$custom" && "$custom" =~ ^[0-9]+$ ]]; then
                "$HOME/.config/scripts/rounding.sh" "$custom"
            fi
            ;;
        "") main_menu ;;
    esac
}

wallpaper_theme_menu() {
    local choice
    choice=$(show_menu "Select theme" "${THEMES[@]}")

	[[ -z "$choice" ]] && exit 0
    
    local theme_lower="${choice,,}"
    
    case "$choice" in
        "random")
            "$BGSELECTOR" --wall-dir "$WALLPAPER_DIR"
            ;;
        "") exit 0 ;;
        *) wallpaper_variation_menu "$theme_lower" ;;
    esac
}

wallpaper_variation_menu() {
    local theme="$1"
    local choice
    choice=$(show_menu "$theme variation" "Dark" "Light")
    
    case "$choice" in
        "Dark")
            local path="$WALLPAPER_DIR/$theme/dark"
            if [[ -d "$path" ]]; then
                "$BGSELECTOR" --wall-dir "$path"
            else
                notify-send "Error" "Directory not found: $path"
            fi
            ;;
        "Light")
            local path="$WALLPAPER_DIR/$theme/light"
            if [[ -d "$path" ]]; then
                "$BGSELECTOR" --wall-dir "$path"
            else
                notify-send "Error" "Directory not found: $path"
            fi
            ;;
        "") wallpaper_theme_menu ;;
    esac
}

# --- Main Execution ---
main_menu
