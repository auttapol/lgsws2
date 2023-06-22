global class DeleteOpptyProductHistoryScheduled implements Schedulable{
	global void execute(SchedulableContext sc){
        String query = 'SELECT Id FROM Opportunity_Product_History__c WHERE LastModifiedDate = LAST_MONTH';
        DeleteOpptyProductHistory delBatch = new DeleteOpptyProductHistory(query);
        Id BatchProcessId = Database.ExecuteBatch(delBatch);
    }
}