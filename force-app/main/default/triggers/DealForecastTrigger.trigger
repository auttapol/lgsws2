trigger DealForecastTrigger on Deal_Forecast_Income__c (after insert, after update, before delete) {
	Boolean RunTrigger = AppConfig__c.getValues('runtrigger').Value__c == 'true' ; 
    
    if(Trigger.isAfter && Trigger.isInsert) 
    {  
        if(RunTrigger || Test.isRunningTest()){
			// DealForecastTriggerHandler.generateForecastInput(Trigger.new);
        }
    }
    else if(Trigger.isAfter && Trigger.isUpdate) 
    {  
        if(RunTrigger || Test.isRunningTest()){
            DealForecastTriggerHandler.updateOpportunitylineitem(Trigger.OldMap, Trigger.NewMap);
            // DealForecastTriggerHandler.updateForecastInput(Trigger.NewMap);
        }
    }
    else if(Trigger.isBefore && Trigger.isDelete) 
    {
        if(RunTrigger || Test.isRunningTest()){
            DealForecastTriggerHandler.syncOpportunitylineitem(Trigger.OldMap);
            DealForecastTriggerHandler.deleteSubDealForecast(Trigger.OldMap);
            DealForecastTriggerHandler.deleteForecastInput(Trigger.OldMap);
        }
    }
}