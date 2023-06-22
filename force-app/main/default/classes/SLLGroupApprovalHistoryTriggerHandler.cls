public class SLLGroupApprovalHistoryTriggerHandler {
    private static final String REQUEST_TO_ADD = 'Request to add';
    private static final String REQUEST_TO_REMOVE = 'Request to remove';
    private static final String APPROVED_STATUS = 'Approved';
    private static final String APPROVER1_APPROVED = 'Approver1 Approved';

    private static SLLGroupApprovalHistoryTriggerHandler inst;

    public static SLLGroupApprovalHistoryTriggerHandler instance() {
        if(inst == null){ inst = new SLLGroupApprovalHistoryTriggerHandler(); }
        return inst;
    }

    public void handleBeforeInsert(List<SLL_Group_Approval_History__c> records) {
        System.debug('handleBeforeInsert SLLGroupApprovalHistoryTriggerHandler');

        List<Id> acctIdLst = new List<Id> ();
        Map<Id, Account> mapAcctId = new Map<Id, Account> ();

        for(SLL_Group_Approval_History__c eachGrpHst : records){
            if(eachGrpHst.Customer__c != null) acctIdLst.add(eachGrpHst.Customer__c);

            if(eachGrpHst.Approval_Status_Pending__c == 'Approved'){
                eachGrpHst.Approved_Date__c = Datetime.now();
                eachGrpHst.Request_Date__c = Datetime.now();
                eachGrpHst.Remark__c = 'Imported from manual upload.';
            }
        }
        
        if(acctIdLst.size() > 0){
            mapAcctId = new Map<Id, Account> ([SELECT Id, OwnerId FROM Account WHERE Id IN :acctIdLst]);
            for(SLL_Group_Approval_History__c eachGrpHst : records){
                eachGrpHst.Customer_Owner__c = mapAcctId.get(eachGrpHst.Customer__c).OwnerId;
            }
        }
    }

    public void handleAfterUpdate(List<SLL_Group_Approval_History__c> records, Map<Id, SLL_Group_Approval_History__c> existingRecords) {
        System.debug('handleBeforeUpdate SLLGroupApprovalHistoryTriggerHandler');
        handleCreateGroupMember(records,existingRecords);
        handleDeleteGroupMember(records,existingRecords);
    }

    private void handleCreateGroupMember(List<SLL_Group_Approval_History__c> records, Map<Id, SLL_Group_Approval_History__c> existingRecords){
        List<SLL_Group_Member__c> listInsertGroupMember = new List<SLL_Group_Member__c>();
        Map<Id,SLL_Group_Member__c> mapGroupMemIdwithApprovalHistory = new Map<Id,SLL_Group_Member__c>();

        for(SLL_Group_Approval_History__c eachGrpHst : records){
            SLL_Group_Member__c newGroupMember = new SLL_Group_Member__c();

            if(eachGrpHst.Request_Type__c == REQUEST_TO_ADD && eachGrpHst.Approval_Status_Pending__c == APPROVED_STATUS && eachGrpHst.Approval_Status_Pending__c != existingRecords.get(eachGrpHst.Id).Approval_Status_Pending__c){
                //create Group Member
                newGroupMember.Customer_Name__c = eachGrpHst.Customer__c;
                newGroupMember.SLL_Group__c = eachGrpHst.SLL_Group_Name__c;
                newGroupMember.Reason__c = eachGrpHst.Reason__c;
                newGroupMember.Last_Approve_Date__c = datetime.now();

                listInsertGroupMember.add(newGroupMember);
                mapGroupMemIdwithApprovalHistory.put(eachGrpHst.Id,newGroupMember);
            }
        }

        if(listInsertGroupMember.size()>0){
            try {
                insert listInsertGroupMember;
                System.debug('mapGroupMemIdwithApprovalHistory : ' + mapGroupMemIdwithApprovalHistory);
                System.debug('Success handleCreateGroupMember : '+ listInsertGroupMember);
            }catch(Exception e){
                System.debug('Error handleCreateGroupMember : '+ e.getMessage());
            }
        }

        if(mapGroupMemIdwithApprovalHistory.size()>0){
            List<SLL_Group_Approval_History__c> apphis = [SELECT Id, SLL_Group_Member__c FROM SLL_Group_Approval_History__c WHERE Id IN: mapGroupMemIdwithApprovalHistory.keySet()];

            if(apphis.size() > 0){
                for(SLL_Group_Approval_History__c each : apphis){
                    SLL_Group_Member__c grpMem = mapGroupMemIdwithApprovalHistory.get(each.Id);
                    each.SLL_Group_Member__c = grpMem.Id;
                }

                try{
                    update apphis;
                }catch(Exception e){
                    System.debug('Error handleCreateGroupMember : '+ e.getMessage());
                }
            }
        }
    }

    private void handleDeleteGroupMember(List<SLL_Group_Approval_History__c> records, Map<Id, SLL_Group_Approval_History__c> existingRecords){
        List<SLL_Group_Member__c> listDeleteGroupMember = new List<SLL_Group_Member__c>();
        for(SLL_Group_Approval_History__c eachGrpHst : records){
            if(eachGrpHst.Request_Type__c == REQUEST_TO_REMOVE && eachGrpHst.Approval_Status_Pending__c == APPROVED_STATUS && eachGrpHst.Approval_Status_Pending__c != existingRecords.get(eachGrpHst.Id).Approval_Status_Pending__c){
                SLL_Group_Member__c delGroupMember = new SLL_Group_Member__c();
                delGroupMember.Id = eachGrpHst.SLL_Group_Member__c;
                listDeleteGroupMember.add(delGroupMember);
            }
        }
        if(listDeleteGroupMember.size()>0){
            System.debug(listDeleteGroupMember);
            try {
                //Delete Group Member
                delete listDeleteGroupMember;
                System.debug('Success handleDeleteGroupMember : '+ listDeleteGroupMember);
            }catch(Exception e){
                System.debug('Error handleDeleteGroupMember : '+ e.getMessage());
            }
        }
    }
}