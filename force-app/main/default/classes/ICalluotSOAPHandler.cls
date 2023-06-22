public interface ICalluotSOAPHandler {
	/**
	*  @author Keattisak
	*  @date 01/11/2016
	*  @description This class make standard for callout handler.
	*
	*   CHANGE HISTORY
	*   ==================================================================
	*   Date            Name                    Description
	*   01/11/2016      Keattisak.C             Created
	*/
	void execute(CalloutRequest__c cr); 
	//Integer calculateTimeout(CalloutRequest__c cr);	
	void processFailure(CalloutRequest__c cr, Exception ex);
	void processCalloutResponse(String request,string response, CalloutRequest__c cr); 
	void updateCalloutRequest(String request,CalloutRequest__c cr, Long start); 
}