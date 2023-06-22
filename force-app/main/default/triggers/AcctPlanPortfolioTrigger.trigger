trigger AcctPlanPortfolioTrigger on AcctPlanPortfolio__c  (before insert, after insert,before update, after update,before delete, after delete, after undelete) {
//////////////////////////////////////
    // Create By : Jantanee Saetung
    // Create Date : 2016-09-02
    // Detail : -
    //////////////////////////////////////
    System.debug('::: AcctPlanPortfolioTrigger Start ::::');
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
        System.debug(':::: Trigger.old ::::'+Trigger.old); 
        if(RunTrigger || Test.isRunningTest()){
            AcctPlanPortfolioTriggerHandler.handlerBeforeDelete(Trigger.old);
        } 
    } 
    // ********   AFTER INSERT TRIGGER RUN HERE   ********* 
    else if(Trigger.isAfter && Trigger.isInsert) 
    {
        
    } 
    // ********AFTER UPDATE TRIGGER RUN HERE   ********* 
    else if(Trigger.isAfter && Trigger.isUpdate) 
    {        
            
    }
    // ********   AFTER DELETE TRIGGER RUN HERE   *********  
    /*else if(Trigger.isAfter && Trigger.isDelete) 
    {        
        
    }*/
    System.debug('::: AcctPlanPortfolioTrigger End ::::');
}