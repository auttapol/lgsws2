public abstract class  DailyBatchAbstract {

	 public abstract void doAction(Database.BatchableContext bc
	 								, List<sObject> scope
	 								,DailyScheduleBatch dailyBatch);

}