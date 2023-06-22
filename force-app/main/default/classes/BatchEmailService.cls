global class BatchEmailService {
	

	global static void SendEmail(Id jobId, string senderDisplayName, String subject, String body) {

	  	 
		// Get the AsyncApexJob that represents the Batch job using the Id from the BatchableContext  
		AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email, ExtendedStatus from AsyncApexJob where Id = :jobId];

		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		String[] toAddresses = new String[] { a.CreatedBy.Email };
		mail.setToAddresses(toAddresses);
		mail.setSenderDisplayName(senderDisplayName);
		mail.setSubject(subject);
		mail.setHtmlBody(body);
		if (Test.isRunningTest()) return;
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}
}