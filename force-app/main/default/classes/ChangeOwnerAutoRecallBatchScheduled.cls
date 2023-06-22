global class ChangeOwnerAutoRecallBatchScheduled implements Schedulable  {
    global void execute(SchedulableContext sc) {

		ChangeOwnerAutoRecallBatch bat = new ChangeOwnerAutoRecallBatch();

		database.executebatch(bat);
	}
}