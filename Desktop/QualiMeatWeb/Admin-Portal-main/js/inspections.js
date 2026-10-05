import { requireAdminSession } from "./auth-guard.js";
await requireAdminSession();

import { db } from "./firebase-config.js";
import { collection, getDocs } from "https://www.gstatic.com/firebasejs/10.12.2/firebase-firestore.js";
import { getPage, renderPagination, DEFAULT_PAGE_SIZE } from "./table-pagination.js";

let allRows = [];
let filteredRows = [];
let currentPage = 1;

async function loadInspections() {
    try {
        const tbody = document.getElementById("inspectionTableBody");
        if (tbody) {
            tbody.innerHTML = Array(6).fill(`
                <tr class="skeleton-row">
                    <td><div class="skeleton sk-text"></div></td>
                    <td><div class="skeleton sk-text" style="width: 80%;"></div></td>
                    <td><div class="skeleton sk-text" style="width: 50%;"></div></td>
                    <td><div class="skeleton sk-text"></div></td>
                    <td><div class="skeleton sk-text"></div></td>
                    <td><div class="skeleton sk-text"></div></td>
                    <td><div class="skeleton sk-text" style="width: 40px;"></div></td>
                </tr>
            `).join("");
        }

        const snapshot = await getDocs(collection(db, "inspections"));
        allRows = [];

        snapshot.forEach(docSnap => {
            const data = docSnap.data();
            let fresh = 0;
            let spoiled = 0;
            const scanHistory = Array.isArray(data.scanHistory) ? data.scanHistory : [];

            scanHistory.forEach(scan => {
                const label = (scan.label || "").toLowerCase();
                if (label.includes("fresh")) fresh++;
                if (label.includes("spoiled")) spoiled++;
            });

            let dateStr = "-";
            let timestampMs = 0;
            if (data.timestamp && typeof data.timestamp.toDate === "function") {
                const date = data.timestamp.toDate();
                timestampMs = date.getTime();
                dateStr = date.toLocaleDateString();
            } else if (data.timestamp) {
                const date = new Date(data.timestamp);
                if (!Number.isNaN(date.getTime())) {
                    timestampMs = date.getTime();
                    dateStr = date.toLocaleDateString();
                }
            }

            allRows.push({
                id: docSnap.id,
                inspector: data.inspectorName || "Unknown",
                vendor: data.vendorName || "Unknown",
                stall: String(data.stallNumber ?? "-"),
                fresh,
                spoiled,
                date: dateStr,
                timestampMs,
                scanHistory
            });
        });

        allRows.sort((a, b) => b.timestampMs - a.timestampMs);
        filteredRows = [...allRows];
        currentPage = 1;
        renderTable();
    } catch (error) {
        console.error("Error loading inspections:", error);
    }
}

function renderTable() {
    const tbody = document.getElementById("inspectionTableBody");
    if (!tbody) return;

    const page = getPage(filteredRows, currentPage, DEFAULT_PAGE_SIZE);
    currentPage = page.currentPage;

    if (!page.pageItems.length) {
        tbody.innerHTML = `<tr><td colspan="7" class="empty-table">No inspection records found.</td></tr>`;
    } else {
        tbody.innerHTML = page.pageItems.map((row, localIndex) => {
            const rowKey = `${page.startIndex + localIndex}`;
            return `
                <tr>
                    <td>${row.inspector}</td>
                    <td>${row.vendor}</td>
                    <td>${row.stall}</td>
                    <td>${row.fresh}</td>
                    <td>${row.spoiled}</td>
                    <td>${row.date}</td>
                    <td><button class="view-btn" onclick="toggleDetails('${rowKey}')">View</button></td>
                </tr>
                <tr id="details-${rowKey}" class="details-row" style="display:none;">
                    <td colspan="7">
                        <div class="scan-history">
                            ${row.scanHistory.length
                                ? row.scanHistory.map(scan => `
                                    <div class="scan-item">
                                        <span>${scan.cut || "Unknown cut"}</span>
                                        <strong class="${(scan.label || "").toLowerCase().includes("fresh") ? "fresh" : "spoiled"}">${scan.label || "Unknown"}</strong>
                                    </div>
                                `).join("")
                                : `<div class="scan-item">No scan history available</div>`
                            }
                        </div>
                    </td>
                </tr>`;
        }).join("");
    }

    renderPagination("inspectionPagination", page, nextPage => {
        currentPage = nextPage;
        renderTable();
        document.querySelector(".table-card")?.scrollIntoView({ behavior: "smooth", block: "start" });
    }, "inspections");
}

window.toggleDetails = function(index) {
    const row = document.getElementById(`details-${index}`);
    if (!row) return;
    row.style.display = row.style.display === "none" ? "table-row" : "none";
};

function initInspectionsPage() {
    const searchInput = document.getElementById("searchInput");
    if (searchInput) {
        searchInput.addEventListener("input", event => {
            const value = event.target.value.trim().toLowerCase();
            filteredRows = allRows.filter(row =>
                row.vendor.toLowerCase().includes(value) ||
                row.inspector.toLowerCase().includes(value) ||
                row.stall.toLowerCase().includes(value)
            );
            currentPage = 1;
            renderTable();
        });
    }
    loadInspections();
}

if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", initInspectionsPage, { once: true });
} else {
    initInspectionsPage();
}
