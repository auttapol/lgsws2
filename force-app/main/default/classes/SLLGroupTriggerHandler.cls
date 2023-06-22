public class SLLGroupTriggerHandler {
    public static final Id AvailableRecordType = Schema.SObjectType.SLL_Group__c.getRecordTypeInfosByName().get('Available').getRecordTypeId();

    public static void handlerBeforeInsert(List<SLL_Group__c> records){
        System.debug('--- SLLGroupTriggerHandler HandleBeforeInsert START ---');
        handleCheckPrimaryCustomer(records,null,false);
        handleCheckPAMApprover(records);
        autoStampFieldFromManualUploadData(records);
        System.debug('--- SLLGroupTriggerHandler HandleBeforeInsert END ---');
    }
    
    public static void handlerBeforeUpdate(List<SLL_Group__c> records,Map<Id, SLL_Group__c> existingRecords){
        System.debug('--- SLLGroupTriggerHandler HandleBeforeUpdate START ---');
        handleBeforeUpdateApprovalStatus(records, existingRecords);
        handleCheckPrimaryCustomer(records, existingRecords, true);
        handleCheckPAMApprover(records);
        System.debug('--- SLLGroupTriggerHandler HandleBeforeUpdate END ---');
    }
    public static void handlerAfterInsert(List<SLL_Group__c> records){
        System.debug('--- SLLGroupTriggerHandler HandleAfterInsert START ---');
        System.debug('--- SLLGroupTriggerHandler HandleAfterInsert END ---');
    }
    public static void handlerAfterUpdate(List<SLL_Group__c> records,Map<Id, SLL_Group__c> existingRecords){
        System.debug('--- SLLGroupTriggerHandler HandleAfterUpdate START ---');
        handleAfterUpdateApprovalStatus(records,existingRecords);
        System.debug('--- SLLGroupTriggerHandler HandleAfterUpdate END ---');
    }

    public static void autoStampFieldFromManualUploadData(List<SLL_Group__c> sllGroupLst){
        Set<Id> pamSet = new Set<Id>();

        for(SLL_Group__c newSG: sllGroupLst) {
            pamSet.add(newSG.PAM__c);
        }

        Map<Id, User> pamMapUser = new Map<Id, User>([SELECT Id, ManagerId, Manager.IsActive FROM User WHERE Id IN :pamSet]);
        // Map<Id, User> pamMapUser = new Map<Id, User>([SELECT Id, ManagerId, Manager.IsActive, Manager.ManagerId, Manager.Manager.IsActive FROM User WHERE Id IN :pamSet]);

        for(SLL_Group__c newSG: sllGroupLst) {
            if(newSG.Approval_Status__c == 'Approved - Active' && newSG.Is_Active__c == true && pamMapUser.containsKey(newSG.PAM__c)){
                newSG.RecordTypeId = AvailableRecordType;
                newSG.Request_Date__c = Datetime.now();
                newSG.Last_Approve_Date__c = Datetime.now();
                newSG.Approver1__c = pamMapUser.get(newSG.PAM__c).ManagerId;
                // newSG.Approver2__c = pamMapUser.get(newSG.PAM__c).Manager.ManagerId;
            }
        }
    }

    public static void handleCheckPrimaryCustomer(List<SLL_Group__c> records, Map<Id, SLL_Group__c> existingRecords, Boolean isUpdate){
        Set<Id> newGroupId = new Set<Id>();

        Set<Id> newPrimCusId = new Set<Id>();
        Set<Id> existingPrimId = new Set<Id>();

        Set<String> newGroupName = new Set<String>();
        Set<String> existingName = new Set<String>();

        for(SLL_Group__c g : records){
            if(g.Id != null) newGroupId.add(g.Id);

            if(g.Primary_Customer__c != null) newPrimCusId.add(g.Primary_Customer__c);
            if(g.Primary_Customer_To_Be__c != null) newPrimCusId.add(g.Primary_Customer_To_Be__c);

            if(g.Name != null) newGroupName.add(g.Name);
            if(g.SLL_Group_Name_To_Be__c != null) newGroupName.add(g.SLL_Group_Name_To_Be__c);
        }

        if(newPrimCusId.size() > 0 ){
            List<SLL_Group__c> lstGroupPrimeCust = [SELECT Id, Primary_Customer__c FROM SLL_Group__c WHERE Primary_Customer__c IN :newPrimCusId AND Id NOT IN :newGroupId AND (is_Active__c = true OR Approval_Status__c = 'Pending Approval - Active')];

            List<SLL_Group__c> lstGroupName = [SELECT Id, Name FROM SLL_Group__c WHERE Name IN :newGroupName AND Id NOT IN :newGroupId AND (is_Active__c = true OR Approval_Status__c = 'Pending Approval - Active')];

            for(SLL_Group__c sg: lstGroupPrimeCust){
                existingPrimId.add(sg.Primary_Customer__c);
            }
            
            for (SLL_Group__c sg : lstGroupName) {
                existingName.add(sg.Name);
            }
        }

        for(SLL_Group__c newGroup : records){
            if((!isUpdate && existingPrimId.contains(newGroup.Primary_Customer__c)) || (isUpdate && (existingPrimId.contains(newGroup.Primary_Customer__c) || existingPrimId.contains(newGroup.Primary_Customer_To_Be__c)) && (newGroup.RecordTypeId == AvailableRecordType || newGroup.is_Active__c == true || newGroup.Approval_Status__c == 'Pending Approval - Active'))){
                newGroup.Primary_Customer__c.addError('The Primary Customer is already in another SLL Group.');
            } else if((!isUpdate && existingName.contains(newGroup.Name)) || (isUpdate && (existingName.contains(newGroup.Name) || existingName.contains(newGroup.SLL_Group_Name_To_Be__c)) && (newGroup.RecordTypeId == AvailableRecordType || newGroup.is_Active__c == true || newGroup.Approval_Status__c == 'Pending Approval - Active'))){
                newGroup.Primary_Customer__c.addError('The SLL Group Name is already used in another SLL Group.');
            }else{
                existingPrimId.add(newGroup.Primary_Customer__c);
                existingName.add(newGroup.Name);
                System.debug('Can Update/Insert :' + newGroup.Primary_Customer__c);
            }
        }
    }
    public static void handleAfterUpdateApprovalStatus(List<SLL_Group__c> records, Map<Id, SLL_Group__c> existingRecords){
        Map<Id, SLL_Group__c> mapAppActiveSLLGroup = new Map<Id, SLL_Group__c>();
        Map<Id, SLL_Group__c> mapRejActiveSLLGroup = new Map<Id, SLL_Group__c>();
        Map<Id, SLL_Group__c> mapAppInactiveSLLGroup = new Map<Id, SLL_Group__c>();

        for(SLL_Group__c cg : records){
            if(existingRecords.get(cg.Id).Approval_Status__c != cg.Approval_Status__c) {
                if(cg.Approval_Status__c == 'Approved - Active'){
                    mapAppActiveSLLGroup.put(cg.Id,cg);
                } else if (cg.Approval_Status__c == 'Rejected - Active') {
                    mapRejActiveSLLGroup.put(cg.Id,cg);
                }  else if(cg.Approval_Status__c == 'Approved - Inactive') {
                    mapAppInactiveSLLGroup.put(cg.Id,cg);
                }
            }        
        } 

        if(mapAppActiveSLLGroup.size() > 0) {
            approveActiveGroup(mapAppActiveSLLGroup);
        }
        if(mapRejActiveSLLGroup.size() > 0) {
            rejectActiveGroup(mapRejActiveSLLGroup);
        }
        if(mapAppInactiveSLLGroup.size() > 0) {
            approveInactiveGroup(mapAppInactiveSLLGroup);
        }
    }

    public static void handleBeforeUpdateApprovalStatus(List<SLL_Group__c> records, Map<Id, SLL_Group__c> existingRecords){
        Map<Id, SLL_Group__c> mapAppUpdateSLLGroup = new Map<Id, SLL_Group__c>();
        Map<Id, SLL_Group__c> mapRejUpdateSLLGroup = new Map<Id, SLL_Group__c>();

        for(SLL_Group__c cg : records){
            if(existingRecords.get(cg.Id).Approval_Status__c != cg.Approval_Status__c) {
                if(cg.Approval_Status__c == 'Approved - Update'){
                    mapAppUpdateSLLGroup.put(cg.Id,cg);
                } else if (cg.Approval_Status__c == 'Rejected - Update') {
                    mapRejUpdateSLLGroup.put(cg.Id,cg);
                }
            }        
        } 

        if(mapAppUpdateSLLGroup.size() > 0) {
            approveUpdateGroup(mapAppUpdateSLLGroup,existingRecords);
        }
        if(mapRejUpdateSLLGroup.size() > 0) {
            rejectUpdateGroup(mapRejUpdateSLLGroup);
        }
    }

    private static void approveActiveGroup(Map<Id, SLL_Group__c> mapAppActiveSLLGroup){
        List<SLL_Group_Approval_History__c> histLst = [SELECT Id,SLL_Group_Name__c,Customer__c, Reason__c FROM SLL_Group_Approval_History__c WHERE SLL_Group_Name__c IN:mapAppActiveSLLGroup.keySet() AND Request_Type__c = 'Request to add' AND Approval_Status_Pending__c = 'Pending'];

        for(SLL_Group_Approval_History__c histRecord : histLst) {
            histRecord.Approval_Status_Pending__c = 'Approved';
            histRecord.Remark__c = 'Auto approve due to new SLL Group was approved.';
            histRecord.Approved_Date__c = Datetime.now();
        }
        update histLst;
    }

    private static void rejectActiveGroup(Map<Id, SLL_Group__c> mapRejActiveSLLGroup){
        List<SLL_Group_Approval_History__c> histLst = [SELECT Id,SLL_Group_Name__c,Customer__c, Reason__c FROM SLL_Group_Approval_History__c WHERE SLL_Group_Name__c IN:mapRejActiveSLLGroup.keySet() AND Request_Type__c = 'Request to add' AND Approval_Status_Pending__c = 'Pending'];

        for(SLL_Group_Approval_History__c histRecord : histLst) {
            histRecord.Approval_Status_Pending__c = 'Rejected';
            histRecord.Remark__c = 'Auto reject due to new SLL Group was rejected.';
            // histRecord.Approved_Date__c = Datetime.now();
        }
        update histLst;
    }

    private static void approveUpdateGroup(Map<Id, SLL_Group__c> mapAppUpdateSLLGroup, Map<Id, SLL_Group__c> existingRecords){
        Set<Id> changedPAMLst = new Set<Id>();
        for(SLL_Group__c sg : mapAppUpdateSLLGroup.values()) {
            if(sg.PAM__c != sg.PAM_To_Be__c && !String.isBlank(sg.PAM_To_Be__c)) {
                changedPAMLst.add(sg.PAM_To_Be__c);
            }
        }
        Map<Id, User> mapChangedPAM = new Map<Id, User>([SELECT Id, Name, ManagerId FROM User WHERE Id IN: changedPAMLst]);
        // Map<Id, User> mapChangedPAM = new Map<Id, User>([SELECT Id, Name, ManagerId, Manager.ManagerId FROM User WHERE Id IN: changedPAMLst]);
        
        for(SLL_Group__c sg : mapAppUpdateSLLGroup.values()) {
            if(sg.PAM__c != sg.PAM_To_Be__c && !String.isBlank(sg.PAM_To_Be__c)) {
                sg.Approver1__c = mapChangedPAM.containsKey(sg.PAM_To_Be__c) ? mapChangedPAM.get(sg.PAM_To_Be__c)?.ManagerId : null;
                // sg.Approver2__c = mapChangedPAM.containsKey(sg.PAM_To_Be__c) ? mapChangedPAM.get(sg.PAM_To_Be__c)?.Manager?.ManagerId : null;
            }
            sg.Name = String.isBlank(sg.SLL_Group_Name_To_Be__c) ? sg.Name : sg.SLL_Group_Name_To_Be__c;
            sg.Primary_Customer__c = String.isBlank(sg.Primary_Customer_To_Be__c) ? sg.Primary_Customer__c : sg.Primary_Customer_To_Be__c;
            sg.PAM__c = String.isBlank(sg.PAM_To_Be__c) ? sg.PAM__c : sg.PAM_To_Be__c;
            sg.Remark__c = String.isBlank(sg.Remark_To_Be__c) ? sg.Remark__c : sg.Remark_To_Be__c;

            sg.SLL_Group_Name_To_Be__c = '';
            sg.Primary_Customer_To_Be__c = null;
            sg.PAM_To_Be__c = null;
            sg.Remark_To_Be__c = '';
        }
    }

    private static void rejectUpdateGroup(Map<Id, SLL_Group__c> mapRejUpdateSLLGroupId){
        for(SLL_Group__c sg : mapRejUpdateSLLGroupId.values()) {
            sg.SLL_Group_Name_To_Be__c = '';
            sg.Primary_Customer_To_Be__c = null;
            sg.PAM_To_Be__c = null;
            sg.Remark_To_Be__c = '';
        }
    }

    private static void approveInactiveGroup(Map<Id, SLL_Group__c> mapAppInactiveSLLGroupId){
        List<SLL_Group_Approval_History__c> histLst = [SELECT Id, SLL_Group_Name__c, Customer__c, Reason__c, Request_Type__c FROM SLL_Group_Approval_History__c WHERE SLL_Group_Name__c IN:mapAppInactiveSLLGroupId.keySet() and Approval_Status_Pending__c = 'Pending'];
        List<SLL_Group_Member__c> memberLst = [SELECT Id, Customer_Name__c, SLL_Group__c, SLL_Group__r.Approver1__c, SLL_Group__r.Request_Date__c, SLL_Group__r.Requester__c, Reason__c FROM SLL_Group_Member__c WHERE SLL_Group__c IN: mapAppInactiveSLLGroupId.keySet()];
        // List<SLL_Group_Member__c> memberLst = [SELECT Id, Customer_Name__c, SLL_Group__c, SLL_Group__r.Approver1__c, SLL_Group__r.Approver2__c, SLL_Group__r.Request_Date__c, SLL_Group__r.Requester__c, Reason__c FROM SLL_Group_Member__c WHERE SLL_Group__c IN: mapAppInactiveSLLGroupId.keySet()];
        List<SLL_Group_Approval_History__c> newHisList = new List<SLL_Group_Approval_History__c>();

        if(memberLst.size() > 0) {
            for (SLL_Group_Member__c member : memberLst) {
                newHisList.add(new SLL_Group_Approval_History__c(
                    SLL_Group_Name__c = member.SLL_Group__c,
                    Customer__c = member.Customer_Name__c,
                    Approver1__c = member.SLL_Group__r.Approver1__c,
                    // Approver2__c = member.SLL_Group__r.Approver2__c,
                    Requester__c = member.SLL_Group__r.Requester__c,
                    Request_Date__c = member.SLL_Group__r.Request_Date__c,
                    Reason__c = member.Reason__c,
                    Approved_Date__c = datetime.now(),
                    Request_Type__c = 'Request to remove',
                    Remark__c = 'Auto remove due to SLL Group was inactive.',
                    Approval_Status_Pending__c = 'Approved'));
            }
        }

        for(SLL_Group_Approval_History__c histRecord : histLst) {
            histRecord.Approval_Status_Pending__c = 'Rejected';
            histRecord.Remark__c = 'Auto reject due to SLL Group was inactive.';
        }

        if(histLst.size() > 0) update histLst;
        if(newHisList.size() > 0) insert newHisList;
        if(memberLst.size() > 0) delete memberLst;
    }

    private static void handleCheckPAMApprover(List<SLL_Group__c> sllGroupLst) {
        
        Set<Id> pamSet = new Set<Id>();
        
        for(SLL_Group__c newSG: sllGroupLst) {
            if(newSG.PAM__c != null){
                pamSet.add(newSG.PAM__c);
            } else{
                newSG.addError('PAM is required.');
            }
        }

        Map<Id, User> pamMapUser = new Map<Id, User>([SELECT Id, ManagerId, Manager.IsActive FROM User WHERE Id IN:pamSet]);
        // Map<Id, User> pamMapUser = new Map<Id, User>([SELECT Id, ManagerId, Manager.IsActive, Manager.ManagerId, Manager.Manager.IsActive FROM User WHERE Id IN:pamSet]);

        for(SLL_Group__c newSG : sllGroupLst) {
            if(pamMapUser.containsKey(newSG.PAM__c)){
                if(String.isBlank(pamMapUser.get(newSG.PAM__c).ManagerId)) {
                // if(String.isBlank(pamMapUser.get(newSG.PAM__c).ManagerId) || String.isBlank(pamMapUser.get(newSG.PAM__c).Manager.ManagerId)) {
                    newSG.addError('Not found team head or group head above the PAM');
                } else if(!pamMapUser.get(newSG.PAM__c).Manager.IsActive) {
                // } else if(!pamMapUser.get(newSG.PAM__c).Manager.IsActive || !pamMapUser.get(newSG.PAM__c).Manager.Manager.IsActive) {
                    newSG.addError('TH or GH is inactive');
                }
            }
        }
    }
}