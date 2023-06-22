trigger ChangeOwnerApprovalHistoryTrigger on Change_Owner_Approval_History__c (before update, after update){
    System.debug('::: ChangeOwnerApprovalHistoryTrigger Start ::::');

    list<Change_Owner_Approval_History__c> listNew = new list<Change_Owner_Approval_History__c>();
    list<Change_Owner_Approval_History__c> listOld = new list<Change_Owner_Approval_History__c>();

    Boolean RunTrigger = AppConfig__c.getValues('runtrigger').Value__c == 'true' ; 
    System.debug('RUNTRIGGER : ' + RunTrigger + ' : ' + Test.isRunningTest());

     if (Trigger.new != null){
        listNew.addAll(Trigger.new);
    }
    if (Trigger.old != null){
        listOld.addAll(Trigger.old);
    }

    if(Trigger.isAfter && Trigger.isUpdate){
        if( (RunTrigger || Test.isRunningTest()) && listNew.size() > 0 ){
            ChangeOwnerApprovalHistoryTriggerHandler.handleAfterUpdate(listNew,listOld);
        } 
    }

    System.debug('::: ChangeOwnerApprovalHistoryTrigger End ::::');
}