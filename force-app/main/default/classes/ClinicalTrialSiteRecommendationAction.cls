public with sharing class ClinicalTrialSiteRecommendationAction {

    public class Input {
        @InvocableVariable(required=true)
        public Id clinicalTrialId;
    }

    @InvocableMethod(label='Get Recommended Trial Sites')
    public static List<List<Site__c>> getRecommendations(List<Input> inputs) {

        List<List<Site__c>> result = new List<List<Site__c>>();

        for (Input input : inputs) {

            List<Site__c> sites = [
                SELECT Id,
                       Name,
                       Site_Rating__c,
                       Previous_Trial_Count__c,
                       Specialty_Area__c
                FROM Site__c
                ORDER BY Site_Rating__c DESC,
                         Previous_Trial_Count__c DESC
                LIMIT 5
            ];

            result.add(sites);
        }

        return result;
    }
}