public class CreateSLLGroupController {
    public class wrapApprover{
        @AuraEnabled
        public User approver1 {get;set;}
        // @AuraEnabled
        // public User approver2 {get;set;}
        @AuraEnabled
        public String errMsg {get;set;}
    }

    @AuraEnabled
    public static List<String> getReasonList(){
        Schema.DescribeFieldResult pickLst = SLL_Group_Member__c.Reason__c.getDescribe();
        List<String> reasonList = new List<String>();
        for (Schema.PicklistEntry reason : pickLst.getPicklistValues()) { //for all values in the picklist list
            reasonList.add(reason.getValue());//add the value  to our final list
         }
        return reasonList;
    }

    @AuraEnabled
    public static List<SLL_Group__c> getSLLGroupOfCustomer(String recordId, String groupName) {
        System.debug(recordId);
        System.debug(groupName);
        List<SLL_Group__c> sg = [SELECT Id, Name, Primary_Customer__c FROM SLL_Group__c WHERE (Name =: groupName OR Primary_Customer__c =: recordId) AND (is_Active__c = true OR Approval_Status__c = 'Pending Approval - Active') LIMIT 1];
        return sg;
    }

    @AuraEnabled
    public static wrapApprover getPAMApprover(String userId) {
    User user = [select Id,Name,ManagerId,Manager.Name,Manager.ManagerId,Manager.Manager.Name from User where Id =: userId];   
    wrapApprover approverObj = new wrapApprover();
    if(user.ManagerId != null) {
            User Approver1 = [Select FirstName,LastName,id,ProfileId,Profile.Name, ManagerId, Manager.Name,IsActive FROM User where id =: user.ManagerId limit 1];
            // User Approver2 = [Select FirstName,LastName,id,ProfileId,Profile.Name, ManagerId, Manager.Name,IsActive FROM User where id =: Approver1.ManagerId limit 1];
            approverObj.approver1 = Approver1;
            // approverObj.approver2 = Approver2;
            return approverObj;
    }
    approverObj.errMsg = 'Not found Team head or Group head above the PAM';
    return approverObj;
    }

    @AuraEnabled
    public static SLL_Group__c createSLLGroup(String gName, String primCusId, String userId, String approverId1, String inpRemark, SLL_Group_Member__c[] memberList){
    // public static SLL_Group__c createSLLGroup(String gName, String primCusId, String userId, String approverId1, String approverId2, String inpRemark, SLL_Group_Member__c[] memberList){
        String status;
        Savepoint sp1 = Database.setSavepoint();
        datetime curDateTime = datetime.now();
        SLL_Group__c newSG = new SLL_Group__c(
            Approval_Status__c='Pending Approval - Active',
            Remark__c=inpRemark,
            Primary_Customer__c=primCusId,
            PAM__c=userId,
            Name=gName,
            Approver1__c=approverId1,
            // Approver2__c=approverId2,
            RecordTypeId=Schema.Sobjecttype.SLL_Group__c.getRecordTypeInfosByName().get('Draft').getRecordTypeId(),
            Is_Active__c=false,
            Requester__c=UserInfo.getUserId(),
            Request_Date__c=curDateTime);
        
        try {
            insert newSG;

            SLL_Group_Member__c[] newMemberList = new List<SLL_Group_Member__c>();
            SLL_Group_Approval_History__c[] newHisList = new List<SLL_Group_Approval_History__c>();
        
            if(memberList.size() > 0) {
                for (SLL_Group_Member__c member : memberList) {
                    newHisList.add(new SLL_Group_Approval_History__c(
                        Customer__c = member.Customer_Name__c,
                        SLL_Group_Name__c = newSG.Id,
                        Requester__c = userId,
                        Request_Date__c = datetime.now(),
                        Request_Type__c = 'Request to add',
                        Reason__c = member.Reason__c,
                        Approver1__c = approverId1,
                        // Approver2__c = approverId2,
                        Approval_Status_Pending__c = 'Pending'));
                }
            }
        
            insert newHisList;
            submitForApproval(newSG.Id);
        }
        catch (Exception e){
            Database.rollback(sp1);
            throw new AuraHandledException(e.getMessage());
        } 
        return newSG;
    }

    private static string submitForApproval(String sllGroupId) {
        Approval.ProcessSubmitRequest req1 = 
            new Approval.ProcessSubmitRequest();

        req1.setComments('Auto submit for approval due to SLL Group was created.');
        req1.setObjectId(sllGroupId);
        req1.setSubmitterId(UserInfo.getUserId()); 
        
        Approval.ProcessResult result = Approval.process(req1);
        
        return 'Submit for approval success';
    }
}