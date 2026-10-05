import { requireAdminSession } from "./auth-guard.js";
await requireAdminSession();

import { db } from "./firebase-config.js";
import { collection, getDocs } from "https://www.gstatic.com/firebasejs/10.12.2/firebase-firestore.js";
import { getPage, renderPagination, DEFAULT_PAGE_SIZE } from "./table-pagination.js";

let vendorCompliance = {};
let currentPage = 1;

async function loadCompliance() {
    try {
        const criticalList = document.getElementById("criticalList");
        if (criticalList) criticalList.innerHTML = Array(2).fill(`<div class="report-item"><div class="skeleton sk-text" style="width:50%;margin:0;"></div><div class="skeleton sk-text" style="width:30%;margin:0;"></div></div>`).join("");
        const warningList = document.getElementById("warningList");
        if (warningList) warningList.innerHTML = Array(2).fill(`<div class="report-item"><div class="skeleton sk-text" style="width:50%;margin:0;"></div><div class="skeleton sk-text" style="width:30%;margin:0;"></div></div>`).join("");
        const tableBody = document.getElementById("complianceTableBody");
        if (tableBody) tableBody.innerHTML = Array(4).fill(`<tr class="skeleton-row"><td><div class="skeleton sk-text"></div></td><td><div class="skeleton sk-text" style="width:40%;"></div></td><td><div class="skeleton sk-badge"></div></td></tr>`).join("");

        const snapshot = await getDocs(collection(db, "inspections"));
        vendorCompliance = {};
        snapshot.forEach(docSnap => {
            const data = docSnap.data();
            const vendor = data.vendorName || "Unknown Vendor";
            if (!vendorCompliance[vendor]) vendorCompliance[vendor] = { spoiledSessions: 0 };
            const hasSpoiled = (data.scanHistory || []).some(scan => (scan.label || "").toLowerCase().includes("spoiled"));
            if (hasSpoiled) vendorCompliance[vendor].spoiledSessions++;
        });
        currentPage = 1;
        renderCompliance();
    } catch (error) {
        console.error("Error loading compliance:", error);
    }
}

function getStatus(count) {
    if (count >= 3) return "CRITICAL";
    if (count >= 1) return "WARNING";
    return "COMPLIANT";
}

function getBadge(status) {
    if (status === "CRITICAL") return `<span class="badge-critical">${status}</span>`;
    if (status === "WARNING") return `<span class="badge-warning">${status}</span>`;
    return `<span class="badge-compliant">${status}</span>`;
}

function renderCompliance() {
    const entries = Object.entries(vendorCompliance).sort((a, b) => b[1].spoiledSessions - a[1].spoiledSessions || a[0].localeCompare(b[0]));
    const critical = entries.filter(([, stats]) => stats.spoiledSessions >= 3);
    const warning = entries.filter(([, stats]) => stats.spoiledSessions >= 1 && stats.spoiledSessions < 3);

    const criticalList = document.getElementById("criticalList");
    if (criticalList) criticalList.innerHTML = critical.length ? critical.map(([vendor, stats]) => `<div class="report-item"><span>${vendor}</span><span>${stats.spoiledSessions} sessions</span></div>`).join("") : `<div class="report-item"><span>No critical vendors</span></div>`;
    const warningList = document.getElementById("warningList");
    if (warningList) warningList.innerHTML = warning.length ? warning.map(([vendor, stats]) => `<div class="report-item"><span>${vendor}</span><span>${stats.spoiledSessions} sessions</span></div>`).join("") : `<div class="report-item"><span>No warning vendors</span></div>`;

    const page = getPage(entries, currentPage, DEFAULT_PAGE_SIZE);
    currentPage = page.currentPage;
    const tableBody = document.getElementById("complianceTableBody");
    if (tableBody) {
        tableBody.innerHTML = page.pageItems.length ? page.pageItems.map(([vendor, stats]) => {
            const status = getStatus(stats.spoiledSessions);
            return `<tr><td>${vendor}</td><td>${stats.spoiledSessions}</td><td>${getBadge(status)}</td></tr>`;
        }).join("") : `<tr><td colspan="3" class="empty-table">No compliance records found.</td></tr>`;
    }

    renderPagination("compliancePagination", page, nextPage => {
        currentPage = nextPage;
        renderCompliance();
    }, "vendors");
}

if (document.readyState === "loading") document.addEventListener("DOMContentLoaded", loadCompliance, { once: true });
else loadCompliance();
