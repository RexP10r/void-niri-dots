#!/usr/bin/env bash
set -euo pipefail

WAYBAR_CSS="$HOME/.config/waybar/style.css"

CURRENT_COLOR=$(awk '/window#waybar > box/,/}/ { 
	if ($0 ~ /background-color/) { 
		gsub(/.*background-color:[[:space:]]*/, "", $0); 
		gsub(/;.*/, "", $0); 
		gsub(/[[:space:]]/, "", $0);
		print $0; 
		exit 
	} 
}' "$WAYBAR_CSS")

if [[ "$CURRENT_COLOR" == "@transparent" ]]; then
	NEW_COLOR="@background"
else
	NEW_COLOR="@transparent"
fi

sed -i "/window#waybar > box/,/}/ s/background-color:[[:space:]]*[^;]*/background-color: $NEW_COLOR/" "$WAYBAR_CSS"
