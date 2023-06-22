global class RTL_SchedulerNBOPurge implements Schedulable{
	global void execute(SchedulableContext sc){		
		//query NBO History older than 3 months
        String query = 'select ID from RTL_NBO_History__c where RTL_NBO_Product_Latest_Modified_Date__c < LAST_N_MONTHS:3';
        RTL_BatchNBOPurge nboPurge = new RTL_BatchNBOPurge(query);
        Id BatchProcessId = Database.ExecuteBatch(nboPurge);
    }   
}