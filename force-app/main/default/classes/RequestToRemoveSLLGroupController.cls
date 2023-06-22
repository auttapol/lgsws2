public class RequestToRemoveSLLGroupController {
    private static final String REQUEST_TO_REMOVE = 'Request to remove';
    private static final String ERROR_NO_PAM_MANAGER_LABEL = System.Label.SLLGroupMessage3;
    private static final String ERROR_EXIST_PENDING_LABEL = System.Label.SLLGroupMessage14;
    public class wrapGroupMember{
        @AuraEnabled
        public SLL_Group_Member__c groupMember {get;set;}
        @AuraEnabled
        public User approver1 {get;set;}
        // @AuraEnabled
        // public User approver2 {get;set;}
        @AuraEnabled
        public String errMsg {get;set;}
    }
    public class wrapApprover{
        @AuraEnabled
        public User approver1 {get;set;}
        // @AuraEnabled
        // public User approver2 {get;set;}
        @AuraEnabled
        public String errMsg {get;set;}
    }

    @AuraEnabled
    public static wrapGroupMember getGroupMemRec(String recordId) {
       wrapGroupMember response = new wrapGroupMember();
       SLL_Group_Member__c sllGroupMember = [SELECT id,Name,Reason__c,SLL_Group__c,SLL_Group__r.Name,SLL_Group__r.PAM__c,SLL_Group__r.Is_Active__c,Customer_Name__c,Customer_Name__r.Name FROM SLL_Group_Member__c WHERE id =: recordId LIMIT 1];
       response.groupMember = sllGroupMember;
       System.debug('SLL_Group_Member__c : ' + response.groupMember);

       Id pamId =  sllGroupMember.SLL_Group__r.PAM__c;
       System.debug('Pam Id : ' + pamId);

       if(pamId != null){
            wrapApprover approver  = getPAMapprover(pamId);
            if(approver.errMsg == null){
                response.approver1 = approver.approver1;
                // response.approver2 = approver.approver2;
                System.debug('approver1 : ' + response.approver1);
                // System.debug('approver2 : ' + response.approver2);
            }else{
                response.errMsg = approver.errMsg;
            }
       }else{
            response.errMsg = 'This Group Member don\'t have PAM';
       }

       return response;
    }
    public static wrapApprover getPAMapprover(Id userId) {
        User user = [SELECT id,ProfileId,Profile.Name, ManagerId FROM User WHERE id =: userId LIMIT 1];
        // User user = [SELECT id,ProfileId,Profile.Name, ManagerId, Manager.Name,Manager.ProfileId,Manager.Profile.Name,Manager.ManagerId FROM User WHERE id =: userId LIMIT 1];
        // System.debug('Manager Profile : ' + user.Manager.Profile.Name);
        wrapApprover approverlst = new wrapApprover();
        if(user.ManagerId != null ){
        // if(user.ManagerId != null && user.Manager.ManagerId != null){
            User Approver1 = [SELECT IsActive,FirstName,LastName,id,ProfileId,Profile.Name, ManagerId, Manager.Name FROM User WHERE id =: user.ManagerId LIMIT 1];
            // User Approver2 = [SELECT IsActive,FirstName,LastName,id,ProfileId,Profile.Name, ManagerId, Manager.Name FROM User WHERE id =: user.Manager.ManagerId LIMIT 1];
            approverlst.approver1 = Approver1;
            // approverlst.approver2 = Approver2;
            }
        else{
             approverlst.errMsg = ERROR_NO_PAM_MANAGER_LABEL;
        }
        return approverlst;
     }


    @AuraEnabled
    public static String createRecord(String recordId, String GroupId,String CustomerId, String Reason, String Approver1 ) {
      String status;
      List<String> appstatus = new List<String>{'Pending','Approver1 Approved'};
      List<SLL_Group_Member__c> groupMember = [SELECT id FROM SLL_Group_Member__c WHERE Customer_Name__c =: CustomerId AND SLL_Group__c =: GroupId];
        if(groupMember.size() > 0){
         List<SLL_Group_Approval_History__c> SLLHistory = [SELECT id,Request_Type__c,Approval_Status_Pending__c FROM SLL_Group_Approval_History__c WHERE Customer__c =: CustomerId AND SLL_Group_Name__c =: GroupId AND Approval_Status_Pending__c IN: appstatus AND Request_Type__c =: REQUEST_TO_REMOVE];
         if(SLLHistory.size() == 0){
            SLL_Group_Approval_History__c rec = new SLL_Group_Approval_History__c();
            Id currentuserId = Userinfo.getUserId();
            datetime curDateTime = datetime.now();
            rec.Customer__c = CustomerId;
            rec.SLL_Group_Name__c = GroupId;
            rec.Requester__c = currentuserId;
            rec.Request_Date__c = curDateTime;
            rec.Request_Type__c = REQUEST_TO_REMOVE;
            rec.Reason__C = Reason;
            rec.Approver1__c = Approver1;
            // rec.Approver2__c = Approver2;
            rec.Approval_Status_Pending__c = 'Pending';
            rec.SLL_Group_Member__c = recordId;
            Savepoint sp = Database.setSavepoint();
            try{
               insert rec;
               Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
               req.setObjectId(rec.Id);
               Approval.ProcessResult result = Approval.process(req);
               System.debug('Insert Record : ' + rec);
               System.debug('Approval result : ' + result);
               status = 'SUCCESS';
            }
            catch (Exception e){
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
            status = 'No customer in this Group Member to remove.';
            System.debug(status);
        }
         return status;
      }
    
}