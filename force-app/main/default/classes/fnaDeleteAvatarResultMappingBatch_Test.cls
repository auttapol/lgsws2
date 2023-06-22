@isTest
public without sharing class fnaDeleteAvatarResultMappingBatch_Test {

    @isTest
    private static void Test_fnaDeleteAvatarResultMappingBatch() {
        List<AvatarResultMapping__c> listAvatarResultMaping = new List<AvatarResultMapping__c>();
        AvatarResultMapping__c avatarResultMaping = new AvatarResultMapping__c();
        avatarResultMaping.Answer__c = 'คำตอบทั้งหมดX';
        avatarResultMaping.isActive__c = true;
        listAvatarResultMaping.add(avatarResultMaping);
        insert listAvatarResultMaping;

        String queryTrue = 'SELECT Id, CreatedDate, CreatedBy.Name, QuestionnaireFlow__c, Answer__c, AvatarMaster__c, Segment__c, isActive__c FROM AvatarResultMapping__c WHERE isActive__c = true';
        fnaDeleteAvatarResultMappingBatch deleteAvatarResultMappingTrue = new fnaDeleteAvatarResultMappingBatch(queryTrue,true); 
        Id batchIdARMT = Database.executeBatch(deleteAvatarResultMappingTrue);
    }
}