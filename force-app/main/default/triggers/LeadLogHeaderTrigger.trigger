trigger LeadLogHeaderTrigger on LeadLogHeader__c (after update) {
    
    if(Trigger.isAfter && Trigger.isUpdate) 
    {
        UploadleadPagingControllerV2.delLogHeaderfromtrigger(Trigger.new);
    }
    
}