export const DEFAULT_PAGE_SIZE = 10;

export function getPage(items, currentPage = 1, pageSize = DEFAULT_PAGE_SIZE) {
    const totalItems = items.length;
    const totalPages = Math.max(1, Math.ceil(totalItems / pageSize));
    const safePage = Math.min(Math.max(1, currentPage), totalPages);
    const startIndex = (safePage - 1) * pageSize;
    return {
        pageItems: items.slice(startIndex, startIndex + pageSize),
        currentPage: safePage,
        totalPages,
        totalItems,
        startIndex,
        endIndex: Math.min(startIndex + pageSize, totalItems)
    };
}

export function renderPagination(containerId, state, onPageChange, noun = 'records') {
    const container = document.getElementById(containerId);
    if (!container) return;

    const { currentPage, totalPages, totalItems, startIndex, endIndex } = state;
    const shownStart = totalItems === 0 ? 0 : startIndex + 1;

    const buildPageNumbers = () => {
        if (totalPages <= 5) return Array.from({ length: totalPages }, (_, i) => i + 1);
        const pages = new Set([1, totalPages, currentPage - 1, currentPage, currentPage + 1]);
        return [...pages].filter(p => p >= 1 && p <= totalPages).sort((a, b) => a - b);
    };

    const pageNumbers = buildPageNumbers();
    let last = 0;
    const numberMarkup = pageNumbers.map(page => {
        const gap = last && page - last > 1 ? '<span class="pagination-ellipsis">…</span>' : '';
        last = page;
        return `${gap}<button type="button" class="page-btn ${page === currentPage ? 'active' : ''}" data-page="${page}" ${page === currentPage ? 'aria-current="page"' : ''}>${page}</button>`;
    }).join('');

    container.innerHTML = `
        <div class="pagination-summary">Showing <strong>${shownStart}-${endIndex}</strong> of <strong>${totalItems}</strong> ${noun}</div>
        <div class="pagination-controls" aria-label="Pagination">
            <button type="button" class="page-btn page-nav" data-page="${currentPage - 1}" ${currentPage <= 1 ? 'disabled' : ''}>Previous</button>
            ${numberMarkup}
            <button type="button" class="page-btn page-nav" data-page="${currentPage + 1}" ${currentPage >= totalPages ? 'disabled' : ''}>Next</button>
        </div>
    `;

    container.querySelectorAll('button[data-page]:not([disabled])').forEach(button => {
        button.addEventListener('click', () => onPageChange(Number(button.dataset.page)));
    });
}
