global class RTL_UploadCampaignMemberDelete implements Database.Batchable<sObject> {
	
	private String query;
	private String id;
	
	global RTL_UploadCampaignMemberDelete(String ucmlID) {
		id = ucmlID;
		query =  'SELECT ID FROM RTL_Upload_Campaign_Members__c WHERE RTL_Upload_Campaign_Member_Logs__r.id = :id';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<RTL_Upload_Campaign_Members__c> scope) {
		delete scope;
	}
	
	global void finish(Database.BatchableContext BC) {

		List<RTL_Upload_Campaign_Member_Batch__c> uploadMemberBatchResults = [
			SELECT ID 
			FROM RTL_Upload_Campaign_Member_Batch__c
			WHERE RTL_Upload_Campaign_Member_Logs__r.id = :id
            ];

        delete uploadMemberBatchResults;
		
	}
	
}