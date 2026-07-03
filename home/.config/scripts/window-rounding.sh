#!/usr/bin/env bash
set -euo pipefail

NIRI_CFG="$HOME/.config/niri/config.kdl"
WAYBAR_CFG="$HOME/.config/waybar/style.css"
GAPS_SCRIPT="$HOME/.config/scripts/window-gaps.sh"
VALUE="${1:-8}"

if [[ "$VALUE" != 0 ]]; then
	"$GAPS_SCRIPT"
fi

sed -i "0,/geometry-corner-radius [0-9]\+/s/geometry-corner-radius [0-9]\+/geometry-corner-radius $VALUE/" "$NIRI_CFG"
sed -i "0,/border-radius: [0-9]\+\(px\)\?;/s/border-radius: [0-9]\+\(px\)\?;/border-radius: ${VALUE}px;/" "$WAYBAR_CFG"

niri msg action do-reload-config 2>/dev/null || true
