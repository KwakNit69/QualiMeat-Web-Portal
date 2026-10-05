import { requireAdminSession } from "./auth-guard.js";
await requireAdminSession();

import { db } from "./firebase-config.js";
import { collection, getDocs } from "https://www.gstatic.com/firebasejs/10.12.2/firebase-firestore.js";
import { getPage, renderPagination, DEFAULT_PAGE_SIZE } from "./table-pagination.js";

let qualityChart = null;
let recentRows = [];
let recentPage = 1;

async function loadDashboard() {
    try {
        ["totalInspections", "freshScans", "spoiledScans", "totalVendors"].forEach(id => {
            const el = document.getElementById(id);
            if (el) el.innerHTML = `<div class="skeleton sk-title" style="margin:0;width:60px;height:35px;"></div>`;
        });
        const topStalls = document.getElementById("topStallsList");
        if (topStalls) topStalls.innerHTML = Array(3).fill(`<div class="progress-skeleton"><div class="skeleton sk-text" style="width:30%;"></div><div class="skeleton sk-text" style="height:10px;border-radius:5px;"></div></div>`).join("");
        const tbody = document.getElementById("inspectionTableBody");
        if (tbody) tbody.innerHTML = Array(5).fill(`<tr class="skeleton-row"><td><div class="skeleton sk-text"></div></td><td><div class="skeleton sk-text"></div></td><td><div class="skeleton sk-text"></div></td><td><div class="skeleton sk-text"></div></td><td><div class="skeleton sk-text"></div></td><td><div class="skeleton sk-text"></div></td></tr>`).join("");

        const snapshot = await getDocs(collection(db, "inspections"));
        let freshTotal = 0;
        let spoiledTotal = 0;
        const vendors = new Set();
        const stallStats = {};
        const dailyStats = {};
        recentRows = [];

        snapshot.forEach(docSnap => {
            const data = docSnap.data();
            if (data.vendorName) vendors.add(data.vendorName);
            const stall = String(data.stallNumber ?? "Unknown");
            if (!stallStats[stall]) stallStats[stall] = { FRESH: 0, SPOILED: 0 };

            let day = "Unknown";
            let formattedDate = "-";
            let timestampMs = 0;
            if (data.timestamp && typeof data.timestamp.toDate === "function") {
                const dateObj = data.timestamp.toDate();
                day = dateObj.toLocaleDateString();
                formattedDate = day;
                timestampMs = dateObj.getTime();
            } else if (data.timestamp) {
                const dateObj = new Date(data.timestamp);
                if (!Number.isNaN(dateObj.getTime())) {
                    day = dateObj.toLocaleDateString();
                    formattedDate = day;
                    timestampMs = dateObj.getTime();
                }
            }
            if (!dailyStats[day]) dailyStats[day] = { FRESH: 0, SPOILED: 0, timestampMs };

            let fresh = 0;
            let spoiled = 0;
            (Array.isArray(data.scanHistory) ? data.scanHistory : []).forEach(scan => {
                const label = (scan.label || "").toLowerCase();
                if (label.includes("fresh")) { freshTotal++; fresh++; dailyStats[day].FRESH++; stallStats[stall].FRESH++; }
                if (label.includes("spoiled")) { spoiledTotal++; spoiled++; dailyStats[day].SPOILED++; stallStats[stall].SPOILED++; }
            });

            recentRows.push({ inspector: data.inspectorName || "Unknown", vendor: data.vendorName || "Unknown", stall, fresh, spoiled, date: formattedDate, timestampMs });
        });

        document.getElementById("totalInspections").textContent = snapshot.size;
        document.getElementById("freshScans").textContent = freshTotal;
        document.getElementById("spoiledScans").textContent = spoiledTotal;
        document.getElementById("totalVendors").textContent = vendors.size;

        recentRows.sort((a, b) => b.timestampMs - a.timestampMs);
        renderTrendChart(dailyStats);
        recentPage = 1;
        renderRecentInspections();
        renderTopStalls(stallStats);
    } catch (error) {
        console.error("Dashboard Data Error:", error);
    }
}

function renderTrendChart(dailyStats) {
    const labels = Object.keys(dailyStats).sort((a, b) => (dailyStats[a].timestampMs || 0) - (dailyStats[b].timestampMs || 0));
    const freshData = labels.map(day => dailyStats[day].FRESH);
    const spoiledData = labels.map(day => dailyStats[day].SPOILED);
    const ctx = document.getElementById("qualityTrendChart");
    if (!ctx || typeof Chart === "undefined") return;
    if (qualityChart) qualityChart.destroy();
    qualityChart = new Chart(ctx, {
        type: "bar",
        data: { labels, datasets: [
            { label: "FRESH", data: freshData, backgroundColor: "#22c55e", borderRadius: 6 },
            { label: "SPOILED", data: spoiledData, backgroundColor: "#ef4444", borderRadius: 6 }
        ]},
        options: { responsive: true, maintainAspectRatio: false, plugins: { legend: { position: "top" } }, scales: { y: { beginAtZero: true } } }
    });
}

function renderRecentInspections() {
    const tbody = document.getElementById("inspectionTableBody");
    if (!tbody) return;
    const page = getPage(recentRows, recentPage, DEFAULT_PAGE_SIZE);
    recentPage = page.currentPage;
    tbody.innerHTML = page.pageItems.length ? page.pageItems.map(row => `<tr><td>${row.inspector}</td><td>${row.vendor}</td><td>${row.stall}</td><td>${row.fresh}</td><td>${row.spoiled}</td><td>${row.date}</td></tr>`).join("") : `<tr><td colspan="6" class="empty-table">No inspection sessions yet.</td></tr>`;
    renderPagination("dashboardPagination", page, next => { recentPage = next; renderRecentInspections(); }, "sessions");
}

function renderTopStalls(stallStats) {
    const container = document.getElementById("topStallsList");
    if (!container) return;
    const topStalls = Object.entries(stallStats)
        .filter(([, stats]) => stats.FRESH > 0)
        .sort((a, b) => (b[1].FRESH - b[1].SPOILED) - (a[1].FRESH - a[1].SPOILED) || b[1].FRESH - a[1].FRESH)
        .slice(0, 20);
    container.innerHTML = topStalls.length ? topStalls.map(([stall, stats], index) => {
        const total = stats.FRESH + stats.SPOILED;
        const score = total ? Math.round((stats.FRESH / total) * 100) : 0;
        return `<div class="progress-item"><div class="performance-row"><span><b>#${index + 1}</b> Stall ${stall}</span><strong>${score}%</strong></div><div class="bar"><div style="width:${score}%"></div></div><small>${stats.FRESH} fresh • ${stats.SPOILED} spoiled</small></div>`;
    }).join("") : `<div class="empty-state-compact">No stall performance data yet.</div>`;
}

if (document.readyState === "loading") document.addEventListener("DOMContentLoaded", loadDashboard, { once: true });
else loadDashboard();
