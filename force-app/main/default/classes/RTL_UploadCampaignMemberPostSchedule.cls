global class RTL_UploadCampaignMemberPostSchedule implements Schedulable {

	String ucmlID;

	global RTL_UploadCampaignMemberPostSchedule(String uploadCampaingMemberLogId)
	{
		ucmlID = uploadCampaingMemberLogId;	
	}

	global void execute(SchedulableContext sc) {

		
		//List<RTL_Upload_Campaign_Members__c> uploadMemberResults = [
		//	SELECT ID 
		//	FROM RTL_Upload_Campaign_Members__c
		//	WHERE RTL_Upload_Campaign_Member_Logs__r.id = :ucmlID
  //          ];

  //      delete uploadMemberResults;
  		RTL_UploadCampaignMemberDelete ucmdBatch = new RTL_UploadCampaignMemberDelete(ucmlID);
        Database.executeBatch(ucmdBatch,5000);

		
        //system.debug('delete upload member log');

        //Abort Job to run only one time
        System.abortJob(sc.getTriggerId());
	}
//

}