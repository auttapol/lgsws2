public without sharing class QueueableHandler implements QueueableDispatcher.IQueueableDispatched {
    // Youtube Resource : https://www.youtube.com/watch?v=taqTG1ommBQ&t=1112s
    // Build Reliable Asynchronous Code with Queueable Apex


    /** Stores whether or not the current transaction has already queued an async job for future processing */
    public static Boolean asyncJobQueued = false;
    /** Stores the id of the async job queued by this transaction */
    private static Id queuedJobId;
    /** Constant representing the token that signifies the queueable apex is to perform a callout */
    public static final String CALLOUT_TOKEN = 'Callout';
    /** Constant representing the token that signifies the queueable apex job itself should be processed asynchronously */
    public static final String ASYNC_TOKEN = 'Async';
    public void execute(QueueableContext sc){
        Id runAsUser;
        // Verify kill switch is not enabled
        /*if (ConfigService.KillSwitchEnabled)
        {
            flushAsyncQueue();            
            return;
        }*/
        // Instantiate async request for later processing
        AsyncRequest__c ar;
        // Instantiate empty map to store processed async requests ready for deletion
        Map<Id,AsyncRequest__c> arsToDelete = new Map<Id,AsyncRequest__c>();
        try{
            // Query for the earliest scheduled async request that still needs to be processed
            List<AsyncRequest__c> asyncRequests = [SELECT Id, AsyncType__c, JobId__c, ScheduledTime__c, Params__c, Attempts__c, MaxAttempts__c, Aborted__c,IsSuccess__c FROM AsyncRequest__c 
                                                   WHERE IsDeleted = false 
                                                   AND IsSuccess__c = false
                                                   AND Aborted__c = false 
                                                   ORDER BY ScheduledTime__c,Id ASC LIMIT 1];                        
            System.debug('asyncRequests List  : '+asyncRequests);
            
            // End chaining if all asynchronous requests have been or are being processed
            if (asyncRequests.isEmpty()) {
                // Set All Queue Done 
                return;
            }
            // Unfortunately the ORDER BY clause is not allowed while pessimistically locking rows in SOQL, so the query must be repeated to prevent concurrency issues
            asyncRequests = [SELECT Id, AsyncType__c, JobId__c, ScheduledTime__c, Params__c, Attempts__c, MaxAttempts__c, Aborted__c,IsSuccess__c 
                             FROM AsyncRequest__c 
                             WHERE Aborted__c = false 
                             AND IsSuccess__c = false
                             AND Id = :asyncRequests[0].Id LIMIT 1 FOR UPDATE];
            System.debug('asyncRequests  : '+asyncRequests); //'a2V1s00000074tGEAQ'
            // Since the first SOQL query ordered by scheduled time was not row locking we must verify again that asyncRequests is not empty
            // End chaining if all asynchronous requests have been or are being processed
            if (asyncRequests.isEmpty()) {
                // Set All Queue Done 

                return;
            }
            // Set async request to be processed
            ar = asyncRequests[0];  // a2V1s00000074tGEAQ
            // Process async request

            processAsyncRequest(ar);
            // Mark async request for deletion
            arsToDelete.put(ar.Id,ar);
            
            
        }
        catch(Exception ex){
            System.debug('error : '+ex.getMessage());
            // Long-running processes could mean locking errors are hit in lieu of concurrency errors; additionally a runtime error could occur while processing the async request
            // In this case the async request record will not be marked for deletion; leaving the job at the beginning of the queue to be processed again later
            //DiagnosticsInstrumentation.DebugException(ex);
        }
        // Update/Delete Aync Request as needed
        updateOrDeleteAsyncRequest(ar, arsToDelete);
        // Chain job to process additional async requests
        chainJob();    
    }
    
    /**
    * @author Scott Covert
    * @date 2/24/2016
    * @description Enqueues Queueable Apex Job
    * @param String Type of asynchronous job to be queued
    * @param CalloutRequest__c Callout request to be performed by the asynchronous job; should have HTTP request info populated but should not yet inserted to the database
    */
    public static void startCalloutJob(String asyncJobType,List<CalloutRequest__c> cr)
    {
        // Add the async request to the queue
        // thanakorn comment for support bulk data
        //AsyncRequest__c ar = startJob(asyncJobType);
        // add by thanakorn for support bulk data START
        Id jobId = startJob(asyncJobType);
        // Insert a related callout request to store HTTP request/response info
        /*List<AsyncRequest__c> arList = new List<AsyncRequest__c>();
        System.debug('cr size : '+cr.size());
        for( CalloutRequest__c each : cr ){
            AsyncRequest__c ar = new AsyncRequest__c(JobId__c = jobId, AsyncType__c = asyncJobType);
            arList.add(ar);
        }
        insert arList;
        Integer index = 0;
        for( CalloutRequest__c each : cr ){
            each.AsyncRequest__c = arList.get(index).Id;          
            index++;
        }              
        // thanakorn END
        update cr;*/
        List<AsyncRequest__c> arList = new List<AsyncRequest__c>();
        for( CalloutRequest__c each : cr ){
            AsyncRequest__c ar = new AsyncRequest__c();
            ar.Id = each.AsyncRequest__c;
            ar.JobId__c = jobId;
            arList.add(ar);
        }
        update arList;
    }   

    /**
    * @author Scott Covert
    * @date 2/24/2016
    * @description Enqueues Queueable Apex Job
    * @param String Type of asynchronous job to be queued    
    */
    // thanakorn comment for support bulk data
    //public static AsyncRequest__c startJob(String asyncJobType)
    public static Id startJob(String asyncJobType)
    {
        // Only enqueue a new job as needed
        //if (!asyncJobQueued)        
        //{
            //asyncJobQueued = true;
            System.debug('startjob : '+CXMHandler.getQueueAvailable());
            queuedJobId = System.enqueueJob(new QueueableDispatcher());
            
        //}
        // Add the async request to the queue
        /* Thanakorn comment for support bulk data
        AsyncRequest__c ar = new AsyncRequest__c(JobId__c = queuedJobId, AsyncType__c = asyncJobType);
        insert ar;
        return ar;
        */
        // add by thanakorn for support bulk data
        return queuedJobId;
    }
    /**
    * @author Scott Covert
    * @date 2/24/2016
    * @description Flushes Async Queue
    */
    private void flushAsyncQueue()
    {
        try
        {
            // Pessimistic locking SOQL query prevents other async jobs from processing async requests
            Map<Id,AsyncRequest__c> asyncRequestsToFlush = new Map<Id,AsyncRequest__c>([SELECT Id, Aborted__c FROM AsyncRequest__c WHERE IsDeleted = false AND Aborted__c = false FOR UPDATE]);
            if (!asyncRequestsToFlush.isEmpty())
            {
                for (AsyncRequest__c ar : asyncRequestsToFlush.values()){
                    ar.Aborted__c = true;
                } 
                update asyncRequestsToFlush.values();
            }                
        }
        catch(Exception ex)
        {
            System.debug('error : '+ex.getMessage());
            // Locking error could occur if some async requests are currently being processed
            // In this case, the other async job will chain itself once it's done and the queue will be flushed then
            //DiagnosticsInstrumentation.DebugException(ex);
        }
    }

    /**
    * @author Scott Covert
    * @date 2/24/2016
    * @description Processes async request based on type; this is where specific business logic will be added
    * @param AsyncRequest__c Async request to be processed
    */
    
    private void processAsyncRequest(AsyncRequest__c ar)
    {
        System.debug('processAsyncRequest : '+ar.AsyncType__c.contains(CALLOUT_TOKEN));
        if (ar.AsyncType__c.contains(CALLOUT_TOKEN)){
            // Initialize Callout Handler
            List<CalloutRequest__c> calloutRequests = [SELECT Id, AsyncRequest__c, Endpoint__c, Method__c, Timeout__c, Status__c, Sent__c ,CalloutHandlerName__c  ,
                                                       RequestId__c,Channel__c
                                                       FROM CalloutRequest__c 
                                                       WHERE AsyncRequest__c = :ar.Id AND Status__c = 'Queued' order by Id asc LIMIT 1];

            System.debug('calloutRequests : '+calloutRequests);
            if (!calloutRequests.isEmpty() && ar.AsyncType__c.contains(ASYNC_TOKEN)){
                System.debug('sendAsyncCallout');
                CalloutHandlerDispatcher.sendAsyncCallout(calloutRequests[0].Id);
            }
            else if (!calloutRequests.isEmpty()) {
                System.debug('sendCallout');
                CalloutHandlerDispatcher.sendCallout(calloutRequests[0]);
            }
        }
    }

    /**
    * @author Scott Covert
    * @date 2/24/2016
    * @description Increments async request attempts counter and aborts the job if needed or deletes the job altogether
    * @param AsyncRequest__c Async request that was processed
    * @param Map Map of Async Requests to be deleted from the queue
    */
    private void updateOrDeleteAsyncRequest(AsyncRequest__c ar, Map<Id,AsyncRequest__c> arsToDelete)
    {
        // Increment attempts counter
        //ar.Attempts__c++;

        // This async request has failed the maximum number of times allowed; abort
        if (ar.Attempts__c >= ar.MaxAttempts__c) ar.Aborted__c = true;
        // Only bother to update async request if it is not set to be deleted
        // This also must be done after processing of the async request in case a synchronous callout is made
        // (SF does not allow DML prior to a callout in the same transaction - http://bit.ly/1QeV6dC)

        //Move in queue with 15 sec 
        //ar.ScheduledTime__c =  DateTime.now().addSeconds(10);

        if (!arsToDelete.containsKey(ar.Id)){ 
            try{
                update ar;
            }catch( Exception e ){
                System.debug('error : '+e.getMessage());
            }
            
        }        
        // if (!arsToDelete.isEmpty())
        // {
            // Delete executed AsyncRequests and empty them from the recycling bin
        //     List<AsyncRequest__c> asyncList = new List<AsyncRequest__c>();
        //     List<CalloutRequest__c> calloutRequestList = new List<CalloutRequest__c>();
        //     for(CalloutRequest__c calloutRequests : [Select Id,AsyncRequest__c 
        //                                              from CalloutRequest__c 
        //                                              where AsyncRequest__c IN: arsToDelete.keySet() and Status__c = 'OK' ]){
        //         calloutRequestList.add(calloutRequests);  
        //         asyncList.add( arsToDelete.get(calloutRequests.AsyncRequest__c) );
        //     }           
            
        //     if( calloutRequestList.size() > 0 ){
        //         try{
        //             delete calloutRequestList;
        //         }catch( Exception e ){
        //             System.debug('error : '+e.getMessage());
        //         }                
        //     }
            
        //     if( asyncList.size() > 0 ){
        //         try{
        //             delete asyncList;    
        //             Database.emptyRecycleBin(asyncList);    
        //         }catch( Exception e ){
        //             System.debug('error : '+e.getMessage());
        //         } 
        //     }
                    
        // }
    }

    /**
    * @author Scott Covert
    * @date 2/22/2016
    * @description Chains Queueable Apex
    */
    
    
    @future
    private static void chainJob()
    {
        // https://releasenotes.docs.salesforce.com/en-us/spring17/release-notes/rn_apex_chaining.htm#topic-title
        // This method for chaining the queued apex job is itself asynchronous in case the completed job made a callout
        // (Normally making a callout prevents chaining from being possible - http://sforce.co/1RnhPD9)

        //Test_Queue__c o = new Test_Queue__c();
        //insert o;
        if( CXMHandler.getQueueAvailable() ){
            Id jobId  = System.enqueueJob(new QueueableDispatcher());       
            List<AsyncRequest__c> asyncRequests = [SELECT Id, AsyncType__c, JobId__c, ScheduledTime__c, Params__c, Attempts__c, MaxAttempts__c, Aborted__c ,CreatedById
                                                   FROM AsyncRequest__c 
                                                   WHERE IsDeleted = false 
                                                   AND Aborted__c = false and IsSuccess__c = false ORDER BY ScheduledTime__c,Id ASC LIMIT 1];                        
            if( asyncRequests.size() > 0 ){
                asyncRequests.get(0).JobId__c = jobId;
                update asyncRequests.get(0);
            }
        }
    }

}