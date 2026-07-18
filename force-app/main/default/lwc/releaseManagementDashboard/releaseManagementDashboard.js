import { LightningElement } from 'lwc';

export default class ReleaseManagementDashboard extends LightningElement {
    metrics = [
        {
            title: 'Current Release',
            value: 'v1.0.0',
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
}