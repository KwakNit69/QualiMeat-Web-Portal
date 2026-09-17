import { logout } from "./auth.js";

document.addEventListener("DOMContentLoaded", () => {
  const container = document.getElementById("sidebar-container");

  if (!container) return;

  container.innerHTML = `
    <aside class="sidebar">
      <div class="logo">
        <span>QualiMeat</span>
        <small>TAGUM CITY • FOOD SAFETY</small>
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

      <button id="logoutBtn" class="logout-btn"><span class="material-symbols-outlined">logout</span>Log out</button>
    </aside>
  `;

  const mobileToggle = document.createElement("button");
  mobileToggle.className = "sidebar-toggle";
  mobileToggle.type = "button";
  mobileToggle.setAttribute("aria-label", "Toggle navigation");
  mobileToggle.innerHTML = '<span class="material-symbols-outlined">menu</span>';
  mobileToggle.addEventListener("click", () => document.body.classList.toggle("sidebar-open"));
  document.body.appendChild(mobileToggle);

  /* ACTIVE LINK */
  const links = container.querySelectorAll(".menu a");
  const currentPage = window.location.pathname.split("/").pop();

  links.forEach(link => {
    if (link.getAttribute("href") === currentPage) {
      link.classList.add("active");
    }
  });

  /* 🔥 LOGOUT FIX (REAL FIX) */
  const logoutBtn = document.getElementById("logoutBtn");

  if (logoutBtn) {
    logoutBtn.addEventListener("click", () => {
      logout();
    });
  }
});
