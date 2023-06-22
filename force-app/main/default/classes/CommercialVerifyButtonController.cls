public with sharing class CommercialVerifyButtonController {
    
    public CommercialVerifyButtonController() {
        
    }

    @AuraEnabled
    public static Contact getContactDetail(String conId){
        try {
            Contact con = [SELECT Id, IsVerified__c, IsTBankData__c FROM Contact WHERE Id =: conId];
            return con;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void UpdateContact(String conId, Boolean isActive){
        try {
            Contact con = [SELECT Id, IsVerified__c, IsActive__c FROM Contact WHERE Id =: conId];

            con.IsVerified__c = true;
        
            if (isActive) {
                con.IsActive__c = isActive;
            }
            
            update con;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}