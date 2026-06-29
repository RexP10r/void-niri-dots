#!/usr/bin/env bash
set -euo pipefail

NIRI_CFG="$HOME/.config/niri/config.kdl"
VALUE="${1:-8}"

sed -i "0,/geometry-corner-radius [0-9]\+/s/geometry-corner-radius [0-9]\+/geometry-corner-radius $VALUE/" "$NIRI_CFG"

niri msg action do-reload-config 2>/dev/null || true
notify-send "Window Rounding" "Set to $VALUE"
