global class fnaDeleteAvatarResultMappingBatch implements 
    Database.Batchable<sObject>, Database.Stateful {
    global final String query;
    global final Boolean continueUpsert;

    global fnaDeleteAvatarResultMappingBatch(String queryString, Boolean conUpsert){
        query = queryString;
        continueUpsert = conUpsert;
    }
    
    // instance member to retain state across transactions
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<AvatarResultMapping__c> avatarResultMapping){
        // process each batch of records
        delete avatarResultMapping;
        system.debug('avatarResultMapping must be  0 : ' + avatarResultMapping);
    }
    global void finish(Database.BatchableContext bc){
        //Status isActive change false -> true
        if(continueUpsert == true){
            fnaUpsertAvatarMappingResultBatch upsertAvatarResultMapping = new fnaUpsertAvatarMappingResultBatch(); 
            Id batchIdUpsertARM = Database.executeBatch(upsertAvatarResultMapping);
            system.debug('Finish process Batchable #2 : upsert AvatarResultMappingBatch');
        }
        system.debug('Finish process Batchable #2 : Success to remove avatarResultMappingTemp isActive : true & false');
    }
}