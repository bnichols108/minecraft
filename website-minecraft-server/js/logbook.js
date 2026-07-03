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
    const date = new Date(isoString + (isoString.endsWith("Z") ? "" : "Z"));
    return date.toLocaleString(undefined, {
        month: "2-digit",
        day: "2-digit",
        year: "2-digit",
        hour: "2-digit",
        minute: "2-digit",
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
