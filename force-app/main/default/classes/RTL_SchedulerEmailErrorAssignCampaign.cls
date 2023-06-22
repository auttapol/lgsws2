global class RTL_SchedulerEmailErrorAssignCampaign implements Schedulable {
	
    global TimeZone tz = UserInfo.getTimeZone();
    global DateTime logDate = DateTime.now();
   	private final String REPORT_NAME = 'Fail_Assign_To_Campaign';
	
	global void execute(SchedulableContext sc) {
		//run report and get total record from report
		//report must be a summary report with 1 level grouping
		Integer recordCount = RTL_ReportUtility.getRecordCountFromReport(REPORT_NAME);
		
		//If record > 0 then send email
		if(recordCount > 0){
			sendEmail(recordCount);
		}
		
		
	}

	private void sendEmail(Integer recordCount){
		String subject = 'Error Occurred when assign lead to Campaign';
		String description = 'Dear Authorized Person';
		String baseURL = System.URL.getSalesforceBaseUrl().toExternalForm();
        String consoleURL = '/ui/support/servicedesk/ServiceDeskPage#';
		
		//Query Report by DevName
		List <Report> reportList = [SELECT Id,DeveloperName 
        								FROM Report 
        								WHERE DeveloperName = :REPORT_NAME];
        //Get reportId to use in url
        String reportId = (String)reportList.get(0).get('Id');

		//email content
		String htmlMsg = description + ' <br/><br/>'
				+ 'There are '+recordCount + ' error records while assign Lead to Campaign on '+logDate.format('dd/MM/yyyy', tz.toString())+'<br/><br/>'
				+ 'Please click this link '+baseURL+consoleURL + '/'+reportId+' for more information. <br/><br/>'
				+ System.Label.RTL_Purge_Email_footer + '</font>';
    
		String[] recipientList = new String[]{'CRM Admin 2','Web drop lead - Fail Assign Campaign'};
		//Send email
    	RTL_BatchEmailService.SendEmailToRecipientList(null,subject,htmlMsg,recipientList);
	}
}