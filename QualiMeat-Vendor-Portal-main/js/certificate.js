import { db } from "./firebase-config.js";
import {
    collection,
    doc,
    getDoc,
    getDocs,
    limit,
    query,
    where
} from "https://www.gstatic.com/firebasejs/10.8.0/firebase-firestore.js";

function escapeHtml(value) {
    return String(value ?? "")
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#39;");
}

async function resolveInspectorSignature(certificate = {}, fallbackInspectorName = "") {
    if (certificate.signatureUrl) {
        return {
            signatureUrl: certificate.signatureUrl,
            jobTitle: certificate.issuedByJobTitle || certificate.jobTitle || "Authorized Meat Inspector"
        };
    }

    if (certificate.issuedByUid) {
        try {
            const userSnap = await getDoc(doc(db, "users", certificate.issuedByUid));
            if (userSnap.exists()) {
                const user = userSnap.data();
                return {
                    signatureUrl: user.signatureUrl || "",
                    jobTitle: user.jobTitle || certificate.issuedByJobTitle || "Authorized Meat Inspector"
                };
            }
        } catch (error) {
            console.warn("Unable to load inspector by UID:", error);
        }
    }

    if (fallbackInspectorName) {
        try {
            const byNameQuery = query(
                collection(db, "users"),
                where("fullName", "==", fallbackInspectorName),
                limit(1)
            );
            const byNameSnap = await getDocs(byNameQuery);
            if (!byNameSnap.empty) {
                const user = byNameSnap.docs[0].data();
                return {
                    signatureUrl: user.signatureUrl || "",
                    jobTitle: user.jobTitle || certificate.issuedByJobTitle || "Authorized Meat Inspector"
                };
            }
        } catch (error) {
            console.warn("Unable to load inspector by name:", error);
        }
    }

    return {
        signatureUrl: "",
        jobTitle: certificate.issuedByJobTitle || certificate.jobTitle || "Authorized Meat Inspector"
    };
}

function renderSignature(signatureUrl, inspectorName, jobTitle) {
    const signatureImg = document.getElementById("certSignature");
    const signatureFallback = document.getElementById("signatureFallback");
    const inspectorField = document.getElementById("certInspector");
    const roleField = document.getElementById("certInspectorRole");

    inspectorField.textContent = inspectorName || "N/A";
    roleField.textContent = jobTitle || "Authorized Meat Inspector";

    if (signatureUrl) {
        signatureImg.src = signatureUrl;
        signatureImg.classList.remove("hidden");
        signatureFallback.classList.add("hidden");
    } else {
        signatureImg.removeAttribute("src");
        signatureImg.classList.add("hidden");
        signatureFallback.classList.remove("hidden");
    }
}

async function loadCertificate() {
    const params = new URLSearchParams(window.location.search);
    const sessionId = params.get("id");

    if (!sessionId) return;

    const ref = doc(db, "publicInspectionLogs", sessionId);
    const snap = await getDoc(ref);

    if (!snap.exists()) return;

    const data = snap.data();

    // Verify whether this inspection has a public certificate record.
    const certificateQuery = query(
        collection(db, "publicCertificates"),
        where("inspectionId", "==", sessionId)
    );
    const certificateSnap = await getDocs(certificateQuery);
    const certificateMeta = document.getElementById("certificateMeta");

    let certificate = null;
    let certificateDocId = "";

    if (!certificateSnap.empty) {
        const certificateDoc = certificateSnap.docs[0];
        certificate = certificateDoc.data();
        certificateDocId = certificateDoc.id;
        const validUntil = certificate.validUntil?.toDate
            ? certificate.validUntil.toDate().toLocaleDateString()
            : "-";
        certificateMeta.innerHTML = `
            <strong>Certificate ID:</strong> ${escapeHtml(certificate.certificateId || certificateDoc.id)}
            &nbsp; • &nbsp; <strong>Status:</strong> ${escapeHtml(certificate.status || "Active")}
            &nbsp; • &nbsp; <strong>Valid Until:</strong> ${escapeHtml(validUntil)}
        `;
    } else {
        certificateMeta.innerHTML = `<strong>Certificate status:</strong> No active public certificate was issued for this inspection.`;
    }

    const inspectorName = data.inspectorName || (certificate?.issuedBy) || "N/A";
    document.getElementById("certStall").textContent = data.stallNumber || "-";
    document.getElementById("certVendor").textContent = data.vendorName || "Unknown";

    const signatureInfo = await resolveInspectorSignature(certificate || {}, inspectorName);
    renderSignature(signatureInfo.signatureUrl, inspectorName, signatureInfo.jobTitle);

    // Format Date
    const dateObj = data.timestamp ? data.timestamp.toDate() : new Date();
    document.getElementById("certDate").textContent = dateObj.toLocaleDateString();

    let hasSpoiled = false;
    let aggregated = {};

    if (data.scanHistory) {
        data.scanHistory.forEach(scan => {
            const cut = scan.cut || "Unknown Cut";
            if (!aggregated[cut]) {
                aggregated[cut] = { total: 0, fresh: 0, spoiled: 0 };
            }

            aggregated[cut].total++;

            const label = String(scan.label || "").trim().toUpperCase();
            if (label === "SPOILED") {
                aggregated[cut].spoiled++;
                hasSpoiled = true;
            } else {
                aggregated[cut].fresh++;
            }
        });
    }

    let rowsHTML = "";
    for (const [cut, stats] of Object.entries(aggregated)) {
        rowsHTML += `
            <tr>
                <td style="font-weight: bold;">${escapeHtml(cut)}</td>
                <td>${stats.total}</td>
                <td class="fresh">${stats.fresh}</td>
                <td class="spoiled">${stats.spoiled}</td>
            </tr>
        `;
    }

    if (rowsHTML === "") {
        rowsHTML = `<tr><td colspan="4">No items scanned.</td></tr>`;
    }

    document.getElementById("certRows").innerHTML = rowsHTML;

    const note = document.getElementById("complianceNote");
    if (hasSpoiled) {
        note.innerHTML = `
            <div class="compliance-note warning">
                <strong>Notice of Condemnation:</strong><br>
                Spoiled meat items detected during this inspection must be immediately removed 
                from the display and disposed of according to standard sanitary protocols.
            </div>
        `;
    } else {
        note.innerHTML = `
            <div class="compliance-note safe">
                <strong>Clearance:</strong><br>
                All inspected items passed visual quality parameters and are cleared for retail display.
            </div>
        `;
    }
}

loadCertificate();
