trigger VisitPlanInviteeTrigger on Visit_Plan_Invitee__c (before insert,after insert,before update,after update, before delete) {
    
    if(Trigger.IsBefore && Trigger.IsInsert){
        VisitPlanTriggerHandler.checkpermissionTMBCounterParty(Trigger.oldMap,Trigger.new,'INSERT');
    }
    else if(Trigger.isAfter && Trigger.isInsert) 
    {  
      VisitPlanTriggerHandler.VisitInviteeSynch(Trigger.oldMap,Trigger.New,'INSERT');
    }
    else if(Trigger.IsBefore && Trigger.isUpdate){
       VisitPlanTriggerHandler.checkpermissionTMBCounterParty(Trigger.oldMap,Trigger.new,'UPDATE');
    }
   
    else if(Trigger.isAfter && Trigger.isUpdate) 
    {        
      VisitPlanTriggerHandler.VisitInviteeSynch(Trigger.oldMap,Trigger.New,'UPDATE');     
    }
    else if(Trigger.isBefore && Trigger.isDelete) 
    {        
      VisitPlanTriggerHandler.checkpermissionTMBCounterParty(Trigger.oldMap,Trigger.old,'DELETE');
      VisitPlanTriggerHandler.VisitInviteeSynch(Trigger.oldMap,Trigger.old,'DELETE');   
    }
}