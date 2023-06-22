public class RequestToAddSLLGroupController {
    private static final String REQUEST_TO_ADD = 'Request to add';
    private static final String ERROR_PROCESSINSTANCE_LABEL = System.Label.RequestChangeOwnerMessage2;
    private static final String ERROR_EXISTCUSTOMER_LABEL = System.Label.SLLGroupMessage11;
    private static final String ERROR_NO_PAM_MANAGER_LABEL = System.Label.SLLGroupMessage3;
    private static final String ERROR_EXIST_PENDING_LABEL = System.Label.SLLGroupMessage14;
   
    public class wrapApprover{
        @AuraEnabled
        public User approver1 {get;set;}
        // @AuraEnabled
        // public User approver2 {get;set;}
        @AuraEnabled
        public String errMsg {get;set;}
    }
        
    @AuraEnabled
    public static Account getAccRec(String recordId) {
        Account acc = [SELECT id,name FROM Account WHERE id =: recordId LIMIT 1];
        return acc;
    }

    @AuraEnabled        
    public static List<String> getPickListValues() {
        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = SLL_Group_Approval_History__c.Reason__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
        }     
        return pickListValuesList;
    }
        
    @AuraEnabled
    public static SLL_Group__c getGroupPAM(String GroupId) {
        SLL_Group__c sll = [SELECT Id, Name, Pam__c, Pam__r.Name, Is_Active__c FROM SLL_Group__c WHERE id =: GroupId LIMIT 1];
        return sll;
    }
        
    @AuraEnabled
    public static wrapApprover getPAMapprover(String userId) {
        User user = [SELECT id, ProfileId, Profile.Name, ManagerId, Manager.Name, Manager.ProfileId, Manager.Profile.Name, Manager.ManagerId FROM User WHERE id =: userId LIMIT 1];

        System.debug('Manager Profile : ' + user.Manager.Profile.Name);

        wrapApprover approverlst = new wrapApprover();
        if(user.ManagerId != null && user.Manager.ManagerId != null){
            User Approver1 = [SELECT IsActive,FirstName,LastName,id,ProfileId,Profile.Name, ManagerId, Manager.Name FROM User WHERE id =: user.ManagerId LIMIT 1];
            // User Approver2 = [SELECT IsActive,FirstName,LastName,id,ProfileId,Profile.Name, ManagerId, Manager.Name FROM User WHERE id =: user.Manager.ManagerId LIMIT 1];
            approverlst.approver1 = Approver1;
            // approverlst.approver2 = Approver2;
        }else{
                approverlst.errMsg = ERROR_NO_PAM_MANAGER_LABEL;
        }
        return approverlst;
    }

    @AuraEnabled
    public static String createRecord(String GroupId,String CustomerId, String Reason, String Approver1 ) {
    // public static String createRecord(String GroupId,String CustomerId, String Reason, String Approver1, String Approver2 ) {
        String status;

        List<ProcessInstanceWorkitem>  checkWorkItem = [SELECT Id, ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId =: GroupId];

        if(checkWorkItem.size() == 0){
            List<SLL_Group_Member__c> groupMember = [SELECT id FROM SLL_Group_Member__c WHERE Customer_Name__c =: CustomerId AND SLL_Group__c =: GroupId];

            if(groupMember.size() == 0){
                List<SLL_Group_Approval_History__c> SLLHistory = [SELECT id, Request_Type__c, Approval_Status_Pending__c FROM SLL_Group_Approval_History__c WHERE Customer__c =: CustomerId AND SLL_Group_Name__c =: GroupId AND Approval_Status_Pending__c = 'Pending' AND Request_Type__c =: REQUEST_TO_ADD];

                if(SLLHistory.size() == 0){
                    SLL_Group_Approval_History__c rec = new SLL_Group_Approval_History__c();

                    Id currentuserId = Userinfo.getUserId();
                    datetime curDateTime = datetime.now();
                    String RequestType = REQUEST_TO_ADD;

                    rec.Customer__c = CustomerId;
                    rec.SLL_Group_Name__c = GroupId;
                    rec.Requester__c = currentuserId;
                    rec.Request_Date__c = curDateTime;
                    rec.Request_Type__c = RequestType;
                    rec.Reason__C = Reason;
                    rec.Approver1__c = Approver1;
                    // rec.Approver2__c = Approver2;
                    rec.Approval_Status_Pending__c = 'Pending';

                    Savepoint sp = Database.setSavepoint();
                    try{
                        insert rec;

                        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                        req.setObjectId(rec.Id);
                        Approval.ProcessResult result = Approval.process(req);
                        System.debug('Insert Record : ' + rec);
                        System.debug('Approval result : ' + result);
                        status = 'SUCCESS';
                    }catch (Exception e){
                        Database.rollback(sp);
                        System.debug('Exception caught');
                        System.debug(e.getMessage());
                        throw new AuraHandledException(e.getMessage());
                    }
                }else{
                    status = ERROR_EXIST_PENDING_LABEL;
                    System.debug(status);
                }
            }else{
                status = ERROR_EXISTCUSTOMER_LABEL;
                System.debug(status);
            }
        }else{
            status = ERROR_PROCESSINSTANCE_LABEL;
            System.debug(status);
        }
        return status;
    }
}