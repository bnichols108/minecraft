import json
from datetime import datetime, timedelta, timezone
from pathlib import Path

from flask import Flask, jsonify, request, send_from_directory

from config import BACKUP_HOURS_24H, TRACKING_START_DATE
from db import get_conn, get_meta, init_db

BACKEND_DIR = Path(__file__).resolve().parent
FRONTEND_DIR = BACKEND_DIR.parent
WORLD_PROGRESSION_FILE = BACKEND_DIR / "data" / "world_progression.json"

STALE_COLLECTOR_THRESHOLD = timedelta(minutes=3)

app = Flask(__name__, static_folder=str(FRONTEND_DIR), static_url_path="")


# ---- helpers -----------------------------------------------------------

def now_utc():
    return datetime.now(timezone.utc)


def parse_ts(value):
    return datetime.fromisoformat(value).replace(tzinfo=timezone.utc)


def format_duration(total_seconds):
    total_seconds = max(0, int(total_seconds))
    hours, remainder = divmod(total_seconds, 3600)
    minutes = remainder // 60
    parts = []
    if hours:
        parts.append(f"{hours} hour{'s' if hours != 1 else ''}")
    parts.append(f"{minutes} min{'s' if minutes != 1 else ''}")
    return ", ".join(parts)


def uptime_percent(conn, since=None):
    query = "SELECT server_online FROM status_checks"
    params = ()
    if since is not None:
        query += " WHERE checked_at >= ?"
        params = (since.isoformat(),)
    rows = conn.execute(query, params).fetchall()
    if not rows:
        return None
    online = sum(1 for r in rows if r["server_online"])
    return round((online / len(rows)) * 100)


def current_players(conn):
    rows = conn.execute(
        "SELECT player_name FROM player_sessions WHERE left_at IS NULL ORDER BY joined_at"
    ).fetchall()
    return [r["player_name"] for r in rows]


def playtime_overall(conn):
    rows = conn.execute(
        "SELECT player_name, joined_at, left_at FROM player_sessions"
    ).fetchall()
    totals = {}
    now = now_utc()
    for row in rows:
        joined = parse_ts(row["joined_at"])
        ended = parse_ts(row["left_at"]) if row["left_at"] else now
        totals.setdefault(row["player_name"], 0)
        totals[row["player_name"]] += (ended - joined).total_seconds()
    return [
        {"player": name, "playtime": format_duration(seconds)}
        for name, seconds in sorted(totals.items(), key=lambda kv: -kv[1])
    ]


def playtime_per_day(conn):
    rows = conn.execute(
        "SELECT player_name, joined_at, left_at FROM player_sessions ORDER BY player_name, joined_at"
    ).fetchall()
    now = now_utc()
    totals = {}
    for row in rows:
        joined = parse_ts(row["joined_at"])
        ended = parse_ts(row["left_at"]) if row["left_at"] else now
        day = joined.date().isoformat()
        key = (row["player_name"], day)
        totals.setdefault(key, 0)
        totals[key] += (ended - joined).total_seconds()

    per_player = {}
    for (player, day), seconds in totals.items():
        per_player.setdefault(player, []).append({"date": day, "playtime": format_duration(seconds)})
    return [
        {"player": player, "days": sorted(days, key=lambda d: d["date"])}
        for player, days in per_player.items()
    ]


def upcoming_maintenance():
    now = now_utc()
    upcoming = []
    for day_offset in (0, 1):
        for hour in BACKUP_HOURS_24H:
            candidate = (now + timedelta(days=day_offset)).replace(
                hour=hour, minute=0, second=0, microsecond=0
            )
            if candidate > now:
                upcoming.append(candidate)
    upcoming.sort()
    return [
        {"time": ts.strftime("%I:%M %p").lstrip("0"), "description": "World Backup"}
        for ts in upcoming[:3]
    ]


# ---- API routes ----------------------------------------------------------

@app.get("/api/status")
def api_status():
    with get_conn() as conn:
        latest = conn.execute(
            "SELECT * FROM status_checks ORDER BY checked_at DESC LIMIT 1"
        ).fetchone()

        server_online = bool(latest["server_online"]) if latest else False
        collectors_alive = bool(
            latest and (now_utc() - parse_ts(latest["checked_at"])) < STALE_COLLECTOR_THRESHOLD
        )

        since_tracking = None
        try:
            since_tracking = datetime.fromisoformat(TRACKING_START_DATE).replace(tzinfo=timezone.utc)
        except ValueError:
            pass

        payload = {
            "minecraft_service_status": "LIVE" if collectors_alive else "DOWN",
            "minecraft_server_status": "ONLINE" if server_online else "OFFLINE",
            "ongoing_maintenance": get_meta(conn, "ongoing_maintenance", "NONE"),
            "minecraft_version": get_meta(conn, "current_version", "unknown"),
            "current_players": current_players(conn),
            "upcoming_maintenance": upcoming_maintenance(),
            "uptime": {
                "monthly": uptime_percent(conn, now_utc() - timedelta(days=30)),
                "yearly": uptime_percent(conn, now_utc() - timedelta(days=365)),
                "overall": uptime_percent(conn, since_tracking),
            },
            "tracking_since": TRACKING_START_DATE,
            "playtime_overall": playtime_overall(conn),
            "playtime_per_day": playtime_per_day(conn),
        }
    return jsonify(payload)


@app.get("/api/logbook")
def api_logbook():
    limit = min(int(request.args.get("limit", 100)), 500)
    with get_conn() as conn:
        rows = conn.execute(
            "SELECT occurred_at, type, detail FROM events ORDER BY occurred_at DESC LIMIT ?",
            (limit,),
        ).fetchall()
    return jsonify([dict(row) for row in rows])


@app.get("/api/world-progression")
def api_world_progression():
    if not WORLD_PROGRESSION_FILE.exists():
        return jsonify([])
    structures = json.loads(WORLD_PROGRESSION_FILE.read_text())
    for structure in structures:
        for entry in structure.get("progress_images", []):
            entry["image_url"] = f"/images/world-progression/{entry['image']}"
    return jsonify(structures)


# ---- static frontend -------------------------------------------------

@app.get("/")
def index():
    return send_from_directory(FRONTEND_DIR, "index.html")


if __name__ == "__main__":
    init_db()
    app.run(host="0.0.0.0", port=8080)
