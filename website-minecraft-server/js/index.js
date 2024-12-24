function getStatuses() {
    fetch('status/minecraft-service-status.txt')
        .then((response) => response.text())
        .then((text) => {
            document.getElementById("minecraft-service-status").innerText = text;
    });
    fetch('status/minecraft-server-status.txt')
        .then((response) => response.text())
        .then((text) => {
            document.getElementById("minecraft-server-status").innerText = text;
    });
    fetch('status/ongoing-maintenance.txt')
        .then((response) => response.text())
        .then((text) => {
            document.getElementById("ongoing-maintenance").innerText = text;
    });
    fetch('status/minecraft-service-version.txt')
        .then((response) => response.text())
        .then((text) => {
            document.getElementById("minecraft-service-version").innerText = text;
    });
    fetch('status/current-players.txt')
        .then((response) => response.text())
        .then((text) => {
            document.getElementById("current-players").innerText = text;
    });
    fetch('status/scheduled-maintenance.txt')
        .then((response) => response.text())
        .then((text) => {
            document.getElementById("scheduled-maintenance").innerText = text;
    });
    fetch('status/minecraft-service-uptime-monthly.txt')
        .then((response) => response.text())
        .then((text) => {
            document.getElementById("minecraft-service-uptime-monthly").innerText = text;
    });
}
getStatuses()
setInterval(getStatuses, 30000); // 5000 = 5 secs, so 30000 should be 30 secs