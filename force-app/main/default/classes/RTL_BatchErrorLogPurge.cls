global class RTL_BatchErrorLogPurge {//implements Database.Batchable<sObject>, Database.Stateful
	/*global final String query;
	// instance member to retain state across transactions
	global TimeZone tz = UserInfo.getTimeZone();
	global Integer recordsProcessed = 0;
	global Integer recordsSuccessful = 0;
	global Integer recordsFailed = 0;
	global Datetime batchDate = datetime.now();
	global Datetime batchStartTime = datetime.now();
	global Datetime batchEndTime = null;
	
    global RTL_BatchErrorLogPurge(String q){
        query = q;
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<RTL_Online_Service_Log__c> scope){
    	System.Debug('TMB: -> RTL_BatchErrorLogPurge start of execute');
    	
        // delete Online Service Log older than x days
        if (scope.size() > 0) {
            Database.DeleteResult[] lsr = Database.delete(scope, false);
            // Iterate through each returned result
            for (Database.DeleteResult sr : lsr) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully deleted Online Service Log with ID: ' + sr.getId());
                    recordsSuccessful++;
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug(logginglevel.ERROR, 'There is error deleting Online Service Log. Error Message is: ' + err.getMessage());
                    }
                    recordsFailed++;
                }
            } 
        } 

        System.Debug('TMB: -> RTL_BatchErrorLogPurge end of execute');
    }    

    global void finish(Database.BatchableContext bc){
    	batchEndTime = datetime.now();
    	recordsProcessed = recordsSuccessful + recordsFailed;
    	
    	String subject = null;
    	String description = null;
    	String status = null;
    	if (recordsFailed > 0) {//there are failed records
    		subject = System.Label.RTL_Purge_MSG003 + ' completely';
    		description = System.Label.RTL_Purge_Email_014 + ' completely';
    		status = 'Failed';
    	} else {//there are no failed records
    		subject = System.Label.RTL_Purge_MSG003 + ' successfully';
    		description = System.Label.RTL_Purge_Email_014 + ' successfully';
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

		RTL_BatchEmailService.SendEmail(bc.getJobId(), subject, htmlMsg);		
    }*/
}