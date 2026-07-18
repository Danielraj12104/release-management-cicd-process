import { createElement } from '@lwc/engine-dom';
import ReleaseManagementDashboard from 'c/releaseManagementDashboard';

describe('c-release-management-dashboard', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('renders the dashboard header and all metric cards', () => {
        const element = createElement('c-release-management-dashboard', {
            is: ReleaseManagementDashboard
        });

        document.body.appendChild(element);

        const header = element.shadowRoot.querySelector('.dashboard-header h1');
        const cards = element.shadowRoot.querySelectorAll('.metric-card');

        expect(header).not.toBeNull();
        expect(header.textContent).toContain('Release Management Dashboard');
        expect(cards).toHaveLength(6);
    });
});