global class newCustomerEmailNotifyBatchScheduled implements Schedulable{
    global void execute(SchedulableContext sc) {

		String q = 	' SELECT Id, OwnerId, Owner.Name, Owner.Email, Owner.Employee_ID__c, Name, LastModifiedDate, Last_Change_Owner_Date_time__c, Account_Type__c, TMB_Customer_ID_PE__c, Core_Banking_Suggested_Segment__c, Previous_Owner_Name__c '
					+ ' FROM Account '
					+ ' WHERE '
					+ ' Last_Change_Owner_Date_time__c = YESTERDAY  AND '
					+ ' Account_Type__c = \'Existing Customer\' '
					+ ' ORDER BY OwnerId ASC ';

		newCustomerEmailNotifyBatch bat = new newCustomerEmailNotifyBatch(q);
		database.executebatch(bat);
	}
}