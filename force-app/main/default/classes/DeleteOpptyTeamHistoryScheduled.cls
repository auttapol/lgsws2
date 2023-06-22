global class DeleteOpptyTeamHistoryScheduled implements Schedulable{
    global void execute(SchedulableContext sc){
        String query = 'SELECT Id FROM OpportunityTeamMemberHistory__c WHERE LastModifiedDate = LAST_MONTH';
        DeleteOpptyTeamHistory delBatch = new DeleteOpptyTeamHistory(query);
        Id BatchProcessId = Database.ExecuteBatch(delBatch);
    }
}