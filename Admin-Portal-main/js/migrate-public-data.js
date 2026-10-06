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

function sanitizeScanHistory(history) {
  if (!Array.isArray(history)) return [];
  return history.map((scan) => ({
    cut: scan?.cut || "Unknown Cut",
    label: scan?.label || "Unknown",
    ...(scan?.imageUrl ? { imageUrl: scan.imageUrl } : {})
  }));
}

async function clearCollection(name) {
  const snap = await getDocs(collection(db, name));
  const operations = snap.docs.map((item) => (batch) => batch.delete(item.ref));
  await commitOperations(operations);
  return snap.size;
}

async function rebuild() {
  button.disabled = true;
  status.textContent = "Starting rebuild…";

  try {
    const removedLogs = await clearCollection("publicInspectionLogs");
    const removedCerts = await clearCollection("publicCertificates");
    log(`Removed ${removedLogs} old public inspection document(s).`);
    log(`Removed ${removedCerts} old public certificate document(s).`);

    const inspections = await getDocs(collection(db, "inspections"));
    const inspectionOps = [];

    inspections.forEach((item) => {
      const data = item.data();
      const safeHistory = sanitizeScanHistory(data.scanHistory);
      const passed = safeHistory.length > 0 && safeHistory.every(
        (scan) => String(scan.label).toLowerCase() === "fresh"
      );

      const target = doc(db, "publicInspectionLogs", item.id);
      inspectionOps.push((batch) => batch.set(target, {
        inspectionId: item.id,
        vendorName: data.vendorName || "",
        stallNumber: data.stallNumber || "",
        inspectorName: data.inspectorName || "",
        scanHistory: safeHistory,
        resultStatus: passed ? "PASSED" : "FLAGGED",
        certificateStatus: passed ? "ACTIVE" : "NOT_ISSUED",
        timestamp: data.timestamp || null
      }));
    });

    await commitOperations(inspectionOps);
    log(`Created ${inspections.size} public inspection document(s).`);

    const certificates = await getDocs(collection(db, "certificates"));
    const certificateOps = [];

    certificates.forEach((item) => {
      const data = item.data();
      const target = doc(db, "publicCertificates", item.id);
      const publicData = {
        certificateId: item.id,
        vendorName: data.vendorName || "",
        stallNumber: data.stallNumber || "",
        issuedBy: data.issuedBy || "",
        issuedAt: data.issuedAt || null,
        validUntil: data.validUntil || null,
        status: data.status || "Active"
      };
      if (data.inspectionId) publicData.inspectionId = data.inspectionId;
      if (data.signatureUrl) publicData.signatureUrl = data.signatureUrl;
      if (data.issuedByUid) publicData.issuedByUid = data.issuedByUid;
      if (data.issuedByJobTitle) publicData.issuedByJobTitle = data.issuedByJobTitle;
      if (data.jobTitle) publicData.jobTitle = data.jobTitle;

      certificateOps.push((batch) => batch.set(target, publicData));
    });

    await commitOperations(certificateOps);
    log(`Created ${certificates.size} public certificate document(s).`);
    log("DONE. The Vendor Portal can now use only public-safe collections.");
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
  if (confirm("Rebuild the two public collections from private data?")) rebuild();
});
