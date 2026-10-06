import {
  findRegisteredStall,
  showStallErrorDialog,
  showVendorMismatchDialog
} from "./stall-validation.js";

const html5QrCode = new Html5Qrcode("reader");
let isCameraRunning = false;
let verificationInProgress = false;

function setVerificationBusy(isBusy) {
  verificationInProgress = isBusy;
  const submit = document.getElementById("submit-manual-btn");
  if (submit) {
    submit.disabled = isBusy;
    submit.textContent = isBusy ? "Checking Registry..." : "Verify Vendor";
  }
}

async function verifyAndOpen(rawValue, vendorName = "") {
  if (verificationInProgress) return;
  setVerificationBusy(true);

  try {
    const result = await findRegisteredStall(rawValue);

    if (!result.found) {
      showStallErrorDialog(result.stallNumber || rawValue);
      return false;
    }

    const typedVendor = vendorName.trim().toLowerCase();
    const registeredVendor = String(result.data?.vendorName || "").trim();

    if (typedVendor && registeredVendor && typedVendor !== registeredVendor.toLowerCase()) {
      showVendorMismatchDialog(result.stallNumber, registeredVendor);
      return false;
    }

    window.location.href = `details.html?id=${encodeURIComponent(result.stallNumber)}`;
    return true;
  } catch (error) {
    console.error("Stall verification failed:", error);
    showStallErrorDialog(rawValue);
    return false;
  } finally {
    setVerificationBusy(false);
  }
}

async function onScanSuccess(decodedText) {
  await stopCamera();
  const opened = await verifyAndOpen(decodedText);
  if (!opened) startCamera();
}

async function startCamera() {
  try {
    if (isCameraRunning || verificationInProgress) return;

    await html5QrCode.start(
      { facingMode: "environment" },
      { fps: 15, qrbox: 250 },
      onScanSuccess
    );

    isCameraRunning = true;
  } catch (err) {
    console.error("Camera failed:", err);
  }
}

async function stopCamera() {
  try {
    if (!isCameraRunning) return;
    await html5QrCode.stop();
    isCameraRunning = false;
  } catch (err) {
    console.error("Stop camera error:", err);
  }
}

const qrInput = document.getElementById("qr-input");
qrInput?.addEventListener("change", async (e) => {
  const file = e.target.files?.[0];
  if (!file) return;

  try {
    await stopCamera();
    const decodedText = await html5QrCode.scanFile(file, true);
    const opened = await verifyAndOpen(decodedText);
    if (!opened) startCamera();
  } catch (err) {
    console.error("Upload QR failed:", err);
    alert("QR code not detected. Please upload a clearer image.");
    startCamera();
  } finally {
    e.target.value = "";
  }
});

const scannerView = document.getElementById("scanner-view");
const manualView = document.getElementById("manual-view");
const showManualBtn = document.getElementById("show-manual-btn");
const backToScannerBtn = document.getElementById("back-to-scanner-btn");
const submitManualBtn = document.getElementById("submit-manual-btn");

showManualBtn?.addEventListener("click", async () => {
  await stopCamera();
  scannerView.style.display = "none";
  manualView.style.display = "block";
  document.getElementById("stall-id")?.focus();
});

backToScannerBtn?.addEventListener("click", () => {
  manualView.style.display = "none";
  scannerView.style.display = "block";
  startCamera();
});

submitManualBtn?.addEventListener("click", async () => {
  const stallId = document.getElementById("stall-id")?.value.trim() || "";
  const vendorName = document.getElementById("vendor-name")?.value.trim() || "";

  if (!stallId) {
    showStallErrorDialog("");
    return;
  }

  await verifyAndOpen(stallId, vendorName);
});

document.getElementById("stall-id")?.addEventListener("keydown", (event) => {
  if (event.key === "Enter") submitManualBtn?.click();
});

startCamera();
