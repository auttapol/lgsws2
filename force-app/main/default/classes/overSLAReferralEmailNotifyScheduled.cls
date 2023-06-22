global class overSLAReferralEmailNotifyScheduled implements Schedulable{

	global static final String CRON = '0 0 8 ? * * *';
	
    global void execute(SchedulableContext sc) {

		String q = 	' SELECT Id, OwnerId, CreatedBy.Email, Owner.Name, Owner.Email, RTL_Preferred_Staff__c, Name, RTL_Stage__c, RecordType.Name, RTL_Interested_Product__c, RTL_Account_Name__c, RTL_Account_Name__r.Name, RTL_Type__c, RTL_Product_Group__c, RTL_Product_Name__r.Name, RTL_Preferred_Staff__r.Manager_Email__c'
					+ ' FROM RTL_Referral__c '
					+ ' WHERE Before_Over_SLA__c = TODAY AND'
					+ ' (RecordType.Name = \'Refer to Retail\' OR RecordType.Name = \'Retail Cross Channel Referral\') AND'
					+ ' RTL_Stage__c = \'New\' ';

        overSLAReferralEmailNotificationBatch bat = new overSLAReferralEmailNotificationBatch(q);
		database.executebatch(bat);
	}
}