public class RTL_UploadCampaignMemberImportError implements Queueable {

	List<RTL_Upload_Campaign_Members__c> errorList;
	RTL_Upload_Campaign_Member_Batch__c ucmb;
	RTL_Upload_Campaign_Member_Logs__c ucml;

	private Integer itemPerSaveMember {
    	get{
                if(itemPerSaveMember==null){
                 RTL_Upload_Campaign_Member__mdt ucmMeta = [select id,RTL_Line_Save_Per_Batch__c
                   from RTL_Upload_Campaign_Member__mdt 
                   where DeveloperName = 'RTL_Upload_Campaign_Member_Setting'];

                   itemPerSaveMember = integer.valueOf(ucmMeta.RTL_Line_Save_Per_Batch__c);
            }
            return itemPerSaveMember;
        }
    	set;
    }

	public RTL_UploadCampaignMemberImportError(RTL_Upload_Campaign_Member_Logs__c logObject,RTL_Upload_Campaign_Member_Batch__c batchOjbect,List<RTL_Upload_Campaign_Members__c> ucmList)
	{
		errorList = ucmList;
		ucmb = batchOjbect;
		ucml = logObject;
	}

	public void execute(QueueableContext context) {

		// Insert error record from parent chianed class
        Database.SaveResult[] ucmResultList = Database.insert(errorList,false);
	
		ucmb.RTL_Status__c ='Completed';
		update ucmb;

        ucmL.RTL_UploadStatus__c = 'In Progress - Import Batch';
        update ucmL;

        // Call Import campaign member from CSV to temp
		RTL_UploadCampaignMemberBatch ucmBatch = new RTL_UploadCampaignMemberBatch(ucmL,ucmb);
		Database.executeBatch(ucmBatch ,itemPerSaveMember);
	}
}