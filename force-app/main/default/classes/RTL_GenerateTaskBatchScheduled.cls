global class RTL_GenerateTaskBatchScheduled implements Schedulable {
	global void execute(SchedulableContext sc) {
		//Date d = System.today();
		//Datetime myDT = datetime.newInstance(d.year(), d.month(),d.day());
		//String toDay = myDT.format('yyyy-MM-dd');
		
		//String q = 'SELECT Id, Name, OwnerId, TMB_Customer_ID_PE__c, Owner.Zone_Code__c, Owner.Region_Code__c, Operating_Model__c, Next_Generate_task_date__c, Last_Generate_task_date__c, RTL_Wealth_RM__c, RTL_Wealth_RM__r.Name FROM Account WHERE RTL_Wealth_RM__c != null AND Next_Generate_task_date__c = ' + toDay;
		String q = ' SELECT Id, Name, OwnerId, TMB_Customer_ID_PE__c, Owner.Zone_Code__c, Owner.Region_Code__c, Operating_Model__c, Next_Generate_task_date__c, '
				   +' Last_Generate_task_date__c, RTL_Wealth_RM__c, RTL_Wealth_RM__r.Name FROM Account '
				   +' WHERE RTL_Wealth_RM__c != null AND Next_Generate_task_date__c = TODAY';

		RTL_GenerateTaskBatch b = new RTL_GenerateTaskBatch(q);
		database.executebatch(b);
	}
}