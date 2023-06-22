trigger EmailMessageTrigger on EmailMessage (before insert, after insert,before update, after update, after delete, after undelete) {
    Boolean RunTrigger = AppConfig__c.getValues('runtrigger').Value__c == 'true'; 

    // ********   BEFORE INSERT TRIGGER RUN HERE   ********* 
    if(Trigger.isBefore && Trigger.isInsert) {
        System.debug('::::: BeforeInsert Start :::::');
        if(RunTrigger || Test.isRunningTest()){
            EmailMessageTriggerHandler.handleBeforeInsert(Trigger.new);
        }
        System.debug('::::: BeforeInsert End :::::');
    }

    // ********   AFTER INSERT TRIGGER RUN HERE   ********* 
    if(Trigger.isAfter && Trigger.isInsert){        
        if(RunTrigger || Test.isRunningTest()){
            EmailMessageTriggerHandler.handleAfterInsert(Trigger.new);
        }
    }
    
     // ********   BEFORE UPDATE TRIGGER RUN HERE   ********* 
    if(Trigger.isBefore && Trigger.isUpdate) {
        System.debug('::::: BeforeUpdate Start :::::');
        if(RunTrigger || Test.isRunningTest()){
            EmailMessageTriggerHandler.handleBeforeUpdate(Trigger.oldMap, Trigger.NewMap);
        }
        System.debug('::::: BeforeUpdate End :::::');
    }

    // ********   AFTER UPDATE TRIGGER RUN HERE   ********* 
    if(Trigger.isAfter && Trigger.isUpdate){  
        System.debug('::::: AfterUpdate Start :::::');
        if(RunTrigger || Test.isRunningTest()){
            EmailMessageTriggerHandler.handleAfterUpdate(Trigger.oldMap, Trigger.NewMap);
        }
        System.debug('::::: AfterUpdate End :::::');
    }
}