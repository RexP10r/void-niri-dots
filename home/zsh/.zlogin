if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
#	sleep 1
#	chvt 1    
#	exec /usr/bin/start-niri -- vt1 -keeptty
fi
