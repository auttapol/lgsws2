global class RTL_BatchEmailCMAssignAdmin implements Database.Batchable<sObject>, Database.Stateful{
	
	global final String query;
    global Integer errorRecords = 0;
    global TimeZone tz = UserInfo.getTimeZone();
    global DateTime logDate = DateTime.now();
    
    global RTL_BatchEmailCMAssignAdmin(String q){
    	query = q;    
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<CampaignMember> scope){
    	System.Debug('TMB: -> RTL_BatchCMAssignEmailErrorLog start of execute');
    	system.debug(scope.size());
    	errorRecords += scope.size();
        System.Debug('TMB: -> RTL_BatchCMAssignEmailErrorLog end of execute');
    }    

    global void finish(Database.BatchableContext bc){ 
    	//send email notification only when there are error records
    	if(errorRecords > 0){
    		String subject = 'Unassigned Campaign Member';
    		String description = 'Dear Authorized Person';
    		String status = null;
        	// String baseURL = System.URL.getSalesforceBaseUrl().toExternalForm();
        	// String consoleURL = '/ui/support/servicedesk/ServiceDeskPage#';
        	// String pathToReAssign = 'apex/RTL_CampaignMemberReassign?unassigned=1';
			
			AppConfig__c lightCF = AppConfig__c.getValues('URL_Lightning');
			String sfdcBaseLightningURL = lightCF == null ? 'https://tmbbank--uat.lightning.force.com' : lightCF.Value__c;
			String url = sfdcBaseLightningURL + '/one/one.app#' + 
				EncodingUtil.base64Encode(Blob.valueOf(JSON.serialize(new Map<String, Object>{
					'componentDef' => 'one:alohaPage',
						'attributes' => new Map<String, Object>{
							'address' => URL.getSalesforceBaseUrl().toExternalForm() + '/apex/RTL_CampaignMemberReassign?unassigned=1'
								}
				})));
    	
			AsyncApexJob job = [SELECT Id, Status FROM AsyncApexJob WHERE Id = :bc.getJobId()];
			
    		string htmlMsg = description + ' <br/><br/>'
    				+ 'There are '+errorRecords + ' unassigned Campaign Member as of '+logDate.format('dd/MM/yyyy', tz.toString())+'<br/><br/>'
					+ 'Please click this link '+url+' for more information. <br/><br/>'
					+ System.Label.RTL_Purge_Email_footer + '</font>';
        
			String[] recipientList = new String[]{'CRM Admin 2','Web drop lead - Assigned Admin'};
			//Send email
    		RTL_BatchEmailService.SendEmailToRecipientList(null,subject,htmlMsg,recipientList);
    	} 	
    	
		
    }

	
}