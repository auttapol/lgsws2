@isTest
public class PurgeAsyncQueueDataBatchTest {
    static{
        TestUtils.createAppConfig();

        AsyncQueue__c oldJob = new AsyncQueue__c();
        OldJob.Job_Status__c = 'Completed';
        OldJob.Status__c = 'Completed';
        insert oldJob;

        Datetime lastYear = Datetime.now().addDays(-366);

        Test.setCreatedDate(oldJob.Id, lastYear);
    }

    @isTest
    static void testExecuteBatch(){
        Test.startTest();
        Database.executeBatch(new PurgeAsyncQueueDataBatch());
        System.schedule('Purge Async Queue Batch Scheduler FOR TEST', '0 0 9 * * ?', new PurgeAsyncQueueDataBatchScheduler());
        Test.stopTest();

        List<AsyncQueue__c> allJob = [SELECT Id FROM AsyncQueue__c];
        System.assertEquals(0, allJob.size(), 'System test assertEquals has Failed AsyncQueue__c');
    }
}