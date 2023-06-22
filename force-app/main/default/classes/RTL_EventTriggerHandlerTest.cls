@isTest
public with sharing class RTL_EventTriggerHandlerTest {
    static {
        TestUtils.createAppConfig();
    }  
    
    public static testMethod void cxmEvent() {
        
        Test.startTest();
                
        Event eventObj = RTL_TestUtilityCXM.cxmCreateEvent(true);        
        
        Event updateEventObj = [select Id, OwnerId, RTL_Event_Subject__c, lastmodifieddate from Event where Id = :eventObj.Id];
        System.debug('Event Id = ' + updateEventObj.Id);          
        
        RTL_TestUtilityCXM.cxmUpdateEvent(updateEventObj);    
        
        Test.stopTest();
                
                
        //beginAdd
        //AsyncCXMService.AsyncTaskEventPort asyncCXM = new AsyncCXMService.AsyncTaskEventPort();         
        //AsyncCXMService.ForwardTaskEventResponse_elementFuture xxxCXM = new AsyncCXMService.ForwardTaskEventResponse_elementFuture();

        //Continuation continuation = new Continuation(10);
        
        //xxxCXM.beginAdd(null,'20170626180500000001', 'CRM', String.valueOf(datetime.now()), 'data');         
    }          
}