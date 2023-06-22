global class AccountOwnerAssignmentBatchScheduled implements Schedulable {
    global void execute(SchedulableContext sc) {

		AccountOwnerAssignmentBatch bat = new AccountOwnerAssignmentBatch();

		database.executebatch(bat);
	}
}