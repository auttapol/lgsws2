public with sharing class RequestToInactiveSLLGroup {
    @AuraEnabled
    public static SLL_Group__c requestToInactiveSLLGroup(String recordId, String comment){
        // create record at sll group as draft
        String status;
        Datetime now = Datetime.now();
        Savepoint sp1 = Database.setSavepoint();
        SLL_Group__c newSG = [SELECT Id, Name, Approver1__c, Approver1__r.IsActive FROM SLL_Group__c WHERE Id =: recordId];
        // SLL_Group__c newSG = [SELECT Id, Name, Approver1__c, Approver2__c, Approver1__r.IsActive, Approver2__r.IsActive FROM SLL_Group__c WHERE Id =: recordId];

        if(newSG.Approver1__c == null ) {
        // if(newSG.Approver1__c == null || newSG == null) {
            throw new AuraHandledException(Label.SLLGroupMessage3);
        }
        else if(!newSG.Approver1__r.IsActive ) {
        // else if(!newSG.A  pprover1__r.IsActive || !newSG.Approver2__r.IsActive) {
            throw new AuraHandledException(Label.SLLGroupMessage4);
        } 
        else {
            newSG.Approval_Status__c = 'Pending Approval - Inactive';
            newSG.Requester__c = UserInfo.getUserId();
            newSG.Request_Date__c = now;
            
            try {
                update newSG;
                submitForApproval(newSG.Id, comment);
            }
            catch (Exception e){
                Database.rollback(sp1);
                System.debug(e.getMessage());
                throw new AuraHandledException(e.getMessage());
            } 
            return newSG;
        }
    }

    private static string submitForApproval(String sllGroupId, String comment) {
        // Create an approval request for the account
        Approval.ProcessSubmitRequest req1 = 
            new Approval.ProcessSubmitRequest();
        req1.setComments(comment);
        req1.setObjectId(sllGroupId);
        
        req1.setSubmitterId(UserInfo.getUserId()); 

        Approval.ProcessResult result = Approval.process(req1);

        return 'Submit for approval success';   
    }   
}