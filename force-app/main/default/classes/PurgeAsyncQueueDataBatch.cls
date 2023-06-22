global class PurgeAsyncQueueDataBatch implements Database.Batchable<sObject>, Database.stateful {
    private String query; 
    private Integer purgeDataDays; 
    private String purgeQuery; 
    private Date lastYearDate; 

    private Integer activityLogDeleteSuccessful = 0;

	private Datetime batchDate = datetime.now(); 
	private Datetime batchStartTime = datetime.now();
	private Datetime batchEndTime = null;

    public PurgeAsyncQueueDataBatch() {
        Commercial_Forecast_App_Config__mdt purgeDataDaysObj = [SELECT Id, DeveloperName, Value__c, Description__c FROM Commercial_Forecast_App_Config__mdt WHERE DeveloperName = 'AsyncApexFramework_Purge_Data_Days' LIMIT 1];
        if(purgeDataDaysObj != null && purgeDataDaysObj.Value__c != null){
            purgeDataDays = Integer.valueOf(purgeDataDaysObj.Value__c);
        }else{
            purgeDataDays = 365;
        }
        System.debug('Start PurgeAsyncQueueDataBatch purgeDataDays: '+ purgeDataDays);

        Commercial_Forecast_App_Config__mdt purgeQueryObj = [SELECT Id, DeveloperName, Value__c, Description__c FROM Commercial_Forecast_App_Config__mdt WHERE DeveloperName = 'AsyncApexFramework_Purge_Query' LIMIT 1];
        if(purgeQueryObj != null && purgeQueryObj.Value__c != null){
            purgeQuery = purgeQueryObj.Value__c;
        }else{
            purgeQuery = 'SELECT id FROM AsyncQueue__c WHERE CreatedDate <=: lastYearDate AND Job_Status__c IN (\'Aborted\', \'Completed\', \'Failed\') AND Status__c IN (\'Completed\',\'Failed\')';
        }
        System.debug('Start PurgeAsyncQueueDataBatch purgeQuery : '+ purgeQuery);


        lastYearDate = Date.today() - purgeDataDays;
        System.debug('Start PurgeAsyncQueueDataBatch purgeQuery : '+ lastYearDate);

        query = purgeQuery;
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('::::::::: Start PurgeAsyncQueueDataBatch ::::::::::::::::');
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<AsyncQueue__c> scope){
        System.debug('::::::::: Execute PurgeAsyncQueueDataBatch ::::::::::::::::');
        if(scope.size() > 0){
            Database.DeleteResult[] logDeleteResult = Database.delete(scope, false);
            for (Database.DeleteResult logDelete : logDeleteResult) {
                if (logDelete.isSuccess()) {
                    activityLogDeleteSuccessful++;
                }       
            } 
        }       
    }

    global void finish(Database.BatchableContext bc){
        System.debug('::::::::: Finish PurgeAsyncQueueDataBatch ::::::::::::::::');
        System.debug('PurgeAsyncQueueDataBatch activityLogDeleteSuccessful : '+activityLogDeleteSuccessful);
       
    }
    
}