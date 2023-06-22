global class RTL_BatchBranchManagerUpdate implements Database.Batchable<sObject>,Database.StateFul {
	
	global final String query;
	//get manager title from custom setting
	global String branchManagerTitle = RTL_Branch_Manager_Title__c.getValues('Branch Manager').RTL_Value__c;
	
	global Map<String,List<User>> branchCodeManagerMap; /*<branchCode,User>*/
	global List<Branch_and_Zone__c> branchToUpdate;
	global Map<Id,RTL_Branch_Manager_Batch_Details__c> detailLogMap;/*<branchId,BranchManagerBatchDetails>*/
	
	// instance member to retain state across transactions
	global TimeZone tz = UserInfo.getTimeZone();
	global Integer recordsProcessed = 0;
	global Integer recordsSuccessful = 0;
	global Integer recordsFailed = 0;
	global Datetime batchDate = datetime.now();
	global Datetime batchStartTime = datetime.now();
	global Datetime batchEndTime = null;

	/*<UserId,User>*/
	global Map<Id,User> branchManagerMap{
		get{
			if(branchManagerMap == null){
				//query all active branch manager
				branchManagerMap = new Map<Id,User>([SELECT ID,Name,RTL_Branch_Code__c,Title 
											 FROM User 
											 WHERE isActive = true AND title=:branchManagerTitle
											 ORDER BY RTL_Branch_Code__c,Name ]);
			}
			return branchManagerMap;
		}set;

	} 

	global RTL_Branch_Manager_Batch_Job__c batchJob{
		get{
			if(batchJob == null){
				batchJob = new RTL_Branch_Manager_Batch_Job__c();
				batchJob.RTL_Status__c = 'Success';
				batchJob.RTL_Branch_Manager_Details__c = branchManagerString(branchManagerMap);
				insert batchJob;
			}
			return batchJob;
		}set;
	}



	global RTL_BatchBranchManagerUpdate(String q) {
		query = q;
				
		branchCodeManagerMap = new Map<String,List<User>>();	
		
		//create a map <branchcode,User>
		for(User userObj: branchManagerMap.values()){
			if(branchCodeManagerMap.containsKey(userObj.RTL_Branch_Code__c)){
				List<User> userList = branchCodeManagerMap.get(userObj.RTL_Branch_Code__c);
				userList.add(userObj);
				//branchCodeManagerMap.put(userObj.RTL);
			}else{
				branchCodeManagerMap.put(userObj.RTL_Branch_Code__c,new List<User>{userObj});
			}
			
		}
		
		
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<Branch_and_Zone__c> scope) {
		System.Debug('TMB: -> RTL_BatchUpdateBranchManager start of execute');
		branchToUpdate = new List<Branch_and_Zone__c>();
		detailLogMap = new Map<Id,RTL_Branch_Manager_Batch_Details__c>();    	
        
        try{// query all Branch Manager and confirm that existing Branch Manager is up-to-date
        if (scope.size() > 0) {

            for(Branch_and_Zone__c branchZone : scope){
            	String oldMgr = branchZone.RTL_Branch_Manager_User__r.Name;
            	//if branch manager not found
            	if(branchCodeManagerMap.containsKey(branchZone.Branch_Code__c) == false){           		
            		//invalid , no branch manager found , set manager to null
            		branchZone.RTL_Branch_Manager_User__c = null;
            		branchToUpdate.add(branchZone);
            		//insert fail log
            		detailLogMap.put(branchZone.id,createBatchDetails(branchZone.id,'Manager not found','',oldMgr,'Fail'));
            	}
            	//if branch manager found
            	else{ 
            		List<User> userList = branchCodeManagerMap.get(branchZone.Branch_Code__c);
            		//if manager is changed
            		if(branchZone.RTL_Branch_Manager_User__c != userList[0].id)
            		{
            			String newMgr = userList[0].Name;
            			branchZone.RTL_Branch_Manager_User__c = userList[0].id;
            			branchToUpdate.add(branchZone);
            			
            			if(userList.size() == 1)
            			{
            				//valid , only 1 branch manager found
            				detailLogMap.put(branchZone.id,createBatchDetails(branchZone.id,null,newMgr,oldMgr,'Success'));
            			}else
            			{
            				//invalid , more than 1 branch manager found
            				detailLogMap.put(branchZone.id,createBatchDetails(branchZone.id,'More than 1 Manager found for this branch',newMgr,oldMgr,'Fail'));
            			}
            		}
            	}
            }

            updateBranchAndZone(branchToUpdate,detailLogMap);
        }
        }catch(Exception ex){
        	system.debug('Line - '+ex.getLineNumber()+' Error - '+ex.getMessage());
        	batchErrorHandler('Line - '+ex.getLineNumber()+' Error - '+ex.getMessage(),batchJob);
        } 

        System.Debug('TMB: -> RTL_BatchUpdateBranchManager end of execute');
	}
	
	global void finish(Database.BatchableContext BC) {
		try{
			
			RTL_Branch_Manager_Batch_Job__c updatedBatchJob = [SELECT Id,Name,RTL_Record_Processed__c,RTL_Record_Failed__c,
																  RTL_Record_Success__c,RTL_Status__c
															FROM RTL_Branch_Manager_Batch_Job__c
															WHERE id=:batchJob.id];
        	recordsProcessed = (Integer)updatedBatchJob.RTL_Record_Processed__c;
        	//send notification email if there are records processed
        	if(recordsProcessed > 0){

        		batchEndTime = datetime.now();
        		String subject = 'Retail Batch: BranchManagerUpdate run';
    			String description = 'Description : Retail Batch BranchManagerUpdate run';
    			String status = updatedBatchJob.RTL_Status__c;
    			recordsFailed = (Integer)updatedBatchJob.RTL_Record_Failed__c;
    			recordsSuccessful = (Integer)updatedBatchJob.RTL_Record_Success__c;

    			subject = subject + ' successfully';
    			description = description + ' successfully';
    	
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
						+ '	<td>' + 'Branch_And_Zone__c' + '</td>'					
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

				sendEmail(bc.getJobId(), subject, htmlMsg);
			}

			purgeOldBranchMangerLog();
		
		}catch(Exception ex){
			
			system.debug('Line - '+ex.getLineNumber()+' Error - '+ex.getMessage());
        	batchErrorHandler('Line - '+ex.getLineNumber()+' Error - '+ex.getMessage(),batchJob);
		
		}


	}

	private void updateBranchAndZone(List<Branch_and_Zone__c> branchZoneList,Map<Id,RTL_Branch_Manager_Batch_Details__c> branchDetailMap){
		if(branchZoneList.size() > 0){
			Database.SaveResult[] lsr = Database.update(branchZoneList, false);
        	// Iterate through each returned result
        	for (Database.SaveResult sr : lsr) {
            	if (sr.isSuccess()) {
                	// Operation was successful, so get the ID of the record that was processed
                	System.debug('Successfully deleted Online Service Log with ID: ' + sr.getId());
            	}
            	else {
            		String recordId = sr.getId();
                	RTL_Branch_Manager_Batch_Details__c log = branchDetailMap.get(recordId);
                	log.RTL_Status__c = 'Fail';
            		// Operation failed, so get all errors                
                	for(Database.Error err : sr.getErrors()) {
                		log.RTL_Message__c += err.getMessage()+',';
                    	System.debug(logginglevel.ERROR, 'There is error deleting Online Service Log. Error Message is: ' + err.getMessage());
                	}
            	}
        	}
        	insert branchDetailMap.values();
		}
	}

	global static void SendEmail(Id jobId, String subject, String body) {
		if (Test.isRunningTest()) return;
		
		OrgWideEmailAddress owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'sf_admin@tmbbank.com' limit 1];
		// Get the list of email address from AppConfig
		String crmTeam2 = AppConfig__c.getValues('CRM Admin 2').Value__c;
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		String[] toAddresses = RTL_BatchEmailService.mergeEmailAddr(crmTeam2,null, null, null, null);
		mail.setToAddresses(toAddresses);
		if (owea != null) {
    		mail.setOrgWideEmailAddressId(owea.Id);
		}			
		mail.setSubject(subject);
		mail.setHtmlBody(body);
		Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		if (results[0].success) {
		    System.debug('The email was sent successfully.');
		} else {
		    System.debug('The email failed to send: ' + results[0].errors[0].message);
		}
	}

	private String branchManagerString(Map<Id,User> branchManagerMap){
		String str = '';
		for(User user : branchManagerMap.values()){
			str = str+'Branch Code: '+user.RTL_Branch_Code__c+' Branch Manager Name: '+user.Name+'\n';
		}
		return str;
	}

	private RTL_Branch_Manager_Batch_Details__c createBatchDetails(String branchId,String message,String newMgr,String oldMgr,String status){
		RTL_Branch_Manager_Batch_Details__c detail = new RTL_Branch_Manager_Batch_Details__c();
		detail.RTL_Branch_and_Zone__c = branchId;
		detail.RTL_Branch_Manager_Batch_Job__c = batchJob.id;
		detail.RTL_Message__c = message;
		detail.RTL_New_Manager__c = newMgr;
		detail.RTL_Old_Manager__c = oldMgr;
		detail.RTL_Status__c = status;

		return detail;
	}

	private void batchErrorHandler(String errMsg,RTL_Branch_Manager_Batch_Job__c batchJob){
		//update error message and status on BatchJob
		batchJob.RTL_Status__c = 'Fail';
		batchJob.RTL_Message__c = errMsg;
		update batchJob;

		//send error email
		String subject = 'Retail Batch: BranchManagerUpdate run Failed';
    	String description = 'Description : Retail Batch BranchManagerUpdate run Failed';
    	String status = 'Failed';

		string htmlMsg = description + ' <br/><br/>'
    				+ 'Batch as of : ' + batchDate.format('dd/MM/yyyy', tz.toString()) + '<br/><br/>'
    				+ System.Label.RTL_Purge_Email_002 + ' : ' + status + '<br/><br/>'
    				+ 'Message' + ' : ' + errMsg + '<br/><br/>'
					+ '<br/><font color="red">' + System.Label.RTL_Purge_Email_011 + '</font><br/>'
					+ '<br/>' + System.Label.RTL_Purge_Email_footer + '</font>';
        SendEmail(null,subject,htmlMsg);


	}

	private void purgeOldBranchMangerLog(){
		//Get x days from custom metadata
		App_Config__mdt PurgeBranchManagerLogsAfter = [SELECT Value__c FROM App_Config__mdt WHERE MasterLabel = 'PurgeBranchManagerLogsAfter']; 
        String days = PurgeBranchManagerLogsAfter.Value__c;
        //query Branch Manager Log older than x days
        String query = 'select ID from RTL_Branch_Manager_Batch_Job__c where LastModifiedDate < LAST_N_DAYS:'+days;
        RTL_BatchBranchManagerLogPurge logPurge = new RTL_BatchBranchManagerLogPurge(query);
        Id BatchProcessId = Database.ExecuteBatch(logPurge);
	}
	
}