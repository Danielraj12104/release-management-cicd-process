@RestResource(urlMapping='/clinicaltrial/*')
global with sharing class ClinicalTrialAPI {

    @HttpGet
    global static String getTrial() {

        RestRequest req = RestContext.request;

        String query = req.params.get('q');

        Clinical_Trial_Details__c trial =
            SalesforceSearchService.findMatchingTrial(query);

        if (trial == null) {
            return '{"found":false}';
        }

        Map<String, Object> response = new Map<String, Object>();

        response.put('found', true);
        response.put('name', trial.Name);
        response.put('status', trial.Status__c);
        response.put('phase', trial.Phase__c);
        response.put('therapeuticArea', trial.Therapeutic_Area__c);
        response.put('summary', trial.Summary__c);

        return JSON.serialize(response);
    }

}