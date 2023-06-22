@isTest
public class AsyncApexFrameworkUtilTest {
    
    @TestSetup
    static void makeData(){
        updateLongtermRepaymentBatch batchClassInstance = new updateLongtermRepaymentBatch(); 
        String s = JSON.serialize(batchClassInstance);

        AsyncQueue__c  eachQ = new AsyncQueue__c ();
        eachQ.Batch_Size__c  = 200;
        eachQ.Batch_Name__c = 'updateLongtermRepaymentBatch';
        eachQ.Priority__c = null;
        eachQ.object__c =  JSON.serialize(batchClassInstance);
        eachQ.Class_Name__c = String.valueOf(batchClassInstance).split(':')[0];
        eachQ.Status__c = 'Queued';
        eachQ.Job_Type__c = 'Batch';
        insert eachQ;

        

    }

    @isTest
    public static void CreateBatchQueueTest(){
        Integer maxBatchList = AsyncApexFrameworkUtil.MAX_BATCHLIMIT;
        String expectedStatus = 'Queued';
        Test.startTest();
        updateLongtermRepaymentBatch instance = new updateLongtermRepaymentBatch();
        AsyncQueue__c resultQueue = AsyncApexFrameworkUtil.CreateBatchQueue(instance,200,'updateLongtermRepaymentBatch',null);
        System.assertEquals(expectedStatus, resultQueue.Status__c);
        Test.stopTest();
    }

    @isTest
    public static void startBatchJobsTest(){
        Integer expectedQueueNumber = 1;
        Test.startTest();
        List<AsyncQueue__c> lstBatch_StatusUpdate = new List<AsyncQueue__c>();
        lstBatch_StatusUpdate = AsyncApexFrameworkUtil.startBatchJobs(lstBatch_StatusUpdate);
        System.assertEquals(expectedQueueNumber, lstBatch_StatusUpdate.size());
        Test.stopTest();
    }

    @isTest
    public static void collectJobInfoTest(){
        database.executebatch(new updateLongtermRepaymentBatch(), 200);
        List<AsyncApexJob> lstJobStatus =[SELECT Id, ExtendedStatus, TotalJobItems, NumberOfErrors, MethodName, Status FROM AsyncApexJob ];
        System.debug('lstJobStatus Size : '+lstJobStatus.size());

        updateLongtermRepaymentBatch batchClassInstance = new updateLongtermRepaymentBatch(); 
        String s = JSON.serialize(batchClassInstance);
        AsyncQueue__c  queueForCollect = new AsyncQueue__c ();
        queueForCollect.Batch_Size__c  = 200;
        queueForCollect.Batch_Name__c = 'updateLongtermRepaymentBatch';
        queueForCollect.Priority__c = null;
        queueForCollect.object__c =  JSON.serialize(batchClassInstance);
        queueForCollect.Class_Name__c = String.valueOf(batchClassInstance).split(':')[0];
        queueForCollect.Status__c = 'Completed';
        queueForCollect.Job_Type__c = 'Batch';
        queueForCollect.Job_Id__c = lstJobStatus[0].Id;
        insert queueForCollect;

        Integer expectedQueueNumber = 1;
        Test.startTest();
        List<AsyncQueue__c> lstBatch_StatusUpdate = new List<AsyncQueue__c>();
        lstBatch_StatusUpdate = AsyncApexFrameworkUtil.collectJobInfo(lstBatch_StatusUpdate);
        System.debug('lstBatch_StatusUpdate Size : '+lstBatch_StatusUpdate.size());

        System.assertEquals(expectedQueueNumber, lstBatch_StatusUpdate.size());
        Test.stopTest();
    }


    @isTest
    public static void saveAsyncRecordsTest(){

        updateLongtermRepaymentBatch batchClassInstance = new updateLongtermRepaymentBatch(); 
        String s = JSON.serialize(batchClassInstance);
        AsyncQueue__c  queueForSaveRec = new AsyncQueue__c ();
        queueForSaveRec.Batch_Size__c  = 200;
        queueForSaveRec.Batch_Name__c = 'updateLongtermRepaymentBatch';
        queueForSaveRec.Priority__c = null;
        queueForSaveRec.object__c =  JSON.serialize(batchClassInstance);
        queueForSaveRec.Class_Name__c = String.valueOf(batchClassInstance).split(':')[0];
        queueForSaveRec.Status__c = 'Completed';
        queueForSaveRec.Job_Type__c = 'Batch';
        insert queueForSaveRec;

        Integer expectedQueueNumber = 0;
        Test.startTest();
        List<AsyncQueue__c> lstBatch_StatusUpdate = new List<AsyncQueue__c>();
        lstBatch_StatusUpdate.add(queueForSaveRec);
        lstBatch_StatusUpdate = AsyncApexFrameworkUtil.saveAsyncRecords(lstBatch_StatusUpdate);

        System.assertEquals(expectedQueueNumber, lstBatch_StatusUpdate.size());
        Test.stopTest();
    }



}