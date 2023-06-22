trigger LeadLogValidHeaderTrigger on LeadLogValidHeader__c (after update) {

    if(Trigger.isAfter && Trigger.isUpdate) 
    {
        UploadleadPagingControllerV2.delLogfromtrigger(Trigger.new);
    }
}