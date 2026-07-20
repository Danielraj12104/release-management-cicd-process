@IsTest
private class SalesforceSearchServiceTest {

    @IsTest
    static void testFindMatchingTrial() {

        // Create test data
        Clinical_Trial_Details__c trial = new Clinical_Trial_Details__c(
            Name = 'Cardio Trial 2026',
            Year__c = 2026,
            Status__c = 'Active',
            Phase__c = 'Phase III',
            Therapeutic_Area__c = 'Cardiology',
            Summary__c = 'Test clinical trial'
        );

        insert trial;

        Test.startTest();

        Clinical_Trial_Details__c result =
            SalesforceSearchService.findMatchingTrial(
                'Show me Cardio Trial 2026'
            );

        Test.stopTest();

        System.assertNotEquals(
            null,
            result,
            'A matching clinical trial should be found.'
        );

        System.assertEquals(
            'Cardio Trial 2026',
            result.Name
        );
    }

    @IsTest
    static void testNoMatchingTrial() {

        Test.startTest();

        Clinical_Trial_Details__c result =
            SalesforceSearchService.findMatchingTrial(
                'What is CRISPR?'
            );

        Test.stopTest();

        System.assertEquals(
            null,
            result,
            'No clinical trial should be returned.'
        );
    }
}