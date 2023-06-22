global class RTL_SchedulerBranchManagerUpdate implements Schedulable {
	global void execute(SchedulableContext sc) {
		String query = 'select ID,Branch_Code__c,RTL_Branch_Manager_User__c,RTL_Branch_Manager_User__r.Name from Branch_And_Zone__c WHERE isActive__c = true';
        RTL_BatchBranchManagerUpdate bm = new RTL_BatchBranchManagerUpdate(query);
        Id BatchProcessId = Database.ExecuteBatch(bm);
	}
}