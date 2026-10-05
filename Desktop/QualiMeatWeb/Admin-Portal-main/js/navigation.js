(() => {
  const prefetched = new Set();

  function prefetch(url) {
    if (!url || prefetched.has(url)) return;
    const parsed = new URL(url, window.location.href);
    if (parsed.origin !== window.location.origin) return;
    if (!parsed.pathname.endsWith('.html')) return;

    prefetched.add(url);
    const link = document.createElement('link');
    link.rel = 'prefetch';
    link.href = url;
    link.as = 'document';
    document.head.appendChild(link);
  }

  document.addEventListener('pointerover', event => {
    const anchor = event.target.closest('a[href]');
    if (anchor) prefetch(anchor.href);
  }, { passive: true });

  document.addEventListener('focusin', event => {
    const anchor = event.target.closest?.('a[href]');
    if (anchor) prefetch(anchor.href);
  });

  document.addEventListener('click', event => {
    const anchor = event.target.closest('a[href]');
    if (!anchor) return;
    const url = new URL(anchor.href, window.location.href);
    if (url.origin !== window.location.origin) return;
    document.body.classList.remove('sidebar-open');
    document.documentElement.classList.add('qm-navigating');
  });

  // Warm the most frequently used pages when the browser is idle.
  const warm = () => [
    'dashboard.html', 'inspections.html', 'inspection_history.html',
    'information.html', 'compliance.html', 'reports.html', 'profile.html'
  ].forEach(prefetch);

  if ('requestIdleCallback' in window) requestIdleCallback(warm, { timeout: 1800 });
  else setTimeout(warm, 800);
})();
