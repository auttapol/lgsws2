trigger SLLGroupTrigger on SLL_Group__c (before insert, before update, after insert, after update) {

    Boolean RunTrigger = AppConfig__c.getValues('runtrigger').Value__c == 'true' ;

    if(Trigger.isBefore && Trigger.isInsert) {
        //SLL Group Trigger before insert
        if(RunTrigger){
            SLLGroupTriggerHandler.handlerBeforeInsert(Trigger.new);
        }
    }else if(Trigger.isBefore && Trigger.isUpdate) {
        //SLL Groups Trigger before insert
        if(RunTrigger){
            SLLGroupTriggerHandler.handlerBeforeUpdate(Trigger.new,Trigger.OldMap);
        }
    }else if(Trigger.isAfter && Trigger.isInsert) {
        //SLL Group Trigger after insert
        if(RunTrigger){
            SLLGroupTriggerHandler.handlerAfterInsert(Trigger.new);
        }
    }else if(Trigger.isAfter && Trigger.isUpdate) {
        //SLL Group Trigger after update
        if(RunTrigger){
            SLLGroupTriggerHandler.handlerAfterUpdate(Trigger.new,Trigger.OldMap);
        }
    }
}