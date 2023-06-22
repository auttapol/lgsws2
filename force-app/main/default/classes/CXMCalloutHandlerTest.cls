@isTest
public class CXMCalloutHandlerTest {
    
    static{
        TestUtils.createAppConfig();
        TestUtils.createStatusCode(); 
        TestUtils.createDisqualifiedReason(); 
        TestUtils.createObjUserPermission();
        TestInit.createCustomSettingTriggerMsg(); 
    }
    
    public static testmethod void positiveTest(){
                
        	new CXMHandler().CXMSendEmailLog(null);
            AsyncRequest__c  asyncReq = insertAsyncRequest(true);
            CalloutRequest__c calloutReq = insertCalloutRequest(asyncReq.Id);        
            new CXMHandler().CXMSendEmailLog(calloutReq.AsyncRequest__c);
    }
    
    private static CalloutRequest__c insertCalloutRequest(String asyncReqId){
        
        CalloutRequest__c calloutReq = new CalloutRequest__c();
        calloutReq.RequestId__c = String.valueOf(datetime.now());
        calloutReq.Response_Description__c = 'MuleSoft unexpected error: Timeout exceeded';
        calloutReq.Status__c = 'Failed';
        calloutReq.Sent__c = datetime.now();
        calloutReq.Response_Code__c = '1001';
        calloutReq.CalloutHandlerName__c = 'CXMCalloutHandler';
        calloutReq.AsyncRequest__c =  asyncReqId;
        
        insert calloutReq;  
        
        return calloutReq;
    }
    
    private static AsyncRequest__c insertAsyncRequest(Boolean doInsert){
        
        AsyncRequest__c asyncReq = new AsyncRequest__c();
        asyncReq.IsSuccess__c = false;
        asyncReq.Aborted__c = true;
        
        if(doInsert){
           insert asyncReq; 
        }         
        
        return asyncReq;
    }

}