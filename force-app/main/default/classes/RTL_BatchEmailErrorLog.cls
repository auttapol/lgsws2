global class RTL_BatchEmailErrorLog implements Database.Batchable<sObject>, Database.Stateful{
	global final String query;
    global Integer errorRecords = 0;
    global TimeZone tz = UserInfo.getTimeZone();
    global DateTime logDate = DateTime.now()-1;
    global RTL_BatchEmailErrorLog(String q){
        query = q;
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<RTL_Online_Service_Log__c> scope){
    	System.Debug('TMB: -> RTL_BatchEmailErrorLog start of execute');
		errorRecords += scope.size();
        System.Debug('TMB: -> RTL_BatchEmailErrorLog end of execute');
    }    

    //Modified on 06-01-2018
    private Integer getTotalRowsfromReport() {
    	String REPORT_NAME = 'Retail_Online_Services_Logs';
    	return RTL_ReportUtility.getRecordCountFromTabularReport(REPORT_NAME);
    }

    global void finish(Database.BatchableContext bc){  	
    	String subject = 'Online Service Log Report';
    	String description = 'Dear CRM Team,ITG Team and Retail Business User';
    	String status = null;
        String url = System.URL.getSalesforceBaseUrl().toExternalForm();
        App_Config__mdt report = [SELECT Value__c FROM App_Config__mdt WHERE MasterLabel = 'RetailOnlineServiceReport']; 
    	
		AsyncApexJob job = [SELECT Id, Status FROM AsyncApexJob WHERE Id = :bc.getJobId()];

		//Modified on 06-01-2018
		errorRecords = getTotalRowsfromReport();
			
    	string htmlMsg = description + ' <br/><br/>'
    				+ 'There are '+errorRecords + ' errors occured on '+logDate.format('dd/MM/yyyy', tz.toString())+'<br/><br/>'
    				+ 'Please click this link '+url + '/'+report.Value__c+' for more information. <br/><br/>'
					+ System.Label.RTL_Purge_Email_footer + '</font>';
        SendEmail(job.id,subject,htmlMsg);
		
    }
    global static void SendEmail(Id jobId, String subject, String body) {
		if (Test.isRunningTest()) return;
		OrgWideEmailAddress owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'sf_admin@tmbbank.com' limit 1];
		// Get the list of email address from AppConfig
		String emailOpsTeamA = AppConfig__c.getValues('Operation Team E').Value__c;
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		String[] toAddresses = mergeEmailAddr(emailOpsTeamA,null, null, null, null);
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
	
	public static String[] mergeEmailAddr(String emailOpsTeamA, String emailOpsTeamB, String emailOpsTeamC, String emailOpsTeamD, String emailOpsTeamAppMon) {
		String emailAddress = ''; //split by ';'
		if (emailOpsTeamA != null && emailOpsTeamA != '') {
			emailAddress += emailOpsTeamA + ';';
		}
		if (emailOpsTeamB != null && emailOpsTeamB != '') {
			emailAddress += emailOpsTeamB + ';';
		}
		if (emailOpsTeamC != null && emailOpsTeamC != '') {
			emailAddress += emailOpsTeamC + ';';
		}	
		if (emailOpsTeamD != null && emailOpsTeamD != '') {
			emailAddress += emailOpsTeamD + ';';
		}	
		if (emailOpsTeamAppMon != null && emailOpsTeamAppMon != '') {
			emailAddress += emailOpsTeamAppMon;
		}
		if (emailAddress.endswith(';')) {
			emailAddress = emailAddress.substring(0, emailAddress.length()-1);
		}
		String[] emailAddrTmp = emailAddress.split(';');
		Set<String> emailAddrSet = new Set<String>();
		for (String email: emailAddrTmp) {
			if (email != '') {//filter blank or duplicate email
				emailAddrSet.add(email);
			}
		}
		List<String> emailAddrList = new List<String>();
		emailAddrList.addAll(emailAddrSet);		
		return emailAddrList;
	}
}