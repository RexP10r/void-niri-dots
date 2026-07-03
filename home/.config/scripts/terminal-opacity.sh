#!/usr/bin/env bash
set -euo pipefail

KITT_CFG="$HOME/.config/kitty/kitty.conf"
ALAC_CFG="$HOME/.config/alacritty/alacritty.toml"

VALUE="${1:-90}"

OPACITY=$(awk "BEGIN {printf \"%.2f\", $VALUE / 100}")

# --- Update Kitty ---
if grep -q "^background_opacity" "$KITT_CFG"; then
    sed -i "s/^background_opacity.*/background_opacity $OPACITY/" "$KITT_CFG"
else
    echo "background_opacity $OPACITY" >> "$KITT_CFG"
fi

if grep -q "^opacity =" "$ALAC_CFG"; then
    sed -i "s/^opacity = .*/opacity = $OPACITY/" "$ALAC_CFG"
else
    if grep -q "^\[window\]" "$ALAC_CFG"; then
        sed -i "/^\[window\]/a opacity = $OPACITY" "$ALAC_CFG"
    else
        echo -e "\n[window]\nopacity = $OPACITY" >> "$ALAC_CFG"
    fi
fi

kitty @ load-config 2>/dev/null || true
