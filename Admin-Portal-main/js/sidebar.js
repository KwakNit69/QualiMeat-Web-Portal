import { requireAdminSession } from "./auth-guard.js";
import { logout } from "./auth.js";

const SIDEBAR_HTML = `
  <div class="logo">
    <img src="assets/qualimeat-logo.png" alt="QualiMeat logo">
    <span>QualiMeat</span>
    <small>SAFE MEAT. HEALTHY PEOPLE.</small>
  </div>
  <nav class="menu">
    <a href="dashboard.html"><span class="material-symbols-outlined">dashboard</span>Dashboard</a>
    <a href="inspections.html"><span class="material-symbols-outlined">fact_check</span>Inspections</a>
    <a href="inspection_history.html"><span class="material-symbols-outlined">history</span>Inspection history</a>
    <a href="information.html"><span class="material-symbols-outlined">storefront</span>Registry</a>
    <a href="compliance.html"><span class="material-symbols-outlined">verified_user</span>Compliance</a>
    <a href="reports.html"><span class="material-symbols-outlined">analytics</span>Reports</a>
    <a href="profile.html"><span class="material-symbols-outlined">account_circle</span>Profile</a>
  </nav>
  <button id="logoutBtn" class="logout-btn" type="button"><span class="material-symbols-outlined">logout</span>Log out</button>`;

function setupSidebar() {
  let sidebar = document.getElementById("sidebar-container");
  if (!sidebar) return;

  // Older pages may still contain an empty placeholder. Render only as fallback.
  if (!sidebar.querySelector(".menu")) {
    if (!sidebar.classList.contains("sidebar")) sidebar.classList.add("sidebar");
    sidebar.innerHTML = SIDEBAR_HTML;
  }

  const currentPage = window.location.pathname.split("/").pop() || "dashboard.html";
  sidebar.querySelectorAll(".menu a").forEach(link => {
    link.classList.toggle("active", link.getAttribute("href") === currentPage);
  });

  const logoutBtn = sidebar.querySelector("#logoutBtn");
  if (logoutBtn && !logoutBtn.dataset.bound) {
    logoutBtn.dataset.bound = "true";
    logoutBtn.addEventListener("click", logout);
  }

  if (!document.querySelector(".sidebar-toggle")) {
    const mobileToggle = document.createElement("button");
    mobileToggle.className = "sidebar-toggle";
    mobileToggle.type = "button";
    mobileToggle.setAttribute("aria-label", "Toggle navigation");
    mobileToggle.innerHTML = '<span class="material-symbols-outlined">menu</span>';
    mobileToggle.addEventListener("click", () => document.body.classList.toggle("sidebar-open"));
    document.body.appendChild(mobileToggle);
  }
}

// Hydrate the already-rendered shell immediately. Do not wait for Firebase.
if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", setupSidebar, { once: true });
} else {
  setupSidebar();
}

// Authorization still happens on every protected page, but it no longer delays the shell.
requireAdminSession().catch(error => {
  console.error("Admin session check failed:", error);
});
