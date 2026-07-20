public with sharing class LangGraphCalloutService {

    public class ChatRequest {
        public String message;
    }

    public class ChatResponse {
        public String source;
        public String answer;
    }

    public class ClassifyResponse {
        public String route;
    }

    private static HttpResponse sendRequest(String endpointPath, String userMessage) {

        HttpRequest req = new HttpRequest();

        req.setEndpoint('callout:HybridLangGraph' + endpointPath);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setTimeout(120000);

        ChatRequest request = new ChatRequest();
        request.message = userMessage;

        req.setBody(JSON.serialize(request));

        Http http = new Http();
        return http.send(req);
    }

    public static String classifyQuestion(String userMessage) {

        HttpResponse res = sendRequest('/classify', userMessage);

        if (res.getStatusCode() == 200) {

            ClassifyResponse response =
                (ClassifyResponse) JSON.deserialize(
                    res.getBody(),
                    ClassifyResponse.class
                );

            return response.route;
        }

        throw new CalloutException(
            'Classifier Error: ' +
            res.getStatusCode() +
            ' : ' +
            res.getBody()
        );
    }

    public static String askLangGraph(String userMessage) {

        HttpResponse res = sendRequest('/chat', userMessage);

        if (res.getStatusCode() == 200) {

            ChatResponse response =
                (ChatResponse) JSON.deserialize(
                    res.getBody(),
                    ChatResponse.class
                );

            return response.answer;
        }

        throw new CalloutException(
            'Chat Error: ' +
            res.getStatusCode() +
            ' : ' +
            res.getBody()
        );
    }
}