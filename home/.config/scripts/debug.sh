LOG="/tmp/startup_chain.log"
echo "====== STAGE: $1======" >> "$LOG"
echo "------ PROCESSES ------" >> "$LOG"
~/.config/scripts/start_debug/pt.sh >> "$LOG"
echo "------ ENV VARS ------" >> "$LOG"
~/.config/scripts/start_debug/vars.sh >> "$LOG"

