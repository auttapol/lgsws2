trigger CallReportTrigger on Call_Report__c (before insert, after insert,before update,before delete, after update, after delete, after undelete) {    
    //////////////////////////////////////
    // Create By : Thanakorn Haewphet
    // Email : tnh@ii.co.th
    // Create Date : 2014-10-24 
    // Summary : -
    //////////////////////////////////////
    System.debug('::: CallReportTrigger Start ::::');
    Boolean RunTrigger = AppConfig__c.getValues('runtrigger').Value__c == 'true' ; 
    //Boolean RunTrigger = false;
    // ********   BEFORE INSERT TRIGGER RUN HERE   ********* 
    if(Trigger.isBefore && Trigger.isInsert) 
    {        
        CallReportTriggerHandler.handlerBeforeInsert(Trigger.new,null);
    }     
    // ********   BEFORE UPDATE TRIGGER RUN HERE   ********* 
    else if(Trigger.isBefore && Trigger.isUpdate) 
    {        
        if(RunTrigger || Test.isRunningTest()){
            VisitPlanTriggerHandler.checkTMBPerson(Trigger.New,Trigger.OldMap);
            CallReportTriggerHandler.handlerBeforeUpdate(Trigger.new,Trigger.old);
        }     
    } 
    // ********   BEFORE DELETE TRIGGER RUN HERE   ********* 
    else if(Trigger.isBefore && Trigger.isDelete) 
    {        
        VisitPlanTriggerHandler.deleteEvents(Trigger.Old);
    } 
    // ********   AFTER INSERT TRIGGER RUN HERE   ********* 
    else if(Trigger.isAfter && Trigger.isInsert) 
    {
        if(RunTrigger || Test.isRunningTest()){
            VisitPlanTriggerHandler.CreateEvents(Trigger.New);
            CallReportTriggerHandler.handlerAfterInsert(Trigger.new);
        }
    } 
    // ********   BEFORE UPDATE TRIGGER RUN HERE   ********* 
    else if(Trigger.isAfter && Trigger.isUpdate) 
    {        
        if(RunTrigger || Test.isRunningTest()){
            CallReportTriggerHandler.handlerAfterUpdate(Trigger.new,Trigger.old);
           VisitPlanTriggerHandler.updateEvents(Trigger.oldMap,Trigger.New);

           //12-03-2018 Add Google Location CR //only support first row
           CallReportTriggerHandler.updateGoogleLocation(Trigger.Old.get(0),Trigger.New.get(0));
           //12-03-2018 Add Google Location CR //only support first row
        }     
    }
    // ********   AFTER DELETE TRIGGER RUN HERE   *********  
  /*  else if(Trigger.isAfter && Trigger.isDelete) 
    {        
        
    } */
    System.debug('::: CallReportTrigger End ::::');
}