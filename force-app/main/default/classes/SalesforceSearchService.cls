public with sharing class SalesforceSearchService {

    public static Clinical_Trial_Details__c findMatchingTrial(String userQuestion) {

        if (String.isBlank(userQuestion)) {
            return null;
        }

        String question = normalize(userQuestion);

        List<Clinical_Trial_Details__c> trials = [
            SELECT Id,
                   Name,
                   Status__c,
                   Phase__c,
                   Therapeutic_Area__c,
                   Summary__c
            FROM Clinical_Trial_Details__c
        ];

        Integer bestScore = 0;
        Clinical_Trial_Details__c bestMatch;

        for (Clinical_Trial_Details__c trial : trials) {

            Integer score = 0;

            String searchable =
                normalize(trial.Name) + ' ' +
                normalize(trial.Status__c) + ' ' +
                normalize(trial.Phase__c) + ' ' +
                normalize(trial.Therapeutic_Area__c) + ' ' +
                normalize(trial.Summary__c);

            List<String> words = question.split('\\s+');

            for (String word : words) {

                if (word.length() < 3)
                    continue;

                if (searchable.contains(word)) {
                    score += 15;
                }
            }

            if (question.contains(normalize(trial.Name))) {
                score += 100;
            }

            if (trial.Therapeutic_Area__c != null &&
                question.contains(normalize(trial.Therapeutic_Area__c))) {
                score += 40;
            }

            if (trial.Status__c != null &&
                question.contains(normalize(trial.Status__c))) {
                score += 20;
            }

            if (trial.Phase__c != null &&
                question.contains(normalize(trial.Phase__c))) {
                score += 20;
            }

            if (score > bestScore) {
                bestScore = score;
                bestMatch = trial;
            }
        }

        if (bestScore >= 30) {
            return bestMatch;
        }

        return null;
    }

    private static String normalize(String text) {

        if (String.isBlank(text)) {
            return '';
        }

        text = text.toLowerCase();

        text = text.replace('trails','trial');
        text = text.replace('trail','trial');
        text = text.replace('trials','trial');
        text = text.replace('tral','trial');
        text = text.replace('traill','trial');

        text = text.replace('.', ' ');
        text = text.replace(',', ' ');
        text = text.replace('-', ' ');
        text = text.replace('/', ' ');
        text = text.replace(':', ' ');

        while (text.contains('  ')) {
            text = text.replace('  ', ' ');
        }

        return text.trim();
    }
}