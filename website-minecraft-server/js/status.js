const REFRESH_MS = 15000;

function setStatusPill(el, isGood, label) {
    el.textContent = label;
    el.classList.remove("status-online", "status-offline", "status-neutral");
    el.classList.add(isGood ? "status-online" : "status-offline");
}

function renderPlayerList(el, players) {
    if (!players || players.length === 0) {
        el.innerHTML = '<span class="empty">No players online</span>';
        return;
    }
    el.innerHTML = "<ul>" + players.map((p) => `<li>${escapeHtml(p)}</li>`).join("") + "</ul>";
}

function renderMaintenanceList(el, items) {
    if (!items || items.length === 0) {
        el.innerHTML = '<span class="empty">Nothing scheduled</span>';
        return;
    }
    el.innerHTML =
        "<ul>" +
        items.map((m) => `<li>${escapeHtml(m.time)} - ${escapeHtml(m.description)}</li>`).join("") +
        "</ul>";
}

function renderPlaytimeOverall(el, rows) {
    if (!rows || rows.length === 0) {
        el.innerHTML = '<span class="empty">No playtime recorded yet</span>';
        return;
    }
    el.innerHTML =
        "<ul>" +
        rows.map((r) => `<li>${escapeHtml(r.player)} - ${escapeHtml(r.playtime)}</li>`).join("") +
        "</ul>";
}

function renderPlaytimePerDay(el, rows) {
    if (!rows || rows.length === 0) {
        el.innerHTML = '<span class="empty">No playtime recorded yet</span>';
        return;
    }
    el.innerHTML = rows
        .map((r) => {
            const days = r.days
                .map((d) => `${escapeHtml(d.date)}, ${escapeHtml(d.playtime)}`)
                .join("<br>");
            return `<div><strong>${escapeHtml(r.player)}</strong><br>${days}</div>`;
        })
        .join("<br>");
}

function formatDateShort(isoDate) {
    if (!isoDate) return "";
    const [year, month, day] = isoDate.split("-");
    return `${month}/${day}/${year.slice(2)}`;
}

function formatUptime(value) {
    return value === null || value === undefined ? "N/A" : `${value}%`;
}

async function refreshStatus() {
    let data;
    try {
        data = await fetchJSON("/api/status");
    } catch (err) {
        console.error("Failed to load status", err);
        return;
    }

    setStatusPill(
        document.getElementById("minecraft-service-status"),
        data.minecraft_service_status === "LIVE",
        data.minecraft_service_status
    );
    setStatusPill(
        document.getElementById("minecraft-server-status"),
        data.minecraft_server_status === "ONLINE",
        data.minecraft_server_status
    );

    const maintenanceEl = document.getElementById("ongoing-maintenance");
    const hasMaintenance = data.ongoing_maintenance && data.ongoing_maintenance !== "NONE";
    maintenanceEl.textContent = data.ongoing_maintenance || "NONE";
    maintenanceEl.classList.toggle("status-value--alert", hasMaintenance);

    document.getElementById("minecraft-version").textContent = data.minecraft_version;
    renderPlayerList(document.getElementById("current-players"), data.current_players);
    renderMaintenanceList(document.getElementById("scheduled-maintenance"), data.upcoming_maintenance);

    document.getElementById("uptime-monthly").textContent = formatUptime(data.uptime.monthly);
    document.getElementById("uptime-yearly").textContent = formatUptime(data.uptime.yearly);
    document.getElementById("uptime-overall").textContent = formatUptime(data.uptime.overall);
    document.getElementById("uptime-since-caption").textContent =
        "Since " + formatDateShort(data.tracking_since);

    renderPlaytimeOverall(document.getElementById("playtime-overall"), data.playtime_overall);
    renderPlaytimePerDay(document.getElementById("playtime-per-day"), data.playtime_per_day);
}

document.addEventListener("DOMContentLoaded", () => {
    refreshStatus();
    setInterval(refreshStatus, REFRESH_MS);
});
