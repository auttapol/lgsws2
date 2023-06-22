public without sharing class CalloutHandlerDispatcher {    
    /**
    * @author Keattisak Chinburarat
    * @date 2/21/2016
    * @description Executes Apex Callout Asynchronously
    * @param Id Id of the callout request to be made
    */
    @future(callout=true)
    public static void sendAsyncCallout(Id crId)
    {       
        // Verify kill switch is not enabled
        if (ConfigService.KillSwitchEnabled) return;
        // Query for Callout Request
        CalloutRequest__c cr = [SELECT Id, AsyncRequest__c, Endpoint__c, Method__c, Timeout__c, Status__c, Sent__c,CalloutHandlerName__c FROM CalloutRequest__c WHERE Id = :crId LIMIT 1];
        // Send Callout
        sendCallout(cr);
    }
	/**
	* @author Keattisak Chinburarat
	* @date 2/23/2016
	* @description Executes Apex Callout Synchronously
	* @param CalloutRequest__c Callout request to be made
	*/
	public static void sendCallout(CalloutRequest__c cr)
	{
        if(null == cr ) return;       
        string calloutHandler =  cr.CalloutHandlerName__c;
        Type handlerType = Type.forName(calloutHandler);   
        if(handlerType!=null) {             
            // Perform HTTP Callout           
            ICalluotSOAPHandler obj = (ICalluotSOAPHandler)handlerType.NewInstance();
            obj.execute(cr);
        }         
	}  
}