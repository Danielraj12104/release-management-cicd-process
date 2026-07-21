public with sharing class TherapeuticAreaService {

    @InvocableMethod(label='Get Therapeutic Areas')
    public static List<String> getAreas(List<String> requests) {

        String result = '';

        for (AggregateResult ar : [
            SELECT Therapeutic_Area__c area,
                   COUNT(Id) total
            FROM Clinical_Trial__c
            WHERE Therapeutic_Area__c != NULL
            GROUP BY Therapeutic_Area__c
            ORDER BY Therapeutic_Area__c
        ]){

            result +=
                (String)ar.get('area')
                + ' ('
                + String.valueOf(ar.get('total'))
                + ')'
                + '\n';

        }

        return new List<String>{ result };

    }
}