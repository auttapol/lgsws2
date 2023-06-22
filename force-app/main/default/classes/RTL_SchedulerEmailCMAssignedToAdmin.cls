global class RTL_SchedulerEmailCMAssignedToAdmin implements Schedulable {
	
	global void execute(SchedulableContext sc) {
		//String query = 'SELECT Id, Name FROM CampaignMember WHERE RTL_Assigned_Channel__c != \'Outbound\' AND RTL_Assigned_Branch__c = null AND RTL_Assigned_Agent__c = null AND RTL_TMB_Campaign_Source__c IN (\'Web\',\'ATM Request\',\'Call me now\')';
        
		String query = 'SELECT Id, Name FROM CampaignMember WHERE RTL_Assigned_Channel__c != \'Outbound\'';
		query = query + ' AND RTL_Assigned_Branch__c = null';
        query = query + ' AND RTL_Assigned_Agent__c = null';
        query = query + ' AND Campaign.Status != \'Expired\'';
       	query = query + ' AND RTL_Contact_Status__c = \'New\' ';
        query = query + ' AND RTL_Offer_Result_Eng__c  = \'Pending\'';
		query = query + ' AND RecordType.DeveloperName = \'Retail_Campaign_Member\'';
		query = query + ' AND RTL_Channel_Outbound__c = false';

        RTL_BatchEmailCMAssignAdmin emailBatch = new RTL_BatchEmailCMAssignAdmin(query);
        Id BatchProcessId = Database.ExecuteBatch(emailBatch);	
	}

	
}