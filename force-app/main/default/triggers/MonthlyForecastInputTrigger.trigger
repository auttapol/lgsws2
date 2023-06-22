trigger MonthlyForecastInputTrigger on Monthly_Forecast_Input__c (before insert, after insert, after update) {
    System.debug('::: trigger Monthly_Forecast_Input__c Start ::::');

    Boolean RunTrigger = AppConfig__c.getValues('runtrigger').Value__c == 'true' ;

    if(Trigger.isBefore && Trigger.isInsert){
        if(RunTrigger || Test.isRunningTest()){
            MonthlyForecastInputTriggerHandler.BeforeInsert(Trigger.new);
        }
    }
    
    if(Trigger.isAfter && Trigger.isInsert){
        if(RunTrigger || Test.isRunningTest()){
            MonthlyForecastInputTriggerHandler.afterInsert(Trigger.NewMap);
        }
    }

    else if(Trigger.isAfter && Trigger.isUpdate){
        if(RunTrigger || Test.isRunningTest()){
            MonthlyForecastInputTriggerHandler.afterUpdate(Trigger.OldMap, Trigger.NewMap);
        }
    }
}