public class PurgeAsyncQueueDataBatchScheduler implements Schedulable{
    public void execute(SchedulableContext ct) {
        Database.executeBatch(new PurgeAsyncQueueDataBatch());
    }
}