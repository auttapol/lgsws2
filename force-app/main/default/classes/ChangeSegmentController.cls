public class ChangeSegmentController {

    public static Set<String> RMProfileListProspect{
        get{
            if(RMProfileListProspect == null){
                RMProfileListProspect = new Set<String>();
                RMProfileListProspect.add('TMB BDM Profile');
                RMProfileListProspect.add('TMB RM Profile');
                RMProfileListProspect.add('TMB RMA Profile');
                RMProfileListProspect.add('TMB BB RM Profile');
                RMProfileListProspect.add('TMB BB ARM Profile');
                RMProfileListProspect.add('System Administrator');
            }
            return RMProfileListProspect;
        }
        set;
    }

    public static List<BI_Team__mdt> BI_Employee_ID{
        get{
            if(BI_Employee_ID == null){
                BI_Employee_ID = [SELECT Employee_Id__c FROM BI_Team__mdt];
            }
            return BI_Employee_ID;
        }set;
    }

    public static List<User> BITeam{
        get{
            if(BITeam == null){
                List<String> Employee_ID = new List<String>();
                for (BI_Team__mdt BI_ID : BI_Employee_ID) {
                    Employee_ID.add(BI_ID.Employee_Id__c);
                }
                BITeam = [SELECT id , Name, IsActive FROM User WHERE IsActive = true AND Employee_Id__c IN :Employee_ID];
            }
            return BITeam;
        }set;
    }
    public static User currentUser {
        get{
            if(currentUser==null){
                currentUser = [SELECT Id, Name, IsActive, Segment__c, managerid, manager.managerid, Profile.Name FROM User Where Id = :userInfo.getUserId() AND isActive = true];
            }
            return currentUser;
        }
        set;
    }
    
    public static map<String, Sub_Segment_Mapping__c> mapsubSegmentMapping {
        get{
            if(mapsubSegmentMapping == null){
                mapsubSegmentMapping = new map<String, Sub_Segment_Mapping__c>();
                for(Sub_Segment_Mapping__c subSegmap : [SELECT Id, Region_Group__c, Region_Code_Group_Code__c, Zone_Team__c, Zone_Code_Team_Code__c, Sub_Segment_Code__c FROM Sub_Segment_Mapping__c]){
                    mapsubSegmentMapping.put(subSegmap.Zone_Code_Team_Code__c, subSegmap);
                }
            }
            return mapsubSegmentMapping;
        }set;
    }

    public static Id reqChangeSegmentId{
        get{
            if(reqChangeSegmentId == null){
                reqChangeSegmentId = Schema.Sobjecttype.Change_Owner_Approval_History__c.getRecordTypeInfosByName().get('Change Segment').getRecordTypeId();
            }
            return reqChangeSegmentId;
        }
        set;
    }

    public class wrapperClass{
        @AuraEnabled 
        public Account acctRec{get; set;}
        @AuraEnabled 
        public boolean checkApprove{get; set;}
        @AuraEnabled 
        public Boolean permission {get; set;}
    }
    
    @AuraEnabled
    public static wrapperClass getAcctRec(String accountId) {
        wrapperClass thisRec = new wrapperClass();
        thisRec.permission = false;
        thisRec.acctRec = new Account();
        Account acct = new Account();
        boolean checkApprove = false;
        if(BITeam == null || BITeam.size() == 0){
            AuraHandledException e = new AuraHandledException('All BI Team user are inactive, please contact CRM admin.');
            e.setMessage('All BI Team user are inactive, please contact CRM admin.');
            throw e;  
        }
        if (RMProfileListProspect.contains(currentUser.Profile.Name)) {
            thisRec.permission = true;
        }else {
            return thisRec;
        }
        Change_Owner_Approval_History__c currentChangeOwnerApproval = new Change_Owner_Approval_History__c();
        acct = [SELECT Id, Name, RecordType.Name, Change_to_be_owner_Name__c, 
        OwnerId, Owner.IsActive, Owner.Profile.Name, Owner.ManagerId, Owner.Segment__c, 
        Owner.Manager.ManagerId, Core_Banking_Suggested_Segment__c FROM Account WHERE Id = :accountId];

        
        try{
            currentChangeOwnerApproval = [SELECT Id FROM Change_Owner_Approval_History__c WHERE RecordtypeId = :reqChangeSegmentId AND Account__c = :accountId AND Change_Owner_Approval_Status__c NOT IN ('Final Approved', 'Rejected', 'Recalled') LIMIT 1];
        }
        catch (Exception ex){
            System.debug(ex.getMessage());
            System.debug('Exception caught');
        }
        List<ProcessInstanceWorkitem> piwi = new List<ProcessInstanceWorkitem>();

        if(currentChangeOwnerApproval != null){
            piwi = [SELECT Id, ProcessInstanceId, ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId = :currentChangeOwnerApproval.Id];
        }
        if(piwi.size() > 0){
            checkApprove = true;
        }
        thisRec.checkApprove = checkApprove;
        thisRec.acctRec = acct;
        return thisRec;
    }

    @AuraEnabled
    public static void saveRecord(String accountId,String newSegment,String remark){
        Change_Owner_Approval_History__c changeOwnerHistory = new Change_Owner_Approval_History__c();
        Account acctRec = [SELECT Name,Core_Banking_Suggested_Segment__c,OwnerId FROM Account WHERE id = :accountId];
        changeOwnerHistory.RecordTypeId = Schema.Sobjecttype.Change_Owner_Approval_History__c.getRecordTypeInfosByName().get('Change Segment').getRecordTypeId();
        changeOwnerHistory.Current_Segement__c = acctRec.Core_Banking_Suggested_Segment__c;
        changeOwnerHistory.To_Be_New_Segment__c = newSegment;
        changeOwnerHistory.Change_Owner_Remark__c = remark;
        changeOwnerHistory.Account__c = accountId;
        changeOwnerHistory.BI_Flag__c = true;
        changeOwnerHistory.Current_Owner__c = acctRec.OwnerId;
        changeOwnerHistory.Change_to_owner__c = userInfo.getUserId();
        for (User BI : BITeam) {
            if(changeOwnerHistory.BI_1__c == null){
                changeOwnerHistory.BI_1__c = BI.id;
            }else if(changeOwnerHistory.BI_2__c == null){
                changeOwnerHistory.BI_2__c = BI.id;
            }else if(changeOwnerHistory.BI_3__c == null){
                changeOwnerHistory.BI_3__c = BI.id;
            }else if(changeOwnerHistory.BI_4__c == null){
                changeOwnerHistory.BI_4__c = BI.id;
            }
        }
        calculateSubSegment(changeOwnerHistory,acctRec.OwnerId);
        Savepoint sp = Database.setSavepoint();

        try{
            insert changeOwnerHistory;
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setObjectId(changeOwnerHistory.Id);
            Approval.ProcessResult result = Approval.process(req);
        }catch (Exception e){
            Database.rollback(sp);
            System.debug('Exception caught');
            System.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        } 
    }

    public static void calculateSubSegment(Change_Owner_Approval_History__c changeOwnerHistory,String OwnerId){
        User u = [SELECT Id, Zone_Code__c FROM User WHERE Id = :OwnerId AND isActive = true];
        String ownerZoneCode = u?.Zone_Code__c;
        String prefixSubseg = changeOwnerHistory.To_Be_New_Segment__c == null ? '0' : changeOwnerHistory.To_Be_New_Segment__c == 'MB' ? '1' : changeOwnerHistory.To_Be_New_Segment__c == 'CB' ? '2' : changeOwnerHistory.To_Be_New_Segment__c == 'BB' ? '3' : changeOwnerHistory.To_Be_New_Segment__c == 'SE' ? '4' : 'x';

        changeOwnerHistory.To_Be_Sub_Segment__c = mapsubSegmentMapping.containsKey(ownerZoneCode) ? prefixSubseg + mapsubSegmentMapping.get(ownerZoneCode).Sub_Segment_Code__c : prefixSubseg + '00';

        System.debug(changeOwnerHistory.To_Be_Sub_Segment__c);
    }
}