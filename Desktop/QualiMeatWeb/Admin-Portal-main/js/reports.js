import { requireAdminSession } from "./auth-guard.js";
await requireAdminSession();

import { db } from "./firebase-config.js";
import { collection, getDocs } from "https://www.gstatic.com/firebasejs/10.12.2/firebase-firestore.js";
import { getPage, renderPagination, DEFAULT_PAGE_SIZE } from "./table-pagination.js";

let vendorStats = {};
let currentPage = 1;

async function loadReports() {
    try {
        ["topVendorList", "warningVendorList", "criticalVendorList"].forEach(id => {
            const el = document.getElementById(id);
            if (el) el.innerHTML = Array(3).fill(`<div class="report-item"><div class="skeleton sk-text" style="width:50%;margin:0;"></div><div class="skeleton sk-text" style="width:20%;margin:0;"></div></div>`).join("");
        });
        const tableBody = document.getElementById("vendorTableBody");
        if (tableBody) tableBody.innerHTML = Array(5).fill(`<tr class="skeleton-row"><td><div class="skeleton sk-text" style="width:70%;"></div></td><td><div class="skeleton sk-text" style="width:30%;"></div></td><td><div class="skeleton sk-text" style="width:30%;"></div></td><td><div class="skeleton sk-text" style="width:30%;"></div></td><td><div class="skeleton sk-badge"></div></td></tr>`).join("");

        const snapshot = await getDocs(collection(db, "inspections"));
        vendorStats = {};
        snapshot.forEach(docSnap => {
            const data = docSnap.data();
            const vendor = data.vendorName || "Unknown Vendor";
            if (!vendorStats[vendor]) vendorStats[vendor] = { inspections: 0, cleanSessions: 0, spoiledSessions: 0 };
            vendorStats[vendor].inspections++;
            const hasSpoiled = (data.scanHistory || []).some(scan => (scan.label || "").toLowerCase().includes("spoiled"));
            if (hasSpoiled) vendorStats[vendor].spoiledSessions++;
            else vendorStats[vendor].cleanSessions++;
        });
        currentPage = 1;
        renderReports();
    } catch (error) {
        console.error("Error loading reports:", error);
    }
}

function getStatusInfo(spoiledCount) {
    if (spoiledCount >= 3) return { label: "CRITICAL", class: "badge-critical" };
    if (spoiledCount >= 1) return { label: "WARNING", class: "badge-warning" };
    return { label: "COMPLIANT", class: "badge-clean" };
}

function renderReports() {
    const entries = Object.entries(vendorStats);
    const topVendors = entries.filter(([, stats]) => stats.spoiledSessions === 0).sort((a, b) => b[1].cleanSessions - a[1].cleanSessions).slice(0, 10);
    const warningVendors = entries.filter(([, stats]) => stats.spoiledSessions === 1 || stats.spoiledSessions === 2).sort((a, b) => b[1].spoiledSessions - a[1].spoiledSessions);
    const criticalVendors = entries.filter(([, stats]) => stats.spoiledSessions >= 3).sort((a, b) => b[1].spoiledSessions - a[1].spoiledSessions);

    const renderList = (id, data, valKey, valClass, suffix) => {
        const el = document.getElementById(id);
        if (!el) return;
        el.innerHTML = data.length ? data.map(([vendor, stats]) => `<div class="report-item"><span>${vendor}</span><span class="${valClass}">${stats[valKey]} ${suffix}</span></div>`).join("") : `<div class="report-item empty-list">No vendors in this category</div>`;
    };
    renderList("topVendorList", topVendors, "cleanSessions", "num-clean", "Clean");
    renderList("warningVendorList", warningVendors, "spoiledSessions", "num-warning", "Flagged");
    renderList("criticalVendorList", criticalVendors, "spoiledSessions", "num-critical", "Flagged");

    const sortedEntries = [...entries].sort((a, b) => b[1].spoiledSessions - a[1].spoiledSessions || b[1].inspections - a[1].inspections);
    const page = getPage(sortedEntries, currentPage, DEFAULT_PAGE_SIZE);
    currentPage = page.currentPage;
    const tableBody = document.getElementById("vendorTableBody");
    if (tableBody) {
        tableBody.innerHTML = page.pageItems.length ? page.pageItems.map(([vendor, stats]) => {
            const status = getStatusInfo(stats.spoiledSessions);
            return `<tr><td style="font-weight:600;">${vendor}</td><td>${stats.inspections}</td><td>${stats.cleanSessions}</td><td><span class="${stats.spoiledSessions > 0 ? "num-critical" : ""}">${stats.spoiledSessions}</span></td><td><span class="badge ${status.class}">${status.label}</span></td></tr>`;
        }).join("") : `<tr><td colspan="5" class="empty-table">No vendor report data found.</td></tr>`;
    }
    renderPagination("reportPagination", page, nextPage => { currentPage = nextPage; renderReports(); }, "vendors");
}

function initReportsPage() {
    const exportBtn = document.getElementById("exportBtn");
    if (exportBtn) {
        exportBtn.addEventListener("click", () => {
            let csv = "Vendor,Total Inspections,Clean Sessions,Flagged Sessions,Compliance Status\n";
            Object.entries(vendorStats).forEach(([vendor, stats]) => {
                const status = getStatusInfo(stats.spoiledSessions).label;
                csv += `"${vendor.replaceAll('"', '""')}",${stats.inspections},${stats.cleanSessions},${stats.spoiledSessions},${status}\n`;
            });
            const blob = new Blob([csv], { type: "text/csv" });
            const url = URL.createObjectURL(blob);
            const a = document.createElement("a");
            a.href = url;
            a.download = "QualiMeat_Vendor_Report.csv";
            a.click();
            URL.revokeObjectURL(url);
        });
    }
    loadReports();
}

if (document.readyState === "loading") document.addEventListener("DOMContentLoaded", initReportsPage, { once: true });
else initReportsPage();
