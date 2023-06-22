trigger ExchangeRateTrigger on Exchange_Rate_Of_Thai_FCY__c (after insert){

    Boolean  RunTrigger = AppConfig__c.getValues('runtrigger').Value__c == 'true' ; 
    if(RunTrigger){
    
        if (Trigger.isAfter && Trigger.isInsert)
        {
            ExchangeRateExtension.afterInsert(Trigger.new);
        }
        
    }
}