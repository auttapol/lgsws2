trigger SLLGroupApprovalHistoryTrigger on SLL_Group_Approval_History__c (before insert, before update, after update, after insert) {
    Boolean RunTrigger = AppConfig__c.getValues('runtrigger').Value__c == 'true' ; 

    if(RunTrigger){
        if(Trigger.isBefore && Trigger.isInsert) {
            //SLL Group Approval History Trigger before insert
            SLLGroupApprovalHistoryTriggerHandler.instance().handleBeforeInsert(Trigger.new);
        }
        else if(Trigger.isBefore && Trigger.isUpdate) {
            //SLL Group Approval History Trigger before insert
        }    
        else if(Trigger.isAfter && Trigger.isInsert) {
            //SLL Group Approval History Trigger after insert
        }    
        else if(Trigger.isAfter && Trigger.isUpdate) {
            //SLL Group Approval History Trigger after update
            SLLGroupApprovalHistoryTriggerHandler.instance().handleAfterUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}