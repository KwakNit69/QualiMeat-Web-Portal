import { db } from "./firebase-config.js";
import {
  collection,
  getDocs,
  limit,
  query,
  where
} from "https://www.gstatic.com/firebasejs/10.8.0/firebase-firestore.js";

export function parseStallNumber(rawValue) {
  const raw = decodeURIComponent(String(rawValue ?? "")).trim();
  if (!raw) return "";

  const labeledMatch = raw.match(/stall\s*(?:number|no\.?|id)?\s*:\s*([^,;|\n]+)/i);
  if (labeledMatch) return labeledMatch[1].trim();

  if (raw.includes(",")) return raw.split(",")[0].trim();
  return raw;
}

export async function findRegisteredStall(rawValue) {
  const stallNumber = parseStallNumber(rawValue);
  if (!stallNumber) return { found: false, stallNumber: "", doc: null, data: null };

  const stallsRef = collection(db, "stalls");
  let snap = await getDocs(query(stallsRef, where("stallNumber", "==", stallNumber), limit(1)));

  // Some older Firestore records may have saved a numeric stallNumber.
  if (snap.empty && /^\d+(?:\.\d+)?$/.test(stallNumber)) {
    const numericValue = Number(stallNumber);
    snap = await getDocs(query(stallsRef, where("stallNumber", "==", numericValue), limit(1)));
  }

  if (snap.empty) {
    return { found: false, stallNumber, doc: null, data: null };
  }

  const stallDoc = snap.docs[0];
  return {
    found: true,
    stallNumber: String(stallDoc.data().stallNumber ?? stallNumber),
    doc: stallDoc,
    data: stallDoc.data()
  };
}

function ensureDialog() {
  let dialog = document.getElementById("qm-stall-error-dialog");
  if (dialog) return dialog;

  dialog = document.createElement("dialog");
  dialog.id = "qm-stall-error-dialog";
  dialog.className = "qm-error-dialog";
  dialog.innerHTML = `
    <div class="qm-error-dialog-card">
      <div class="qm-error-dialog-icon" aria-hidden="true">
        <span class="material-symbols-outlined">storefront</span>
      </div>
      <div class="qm-error-dialog-copy">
        <span class="qm-error-dialog-kicker">VERIFICATION FAILED</span>
        <h2 id="qm-stall-error-title">Not a Registered Stall</h2>
        <p id="qm-stall-error-message"></p>
        <div class="qm-error-dialog-actions">
          <button id="qm-stall-error-close" type="button">Try Again</button>
        </div>
      </div>
    </div>`;

  document.body.appendChild(dialog);
  return dialog;
}

export function showStallErrorDialog(stallNumber, { onClose } = {}) {
  const dialog = ensureDialog();
  const message = dialog.querySelector("#qm-stall-error-message");
  const closeButton = dialog.querySelector("#qm-stall-error-close");

  const shownValue = String(stallNumber || "").trim();
  message.textContent = shownValue
    ? `Stall ${shownValue} is not registered in the QualiMeat stall registry. Please check the stall number or scan an official QualiMeat QR code.`
    : "This QR code or stall number is not registered in the QualiMeat stall registry. Please verify the information and try again.";

  const close = () => {
    if (dialog.open) dialog.close();
    if (typeof onClose === "function") onClose();
  };

  closeButton.onclick = close;
  dialog.oncancel = (event) => {
    event.preventDefault();
    close();
  };
  dialog.onclick = (event) => {
    if (event.target === dialog) close();
  };

  if (typeof dialog.showModal === "function") {
    if (!dialog.open) dialog.showModal();
  } else {
    alert(message.textContent);
    if (typeof onClose === "function") onClose();
  }
}

export function showVendorMismatchDialog(stallNumber, expectedVendor) {
  const dialog = ensureDialog();
  dialog.querySelector("#qm-stall-error-title").textContent = "Vendor Name Does Not Match";
  dialog.querySelector("#qm-stall-error-message").textContent =
    `Stall ${stallNumber} is registered, but the vendor name entered does not match ${expectedVendor || "the registered vendor"}. Please check the details and try again.`;
  const closeButton = dialog.querySelector("#qm-stall-error-close");
  closeButton.onclick = () => dialog.close();
  if (typeof dialog.showModal === "function") dialog.showModal();
  else alert(dialog.querySelector("#qm-stall-error-message").textContent);
}
