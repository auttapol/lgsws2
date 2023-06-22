trigger LiveChatTranscriptTrigger on LiveChatTranscript (before insert,after insert,before update,after update) {

     Boolean RunTrigger = AppConfig__c.getValues('runtrigger').Value__c == 'true'; 
    
    //Before update record to database
    if(Trigger.isBefore && Trigger.isUpdate)
    {
        if(RunTrigger || Test.isRunningTest())
        {          
            LiveChatTranscriptTriggerHandler.handleBeforeUpdate(Trigger.oldMap, Trigger.NewMap);
        }
    }
    
    //After update record to database
    if(Trigger.isAfter && Trigger.isUpdate)
    {
        if(RunTrigger || Test.isRunningTest())
        {          
            LiveChatTranscriptTriggerHandler.handleAfterUpdate(Trigger.oldMap, Trigger.NewMap);
        }
    }
}