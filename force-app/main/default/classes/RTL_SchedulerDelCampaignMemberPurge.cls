global class RTL_SchedulerDelCampaignMemberPurge implements Schedulable {
	global void execute(SchedulableContext sc) {
		//query Del Campaign member older than x days
		App_Config__mdt PurgeDelCampaignMemberDays = [SELECT Value__c FROM App_Config__mdt WHERE MasterLabel = 'PurgeDelCampaignMemberDays']; 
        String days = PurgeDelCampaignMemberDays.Value__c;
        String query = 'select ID from RTL_Deleted_Campaign_Member__c where CreatedDate < LAST_N_DAYS:'+days;
        RTL_BatchDelCampaignMemberPurge memberPurge = new RTL_BatchDelCampaignMemberPurge(query);
        Id BatchProcessId = Database.ExecuteBatch(memberPurge);

	}
}