trigger UserTrigger on User (before insert, after insert,before update, after update, after delete, after undelete) {
    //////////////////////////////////////
    // Create By : Uttaporn Latthitham
    // Email : utl@ii.co.th
    // Create Date : 2015-04-12
    // Summary :
    // NOte : https://www.salesforce.com/us/developer/docs/apexcode/Content/apex_triggers_context_variables_considerations.htm
    //        ***  All Trigger.New   You can use an object to change its own field values using trigger.new, 
    //        but only in before triggers. In all after triggers, trigger.new is not saved, so a runtime exception is thrown.
    //
    //
    //////////////////////////////////////
    System.debug('::: UserTrigger Start ::::');
     Boolean RunUserTrigger = false;
    // Use App Configuration to control =>  go to  App Setup > Develop > Custom Settings > AppConfig > Manage > runtrigger and then change the value
    if(!Test.isRunningTest()){
          RunUserTrigger = AppConfig__c.getValues('runUserTrigger').Value__c == 'true' ;
    }
    //Boolean RunTrigger = false;
    // ********   BEFORE INSERT TRIGGER RUN HERE   ********* 
    if(Trigger.isBefore && Trigger.isInsert)
    {
        if(RunUserTrigger || Test.isRunningTest())
        {
            UserTriggerHandler.handleBeforeInsert(Trigger.new);
            
        }
    }
    // ********   BEFORE UPDATE TRIGGER RUN HERE   ********* 
    else if(Trigger.isBefore && Trigger.isUpdate)
    {
        if(RunUserTrigger || Test.isRunningTest())
        {
            UserTriggerHandler.handleBeforeUpdate(Trigger.new, Trigger.oldMap);
        }
    }
    // ********   AFTER INSERT TRIGGER RUN HERE   *********  
    else if(Trigger.isAfter && Trigger.isInsert)
    {
        if(RunUserTrigger || Test.isRunningTest())
        {
            UserTriggerHandler.handleAfterInsert(Trigger.newMap, Trigger.old);
        }
    } 
    // ********   AFTER UPDATE TRIGGER RUN HERE   *********  
    else if(Trigger.isAfter && Trigger.isUpdate)
    {
        if(RunUserTrigger || Test.isRunningTest())
        {
            UserTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
        }
    } 
    // ********   BEFORE DELETE TRIGGER RUN HERE   ********* 
/*    else if(Trigger.isBefore && Trigger.isDelete)
    {
        
    }
    // ********   AFTER INSERT TRIGGER RUN HERE   ********* 
    else if(Trigger.isAfter && Trigger.isInsert) 
    {
        
    } 
    // ********   BEFORE UPDATE TRIGGER RUN HERE   ********* 
    else if(Trigger.isAfter && Trigger.isUpdate)
    {

    }
    // ********   AFTER DELETE TRIGGER RUN HERE   *********  
    else if(Trigger.isAfter && Trigger.isDelete)
    {
        
    } */
    System.debug('::: UserTrigger End ::::');
}