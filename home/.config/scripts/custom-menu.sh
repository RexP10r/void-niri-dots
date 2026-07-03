#!/usr/bin/env bash
set -euo pipefail

ROFI_CMD="rofi -config ~/.config/rofi/default/config.rasi -dmenu -i -p"
WALLPAPER_DIR="$HOME/.config/wallpapers"
BGSELECTOR="$HOME/.config/scripts/bgselect.sh"
ROUNDING_SCRIPT="$HOME/.config/scripts/window-rounding.sh"
GAPS_SCRIPT="$HOME/.config/scripts/window-gaps.sh"
OPACITY_SCRIPT="$HOME/.config/scripts/terminal-opacity.sh"

THEMES=("Catppuccin" "Nord" "Everforest" "Gruvbox" "Osaka")

show_menu() {
    local prompt="$1"
    shift
    printf '%s\n' "$@" | $ROFI_CMD "$prompt"
}

main_menu() {
    local choice
    choice=$(show_menu "Settings" "Window rounding" "Change wallpaper" "Terminal opacity" "Window gaps")
    
    case "$choice" in
        "Window rounding") window_rounding_menu ;;
        "Window gaps") window_gaps_menu ;;
        "Change wallpaper") wallpaper_theme_menu ;;
		"Terminal opacity") terminal_opacity_menu ;;
        "") exit 0 ;;
    esac
}

window_rounding_menu() {
    local choice
    choice=$(show_menu "Window rounding" "On (8px)" "Off (0px)" "Custom" "Back to main menu")
    
    case "$choice" in
        "On (8px)")
			"$ROUNDING_SCRIPT" 8
            ;;
        "Off (0px)")
			"$ROUNDING_SCRIPT" 0
            ;;
        "Custom")
            local custom
            custom=$(echo "" | rofi -config ~/.config/rofi/default/config.rasi -dmenu -p "Enter radius value")
            if [[ -n "$custom" && "$custom" =~ ^[0-9]+$ ]]; then
                "$ROUNDING_SCRIPT" "$custom"
            fi
            ;;
        ""|"Back to main menu") main_menu ;;
    esac
}

terminal_opacity_menu() {
    local choice
    choice=$(show_menu "Terminal opacity" "100%" "90%" "80%" "Custom" "Back to main menu")
    
    case "$choice" in
        "100%")
			"$OPACITY_SCRIPT" 100
            ;;
        "90%")
			"$OPACITY_SCRIPT" 90
            ;;
        "80%")
			"$OPACITY_SCRIPT" 80
            ;;
        "Custom")
            local custom
            custom=$(echo "" | rofi -config ~/.config/rofi/default/config.rasi -dmenu -p "Enter opacity percentage (0-100)")
            if [[ -n "$custom" && "$custom" =~ ^[0-9]+$ && "$custom" -ge 0 && "$custom" -le 100 ]]; then
				"$OPACITY_SCRIPT" "$custom"
            fi
            ;;
        ""|"Back to main menu") main_menu ;;
    esac
}

wallpaper_theme_menu() {
    local choice
    choice=$(show_menu "Select theme" "${THEMES[@]}" "Back to main menu")

	[[ -z "$choice" ]] && exit 0
    
    local theme_lower="${choice,,}"
    
    case "$choice" in
		# TODO
        "random")
            "$BGSELECTOR" --wall-dir "$WALLPAPER_DIR"
            ;;
        ""|"Back to main menu") main_menu ;;
        *) "$BGSELECTOR" --wall-dir "$WALLPAPER_DIR/$theme_lower" ;;
    esac
}

window_gaps_menu() {
    local choice
    choice=$(show_menu "Window gaps" "16 (Niri 32)" "8 (Niri 16)" "4 (Niri 8)" "0 (Niri 0)" "Custom" "Back to main menu")
    
    case "$choice" in
        "16 (Niri 32)")
            "$GAPS_SCRIPT" 16
            ;;
        "8 (Niri 16)")
            "$GAPS_SCRIPT" 8
            ;;
        "4 (Niri 8)")
            "$GAPS_SCRIPT" 4
            ;;
        "0 (Niri 0)")
            "$GAPS_SCRIPT" 0
            ;;
        "Custom")
            local custom
            custom=$(echo "" | rofi -dmenu -p "Enter Waybar gap value")
            if [[ -n "$custom" && "$custom" =~ ^[0-9]+$ ]]; then
				"$GAPS_SCRIPT" "$custom"
            fi
            ;;
        ""|"Back to main menu") main_menu ;;
    esac
}

# --- Main Execution ---
main_menu
