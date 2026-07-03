import os

TRACKING_START_DATE = os.environ.get("MC_WEBSITE_TRACKING_START", "2024-12-01")

# Matches the real crontab backup schedule (minecraft-server-maintenance.sh "backup").
BACKUP_HOURS_24H = [0, 6, 12, 18]
