-- Schema for the Minecraft status website's SQLite database.
-- Applied once via db.py's init_db(); safe to re-run.

CREATE TABLE IF NOT EXISTS status_checks (
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    checked_at     TEXT NOT NULL,
    server_online  INTEGER NOT NULL,
    service_online INTEGER NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_status_checks_checked_at ON status_checks(checked_at);

CREATE TABLE IF NOT EXISTS player_sessions (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    player_name TEXT NOT NULL,
    joined_at   TEXT NOT NULL,
    left_at     TEXT
);
CREATE INDEX IF NOT EXISTS idx_player_sessions_left_at ON player_sessions(left_at);
CREATE INDEX IF NOT EXISTS idx_player_sessions_player ON player_sessions(player_name);

CREATE TABLE IF NOT EXISTS events (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    occurred_at TEXT NOT NULL,
    type        TEXT NOT NULL,
    detail      TEXT
);
CREATE INDEX IF NOT EXISTS idx_events_occurred_at ON events(occurred_at);

CREATE TABLE IF NOT EXISTS meta (
    key        TEXT PRIMARY KEY,
    value      TEXT,
    updated_at TEXT
);
