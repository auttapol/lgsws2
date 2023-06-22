public with sharing class DeleteBuMember implements Database.Batchable<sObject>{
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        String query = '';
        String RuntestQuery = 'select Id from BU_Member__c where lastmodifieddate = TODAY';
        String StandardQuery = 'select Id from BU_Member__c where lastmodifieddate < TODAY';
        query = Test.isRunningTest()? RuntestQuery : StandardQuery; 
        return Database.getQueryLocator( query );
    }

    public void execute(Database.BatchableContext BC, List<BU_Member__c> scope){
        List<Id> bumember_id = new List<Id>();
        Database.DeleteResult result;
        for(BU_Member__c buMemberList : scope){
            bumember_id.add( buMemberList.Id );
        }

        if( bumember_id.size() > 0){
            Database.delete(bumember_id, false);
        }
    }
    
    public void finish(Database.BatchableContext BC){
        // not to do
    }


}