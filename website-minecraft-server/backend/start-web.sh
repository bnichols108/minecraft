#!/bin/bash
#
# start-web.sh - starts the Minecraft status website (gunicorn) in a detached
# screen session, if it isn't already running. Mirrors minecraft-start-server.sh's
# pattern so it fits the existing cron/@reboot conventions.

BACKEND_DIR="/home/brian/repos/minecraft/website-minecraft-server/backend"
export MC_WEBSITE_DB="/home/brian/maintenance/minecraft-website.db"
export MC_WEBSITE_SECRETS="/home/brian/maintenance/website-secrets.json"
export PATH="$HOME/.local/bin:$PATH"

if pgrep -f "gunicorn -b 0.0.0.0:8080" > /dev/null; then
    echo "Website already running. Nothing to do. Exiting." | ts
    exit 0
fi

if screen -ls | grep -q 'mc-website'; then
    echo "screen session 'mc-website' exists but gunicorn isn't running under it. Wiping and restarting." | ts
    screen -S mc-website -X quit
fi

cd "$BACKEND_DIR" || exit 1
python3 -c "from db import init_db; init_db()"
screen -dmS mc-website -L -Logfile /home/brian/maintenance/mc-website-gunicorn.log \
    gunicorn -b 0.0.0.0:8080 --chdir "$BACKEND_DIR" app:app
echo "Website started." | ts
