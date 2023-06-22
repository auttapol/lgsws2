global class RTL_BatchNBOPurge implements Database.Batchable<sObject>, Database.Stateful {
	global final String query;
	// instance member to retain state across transactions
	global TimeZone tz = UserInfo.getTimeZone();
	global Integer recordsProcessed = 0;
	global Integer recordsSuccessful = 0;
	global Integer recordsFailed = 0;
	global Datetime batchDate = datetime.now();
	global Datetime batchStartTime = datetime.now();
	global Datetime batchEndTime = null;
	
    //Refacorting Delete Batch 27-12-2017
    private String sobjectName = System.Label.RTL_Purge_Email_010;
    private String purgeName   = 'PurgeNBOHistory';
    private Boolean isFromChainMethod = false;

    global RTL_BatchNBOPurge(String q,String sobjName){
        query = q;
        sobjectName = sobjName;
        purgeName   = 'Purge'+sobjectName;
        isFromChainMethod = true;
    }
    //Refacorting Delete Batch 27-12-2017
    
    global RTL_BatchNBOPurge(String q){
        query = q;
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<sObject> scope){
    	System.Debug('TMB: -> RTL_BatchNBOPurge start of execute');
    	
        // delete NBO History and products older than 3 months
        // because of master-detail relationship, RTL_NBO_History_Product__c related with RTL_NBO_History__c in the scope will be deleted automatically
        if (scope.size() > 0) {
            Database.DeleteResult[] lsr = Database.delete(scope, false);
            // Iterate through each returned result
            for (Database.DeleteResult sr : lsr) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully deleted NBO History with ID: ' + sr.getId());
                    recordsSuccessful++;
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug(logginglevel.ERROR, 'There is error deleting NBO History. Error Message is: ' + err.getMessage());
                    }
                    recordsFailed++;
                }
            } 
        } 

        System.Debug('TMB: -> RTL_BatchNBOPurge end of execute');
    }    

    global void finish(Database.BatchableContext bc){
    	batchEndTime = datetime.now();
    	recordsProcessed = recordsSuccessful + recordsFailed;
    	
    	String subject = null;
    	String description = null;
    	String status = null;

        //Refacorting Delete Batch 27-12-2017
        List<String> fillers = new String[]{purgeName};
        String purgeJobDesc = String.format(System.Label.RTL_Purge_Email_001
                                            , fillers);
        String subjectJob   = String.format(System.Label.RTL_Purge_MSG001
                                            , fillers);
        //Refacorting Delete Batch 27-12-2017

    	if (recordsFailed > 0) {//there are failed records
    		subject = subjectJob + ' completely';
    		description = purgeJobDesc + ' completely';
    		status = 'Failed';
    	} else {//there are no failed records
    		subject = subjectJob + ' successfully';
    		description = purgeJobDesc + ' successfully';
    		status = 'Success';
    	}
    	
		AsyncApexJob job = [SELECT Id, Status FROM AsyncApexJob WHERE Id = :bc.getJobId()];
			
    	string htmlMsg = description + ' <br/><br/>'
    				+ 'Batch as of : ' + batchDate.format('dd/MM/yyyy', tz.toString()) + '<br/><br/>'
    				+ System.Label.RTL_Purge_Email_002 + ' : ' + status + '<br/><br/>'
					+ '<table style="width:100%" border=1>'
					+ '<tr>'
					+ '	<th>No.</th>'
					+ '	<th>' + System.Label.RTL_Purge_Email_006 + '</th>'					
					+ '	<th>' + System.Label.RTL_Purge_Email_003 + '</th>'
					+ '	<th>' + System.Label.RTL_Purge_Email_004 + '</th>'
					+ '	<th>' + System.Label.RTL_Purge_Email_005 + '</th>'
					+ '	<th>' + System.Label.RTL_Purge_Email_007 + '</th>'
					+ '	<th>' + System.Label.RTL_Purge_Email_008 + '</th>'
					+ '	<th>' + System.Label.RTL_Purge_Email_009 + '</th>'
					+ '</tr>'
					+ '<tr>'
					+ '	<td>1</td>'	
					//+ '	<td>' + System.Label.RTL_Purge_Email_010 + '</td>'		
                    + ' <td>' + sobjectName + '</td>'      			
					+ '	<td>' + batchDate.format('dd/MM/yyyy', tz.toString()) + '</td>'
					+ '	<td>' + batchStartTime.format('dd/MM/yyyy HH:mm:ss', tz.toString()) + '</td>'
					+ '	<td>' + batchEndTime.format('dd/MM/yyyy HH:mm:ss', tz.toString()) + '</td>'
					+ '	<td>' + recordsProcessed + '</td>'
					+ '	<td>' + recordsSuccessful + '</td>'
					+ '	<td>' + recordsFailed + '</td>'
					+ '</tr>'
					+ '</table>'
					+ '<br/><font color="red">' + System.Label.RTL_Purge_Email_011 + '</font><br/>'
					+ '<br/>' + System.Label.RTL_Purge_Email_footer + '</font>';

		RTL_BatchEmailService.SendEmail(bc.getJobId(), subject, htmlMsg);		

        if (!isFromChainMethod) chainFinishJob(); 
    }

    //Refacorting Delete Batch 27-12-2017
    private void chainFinishJob() {
        Integer PurgeLeadLogNDays = 45;
        try{
            List<App_Config__mdt> PurgeLeadLogNDaysMetaData 
                = [SELECT Value__c FROM App_Config__mdt WHERE MasterLabel = 'PurgeLeadLogNDays'];

            if (PurgeLeadLogNDaysMetaData != null && PurgeLeadLogNDaysMetaData.size() > 0) {
                PurgeLeadLogNDays = Integer.valueOf(PurgeLeadLogNDaysMetaData.get(0).Value__c);
            }      
        }catch( Exception e ){
            System.debug(e);
        }
        //Purge LeadLogHeader
        String queryForLeadHeader = 'select Id from LeadLogHeader__c where CreatedDate < LAST_N_DAYS:'
                        +PurgeLeadLogNDays;


        RTL_BatchNBOPurge leadLogPurge = new RTL_BatchNBOPurge(queryForLeadHeader,'LeadLogHeader__c');
        Id BatchProcessIdForLeadHeader = Database.ExecuteBatch(leadLogPurge);

        String queryForLeadValidHeader = 'select Id from LeadLogValidHeader__c where CreatedDate < LAST_N_DAYS:'
                        +PurgeLeadLogNDays;

        RTL_BatchNBOPurge leadLogValidPurge = new RTL_BatchNBOPurge(queryForLeadValidHeader,'LeadLogValidHeader__c');
        Id BatchProcessIdForLeadValidHeader = Database.ExecuteBatch(leadLogValidPurge);
        //Purge LeadLogValidHeader
    }
    //Refacorting Delete Batch 27-12-2017
}