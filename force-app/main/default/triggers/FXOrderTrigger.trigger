trigger FXOrderTrigger on FX_Order__c (before insert,after insert, before update, after update) {

     if(Trigger.isBefore && Trigger.isInsert) 
    {
        FXOrderTriggerHandler.handleBeforeInsert(trigger.new);
    }
    
    if(Trigger.isAfter && Trigger.isInsert) 
    {
       FXOrderTriggerHandler.handleAfterInsert(trigger.new , trigger.oldMap);
    }
    
    if(Trigger.isBefore && Trigger.isUpdate) 
    {
        FXOrderTriggerHandler.handleBeforeUpdate(trigger.new , trigger.oldMap);
    } 

    if(Trigger.isAfter && Trigger.isUpdate) 
    {
       FXOrderTriggerHandler.handleAfterUpdate(trigger.new , trigger.oldMap);
    }
    
    
}