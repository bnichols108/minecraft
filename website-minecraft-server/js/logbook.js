const EVENT_LABELS = {
    join: "JOIN",
    quit: "QUIT",
    server_up: "ONLINE",
    server_down: "OFFLINE",
};

function describeEvent(entry) {
    switch (entry.type) {
        case "join":
            return `${entry.detail} joined the server`;
        case "quit":
            return `${entry.detail} left the server`;
        case "server_up":
            return "Minecraft server came online";
        case "server_down":
            return "Minecraft server went offline";
        default:
            return entry.detail || entry.type;
    }
}

function formatTimestamp(isoString) {
    // Backend sends fully-qualified ISO 8601 strings (e.g. "...+00:00"), which
    // Date parses natively - no manual "Z" suffixing needed (that was the bug:
    // appending "Z" after an existing offset produced an unparseable string).
    const date = new Date(isoString);
    // Fixed to the server's own timezone (not the viewer's browser timezone) so
    // everyone looking at the Logbook together sees the same time for the same
    // event; Intl handles the EST/EDT switch automatically.
    return date.toLocaleString(undefined, {
        timeZone: "America/New_York",
        month: "2-digit",
        day: "2-digit",
        year: "2-digit",
        hour: "2-digit",
        minute: "2-digit",
        timeZoneName: "short",
    });
}

async function loadLogbook() {
    const container = document.getElementById("logbook-list");
    try {
        const entries = await fetchJSON("/api/logbook?limit=150");
        if (entries.length === 0) {
            container.innerHTML = '<p style="padding:16px;">No events recorded yet.</p>';
            return;
        }
        container.innerHTML = entries
            .map(
                (entry) => `
            <div class="logbook-entry">
                <span class="logbook-entry__time">${escapeHtml(formatTimestamp(entry.occurred_at))}</span>
                <span class="logbook-entry__type logbook-entry__type--${escapeHtml(entry.type)}">${escapeHtml(EVENT_LABELS[entry.type] || entry.type)}</span>
                <span>${escapeHtml(describeEvent(entry))}</span>
            </div>`
            )
            .join("");
    } catch (err) {
        console.error("Failed to load logbook", err);
        container.innerHTML = '<p style="padding:16px;">Could not load logbook data.</p>';
    }
}

document.addEventListener("DOMContentLoaded", loadLogbook);
