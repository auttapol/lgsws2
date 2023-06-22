global class UserLoginHistDeleteScheduler implements Schedulable {
    global void execute(SchedulableContext sc){
    	//Get Days_of_Delete_BatchHistory from AppConfig
    	Integer delLogDate = 45;
    	try {
    		AppConfig__c cf = AppConfig__c.getValues('PurgeErrorLogsAfter');
    		delLogDate = Integer.valueOf(cf.Value__c);
    	}catch(Exception e) {}

    	String delSQL = 'Select ID, Name from User_Login_History__c where Date__c < LAST_N_DAYS:'+delLogDate;

    	DailyScheduleBatch delLogHis = new DailyScheduleBatch(delSQL
                                                                    ,DailyScheduleBatch.DELETE_USER_HISTORYLOG_BATCH
                                                                    ,'User_Login_History__c'
                                                                    ,'CRM Admin 2'
                                                                    ,false);

        Id BatchProcessIdForCampExpr = Database.ExecuteBatch(delLogHis);
    }

}