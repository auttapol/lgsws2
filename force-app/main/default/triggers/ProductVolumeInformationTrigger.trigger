trigger ProductVolumeInformationTrigger on Product_Volume_Information__c (before insert) {
    Boolean RunTrigger = AppConfig__c.getValues('runtrigger').Value__c == 'true' ; 
    
    if(RunTrigger){
        if(Trigger.isBefore && Trigger.isInsert){
            ProductVolumeInformationTriggerHandler.handleBeforeInsert(Trigger.new);
        }//else if(Trigger.isBefore && Trigger.isUpdate){

        // } else if(Trigger.isAfter && Trigger.isInsert) {  

        // } else if(Trigger.isAfter && Trigger.isUpdate) {  

        // } 
    }
}