trigger OtherBankTrigger on Other_Bank__c (before delete) {
    if(Trigger.isBefore && Trigger.isDelete){
        OtherBankTriggerHandler.onDelete(trigger.old);
    }
}