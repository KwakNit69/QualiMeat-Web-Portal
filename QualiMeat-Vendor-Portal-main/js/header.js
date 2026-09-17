class GlobalHeader extends HTMLElement {
    connectedCallback() {
        const backUrl = this.getAttribute('back-url');
        const backBtn = backUrl
            ? `<button class="back-btn" type="button" aria-label="Go back" onclick="window.location.href='${backUrl}'"><span class="material-symbols-outlined">arrow_back</span> Back</button>`
            : '';

        this.innerHTML = `
            <header class="app-bar">
                <div class="brand">
                    ${backBtn}
                    <span class="material-symbols-outlined" aria-hidden="true" style="color:var(--primary);font-size:28px">health_and_safety</span>
                    <div>
                        <h2>QualiMeat</h2>
                        <small>Vendor verification portal</small>
                    </div>
                </div>
                <div class="live-indicator" aria-label="Live records">
                    <span class="dot" aria-hidden="true"></span>
                    Live records
                </div>
            </header>`;
    }
}
customElements.define('global-header', GlobalHeader);
