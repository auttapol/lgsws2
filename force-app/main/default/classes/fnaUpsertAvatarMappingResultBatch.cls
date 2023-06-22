global class fnaUpsertAvatarMappingResultBatch implements 
    Database.Batchable<sObject>, Database.Stateful {
    
    // instance member to retain state across transactions
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT Id, CreatedDate, CreatedBy.Name, QuestionnaireFlow__c, Answer__c, AvatarMaster__c, Segment__c, isActive__c FROM AvatarResultMapping__c WHERE isActive__c = false'
        );
    }
    global void execute(Database.BatchableContext bc, List<AvatarResultMapping__c> avatarResultMapping){
        // process each batch of records
        for(AvatarResultMapping__c avatarMapping : avatarResultMapping){
            avatarMapping.isActive__c = true;
        }                
        upsert avatarResultMapping;
        system.debug('avatarResultMapping must be  0 : ' + avatarResultMapping);
    }
    global void finish(Database.BatchableContext bc){
        system.debug('Finish Change Status isActive false -> true Batchable #2');
    }
}