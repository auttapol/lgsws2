trigger HostAppResponseTrigger on Host_Application_Response__c (before insert, after insert, after update) {

    Boolean RunTrigger = AppConfig__c.getValues('runtrigger').Value__c == 'true' ;

    if (RunTrigger || Test.isRunningTest()){  
        if (Trigger.isBefore && Trigger.isInsert)
        {
            for (Host_Application_Response__c ha : Trigger.new)
            {
                ha.Current_Application_Response__c = true;
            }
        }  
        else if (Trigger.isAfter && Trigger.isInsert)    
        {
            HostApplicationResponseService.HostApplicationResponseMainProcess(Trigger.new, new list<host_application_response__c>());
        }
        
        else if (Trigger.isAfter && Trigger.isUpdate)    
        {
            HostApplicationResponseService.HostApplicationResponseMainProcess(Trigger.new, Trigger.old);
        }
    }

}