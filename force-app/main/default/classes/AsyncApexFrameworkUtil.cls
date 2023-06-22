public class AsyncApexFrameworkUtil {
    
    public static Integer MAX_BATCHLIMIT{
        get{
            if(MAX_BATCHLIMIT == null){
                MAX_BATCHLIMIT = 4;

                Commercial_Forecast_App_Config__mdt mc = Commercial_Forecast_App_Config__mdt.getInstance('AsyncApexFramework_Maximum_Batch_Queue');

                if(mc != null && mc.Value__c != null){
                    MAX_BATCHLIMIT = Integer.valueOf(mc.Value__c);
                }
            }
            return MAX_BATCHLIMIT;
        }set;
    }

    public static AsyncQueue__c CreateBatchQueue(Object batchClassInstance, Integer scopeSize, String batchName, Integer priority){
        String s = JSON.serialize(batchClassInstance);

        AsyncQueue__c  eachQ = new AsyncQueue__c ();
        eachQ.Batch_Size__c  = scopeSize;
        eachQ.Batch_Name__c = batchName;
        eachQ.Priority__c = priority;
        eachQ.object__c =  JSON.serialize(batchClassInstance);
        eachQ.Class_Name__c = String.valueOf(batchClassInstance).split(':')[0];
        eachQ.Status__c = 'Queued';
        eachQ.Job_Type__c = 'Batch';

        return eachQ;
    }

    private static List<AsyncQueue__c> getPendingJobs(Integer recordToFetch){
        return [SELECT Id, Name, Class_Name__c, Job_Id__c, Job_Type__c, Object__c, Status__c, Remark__c, Job_Status__c, Batch_Size__c, Priority__c FROM AsyncQueue__c WHERE Status__c = 'Queued' ORDER BY CreatedDate ASC, Priority__c ASC NULLS LAST LIMIT :recordToFetch];
    }
    
    public static List<AsyncQueue__c > startBatchJobs(List<AsyncQueue__c> lstBatch_StatusUpdate){ 
        Integer availableLimit = 0;

        AggregateResult[] groupedResults = [SELECT Count(Id) FROM AsyncQueue__c WHERE Status__c IN ('Completed', 'Failed') AND Job_Status__c NOT IN ('Aborted', 'Completed', 'Failed')];

        String exp0 = String.valueOf(groupedResults[0].get('expr0'));
        availableLimit = MAX_BATCHLIMIT - Integer.valueOf(exp0);
        
		if(availableLimit > 0){
            List<AsyncQueue__c> lstBatch = getPendingJobs(availableLimit);

            if(!lstBatch.isEmpty()){
                for(AsyncQueue__c  eachQ : lstBatch){ 
                    try{
                        eachQ.Status__c = 'Completed';

                        Type t = Type.forName(eachQ.Class_Name__c);

                        Object des_Obj = JSON.deserialize(eachQ.object__c, t);

                        Database.batchable<sObject> bat = (Database.batchable<sObject>) des_Obj;

                        eachQ.Job_Id__c = Database.executeBatch(bat, Integer.valueOf(eachQ.Batch_Size__c));

                    }catch(Exception e){
                        eachQ.status__c = 'Failed'; 
                        eachQ.Remark__c = e.getMessage() + '\n' + e.getStackTraceString();
                    }

                    lstBatch_StatusUpdate.add(eachQ);
                }
            }
        }

        return lstBatch_StatusUpdate;
    }
    
    public static List<AsyncQueue__c > collectJobInfo(List<AsyncQueue__c > lstBatch_StatusUpdate){
        List<AsyncQueue__c> lstStatusCheck = [SELECT Job_Id__c, Remark__c FROM AsyncQueue__c Where Job_Status__c NOT IN ('Aborted', 'Completed', 'Failed') AND Status__c IN ('Completed','Failed')];

        Map<String, AsyncQueue__c> mapAsyncJobId = new Map<String, AsyncQueue__c>();

        for(AsyncQueue__c each : lstStatusCheck){
            if(!string.isEmpty(each.Job_Id__c)){
                Id recId = each.Job_Id__c ;
                mapAsyncJobId.put(recId, each); 
            } 
        } 

        if(mapAsyncJobId.keyset().size() > 0){
            List<AsyncApexJob> lstJobStatus = [SELECT Id, ExtendedStatus, TotalJobItems, NumberOfErrors, JobItemsProcessed, MethodName, Status FROM AsyncApexJob WHERE Id IN :mapAsyncJobId.keyset()];

            for(AsyncApexJob eachJob : lstJobStatus){
                AsyncQueue__c eachQ = mapAsyncJobId.get(eachJob.Id);
                if(eachQ != null){
                    String note = '';
                    // note += String.isEmpty(eachQ.Remark__c) ? '' : eachQ.Remark__c + '\n';

                    if(!String.isEmpty(eachJob.ExtendedStatus)){
                        note += String.isEmpty(eachJob.ExtendedStatus) ? '' : 'Error Messages - ' + eachJob.ExtendedStatus + '\n';
                        eachQ.Status__c = 'Failed';
                    }else{
                        eachQ.Status__c = 'Completed';
                    }

                    note += String.isEmpty(eachJob.MethodName) ? '' : 'Method - ' + eachJob.MethodName + '\n';
                    note += 'Total Batches - ' + eachJob.TotalJobItems + '\n';
                    note += 'Number of Processed - ' + eachJob.JobItemsProcessed + '\n';
                    note += 'Number of Errors - ' + eachJob.NumberOfErrors + '\n';

                    eachQ.Remark__c = note;
                    eachQ.Job_Status__c = eachJob.Status;
                    lstBatch_StatusUpdate.add(eachQ);
                }
            }
        }
        return lstBatch_StatusUpdate;
    }

    public static List<AsyncQueue__c > saveAsyncRecords(List<AsyncQueue__c > lstBatch_StatusUpdate){
        if(!lstBatch_StatusUpdate.isEmpty()){
            Database.update(lstBatch_StatusUpdate,false);
        }

        lstBatch_StatusUpdate.clear();

        return lstBatch_StatusUpdate;
    }
}