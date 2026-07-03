#!/usr/bin/env bash
set -euo pipefail

NIRI_CFG="$HOME/.config/niri/config.kdl"
WAYBAR_CFG="$HOME/.config/waybar/config.jsonc"
ROUNDING_SCRIPT="$HOME/.config/scripts/window-rounding.sh"

WAYBAR_GAPS="${1:-8}"
NIRI_GAPS=$((WAYBAR_GAPS * 2))

if [[ "$WAYBAR_GAPS" == 0 ]]; then
	"$ROUNDING_SCRIPT" 0
fi

sed -i "s/^\([[:space:]]*\)gaps [0-9]\+/\1gaps $NIRI_GAPS/" "$NIRI_CFG"

sed -i "s/\"margin-top\": [0-9]\+/\"margin-top\": $WAYBAR_GAPS/" "$WAYBAR_CFG"
sed -i "s/\"margin-left\": [0-9]\+/\"margin-left\": $WAYBAR_GAPS/" "$WAYBAR_CFG"
sed -i "s/\"margin-right\": [0-9]\+/\"margin-right\": $WAYBAR_GAPS/" "$WAYBAR_CFG"

niri msg action do-reload-config 2>/dev/null || true
pkill -SIGUSR2 waybar 2>/dev/null || true
