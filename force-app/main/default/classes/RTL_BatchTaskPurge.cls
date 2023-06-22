global class RTL_BatchTaskPurge implements Database.Batchable<sObject>, Database.Stateful {
	global final String query;
	// instance member to retain state across transactions
	global TimeZone tz = UserInfo.getTimeZone();	
	global Integer taskRecordsProcessed = 0;
	global Integer taskRecordsSuccessful = 0;	
	global Integer taskRecordsFailed = 0;
	global Integer nboRecordsProcessed = 0;
	global Integer nboRecordsSuccessful = 0;
	global Integer nboRecordsFailed = 0;	
	global Datetime batchDate = datetime.now();
	global Datetime batchStartTime = datetime.now();
	global Datetime batchEndTime = null;
		
    global RTL_BatchTaskPurge(String q){
        query = q;
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Task> scope){
    	System.Debug('TMB: -> RTL_BatchTaskPurge start of execute');
    	
    	Set<Id> nboIDList = new Set<Id>();
    	for (Task task: scope) {
    		//Delete NBO History & Product together with the task
    		if (task.RTL_NBO_History__c != null) {//NBO related task
    			nboIDList.add(task.RTL_NBO_History__c);
    		}
    	}
    	
    	List<RTL_NBO_History__c> nboHistoryToDelete = new List<RTL_NBO_History__c>();
        for(RTL_NBO_History__c nboHistory : [Select Id from RTL_NBO_History__c where Id in :nboIDList]) {
            nboHistoryToDelete.add(nboHistory);
        }
    	
        // delete Task older than 3 months
        if (scope.size() > 0) {
            Database.DeleteResult[] lsr = Database.delete(scope, false);
            // Iterate through each returned result
            for (Database.DeleteResult sr : lsr) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully deleted Task with ID: ' + sr.getId());
                    taskRecordsSuccessful++;
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug(logginglevel.ERROR, 'There is error deleting Task. Error Message is: ' + err.getMessage());
                    }
                    taskRecordsFailed++;
                }
            } 
        } 
        
        // delete Task related NBO History & Product
		// because of master-detail relationship, RTL_NBO_History_Product__c related with RTL_NBO_History__c in the scope will be deleted automatically
        if (nboHistoryToDelete.size() > 0) {
            Database.DeleteResult[] lsr = Database.delete(nboHistoryToDelete, false);
            // Iterate through each returned result
            for (Database.DeleteResult sr : lsr) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully deleted NBO History with ID: ' + sr.getId());
                    nboRecordsSuccessful++;
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug(logginglevel.ERROR, 'There is error deleting NBO History. Error Message is: ' + err.getMessage());
                    }
                    nboRecordsFailed++;
                }
            } 
        }         

        System.Debug('TMB: -> RTL_BatchTaskPurge end of execute');
    }
    
	global void finish(Database.BatchableContext bc){
    	batchEndTime = datetime.now();
    	taskRecordsProcessed = taskRecordsSuccessful + taskRecordsFailed;
    	nboRecordsProcessed = nboRecordsSuccessful + nboRecordsFailed;
    	
    	String subject = null;
    	String description = null;
    	String status = null;
    	if (taskRecordsFailed > 0 || nboRecordsFailed > 0) {//there are failed records
    		subject = System.Label.RTL_Purge_MSG002 + ' completely';
    		description = System.Label.RTL_Purge_Email_012 + ' completely';
    		status = 'Failed';
    	} else {//there are no failed records
    		subject = System.Label.RTL_Purge_MSG002 + ' successfully';
    		description = System.Label.RTL_Purge_Email_012 + ' successfully';
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
					+ '	<td>' + System.Label.RTL_Purge_Email_013 + '</td>'					
					+ '	<td>' + batchDate.format('dd/MM/yyyy', tz.toString()) + '</td>'
					+ '	<td>' + batchStartTime.format('dd/MM/yyyy HH:mm:ss', tz.toString()) + '</td>'
					+ '	<td>' + batchEndTime.format('dd/MM/yyyy HH:mm:ss', tz.toString()) + '</td>'
					+ '	<td>' + taskRecordsProcessed + '</td>'
					+ '	<td>' + taskRecordsSuccessful + '</td>'
					+ '	<td>' + taskRecordsFailed + '</td>'
					+ '</tr>'
					+ '<tr>'
					+ '	<td>2</td>'	
					+ '	<td>' + System.Label.RTL_Purge_Email_010 + '</td>'					
					+ '	<td>' + batchDate.format('dd/MM/yyyy', tz.toString()) + '</td>'
					+ '	<td>' + batchStartTime.format('dd/MM/yyyy HH:mm:ss', tz.toString()) + '</td>'
					+ '	<td>' + batchEndTime.format('dd/MM/yyyy HH:mm:ss', tz.toString()) + '</td>'
					+ '	<td>' + nboRecordsProcessed + '</td>'
					+ '	<td>' + nboRecordsSuccessful + '</td>'
					+ '	<td>' + nboRecordsFailed + '</td>'
					+ '</tr>'					
					+ '</table>'
					+ '<br/><font color="red">' + System.Label.RTL_Purge_Email_011 + '</font><br/>'
					+ '<br/>' + System.Label.RTL_Purge_Email_footer + '</font>';

		RTL_BatchEmailService.SendEmail(bc.getJobId(), subject, htmlMsg);
    }
}