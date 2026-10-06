import { auth, db } from "./firebase-config.js";
import { onAuthStateChanged, signOut } from "https://www.gstatic.com/firebasejs/10.12.2/firebase-auth.js";
import { doc, getDoc } from "https://www.gstatic.com/firebasejs/10.12.2/firebase-firestore.js";

const LOGOUT_MARKER = "qualimeat_logged_out";
let activeCheck = null;

function hideProtectedPage() {
  document.documentElement.style.visibility = "hidden";
}

function showProtectedPage() {
  document.documentElement.style.visibility = "";
}

function redirectToLogin() {
  hideProtectedPage();
  window.location.replace("index.html");
}

/**
 * Blocks every admin page unless the signed-in Firebase user has:
 * users/{uid}.role == "admin"
 * users/{uid}.enabled == true
 *
 * A logout marker is intentionally kept in sessionStorage until a new
 * successful login. This makes Back/Forward restoration fail closed.
 */
export function requireAdminSession({ force = false } = {}) {
  if (sessionStorage.getItem(LOGOUT_MARKER) === "1") {
    redirectToLogin();
    return Promise.reject(new Error("Session ended by logout."));
  }

  if (activeCheck && !force) return activeCheck;

  activeCheck = new Promise((resolve, reject) => {
    const unsubscribe = onAuthStateChanged(auth, async (user) => {
      unsubscribe();

      if (!user) {
        redirectToLogin();
        reject(new Error("Not authenticated."));
        return;
      }

      try {
        const snapshot = await getDoc(doc(db, "users", user.uid));
        const profile = snapshot.exists() ? snapshot.data() : null;

        if (profile?.role !== "admin" || profile?.enabled !== true) {
          sessionStorage.setItem(LOGOUT_MARKER, "1");
          await signOut(auth);
          redirectToLogin();
          reject(new Error("Administrator access required."));
          return;
        }

        showProtectedPage();
        resolve({ user, profile });
      } catch (error) {
        console.error("Authorization check failed:", error);
        sessionStorage.setItem(LOGOUT_MARKER, "1");
        try { await signOut(auth); } catch (_) {}
        redirectToLogin();
        reject(error);
      } finally {
        activeCheck = null;
      }
    });
  });

  return activeCheck;
}

// bfcache protection: a logged-out Admin page may be restored by the browser
// without running normal page-load code. pageshow always runs on restoration.
window.addEventListener("pageshow", () => {
  if (sessionStorage.getItem(LOGOUT_MARKER) === "1") {
    redirectToLogin();
    return;
  }

  requireAdminSession({ force: true }).catch(() => {});
});

// If a logout has happened, keep this cached document invisible when the
// browser stores/restores it. This prevents stale admin content flashing.
window.addEventListener("pagehide", () => {
  if (sessionStorage.getItem(LOGOUT_MARKER) === "1") {
    hideProtectedPage();
  }
});
