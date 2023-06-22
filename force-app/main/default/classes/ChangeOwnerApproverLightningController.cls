public with sharing class ChangeOwnerApproverLightningController {
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

    public static Set<String> RMBDMProfiles{
        get{
            if(RMBDMProfiles == null){
                RMBDMProfiles = new Set<String>();
                
                AppConfig__c conf = AppConfig__c.getValues('RM/BDM Profile');

                if(conf != null && conf.Value__c != null){
                    for(String str : conf.Value__c.split(';')){
                        RMBDMProfiles.add(str);
                    }
                }else{
                    RMBDMProfiles.add('TMB ABDM Profile');
                    RMBDMProfiles.add('TMB BDM Profile');
                    RMBDMProfiles.add('TMB RM Profile');
                    RMBDMProfiles.add('TMB RMA Profile');
                    RMBDMProfiles.add('TMB BB RM Profile');
                    RMBDMProfiles.add('TMB BB ARM Profile');
                }
            }
            return RMBDMProfiles;
        }
        set;
    }

    public static Set<String> profilesToBeExistingCustApprover{
        get{
            if(profilesToBeExistingCustApprover == null){
                profilesToBeExistingCustApprover = new Set<String>();
                
                profilesToBeExistingCustApprover.addAll(RMBDMProfiles);

                AppConfig__c conf = AppConfig__c.getValues('Custbase Approver Profile');

                if(conf != null && conf.Value__c != null){
                    for(String str : conf.Value__c.split(';')){
                        profilesToBeExistingCustApprover.add(str);
                    }
                }else{
                    profilesToBeExistingCustApprover.add('TMB SE Zone Manager Profile');
                    profilesToBeExistingCustApprover.add('TMB SE Regional Manager Profile');
                    profilesToBeExistingCustApprover.add('TMB Team Head Profile');
                    profilesToBeExistingCustApprover.add('TMB BB Regional Manager Profile');
                }

            }
            return profilesToBeExistingCustApprover;
        }
        set;
    }

    public static Set<String> teamHeadProfilelst{
        get{
            if(teamHeadProfilelst == null){
                teamHeadProfilelst = new Set<String>();
                AppConfig__c conf = AppConfig__c.getValues('Custbase Approver Profile');

                if(conf != null && conf.Value__c != null){
                    for(String str : conf.Value__c.split(';')){
                        teamHeadProfilelst.add(str);
                    }
                }else{
                    teamHeadProfilelst.add('TMB SE Zone Manager Profile');
                    teamHeadProfilelst.add('TMB SE Regional Manager Profile');
                    teamHeadProfilelst.add('TMB Team Head Profile');
                    teamHeadProfilelst.add('TMB BB Regional Manager Profile');
                }
            }
            return teamHeadProfilelst;
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

    public static String invalidSMErrormsg{
        get{
            if(invalidSMErrormsg == null){
                invalidSMErrormsg = Label.ChangeOwnerMessage1;
            }
            return invalidSMErrormsg;
        }
        set;
    }

    public static String biTeamInactive{
        get{
            if(biTeamInactive == null){
                biTeamInactive = Label.CustBase_all_BI_Team_s_inactive;
            }
            return biTeamInactive;
        }
        set;
    }

    public static User currentUser {
        get{
            if(currentUser == null){
                currentUser = [SELECT Id, Name, IsActive, Segment__c, Zone_Code__c, managerid, manager.managerid, Profile.Name FROM User Where Id = :userInfo.getUserId() AND isActive = true];
            }
            return currentUser;
        }
        set;
    }

    public static Id reqChangeOwnerProspectId{
        get{
            if(reqChangeOwnerProspectId == null){
                reqChangeOwnerProspectId = Schema.Sobjecttype.Change_Owner_Approval_History__c.getRecordTypeInfosByName().get('Change Owner Qualified Prospect').getRecordTypeId();
            }
            return reqChangeOwnerProspectId;
        }
        set;
    }
    
    public static Id reqChangeOwnerExistingId{
        get{
            if(reqChangeOwnerExistingId == null){
                reqChangeOwnerExistingId = Schema.Sobjecttype.Change_Owner_Approval_History__c.getRecordTypeInfosByName().get('Change Owner Existing Customer').getRecordTypeId();
            }
            return reqChangeOwnerExistingId;
        }
        set;
    }

    public static User BITeam{
        get{
            if(BITeam == null){
                BITeam = new User(FirstName = 'BI Team', Zone__c = 'BI Zone', Title = 'Business Intelligence Team');
            }
            return BITeam;
        }set;
    }

    public static List<User> BITeamlst{
        get{
            if(BITeamlst == null){
                BITeamlst = new List<User>();
                Set<String> empIdset = new Set<String>();
                for(BI_Team__mdt BI : [SELECT Id, Employee_Id__c FROM BI_Team__mdt]){
                    empIdset.add(BI.Employee_Id__c);
                }
                BITeamlst = [SELECT Id, Name, IsActive, Zone__c, Title, Profile.Name FROM User WHERE Employee_ID__c IN :empIdset AND IsActive = true];
            }
            return BITeamlst;
        }set;
    }

    public class approverWraperClass {
        @AuraEnabled
        public String RowNumber {get;set;}
        @AuraEnabled
        public User Approver {get; set;}
    }

    @AuraEnabled
    public static Account getAccountDetail(Id AccId){
        System.debug('AccId : ' + AccId);
        return [SELECT Id, Name, Recordtype.Name, Change_to_be_segment__c, Segment_crm__c, OwnerId, Owner.Zone_Code__c, Owner.IsActive, Owner.Profile.Name, Owner.ManagerId, Owner.Manager.ManagerId, Core_Banking_Suggested_Segment__c FROM Account WHERE Id = :AccId LIMIT 1];
    }

    @AuraEnabled
    public static Account getRequestPermission(Id AccId){
        System.debug(AccId);
        Account acct = getAccountDetail(AccId);
        System.debug(acct);
        System.debug(currentUser.Profile.Name);

        if(acct.OwnerId == currentUser.Id){
            throwExcp('You are already an account owner.');
            // throw new AuraHandledException('You are already an account owner.');
        }

        // SELECT Id, Name, Recordtype.Name FROM Change_Owner_Approval_History__c WHERE (RecordtypeId = '0120o000001lVNxAAM' OR RecordtypeId = '0120o000001lVNnAAM') AND Account__c = '0011y00000ALJDSAA5' AND Change_Owner_Approval_Status__c NOT IN ('Final Approved', 'Rejected', 'Recalled')
        Map<Id, Change_Owner_Approval_History__c> currentChangeOwnerApproval = new Map<Id, Change_Owner_Approval_History__c>([SELECT Id FROM Change_Owner_Approval_History__c WHERE (RecordtypeId = :reqChangeOwnerProspectId OR RecordtypeId = :reqChangeOwnerExistingId) AND Account__c = :accId AND Change_Owner_Approval_Status__c NOT IN ('Final Approved', 'Rejected', 'Recalled')]);

        List<ProcessInstanceWorkitem> piwi = new List<ProcessInstanceWorkitem>();

        if(currentChangeOwnerApproval.size() > 0){
            piwi = [SELECT Id, ProcessInstanceId, ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId IN :currentChangeOwnerApproval.keySet()];
        }

        if(currentChangeOwnerApproval.size() > 0 && piwi.size() > 0){
            throw new AuraHandledException(Label.RequestChangeOwnerMessage2);
        }

        if(acct.RecordType.Name == 'Prospect' && !RMProfileListProspect.contains(currentUser.Profile.Name)){
            System.debug('Request Prospect::');
            throwExcp('Your Profile can not request owner from Qualified Prospect Customer.');
            // throw new AuraHandledException('Your Profile can not request owner from Qualified Prospect Customer.');
        }else if(acct.RecordType.Name == 'Existing Customer'){
            System.debug('Request Existing Customer::');
        }else if(acct.RecordType.Name != 'Prospect' && acct.RecordType.Name != 'Existing Customer'){
            System.debug('ERROR' + acct.RecordType.Name);
            throwExcp('Not support Customer record type.');
            // throw new AuraHandledException('Not support Customer record type.').setMessage('Not support Customer record type.');
        }
        return acct;
    }

    @AuraEnabled
    public static List<approverWraperClass> getApprover(Id AccId){
        List<approverWraperClass> result = new List<approverWraperClass>();
        List<User> Approvers = new List<User>();
        Account acct = getAccountDetail(AccId);

        if(acct.RecordType.Name == 'Prospect'){
            System.debug('Get Approver Prospect::');
            Approvers = getApproversProspect(acct);
        }else if(acct.RecordType.Name == 'Existing Customer'){
            System.debug('Request Existing Customer::');
            Approvers = getApproversExisting(acct);
        }else{
            // System.debug('ERROR' + acct.RecordType.Name);
            throwExcp('Not support Customer record type.');
            // throw new AuraHandledException('Not support Customer record type.');
        }

        // System.debug('Approvers : ' + Approvers);
        
        if(Approvers != null && Approvers.size() > 0){
            Integer i = 0 ;
            for(User appver : Approvers){
                i += 1;
                approverWraperClass appverWrap = new approverWraperClass();
                appverWrap.RowNumber = 'Approver ' + i;
                appverWrap.Approver = appver;
                result.add(appverWrap);
            }
        }else{
            // System.debug('invalidSMErrormsg : ' + invalidSMErrormsg);
            throw new AuraHandledException('No approver available.');
        }

        return result;
    }

    @AuraEnabled
    public static Boolean submitRequest(Id accId, String remark, Object approvelst){
        List<approverWraperClass> approvers = (List<approverWraperClass>) JSON.deserialize(JSON.serialize(approvelst), List<approverWraperClass>.class);
        System.debug(approvers);

        Account acct = getAccountDetail(AccId);
        Change_Owner_Approval_History__c changeOwnerHistory = new Change_Owner_Approval_History__c();

        if(acct.RecordType.Name == 'Prospect'){
            changeOwnerHistory.RecordTypeId = reqChangeOwnerProspectId;
        }else if(acct.RecordType.Name == 'Existing Customer'){
            changeOwnerHistory.RecordTypeId = reqChangeOwnerExistingId;
        }
        
        changeOwnerHistory.Account__c = accId;

        for(Integer i = 0 ; i < approvers.size() ; i ++){
            System.debug(approvers[i].Approver);
            if(approvers[i].Approver.Name == 'BI Team'){
                System.debug('Add BI Team');
               	changeOwnerHistory.BI_Flag__c = true;

                for(Integer bi = 0 ; bi < BITeamlst.size() ; bi++){
                    Integer binum = bi + 1;
                    changeOwnerHistory.put('BI_' + binum + '__c', BITeamlst[bi].Id);
                }
            }

            Integer num = i + 1;
            changeOwnerHistory.put('Approver' + num + '__c', approvers[i].Approver.Id);
            changeOwnerHistory.put('Approver' + num + '_Profile__c', approvers[i].Approver.Profile.Name);
        }
        
        changeOwnerHistory.Change_to_owner__c = currentUser.Id;
        changeOwnerHistory.Current_Owner__c = acct.OwnerId; 

        if(mapsubSegmentMapping.containsKey(currentUser.Zone_Code__c)){
            String prefixSubseg = acct.Change_to_be_segment__c == null ? acct.Segment_crm__c : acct.Change_to_be_segment__c == 'MB' ? '1' : acct.Change_to_be_segment__c == 'CB' ? '2' : acct.Change_to_be_segment__c == 'BB' ? '3' : acct.Change_to_be_segment__c == 'SE' ? '4' : acct.Segment_crm__c;
            changeOwnerHistory.To_Be_Sub_Segment__c = prefixSubseg + mapsubSegmentMapping.get(currentUser.Zone_Code__c).Sub_Segment_Code__c;
        }

        changeOwnerHistory.Change_Owner_Remark__c = remark;

        System.debug(changeOwnerHistory);

        Savepoint sp = Database.setSavepoint();
        try{
            insert changeOwnerHistory;
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setObjectId(changeOwnerHistory.Id);
            Approval.ProcessResult result = Approval.process(req);
        }
        catch (Exception e){
            Database.rollback(sp);
            System.debug('Exception caught');
            System.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        } 
        return true;
    }

    public static List<User> getApproversProspect(Account acct){
        List<User> result = new List<User>();

        User u = [SELECT Id, Name, IsActive, Zone__c, Title, Segment__c, Profile.Name FROM User WHERE Id = :acct.OwnerId LIMIT 1];

        System.debug('u : ' + u);
        
        if(u.Profile.Name == 'System Administrator' || u.Profile.Name == 'App External API'){
            User SMuser = getSaleManageUserBySegment(currentUser.Segment__c);
            if(SMuser?.IsActive == true){
                result.add(SMuser);
            }else{
                throw new AuraHandledException(invalidSMErrormsg);
            }
        }else if(u.IsActive){
            result.add(u);
        }else {
            User SMuser;

            if(u.Segment__c != null){
                User SMtemp = getSaleManageUserBySegment(u.Segment__c);
                if(SMtemp.IsActive){
                    SMuser = SMtemp;
                }
            }else if(currentUser.Segment__c != null){
                User SMtemp = getSaleManageUserBySegment(currentUser.Segment__c);
                if(SMtemp.IsActive){
                    SMuser = SMtemp;
                }
            }

            if(SMuser != null){
                result.add(SMuser);
            }else{
                throw new AuraHandledException(invalidSMErrormsg);
            }
        }
        return result;
    }

    public static List<User> getApproversExisting(Account acct){
        List<User> result  = new List<User>();
        List<Id> appverIdlst = new List<Id>();
        Map<Id, User> appverMapIdUser = new Map<Id, User>();

        appverIdlst.add(acct.OwnerId);
        appverIdlst.add(acct.Owner.ManagerId);
        appverIdlst.add(acct.Owner.Manager.ManagerId);

        appverMapIdUser = getUserFromlist(appverIdlst);

        User user1 = appverMapIdUser.get(appverIdlst[0]);
        User user2 = appverMapIdUser.get(appverIdlst[1]);
        User user3 = appverMapIdUser.get(appverIdlst[2]);

        System.debug('user1 : ' + user1);
        System.debug('user2 : ' + user2);
        System.debug('user3 : ' + user3);

        if(RMBDMProfiles.contains(acct.Owner.Profile.Name) && user1 != null && user1.IsActive){
            result.add(user1);
            if(user2 != null && user2.IsActive) result.add(user2);
            if(result.size() < 2 && user3 != null && user3.IsActive) result.add(user3);
            if(result.size() < 2){
                if(BITeamlst.size() > 0){
                    result.add(BITeam);//Add BI team;
                }else{
                    throw new AuraHandledException(biTeamInactive);
                }
            }
        }else if(RMBDMProfiles.contains(acct.Owner.Profile.Name) && !user1.IsActive){
            if(user2 != null && user2.IsActive) result.add(user2);
            if(result.size() < 1 && user3 != null && user3.IsActive) result.add(user3);
            if(result.size() < 1){
                if(BITeamlst.size() > 0){
                    result.add(BITeam);//Add BI team;
                }else{
                    throw new AuraHandledException(biTeamInactive);
                }
            }
        }else if(teamHeadProfilelst.contains(acct.Owner.Profile.Name) && user1.IsActive){
            result.add(user1);
        }else if(acct.Owner.Profile.Name == 'TMB SE Zone Manager Profile' && !user1.IsActive && user2.IsActive){
            result.add(user2);
        }else{
            if(BITeamlst.size() > 0){
                result.add(BITeam);//Add BI team;
            }else{
                throw new AuraHandledException(biTeamInactive);
            }
        }

        return result;
    }

    public static Map<Id, User> getUserFromlist(List<Id> appverIdlst){
        Map<Id, User>  userlst = new Map<Id, User> ();
        System.debug('appverIdlst : '  + appverIdlst);
        userlst = new Map<Id, User>([SELECT Id, Name, IsActive, Zone__c, Title, Profile.Name FROM User WHERE Id IN :appverIdlst AND Profile.Name IN :profilesToBeExistingCustApprover]);
        return userlst;
    }

    public static User getSaleManageUserBySegment(String segment){
        User u;
        try {
            Sales_Management__mdt saleManage2 = [SELECT Id, Label, EmployeeId__c, Segment__c FROM Sales_Management__mdt WHERE Segment__c = :segment];
            u = [SELECT Id, Name, IsActive, Employee_ID__c, Zone__c, Title, Profile.Name FROM User WHERE Employee_ID__c = :saleManage2.EmployeeId__c];
        } catch (Exception e) {
            System.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        return u;
    }

    public static void throwExcp(String msg){
        AuraHandledException e = new AuraHandledException(msg);
        e.setMessage(msg);
        throw e;   
    }
}