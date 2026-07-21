import { LightningElement } from 'lwc';

export default class ReleaseManagementDashboard extends LightningElement {
    metrics = [
        {
            title: 'Current Release',
            value: 'v1.0.1',
            subtitle: 'Latest deployment version',
            iconName: 'utility:launch',
            iconClass: 'card-icon blue-accent'
        },
        {
            title: 'Deployment Status',
            value: 'Successful',
            subtitle: 'Production rollout completed',
            iconName: 'utility:check',
            iconClass: 'card-icon green-accent'
        },
        {
            title: 'Build History',
            value: '25 Builds',
            subtitle: 'Completed over the last quarter',
            iconName: 'utility:refresh',
            iconClass: 'card-icon purple-accent'
        },
        {
            title: 'Open Bugs',
            value: '8',
            subtitle: 'Critical issues under review',
            iconName: 'utility:bug',
            iconClass: 'card-icon red-accent'
        },
        {
            title: 'Change Requests',
            value: '14',
            subtitle: 'Pending approvals and rollout',
            iconName: 'utility:copy',
            iconClass: 'card-icon indigo-accent'
        },
        {
            title: 'Team Members',
            value: '12',
            subtitle: 'Cross-functional delivery team',
            iconName: 'utility:people',
            iconClass: 'card-icon teal-accent'
        }
    ];

    detailCards = [
        {
            title: 'Last Deployment',
            status: 'Successful',
            statusClass: 'slds-badge slds-theme_success detail-badge',
            iconName: 'utility:history',
            iconClass: 'card-icon blue-accent',
            fields: [
                { label: 'Deployment Time', value: '16 Jul 2026, 11:45 AM' },
                { label: 'Deployment By', value: 'Jenkins Pipeline' },
                { label: 'Environment', value: 'Developer Sandbox' },
                { label: 'Status', value: 'Successful' }
            ]
        },
        {
            title: 'Pipeline Information',
            status: 'Running',
            statusClass: 'slds-badge slds-theme_warning detail-badge',
            iconName: 'utility:custom_notification',
            iconClass: 'card-icon purple-accent',
            fields: [
                { label: 'Pipeline Name', value: 'release-management-cicd' },
                { label: 'Branch', value: 'feature/release-dashboard-v2' },
                { label: 'Build Number', value: '#15' },
                { label: 'Trigger', value: 'GitHub Push' }
            ]
        }
    ];
}