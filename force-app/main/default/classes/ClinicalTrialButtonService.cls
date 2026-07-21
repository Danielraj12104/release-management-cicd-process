public with sharing class ClinicalTrialButtonService {

    public class Request {

        @InvocableVariable(required=true)
        public String command;
    }

    public class Response {

        @InvocableVariable
        public String answer;
    }

    @InvocableMethod(label='Clinical Trial Button Service')
    public static List<Response> process(List<Request> requests) {

        List<Response> responses = new List<Response>();

        for (Request req : requests) {

            Response res = new Response();

            // ---------------------------------------
            // LIST CLINICAL TRIALS
            // ---------------------------------------

            if (req.command == 'List Clinical Trials') {

                List<Clinical_Trial_Details__c> trials = [

                    SELECT Name
                    FROM Clinical_Trial_Details__c
                    ORDER BY Name

                ];

                String answer =
                    'Clinical Trials\n' +
                    '------------------------------\n\n';

                Integer i = 1;

                for (Clinical_Trial_Details__c trial : trials) {

                    answer += i + '. ' + trial.Name + '\n';
                    i++;
                }

                answer +=
                    '\n------------------------------\n' +
                    'Total Trials: ' + trials.size();

                res.answer = answer;
            }

            // ---------------------------------------
            // ACTIVE TRIALS
            // ---------------------------------------

            else if (req.command == 'Active Trials') {

                List<Clinical_Trial_Details__c> trials = [

                    SELECT Name
                    FROM Clinical_Trial_Details__c
                    WHERE Status__c = 'Active'
                    ORDER BY Name

                ];

                String answer =
                    'Active Clinical Trials\n' +
                    '------------------------------\n\n';

                Integer i = 1;

                for (Clinical_Trial_Details__c trial : trials) {

                    answer += i + '. ' + trial.Name + '\n';
                    i++;
                }

                answer +=
                    '\n------------------------------\n' +
                    'Total Active Trials: ' + trials.size();

                res.answer = answer;
            }

            // ---------------------------------------
            // RECRUITING TRIALS
            // ---------------------------------------

            else if (req.command == 'Recruiting Trials') {

                List<Clinical_Trial_Details__c> trials = [

                    SELECT Name
                    FROM Clinical_Trial_Details__c
                    WHERE Status__c = 'Recruiting'
                    ORDER BY Name

                ];

                String answer =
                    'Recruiting Clinical Trials\n' +
                    '------------------------------\n\n';

                Integer i = 1;

                for (Clinical_Trial_Details__c trial : trials) {

                    answer += i + '. ' + trial.Name + '\n';
                    i++;
                }

                answer +=
                    '\n------------------------------\n' +
                    'Total Recruiting Trials: ' + trials.size();

                res.answer = answer;
            }

            // ---------------------------------------
            // TRIAL STATISTICS
            // ---------------------------------------

            else if (req.command == 'Trial Statistics') {

                Integer totalTrials = [

                    SELECT COUNT()
                    FROM Clinical_Trial_Details__c

                ];

                Integer activeTrials = [

                    SELECT COUNT()
                    FROM Clinical_Trial_Details__c
                    WHERE Status__c = 'Active'

                ];

                Integer recruitingTrials = [

                    SELECT COUNT()
                    FROM Clinical_Trial_Details__c
                    WHERE Status__c = 'Recruiting'

                ];

                res.answer =
                    'Clinical Trial Statistics\n' +
                    '------------------------------\n\n' +
                    'Total Trials       : ' + totalTrials + '\n' +
                    'Active Trials      : ' + activeTrials + '\n' +
                    'Recruiting Trials  : ' + recruitingTrials;
            }

            // ---------------------------------------
            // UNKNOWN COMMAND
            // ---------------------------------------

            else {

                res.answer = 'Unknown menu option selected.';
            }

            responses.add(res);
        }

        return responses;
    }
}