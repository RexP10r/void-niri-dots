#!/bin/bash

X_POS=100
Y_POS=150
WIDTH=800
HEIGHT=600
COMMAND_TO_RUN="pkill mpd && mpd"

while getopts "x:y:w:h:c:" opt; do
  case ${opt} in
    x ) X_POS=$OPTARG ;;
    y ) Y_POS=$OPTARG ;;
    w ) WIDTH=$OPTARG ;;
    h ) HEIGHT=$OPTARG ;;
    c ) COMMAND_TO_RUN=$OPTARG ;;
    \? ) echo "Usage: $0 [-x x_pos] [-y y_pos] [-w width] [-h height] [-c command]"; exit 1 ;;
  esac
done

UNIQUE_ID="float-term-$(date +%s%N)"
alacritty --title "$UNIQUE_TITLE" -e bash -c "$COMMAND_TO_RUN" &

sleep 0.5

WINDOW_ID=$(niri msg -j windows | jq ".[] | select(.title == \"$UNIQUE_TITLE\") | .id")

if [ -z "$WINDOW_ID" ] || [ "$WINDOW_ID" = "null" ]; then
    echo "Error: Could not capture the window ID."
    exit 1
fi

niri msg action move-window-to-floating --id "$WINDOW_ID"
niri msg action set-window-height "$HEIGHT" --id "$WINDOW_ID"
niri msg action move-floating-window --id "$WINDOW_ID" --x "$X_POS" --y "$Y_POS"
