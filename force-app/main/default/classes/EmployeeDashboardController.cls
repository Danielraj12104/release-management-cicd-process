public with sharing class EmployeeDashboardController {
    private static final String STATUS_COMPLETED = 'Completed';
    private static final String STATUS_IN_PROGRESS = 'In Progress';
    private static final String STATUS_BREACHED = 'Breached';
    private static final String STATUS_NOT_STARTED = 'Not Started';
    private static final String SLA_ON_TRACK = 'ON TRACK';
    private static final String SLA_BREACHED = 'BREACHED';
    private static final String SLA_COMPLETED = 'COMPLETED';
    private static final String SLA_NOT_STARTED = 'NOT STARTED';

    public class DashboardData {
        @AuraEnabled public String employeeName;
        @AuraEnabled public String employeeId;
        @AuraEnabled public String department;
        @AuraEnabled public String manager;
        @AuraEnabled public Date joiningDate;

        @AuraEnabled public Id caseId;
        @AuraEnabled public String caseNumber;
        @AuraEnabled public String caseStatus;
        @AuraEnabled public String caseOwner;

        @AuraEnabled public String entitlementName;

        @AuraEnabled public String milestoneName;
        @AuraEnabled public String milestoneStatus;
        @AuraEnabled public Datetime milestoneTargetDate;
        @AuraEnabled public Datetime milestoneCompletionDate;

        @AuraEnabled public String slaStatus;
        @AuraEnabled public Long remainingMilliseconds;

        @AuraEnabled public List<TimelineItem> timelineItems;
        @AuraEnabled public List<NotificationItem> notificationItems;
    }

    public class TimelineItem {
        @AuraEnabled public String title;
        @AuraEnabled public String description;
        @AuraEnabled public String status;
        @AuraEnabled public Datetime timelineDate;

        public TimelineItem(String title, String description, String status, Datetime dateValue) {
            this.title = title;
            this.description = description;
            this.status = status;
            this.timelineDate = dateValue;
        }
    }

    public class NotificationItem {
        @AuraEnabled public String title;
        @AuraEnabled public String description;
        @AuraEnabled public Datetime timestamp;
        @AuraEnabled public String type;

        public NotificationItem(String title, String description, Datetime timestampValue, String type) {
            this.title = title;
            this.description = description;
            this.timestamp = timestampValue;
            this.type = type;
        }
    }

    @AuraEnabled(cacheable=true)
    public static DashboardData getDashboardData(Id caseId) {
        if (caseId == null) {
            throw new AuraHandledException('A Case Id is required to load the employee dashboard.');
        }

        Case caseRecord = queryCase(caseId);
        if (caseRecord == null) {
            throw new AuraHandledException('No Case was found for the supplied Id.');
        }

        Entitlement entitlementRecord = queryEntitlement(caseRecord.EntitlementId);
        List<CaseMilestone> milestones = queryCaseMilestones(caseRecord.Id);

        DashboardData data = new DashboardData();
        data.timelineItems = new List<TimelineItem>();
        data.notificationItems = new List<NotificationItem>();

        populateEmployeeInformation(data, caseRecord);
        populateCaseInformation(data, caseRecord);
        populateEntitlementInformation(data, entitlementRecord);
        populateMilestoneAndSlaInformation(data, milestones);
        populateNotifications(data, caseRecord, entitlementRecord, milestones);

        return data;
    }

    private static Case queryCase(Id caseId) {
        List<String> fields = new List<String>{
            'Id',
            'CaseNumber',
            'Status',
            'Owner.Name',
            'ContactId',
            'Contact.Name',
            'Contact.Department',
            'Contact.ReportsTo.Name',
            'EntitlementId'
        };

        addAccessibleCaseField(fields, 'Employee_Name__c');
        addAccessibleCaseField(fields, 'Employee_ID__c');
        addAccessibleCaseField(fields, 'EmployeeId__c');
        addAccessibleCaseField(fields, 'Department__c');
        addAccessibleCaseField(fields, 'Manager_Name__c');
        addAccessibleCaseField(fields, 'Manager__c');
        addAccessibleCaseField(fields, 'Joining_Date__c');
        addAccessibleCaseField(fields, 'JoiningDate__c');

        String queryText =
            'SELECT ' + String.join(fields, ', ') +
            ' FROM Case WHERE Id = :caseId LIMIT 1';

        List<Case> cases = Database.query(queryText);
        return cases.isEmpty() ? null : cases[0];
    }

    private static Entitlement queryEntitlement(Id entitlementId) {
        if (entitlementId == null) {
            return null;
        }

        List<Entitlement> entitlements = [
            SELECT Id, Name
            FROM Entitlement
            WHERE Id = :entitlementId
            LIMIT 1
        ];

        return entitlements.isEmpty() ? null : entitlements[0];
    }

    private static List<CaseMilestone> queryCaseMilestones(Id caseId) {
        return [
            SELECT Id, MilestoneType.Name, TargetDate, CompletionDate, IsCompleted, IsViolated
            FROM CaseMilestone
            WHERE CaseId = :caseId
            ORDER BY TargetDate ASC
            LIMIT 50
        ];
    }

    private static void populateEmployeeInformation(DashboardData data, Case caseRecord) {
        SObject contactRecord = caseRecord.getSObject('Contact');
        SObject reportsToRecord = contactRecord == null ? null : contactRecord.getSObject('ReportsTo');

        data.employeeName = firstNonBlank(
            getCaseString(caseRecord, new List<String>{ 'Employee_Name__c' }),
            contactRecord == null ? null : String.valueOf(contactRecord.get('Name'))
        );
        data.employeeId = firstNonBlank(
            getCaseString(caseRecord, new List<String>{ 'Employee_ID__c', 'EmployeeId__c' }),
            caseRecord.ContactId == null ? null : String.valueOf(caseRecord.ContactId)
        );
        data.department = firstNonBlank(
            getCaseString(caseRecord, new List<String>{ 'Department__c' }),
            contactRecord == null ? null : String.valueOf(contactRecord.get('Department'))
        );
        data.manager = firstNonBlank(
            getCaseString(caseRecord, new List<String>{ 'Manager_Name__c', 'Manager__c' }),
            reportsToRecord == null ? null : String.valueOf(reportsToRecord.get('Name'))
        );
        data.joiningDate = getCaseDate(caseRecord, new List<String>{ 'Joining_Date__c', 'JoiningDate__c' });
    }

    private static void populateCaseInformation(DashboardData data, Case caseRecord) {
        data.caseId = caseRecord.Id;
        data.caseNumber = caseRecord.CaseNumber;
        data.caseStatus = caseRecord.Status;
        data.caseOwner = caseRecord.Owner == null ? null : caseRecord.Owner.Name;
    }

    private static void populateEntitlementInformation(DashboardData data, Entitlement entitlementRecord) {
        data.entitlementName = entitlementRecord == null ? null : entitlementRecord.Name;
    }

    private static void populateMilestoneAndSlaInformation(DashboardData data, List<CaseMilestone> milestones) {
        Datetime nowValue = System.now();
        CaseMilestone activeMilestone;
        Boolean hasBreachedMilestone = false;
        Integer completedCount = 0;

        for (CaseMilestone milestone : milestones) {
            String status = getMilestoneStatus(milestone, nowValue);
            if (status == STATUS_COMPLETED) {
                completedCount++;
            }
            if (status == STATUS_BREACHED) {
                hasBreachedMilestone = true;
            }
            if (activeMilestone == null && status != STATUS_COMPLETED) {
                activeMilestone = milestone;
            }

            data.timelineItems.add(
                new TimelineItem(
                    milestone.MilestoneType == null ? 'Milestone' : milestone.MilestoneType.Name,
                    buildMilestoneDescription(milestone, status),
                    status,
                    milestone.CompletionDate == null ? milestone.TargetDate : milestone.CompletionDate
                )
            );
        }

        if (activeMilestone == null && !milestones.isEmpty()) {
            activeMilestone = milestones[milestones.size() - 1];
        }

        if (activeMilestone != null) {
            String activeStatus = getMilestoneStatus(activeMilestone, nowValue);
            data.milestoneName = activeMilestone.MilestoneType == null ? null : activeMilestone.MilestoneType.Name;
            data.milestoneStatus = activeStatus;
            data.milestoneTargetDate = activeMilestone.TargetDate;
            data.milestoneCompletionDate = activeMilestone.CompletionDate;
            data.remainingMilliseconds = calculateRemainingMilliseconds(activeMilestone.TargetDate, nowValue);
        } else {
            data.milestoneStatus = STATUS_NOT_STARTED;
            data.remainingMilliseconds = 0;
        }

        if (milestones.isEmpty()) {
            data.slaStatus = SLA_NOT_STARTED;
        } else if (hasBreachedMilestone) {
            data.slaStatus = SLA_BREACHED;
        } else if (completedCount == milestones.size()) {
            data.slaStatus = SLA_COMPLETED;
        } else {
            data.slaStatus = SLA_ON_TRACK;
        }
    }

    private static void populateNotifications(
        DashboardData data,
        Case caseRecord,
        Entitlement entitlementRecord,
        List<CaseMilestone> milestones
    ) {
        Datetime nowValue = System.now();

        data.notificationItems.add(
            new NotificationItem(
                'Case Loaded',
                'Case ' + caseRecord.CaseNumber + ' is currently ' + caseRecord.Status + '.',
                nowValue,
                'info'
            )
        );

        if (entitlementRecord != null) {
            data.notificationItems.add(
                new NotificationItem(
                    'Entitlement Applied',
                    entitlementRecord.Name + ' is linked to this onboarding case.',
                    nowValue,
                    'success'
                )
            );
        }

        if (data.milestoneName != null) {
            data.notificationItems.add(
                new NotificationItem(
                    'Milestone Update',
                    data.milestoneName + ' is ' + data.milestoneStatus + '.',
                    nowValue,
                    data.slaStatus == SLA_BREACHED ? 'warning' : 'info'
                )
            );
        }

        if (milestones.isEmpty()) {
            data.notificationItems.add(
                new NotificationItem(
                    'No Milestones Found',
                    'No active entitlement milestones were found for this case.',
                    nowValue,
                    'warning'
                )
            );
        }
    }

    private static String getMilestoneStatus(CaseMilestone milestone, Datetime nowValue) {
        if (milestone.IsCompleted) {
            return STATUS_COMPLETED;
        }
        if (milestone.IsViolated || (milestone.TargetDate != null && milestone.TargetDate.getTime() < nowValue.getTime())) {
            return STATUS_BREACHED;
        }
        return STATUS_IN_PROGRESS;
    }

    private static String buildMilestoneDescription(CaseMilestone milestone, String status) {
        String milestoneName = milestone.MilestoneType == null ? 'This milestone' : milestone.MilestoneType.Name;
        if (status == STATUS_COMPLETED) {
            return milestoneName + ' was completed successfully.';
        }
        if (status == STATUS_BREACHED) {
            return milestoneName + ' has passed its target date.';
        }
        return milestoneName + ' is within the active SLA window.';
    }

    private static Long calculateRemainingMilliseconds(Datetime targetDate, Datetime nowValue) {
        if (targetDate == null) {
            return 0;
        }
        Long remaining = targetDate.getTime() - nowValue.getTime();
        return remaining > 0 ? remaining : 0;
    }

    private static void addAccessibleCaseField(List<String> fields, String fieldApiName) {
        Map<String, Schema.SObjectField> caseFields = Schema.SObjectType.Case.fields.getMap();
        if (!caseFields.containsKey(fieldApiName)) {
            return;
        }
        if (!caseFields.get(fieldApiName).getDescribe().isAccessible()) {
            return;
        }
        fields.add(fieldApiName);
    }

    private static String getCaseString(Case caseRecord, List<String> fieldApiNames) {
        for (String fieldApiName : fieldApiNames) {
            if (!hasPopulatedField(caseRecord, fieldApiName)) {
                continue;
            }

            Object value = caseRecord.get(fieldApiName);
            if (value != null && String.isNotBlank(String.valueOf(value))) {
                return String.valueOf(value);
            }
        }
        return null;
    }

    private static Date getCaseDate(Case caseRecord, List<String> fieldApiNames) {
        for (String fieldApiName : fieldApiNames) {
            if (!hasPopulatedField(caseRecord, fieldApiName)) {
                continue;
            }

            Object value = caseRecord.get(fieldApiName);
            if (value instanceof Date) {
                return (Date) value;
            }
            if (value instanceof Datetime) {
                return ((Datetime) value).date();
            }
        }
        return null;
    }

    private static Boolean hasPopulatedField(Case caseRecord, String fieldApiName) {
        return caseRecord.getPopulatedFieldsAsMap().containsKey(fieldApiName);
    }

    private static String firstNonBlank(String primaryValue, String fallbackValue) {
        return String.isNotBlank(primaryValue) ? primaryValue : fallbackValue;
    }
}