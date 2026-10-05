document.addEventListener("DOMContentLoaded", () => {
  const header = document.getElementById("header");
  const nav = document.getElementById("nav");
  const menuToggle = document.getElementById("menuToggle");
  const links = [...document.querySelectorAll(".nav-link")];
  const sections = [...document.querySelectorAll("main section[id]")];
  const form = document.getElementById("contactForm");
  const formNote = document.getElementById("formNote");
  const year = document.getElementById("year");

  if (year) {
    year.textContent = new Date().getFullYear();
  }

  function headerHeight() {
    return header ? header.getBoundingClientRect().height : 76;
  }

  function setActive(id) {
    links.forEach(link => {
      const target = (link.getAttribute("href") || "").slice(1);
      const active = target === id;

      link.classList.toggle("active", active);

      if (active) {
        link.setAttribute("aria-current", "page");
      } else {
        link.removeAttribute("aria-current");
      }
    });
  }

  /*
   * Find the section that occupies the largest
   * visible area of the browser.
   */
  function getVisibleSection() {
    const top = headerHeight();
    const bottom = window.innerHeight;

    let bestSection = sections[0];
    let bestVisible = -1;

    sections.forEach(section => {
      const rect = section.getBoundingClientRect();

      const visibleTop = Math.max(rect.top, top);
      const visibleBottom = Math.min(rect.bottom, bottom);

      const visibleHeight = Math.max(
        0,
        visibleBottom - visibleTop
      );

      if (visibleHeight > bestVisible) {
        bestVisible = visibleHeight;
        bestSection = section;
      }
    });

    return bestSection;
  }

  function updateActiveSection() {
    if (!sections.length) return;

    const current = getVisibleSection();

    if (current) {
      setActive(current.id);
    }
  }

  /*
   * Scroll the selected section so that its top
   * starts directly below the fixed navigation bar.
   */
  function goToSection(id, behavior = "smooth") {
    const section = document.getElementById(id);

    if (!section) return;

    const top =
      section.getBoundingClientRect().top +
      window.scrollY -
      headerHeight();

    window.scrollTo({
      top: Math.max(0, top),
      behavior
    });

    setActive(id);
  }

  /*
   * NAVIGATION
   */
  links.forEach(link => {
    link.addEventListener("click", event => {
      const href = link.getAttribute("href");

      if (!href || !href.startsWith("#")) {
        return;
      }

      const id = href.slice(1);

      if (!document.getElementById(id)) {
        return;
      }

      event.preventDefault();

      setActive(id);

      nav?.classList.remove("open");

      menuToggle?.setAttribute(
        "aria-expanded",
        "false"
      );

      history.pushState(
        null,
        "",
        "#" + id
      );

      goToSection(id, "smooth");
    });
  });

  /*
   * LOGO -> HOME
   */
  document
    .querySelector(".brand")
    ?.addEventListener("click", event => {

      event.preventDefault();

      history.pushState(
        null,
        "",
        "#home"
      );

      setActive("home");

      goToSection(
        "home",
        "smooth"
      );
    });

  /*
   * SCROLL TRACKING
   */
  let ticking = false;

  window.addEventListener(
    "scroll",
    () => {

      if (ticking) return;

      ticking = true;

      requestAnimationFrame(() => {

        updateActiveSection();

        ticking = false;

      });

    },
    {
      passive: true
    }
  );

  /*
   * WINDOW RESIZE
   */
  window.addEventListener(
    "resize",
    updateActiveSection
  );

  /*
   * BROWSER BACK / FORWARD
   */
  window.addEventListener(
    "popstate",
    () => {

      const id =
        window.location.hash.slice(1) ||
        "home";

      if (document.getElementById(id)) {

        goToSection(
          id,
          "smooth"
        );

      } else {

        goToSection(
          "home",
          "smooth"
        );

      }
    }
  );

  /*
   * INITIAL PAGE LOAD
   */
  const initialId =
    window.location.hash.slice(1) ||
    "home";

  requestAnimationFrame(() => {

    if (
      document.getElementById(initialId)
    ) {

      goToSection(
        initialId,
        "auto"
      );

    } else {

      goToSection(
        "home",
        "auto"
      );

    }

  });

  /*
   * MOBILE MENU
   */
  menuToggle?.addEventListener(
    "click",
    () => {

      const isOpen =
        nav?.classList.toggle("open") ||
        false;

      menuToggle.setAttribute(
        "aria-expanded",
        String(isOpen)
      );

    }
  );

  /*
   * CONTACT FORM
   */
  form?.addEventListener(
    "submit",
    event => {

      event.preventDefault();

      if (formNote) {

        formNote.textContent =
          "Thanks! Your message has been prepared.";

      }

      form.reset();

    }
  );

});

/* =========================================================
   SCROLL REVEAL ANIMATIONS
========================================================= */

const revealElements = document.querySelectorAll(
  ".section-label, " +
  ".section-title, " +
  ".fact-card, " +
  ".single-image-frame, " +
  ".stack-card, " +
  ".project-card, " +
  ".service-card, " +
  ".contact-copy, " +
  ".contact-form, " +
  ".quote"
);


const revealObserver = new IntersectionObserver(
  (entries, observer) => {

    entries.forEach((entry) => {

      if (!entry.isIntersecting) {
        return;
      }

      entry.target.classList.add("show");

      observer.unobserve(entry.target);

    });

  },
  {
    threshold: 0.15,
    rootMargin: "0px 0px -60px 0px"
  }
);


revealElements.forEach((element) => {

  revealObserver.observe(element);

});