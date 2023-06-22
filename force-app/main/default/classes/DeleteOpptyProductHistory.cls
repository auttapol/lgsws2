global class DeleteOpptyProductHistory implements Database.Batchable<sObject> {
	global final String Query;
    global DeleteOpptyProductHistory(String q){
        Query=q;
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC,List<Opportunity_Product_History__c> scope){
        delete scope;
    }

    global void finish(Database.BatchableContext BC){}
}