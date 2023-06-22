global class RTL_SchedulerEmailCMAssignedToDummy implements Schedulable {

	global TimeZone tz = UserInfo.getTimeZone();
    global DateTime logDate = DateTime.now()-1;
   	private final String REPORT_NAME = 'Campaign_Member_under_Dummy_Campaign';
	
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
		String subject = 'Campaign Member assigned to Dummy Campaign';
    	String description = 'Dear Authorized Person';
    	String status = null;
        String baseURL = System.URL.getSalesforceBaseUrl().toExternalForm();
        String consoleURL = '/ui/support/servicedesk/ServiceDeskPage#';
		
		//Query Report by DevName
		List <Report> reportList = [SELECT Id,DeveloperName 
        								FROM Report 
        								WHERE DeveloperName = :REPORT_NAME];
        //Get reportId to use in url
        String reportId = (String)reportList.get(0).get('Id');
			
    	string htmlMsg = description + ' <br/><br/>'
    				+ 'There are '+recordCount + ' Campaign Member assigned to Dummy Campaign as of '+logDate.format('dd/MM/yyyy', tz.toString())+'<br/><br/>'
					+ 'Please click this link '+baseURL+consoleURL + '/'+reportId+' for more information. <br/><br/>'
					+ System.Label.RTL_Purge_Email_footer + '</font>';
        
    
		String[] recipientList = new String[]{'CRM Admin 2','Web drop lead - Assigned Dummy'};
		//Send email
    	RTL_BatchEmailService.SendEmailToRecipientList(null,subject,htmlMsg,recipientList);
	}
}