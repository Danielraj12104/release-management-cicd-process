@RestResource(urlMapping='/clinicaltrials/*')
global with sharing class ClinicalTrialRestService {

    @HttpGet
    global static String searchTrial() {

        RestRequest request = RestContext.request;

        String question = request.params.get('q');
        String intent = request.params.get('intent');

        Map<String,Object> response = new Map<String,Object>();

        if(String.isBlank(question)){
            response.put('found', false);
            response.put('message','No question provided.');
            return JSON.serialize(response);
        }

        // ---------------------------------------
        // COUNT
        // ---------------------------------------

        if(intent == 'COUNT'){

            Integer total = [
                SELECT COUNT()
                FROM Clinical_Trial_Details__c
            ];

            response.put('intent','COUNT');
            response.put('count',total);

            return JSON.serialize(response);
        }

        // ---------------------------------------
        // LIST
        // ---------------------------------------

        if(intent == 'LIST'){

            List<Clinical_Trial_Details__c> trials = [

                SELECT Name
                FROM Clinical_Trial_Details__c
                ORDER BY Name

            ];

            List<String> names = new List<String>();

            for(Clinical_Trial_Details__c t : trials){
                names.add(t.Name);
            }

            response.put('intent','LIST');
            response.put('count',names.size());
            response.put('trials',names);

            return JSON.serialize(response);
        }

        // ---------------------------------------
        // ACTIVE
        // ---------------------------------------

        if(intent == 'ACTIVE'){

            List<Clinical_Trial_Details__c> trials = [

                SELECT Name,Status__c
                FROM Clinical_Trial_Details__c
                WHERE Status__c='Active'
                ORDER BY Name

            ];

            List<Map<String,String>> data =
                new List<Map<String,String>>();

            for(Clinical_Trial_Details__c t : trials){

                data.add(new Map<String,String>{

                    'name'=>t.Name,
                    'status'=>t.Status__c

                });

            }

            response.put('intent','ACTIVE');
            response.put('count',data.size());
            response.put('trials',data);

            return JSON.serialize(response);
        }

        // ---------------------------------------
        // RECRUITING
        // ---------------------------------------

        if(intent == 'RECRUITING'){

            List<Clinical_Trial_Details__c> trials = [

                SELECT Name,Status__c
                FROM Clinical_Trial_Details__c
                WHERE Status__c='Recruiting'
                ORDER BY Name

            ];

            List<Map<String,String>> data =
                new List<Map<String,String>>();

            for(Clinical_Trial_Details__c t : trials){

                data.add(new Map<String,String>{

                    'name'=>t.Name,
                    'status'=>t.Status__c

                });

            }

            response.put('intent','RECRUITING');
            response.put('count',data.size());
            response.put('trials',data);

            return JSON.serialize(response);
        }

        // ---------------------------------------
        // PHASE
        // ---------------------------------------

        if(intent == 'PHASE'){

            String phase='';

            if(question.toLowerCase().contains('phase i'))
                phase='Phase I';

            else if(question.toLowerCase().contains('phase ii'))
                phase='Phase II';

            else if(question.toLowerCase().contains('phase iii'))
                phase='Phase III';

            else if(question.toLowerCase().contains('phase iv'))
                phase='Phase IV';

            List<Clinical_Trial_Details__c> trials=[

                SELECT Name,Phase__c
                FROM Clinical_Trial_Details__c
                WHERE Phase__c=:phase
                ORDER BY Name

            ];

            List<Map<String,String>> data =
                new List<Map<String,String>>();

            for(Clinical_Trial_Details__c t:trials){

                data.add(new Map<String,String>{

                    'name'=>t.Name,
                    'phase'=>t.Phase__c

                });

            }

            response.put('intent','PHASE');
            response.put('count',data.size());
            response.put('trials',data);

            return JSON.serialize(response);
        }

        // ---------------------------------------
        // THERAPEUTIC AREA
        // ---------------------------------------

        if(intent == 'THERAPEUTIC_AREA'){

            String area='';

            if(question.toLowerCase().contains('cardio'))
                area='Cardiology';

            else if(question.toLowerCase().contains('oncology'))
                area='Oncology';

            else if(question.toLowerCase().contains('diabetes'))
                area='Endocrinology';

            List<Clinical_Trial_Details__c> trials=[

                SELECT Name,Therapeutic_Area__c
                FROM Clinical_Trial_Details__c
                WHERE Therapeutic_Area__c=:area
                ORDER BY Name

            ];

            List<Map<String,String>> data =
                new List<Map<String,String>>();

            for(Clinical_Trial_Details__c t:trials){

                data.add(new Map<String,String>{

                    'name'=>t.Name,
                    'area'=>t.Therapeutic_Area__c

                });

            }

            response.put('intent','THERAPEUTIC_AREA');
            response.put('count',data.size());
            response.put('trials',data);

            return JSON.serialize(response);
        }

        // ---------------------------------------
// DETAIL
// ---------------------------------------

Clinical_Trial_Details__c trial =
    SalesforceSearchService.findMatchingTrial(question);

if (trial == null) {

    response.put('found', false);

} else {

    response.put('intent', 'DETAIL');
    response.put('found', true);
    response.put('name', trial.Name);
    response.put('status', trial.Status__c);
    response.put('phase', trial.Phase__c);
    response.put('therapeuticArea', trial.Therapeutic_Area__c);
    response.put('summary', trial.Summary__c);

}

RestContext.response.addHeader(
    'Content-Type',
    'application/json'
);

return JSON.serialize(response);
    }

}