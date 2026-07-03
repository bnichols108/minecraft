#!/usr/bin/env python3
"""log_event_listener.py - tails the live Bedrock server log and writes
join/quit sessions, events, and the detected server version into SQLite.

Adapted from the existing (print-only) minecraft-server-log-parser.py so it
persists data instead. Runs continuously - start it the same way the
Minecraft server itself is started (a detached `screen` session via
@reboot cron), not as a one-shot cron job:

@reboot screen -dmS mc-website-log-listener /usr/bin/python3 \
  /home/brian/repos/minecraft/website-minecraft-server/backend/collectors/log_event_listener.py
"""
import sys
import time
from datetime import datetime, timezone
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from db import get_conn, init_db, set_meta  # noqa: E402

LOG_FILE = Path.home() / "maintenance" / "minecraft-server-live-log.log"


def follow_log(log_file):
    with open(log_file, "r") as f:
        f.seek(0, 2)  # start at end of file, only pick up new lines
        while True:
            line = f.readline()
            if not line:
                time.sleep(0.5)
                continue
            yield line


def open_session(conn, player):
    existing = conn.execute(
        "SELECT id FROM player_sessions WHERE player_name = ? AND left_at IS NULL", (player,)
    ).fetchone()
    if existing:
        return
    now = datetime.now(timezone.utc).isoformat()
    conn.execute("INSERT INTO player_sessions (player_name, joined_at) VALUES (?, ?)", (player, now))
    conn.execute("INSERT INTO events (occurred_at, type, detail) VALUES (?, 'join', ?)", (now, player))
    conn.commit()


def close_session(conn, player):
    row = conn.execute(
        "SELECT id FROM player_sessions WHERE player_name = ? AND left_at IS NULL", (player,)
    ).fetchone()
    if not row:
        return
    now = datetime.now(timezone.utc).isoformat()
    conn.execute("UPDATE player_sessions SET left_at = ? WHERE id = ?", (now, row["id"]))
    conn.execute("INSERT INTO events (occurred_at, type, detail) VALUES (?, 'quit', ?)", (now, player))
    conn.commit()


def close_all_sessions(conn):
    now = datetime.now(timezone.utc).isoformat()
    open_rows = conn.execute("SELECT id, player_name FROM player_sessions WHERE left_at IS NULL").fetchall()
    for row in open_rows:
        conn.execute("UPDATE player_sessions SET left_at = ? WHERE id = ?", (now, row["id"]))
        conn.execute(
            "INSERT INTO events (occurred_at, type, detail) VALUES (?, 'quit', ?)", (now, row["player_name"])
        )
    conn.commit()


def parse_line(conn, line):
    if "Player connected" in line:
        player = line.split(":")[4].replace(", xuid", "")[1:].strip()
        open_session(conn, player)
    elif "Player disconnected" in line:
        player = line.split(":")[4].replace(", xuid", "")[1:].strip()
        close_session(conn, player)
    elif "Server stop requested" in line:
        close_all_sessions(conn)
    elif "INFO] Version: " in line:
        version = line.split(":")[4].replace(" ", "").strip()
        set_meta(conn, "current_version", f"v{version}")


def detect_initial_version(conn):
    with open(LOG_FILE, "r", errors="replace") as f:
        for line in reversed(f.readlines()):
            if "INFO] Version: " in line:
                version = line.split(":")[4].replace(" ", "").strip()
                set_meta(conn, "current_version", f"v{version}")
                return


def main():
    init_db()
    if not LOG_FILE.exists():
        print(f"Log file not found yet, waiting: {LOG_FILE}")
        while not LOG_FILE.exists():
            time.sleep(5)

    with get_conn() as conn:
        try:
            detect_initial_version(conn)
        except (IndexError, ValueError):
            pass

        for line in follow_log(LOG_FILE):
            try:
                parse_line(conn, line)
            except (IndexError, ValueError):
                continue  # malformed/unexpected log line shape, skip it


if __name__ == "__main__":
    main()
