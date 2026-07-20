public class AgentforceRequestHandler {
    
    public static void summarizeOpportunityFromAgentforce( String opportunityName ) {
        
        Invocable.Action action = Invocable.Action.createCustomAction(
            'generateAiAgentResponse', 
            'Copilot_for_Salesforce'
        );
        
        action.setInvocationParameter(
            'userMessage', 
            'Summarize my Opportunity ' + opportunityName
        );
        
        List < Invocable.Action.Result > actionResults = action.invoke();
        Invocable.Action.Result actionResult = actionResults[ 0 ];
        
        if ( actionResult.isSuccess() ) {
            
            System.debug( 
                'Session Id: ' + 
                actionResult.getOutputParameters().get( 'sessionId' ) 
            );
            System.debug( 
                'Agent Response: ' + 
                actionResult.getOutputParameters().get( 'agentResponse' ) 
            );
            
        } else {
            
            System.debug( actionResult.getErrors() );
            
        }
        
    }
    
}