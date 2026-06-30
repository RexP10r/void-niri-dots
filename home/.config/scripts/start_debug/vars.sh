#!/bin/sh
echo "=== Environment at $(date) ==="
echo "TTY: $(tty)"
echo "DISPLAY: $DISPLAY"
echo "XAUTHORITY: $XAUTHORITY"
echo "HOME: $HOME"
echo "USER: $USER"
echo "LOGNAME: $LOGNAME"
echo "SHELL: $SHELL"
echo "PATH: $PATH"
echo "PWD: $PWD"
echo "TERM: $TERM"
env | sort
