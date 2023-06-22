trigger AcctPlanComProfileTrigger on AcctPlanCompanyProfile__c (before insert, after insert,before update, after update, after delete, after undelete) {
//////////////////////////////////////
    // Create By : Piyawat Pitakpawatkul
    // Email : pyp@ii.co.th
    // Create Date : 2015-10-26
    // Summary : -
    //////////////////////////////////////
    System.debug('::: AcctPlanCompanyPortTrigger Start ::::');
    Boolean RunTrigger = AppConfig__c.getValues('runtrigger').Value__c == 'true' ; 
    //Boolean RunTrigger = false;
    // ********   BEFORE INSERT TRIGGER RUN HERE   ********* 
    if(Trigger.isBefore && Trigger.isInsert) 
    {        
        
    }     
    // ********   BEFORE UPDATE TRIGGER RUN HERE   ********* 
    else if(Trigger.isBefore && Trigger.isUpdate) 
    {        
          
    } 
    // ********   BEFORE DELETE TRIGGER RUN HERE   ********* 
    else if(Trigger.isBefore && Trigger.isDelete) 
    {        
        
    } 
    // ********   AFTER INSERT TRIGGER RUN HERE   ********* 
    else if(Trigger.isAfter && Trigger.isInsert) 
    {
        if(RunTrigger || Test.isRunningTest()){
            AcctPlanComProfileTriggerHandler.handlerAfterInsert(Trigger.new);
        }
    } 
    // ********AFTER UPDATE TRIGGER RUN HERE   ********* 
    else if(Trigger.isAfter && Trigger.isUpdate) 
    {        
        if(RunTrigger || Test.isRunningTest()){
            AcctPlanComProfileTriggerHandler.handlerAfterUpdate(Trigger.new,Trigger.old);
        }     
    }
    // ********   AFTER DELETE TRIGGER RUN HERE   *********  
    /*else if(Trigger.isAfter && Trigger.isDelete) 
    {        
        
    }*/
    System.debug('::: AcctPlanCompanyPortTrigger End ::::');
}