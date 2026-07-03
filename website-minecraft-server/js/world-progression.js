function renderStructure(structure) {
    const coords = structure.coordinates || {};
    const images = (structure.progress_images || [])
        .map(
            (img) => `
        <figure>
            <img src="${escapeHtml(img.image_url)}" alt="${escapeHtml(img.caption || structure.name)}" loading="lazy">
            <figcaption>${escapeHtml(img.date)}${img.caption ? " - " + escapeHtml(img.caption) : ""}</figcaption>
        </figure>`
        )
        .join("");

    const card = document.createElement("div");
    card.className = "structure-card";
    card.innerHTML = `
        <button class="structure-card__header" type="button">
            <span>${escapeHtml(structure.name)}</span>
            <span class="structure-card__coords">X: ${coords.x ?? "?"} Y: ${coords.y ?? "?"} Z: ${coords.z ?? "?"}</span>
        </button>
        <div class="structure-card__body">
            <p class="structure-card__history">${escapeHtml(structure.history)}</p>
            <div class="structure-card__images">${images || '<span class="empty">No progress images yet</span>'}</div>
        </div>
    `;
    card.querySelector(".structure-card__header").addEventListener("click", () => {
        card.classList.toggle("is-open");
    });
    return card;
}

async function loadWorldProgression() {
    const container = document.getElementById("structure-list");
    try {
        const structures = await fetchJSON("/api/world-progression");
        container.innerHTML = "";
        if (structures.length === 0) {
            container.innerHTML = '<p style="color:#ccc;">No structures documented yet.</p>';
            return;
        }
        structures.forEach((structure) => container.appendChild(renderStructure(structure)));
    } catch (err) {
        console.error("Failed to load world progression", err);
        container.innerHTML = '<p style="color:#ccc;">Could not load world progression data.</p>';
    }
}

document.addEventListener("DOMContentLoaded", loadWorldProgression);
