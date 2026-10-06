import { db } from "./firebase-config.js";
import { requireAdminSession } from "./auth-guard.js";
import {
  collection,
  doc,
  getDocs,
  writeBatch
} from "https://www.gstatic.com/firebasejs/10.12.2/firebase-firestore.js";

const button = document.getElementById("migrateBtn");
const status = document.getElementById("status");

function log(message) {
  status.textContent += `\n${message}`;
}

async function commitOperations(operations, chunkSize = 400) {
  for (let i = 0; i < operations.length; i += chunkSize) {
    const batch = writeBatch(db);
    for (const op of operations.slice(i, i + chunkSize)) op(batch);
    await batch.commit();
  }
}

function normalizeHistory(history) {
  return Array.isArray(history) ? history : [];
}

async function consolidate() {
  button.disabled = true;
  status.textContent = "Starting consolidation…";

  try {
    const inspections = await getDocs(collection(db, "inspections"));
    const inspectionOps = [];

    inspections.forEach((item) => {
      const data = item.data();
      const history = normalizeHistory(data.scanHistory);
      const passed = history.length > 0 && history.every(
        (scan) => String(scan?.label || "").trim().toLowerCase() === "fresh"
      );

      inspectionOps.push((batch) => batch.set(item.ref, {
        inspectionId: item.id,
        isPassed: passed,
        resultStatus: passed ? "PASSED" : "FLAGGED"
      }, { merge: true }));
    });

    await commitOperations(inspectionOps);
    log(`Normalized ${inspections.size} inspection document(s).`);

    const certificates = await getDocs(collection(db, "certificates"));
    const certificateOps = [];
    let linked = 0;
    let skipped = 0;

    certificates.forEach((item) => {
      const data = item.data();
      const inspectionId = String(data.inspectionId || "").trim();
      if (!inspectionId) {
        skipped++;
        return;
      }

      const target = doc(db, "inspections", inspectionId);
      certificateOps.push((batch) => batch.set(target, {
        certificate: {
          certificateId: data.certificateId || item.id,
          inspectionId,
          vendorName: data.vendorName || "",
          stallNumber: data.stallNumber || "",
          issuedBy: data.issuedBy || "",
          issuedByUid: data.issuedByUid || null,
          issuedByJobTitle: data.issuedByJobTitle || data.jobTitle || "Inspector",
          signatureUrl: data.signatureUrl || null,
          issuedAt: data.issuedAt || null,
          validUntil: data.validUntil || null,
          status: data.status || "Active"
        }
      }, { merge: true }));
      linked++;
    });

    await commitOperations(certificateOps);
    log(`Merged ${linked} legacy certificate(s) into inspections.`);
    if (skipped) log(`Skipped ${skipped} certificate(s) without an inspectionId.`);
    log("DONE. The app and Vendor Portal can now use the inspections collection directly.");
  } catch (error) {
    console.error(error);
    log(`ERROR: ${error.message || error}`);
  } finally {
    button.disabled = false;
  }
}

await requireAdminSession();
status.textContent = "Administrator verified. Click the button when ready.";
button.addEventListener("click", () => {
  if (confirm("Consolidate legacy certificate data into the inspections collection?")) consolidate();
});
