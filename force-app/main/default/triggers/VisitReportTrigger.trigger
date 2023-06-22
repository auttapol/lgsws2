trigger VisitReportTrigger on Visit_Report__c (before insert,before update,before delete) {
    if(Trigger.isBefore && Trigger.isInsert) 
    { 
      VisitReportTriggerHandler.checkTMBPerson(Trigger.new,'INSERT');
    } 
    else if(Trigger.isBefore && Trigger.isUpdate) 
    { 
      VisitReportTriggerHandler.checkTMBPerson(Trigger.new,'UPDATE');
    }
    else if(Trigger.isBefore && Trigger.isDelete) 
    { 
      VisitReportTriggerHandler.checkTMBPerson(Trigger.old,'DELETE');
    }  
}