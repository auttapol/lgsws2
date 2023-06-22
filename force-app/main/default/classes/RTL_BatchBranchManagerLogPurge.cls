global class RTL_BatchBranchManagerLogPurge implements Database.Batchable<sObject> {
	
	global final String query;
	// instance member to retain state across transactions
	global TimeZone tz = UserInfo.getTimeZone();
	global Integer recordsProcessed = 0;
	global Integer recordsSuccessful = 0;
	global Integer recordsFailed = 0;
	global Datetime batchDate = datetime.now();
	global Datetime batchStartTime = datetime.now();
	global Datetime batchEndTime = null;
	
	global RTL_BatchBranchManagerLogPurge(String q) {
		query = q;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		System.Debug('TMB: -> RTL_BatchBranchManagerLogPurge start of execute');
    	
        // delete Branch Manger Log and its child older than x days
        if (scope.size() > 0) {
            Database.DeleteResult[] lsr = Database.delete(scope, false);
            // Iterate through each returned result
            for (Database.DeleteResult sr : lsr) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully deleted Branch Manger Log with ID: ' + sr.getId());
                    recordsSuccessful++;
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug(logginglevel.ERROR, 'There is error deleting Branch Manger Log. Error Message is: ' + err.getMessage());
                    }
                    recordsFailed++;
                }
            } 
        } 

        System.Debug('TMB: -> RTL_BatchBranchManagerLogPurge end of execute');
	}
	
	global void finish(Database.BatchableContext BC) {
        //Do not send email after purge finish
		/*batchEndTime = datetime.now();
    	recordsProcessed = recordsSuccessful + recordsFailed;
    	
    	String subject = 'Retail Batch: BranchManagerLogPurge run';
    	String description = 'Description : Retail Batch BranchManagerLogPurge run';
    	String status = null;
    	if (recordsFailed > 0) {//there are failed records
    		subject = subject + ' completely';
    		description = description + ' completely';
    		status = 'Failed';
    	} else {//there are no failed records
    		subject = subject + ' successfully';
    		description = description + ' successfully';
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
					+ '	<td>' + System.Label.RTL_Purge_Email_015 + '</td>'					
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

		RTL_BatchBranchManagerUpdate.SendEmail(bc.getJobId(), subject, htmlMsg);
		*/////
	}
	
}