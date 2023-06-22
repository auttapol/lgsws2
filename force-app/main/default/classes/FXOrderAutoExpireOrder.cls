global class FXOrderAutoExpireOrder implements Schedulable  {
    global void execute(SchedulableContext SC){

    	Id batchInstanceId = Database.executeBatch(new FXOrderAutoExpireOrderBatch());

    }
}