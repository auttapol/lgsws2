trigger HostProductResponseTrigger on Host_Product_Response__c (before insert, after insert, before update, after update) {

    Boolean RunTrigger = AppConfig__c.getValues('runtrigger').Value__c == 'true' ;

    if (RunTrigger || Test.isRunningTest()){    
        if (Trigger.isBefore && Trigger.isInsert)
        {
            HostProductResponseService.populateProductID(Trigger.new);
        }
        
        else if (Trigger.isBefore && Trigger.isUpdate)
        {
//*****************  COMMENT TO FIX GAP DELETE FROM SLOS BEFORE SEND TO SF ********************//            
//            HostProductResponseService.populateProductID(Trigger.new);                       //
//*****************  COMMENT TO FIX GAP DELETE FROM SLOS BEFORE SEND TO SF ********************//
        }
        
        else if (Trigger.isAfter && Trigger.isInsert)    
        {
            HostProductResponseService.validateCurrentAppAfterUpsertHostApp(Trigger.new);
            HostProductResponseService.checkProductExistInSalesforce(Trigger.new, false);
        }
        
        else if (Trigger.isAfter && Trigger.isUpdate)    
        {
//*****************  COMMENT TO FIX GAP DELETE FROM SLOS BEFORE SEND TO SF ********************// 
//            HostProductResponseService.checkProductExistInSalesforce(Trigger.new, false);    //
//*****************  COMMENT TO FIX GAP DELETE FROM SLOS BEFORE SEND TO SF ********************// 
        }
    }

}