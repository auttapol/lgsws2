global class fnaDeleteAvatarResultMappingTemp implements 
    Database.Batchable<sObject>, Database.Stateful {
    global final Boolean finishProcessBatch;

    global fnaDeleteAvatarResultMappingTemp(Boolean finishBatch){
        finishProcessBatch = finishBatch;
    }
    
    // instance member to retain state across transactions
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT Id FROM Avatar_Result_Mapping_Temp__c'
        );
    }
    global void execute(Database.BatchableContext bc, List<Avatar_Result_Mapping_Temp__c> avatarResultMapping){
        // process each batch of records
        delete avatarResultMapping;
        system.debug('avatarResultMapping must be  0 : ' + avatarResultMapping);
    }
    global void finish(Database.BatchableContext bc){
        if(finishProcessBatch == true){
            fnaGenerateAvatarResultsMappingBatch generateAvatarResultMapping = new fnaGenerateAvatarResultsMappingBatch(); 
            Id batchId = Database.executeBatch(generateAvatarResultMapping,5);
            system.debug('batchId : ' + batchId);
        }
        else{
            system.debug('Finish process Batchable #2');
        }
    }
}