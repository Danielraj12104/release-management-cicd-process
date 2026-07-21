public with sharing class HybridAIService {

    public class Request {

        @InvocableVariable(required=true)
        public String question;
    }

    public class Response {

        @InvocableVariable
        public String answer;
    }

    @InvocableMethod(label='Hybrid AI Service')
    public static List<Response> process(List<Request> requests) {

        List<Response> responses = new List<Response>();

        for (Request req : requests) {

            Response res = new Response();

            try {

                // Let LangGraph decide where to route
                res.answer = LangGraphCalloutService.askLangGraph(
                    req.question
                );

            } catch (Exception ex) {

                res.answer =
                    'Error calling LangGraph:\n\n'
                    + ex.getMessage();
            }

            responses.add(res);
        }

        return responses;
    }
}