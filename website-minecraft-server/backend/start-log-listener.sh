#!/bin/bash
#
# start-log-listener.sh - starts collectors/log_event_listener.py in a detached
# screen session, if it isn't already running. Same pattern as start-web.sh /
# minecraft-start-server.sh.

BACKEND_DIR="/home/brian/repos/minecraft/website-minecraft-server/backend"
export MC_WEBSITE_DB="/home/brian/maintenance/minecraft-website.db"

if pgrep -f "collectors/log_event_listener.py" > /dev/null; then
    echo "Log listener already running. Nothing to do. Exiting." | ts
    exit 0
fi

if screen -ls | grep -q 'mc-website-log-listener'; then
    echo "screen session 'mc-website-log-listener' exists but listener isn't running under it. Wiping and restarting." | ts
    screen -S mc-website-log-listener -X quit
fi

screen -dmS mc-website-log-listener -L -Logfile /home/brian/maintenance/mc-website-log-listener.log \
    python3 "$BACKEND_DIR/collectors/log_event_listener.py"
echo "Log listener started." | ts
