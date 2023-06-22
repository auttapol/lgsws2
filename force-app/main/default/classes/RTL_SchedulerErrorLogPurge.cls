global class RTL_SchedulerErrorLogPurge { //implements Schedulable
	/*global void execute(SchedulableContext sc){		
		//query Online Service Log older than x days
		App_Config__mdt PurgeErrorLogsAfter = [SELECT Value__c FROM App_Config__mdt WHERE MasterLabel = 'PurgeErrorLogsAfter']; 
        String days = PurgeErrorLogsAfter.Value__c;
        String query = 'select ID from RTL_Online_Service_Log__c where LastModifiedDate < LAST_N_DAYS:'+days;
        RTL_BatchErrorLogPurge logPurge = new RTL_BatchErrorLogPurge(query);
        Id BatchProcessId = Database.ExecuteBatch(logPurge);
    }*/
}