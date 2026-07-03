#!/usr/bin/env python3
"""status_check.py - records one status_checks row per run and logs server_up/
server_down transition events. Meant to run every minute via cron:

* * * * * /usr/bin/python3 /home/brian/repos/minecraft/website-minecraft-server/backend/collectors/status_check.py
"""
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from db import get_conn, init_db  # noqa: E402


def server_process_running():
    result = subprocess.run(
        ["pgrep", "bedrock_server"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL
    )
    return result.returncode == 0


def main():
    init_db()
    online = server_process_running()
    now = datetime.now(timezone.utc).isoformat()

    with get_conn() as conn:
        previous = conn.execute(
            "SELECT server_online FROM status_checks ORDER BY checked_at DESC LIMIT 1"
        ).fetchone()

        conn.execute(
            "INSERT INTO status_checks (checked_at, server_online, service_online) VALUES (?, ?, 1)",
            (now, int(online)),
        )

        if previous is not None and bool(previous["server_online"]) != online:
            conn.execute(
                "INSERT INTO events (occurred_at, type, detail) VALUES (?, ?, ?)",
                (now, "server_up" if online else "server_down", None),
            )

        conn.commit()


if __name__ == "__main__":
    main()
