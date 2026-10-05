class GlobalHeader extends HTMLElement {
    connectedCallback() {
        const backUrl = this.getAttribute('back-url');
        const current = (window.location.pathname.split('/').pop() || 'index.html').toLowerCase();

        const isVerify = current === 'index.html' || current === '' || current === 'details.html' || current === 'certificate.html';
        const isWarnings = current === 'warnings.html';

        const backBtn = backUrl
            ? `<button class="qm-back" type="button" aria-label="Go back" onclick="window.location.href='${backUrl}'"><span class="material-symbols-outlined">arrow_back</span><span>Back</span></button>`
            : '';

        this.innerHTML = `
            <header class="vendor-header">
                <div class="vendor-header-inner">
                    <div class="vendor-brand-wrap">
                        ${backBtn}
                        <a class="vendor-brand" href="index.html" aria-label="QualiMeat home">
                            <img src="assets/qualimeat-logo.png" alt="QualiMeat logo">
                            <div>
                                <strong>QualiMeat</strong>
                                <small>Safe Meat. Healthy People.</small>
                            </div>
                        </a>
                    </div>
                    <nav class="vendor-nav" aria-label="Vendor portal navigation">
                        <a href="index.html" class="${isVerify ? 'active' : ''}"><span class="material-symbols-outlined">verified_user</span>Verify</a>
                        <a href="warnings.html" class="${isWarnings ? 'active' : ''}"><span class="material-symbols-outlined">warning</span>Warnings</a>
                        <a href="../index.html"><span class="material-symbols-outlined">apps</span>Portals</a>
                    </nav>
                    <div class="vendor-live"><span class="dot"></span><span>Live records</span></div>
                </div>
            </header>`;
    }
}
customElements.define('global-header', GlobalHeader);
