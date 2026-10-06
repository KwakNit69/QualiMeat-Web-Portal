import { requireAdminSession } from "./auth-guard.js";
await requireAdminSession();

import { db } from "./firebase-config.js";
import { collection, getDocs, deleteDoc, doc } from "https://www.gstatic.com/firebasejs/10.12.2/firebase-firestore.js";
import { getPage, renderPagination, DEFAULT_PAGE_SIZE } from "./table-pagination.js";

let inspections = [];
let inspectors = [];
let stalls = [];
let filterText = "";
let inspectorPage = 1;
let stallPage = 1;

async function loadPage() {
    try {
        const inspectorBody = document.getElementById("inspectorTableBody");
        if (inspectorBody) inspectorBody.innerHTML = Array(3).fill(`<tr class="skeleton-row"><td><div class="skeleton sk-text" style="width:60%;"></div></td><td><div class="skeleton sk-text" style="width:40%;"></div></td></tr>`).join("");
        const stallBody = document.getElementById("stallTableBody");
        if (stallBody) stallBody.innerHTML = Array(4).fill(`<tr class="skeleton-row"><td><div class="skeleton sk-text" style="width:30%;"></div></td><td><div class="skeleton sk-text" style="width:70%;"></div></td><td><div class="skeleton sk-badge"></div></td></tr>`).join("");

        const [userSnap, stallSnap, inspectSnap] = await Promise.all([
            getDocs(collection(db, "users")),
            getDocs(collection(db, "stalls")),
            getDocs(collection(db, "inspections"))
        ]);

        inspections = inspectSnap.docs.map(d => ({ id: d.id, ...d.data() }));
        inspectors = userSnap.docs.map(d => ({ id: d.id, ...d.data() }));
        stalls = stallSnap.docs.map(d => ({ id: d.id, ...d.data() }));

        renderRegistry();
    } catch (error) {
        console.error("Error loading page data:", error);
    }
}

function matches(value, query) {
    return String(value ?? "").toLowerCase().includes(query);
}

function renderRegistry() {
    const q = filterText.trim().toLowerCase();
    const filteredInspectors = inspectors
        .filter(item => !q || matches(item.fullName, q) || matches(item.jobTitle, q) || matches(item.email, q))
        .sort((a, b) => String(a.fullName || "").localeCompare(String(b.fullName || "")));
    const filteredStalls = stalls
        .filter(item => !q || matches(item.stallNumber, q) || matches(item.vendorName, q))
        .sort((a, b) => String(a.stallNumber || "").localeCompare(String(b.stallNumber || ""), undefined, { numeric: true }));

    renderInspectors(filteredInspectors);
    renderStalls(filteredStalls);

    const count = document.getElementById("registryFilterCount");
    if (count) {
        count.textContent = q
            ? `${filteredInspectors.length} inspector${filteredInspectors.length === 1 ? "" : "s"} • ${filteredStalls.length} stall${filteredStalls.length === 1 ? "" : "s"}`
            : `${inspectors.length} inspectors • ${stalls.length} stalls`;
    }
}

function renderInspectors(rows) {
    const tbody = document.getElementById("inspectorTableBody");
    if (!tbody) return;
    const page = getPage(rows, inspectorPage, DEFAULT_PAGE_SIZE);
    inspectorPage = page.currentPage;
    tbody.innerHTML = page.pageItems.length ? page.pageItems.map(data => {
        const encodedName = encodeURIComponent(data.fullName || "Unknown");
        return `<tr><td><button type="button" class="table-link" onclick="showInspector(decodeURIComponent('${encodedName}'))">${data.fullName || "Unknown"}</button></td><td>${data.jobTitle || data.role || "-"}</td></tr>`;
    }).join("") : `<tr><td colspan="2" class="empty-table">No inspectors match this filter.</td></tr>`;
    renderPagination("inspectorPagination", page, next => { inspectorPage = next; renderInspectors(rows); }, "inspectors");
}

function renderStalls(rows) {
    const tbody = document.getElementById("stallTableBody");
    if (!tbody) return;
    const page = getPage(rows, stallPage, DEFAULT_PAGE_SIZE);
    stallPage = page.currentPage;
    tbody.innerHTML = page.pageItems.length ? page.pageItems.map(data => {
        const stallNumber = String(data.stallNumber ?? "-");
        const qrData = `${stallNumber},${data.vendorName || "Unknown"}`;
        return `<tr>
            <td><button type="button" class="table-link" onclick="showStall(decodeURIComponent('${encodeURIComponent(stallNumber)}'))">${stallNumber}</button></td>
            <td>${data.vendorName || "Unknown"}</td>
            <td><button class="qr-btn" onclick="showQR(decodeURIComponent('${encodeURIComponent(qrData)}'))">View QR</button></td>
        </tr>`;
    }).join("") : `<tr><td colspan="3" class="empty-table">No stalls match this filter.</td></tr>`;
    renderPagination("stallPagination", page, next => { stallPage = next; renderStalls(rows); }, "stalls");
}

window.openModal = function(content) {
    const modalContent = document.getElementById("modalContent");
    const modalOverlay = document.getElementById("modalOverlay");
    if (modalContent && modalOverlay) { modalContent.innerHTML = content; modalOverlay.classList.remove("hidden"); }
};
window.closeModal = function() { document.getElementById("modalOverlay")?.classList.add("hidden"); };

window.showInspector = function(name) {
    const sessions = inspections.filter(i => i.inspectorName === name);
    openModal(`
        <div class="profile-header"><div class="profile-avatar-fallback">${(name || "?").charAt(0).toUpperCase()}</div><div><h2>${name}</h2><p>Total Sessions: ${sessions.length}</p></div></div>
        <h3>Inspection Sessions</h3>
        <div class="modal-session-list">${sessions.length ? sessions.map(s => `<div class="session-item"><strong>${s.vendorName || "Unknown"}</strong><br>Stall: ${s.stallNumber ?? "-"}<br>Date: ${s.timestamp?.toDate ? s.timestamp.toDate().toLocaleDateString() : "-"}<br><button class="delete-btn" onclick="deleteOne('${s.id}')">Delete</button></div>`).join("") : '<div class="empty-state-compact">No inspection sessions.</div>'}</div>
        <div class="modal-actions"><button class="delete-btn" onclick="deleteAllInspector(decodeURIComponent('${encodeURIComponent(name)}'))">Delete All Sessions</button><button class="close-btn" onclick="closeModal()">Close</button></div>`);
};

window.showStall = async function(stallNumber) {
    const stallData = stalls.find(s => String(s.stallNumber) === String(stallNumber));
    const sessions = inspections.filter(i => String(i.stallNumber) === String(stallNumber));
    openModal(`
        <div class="profile-header"><img src="${stallData?.stallImageUrl || "https://via.placeholder.com/90"}" alt="Stall ${stallNumber}"><div><h2>Stall ${stallNumber}</h2><p>Vendor: ${stallData?.vendorName || "Unknown"}</p><p>Total Sessions: ${sessions.length}</p></div></div>
        <h3>Inspection Sessions</h3>
        <div class="modal-session-list">${sessions.length ? sessions.map(s => `<div class="session-item"><strong>${s.vendorName || "Unknown"}</strong><br>Inspector: ${s.inspectorName || "Unknown"}<br>Date: ${s.timestamp?.toDate ? s.timestamp.toDate().toLocaleDateString() : "-"}<br><button class="delete-btn" onclick="deleteOne('${s.id}')">Delete</button></div>`).join("") : '<div class="empty-state-compact">No inspection sessions.</div>'}</div>
        <div class="modal-actions"><button class="delete-btn" onclick="deleteAllStall(decodeURIComponent('${encodeURIComponent(String(stallNumber))}'))">Delete All Sessions</button><button class="close-btn" onclick="closeModal()">Close</button></div>`);
};

window.deleteOne = async id => { await deleteDoc(doc(db, "inspections", id)); location.reload(); };
window.deleteAllInspector = async name => { for (const row of inspections.filter(i => i.inspectorName === name)) await deleteDoc(doc(db, "inspections", row.id)); location.reload(); };
window.deleteAllStall = async stallNumber => { for (const row of inspections.filter(i => String(i.stallNumber) === String(stallNumber))) await deleteDoc(doc(db, "inspections", row.id)); location.reload(); };
window.showQR = function(data) {
    openModal(`<h2 style="text-align:center;">Stall QR Code</h2><div style="display:flex;justify-content:center;margin:20px 0;"><img src="https://api.qrserver.com/v1/create-qr-code/?size=220x220&data=${encodeURIComponent(data)}" alt="QR code"></div><p style="text-align:center;color:#64748b;">${data}</p><div style="text-align:center;"><button class="close-btn" onclick="closeModal()">Close</button></div>`);
};

function initInformationPage() {
    const filter = document.getElementById("registryFilter");
    if (filter) {
        filter.addEventListener("input", event => {
            filterText = event.target.value;
            inspectorPage = 1;
            stallPage = 1;
            renderRegistry();
        });
    }
    loadPage();
}

if (document.readyState === "loading") document.addEventListener("DOMContentLoaded", initInformationPage, { once: true });
else initInformationPage();
