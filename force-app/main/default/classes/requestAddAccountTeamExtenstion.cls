public class requestAddAccountTeamExtenstion {
    private ApexPages.StandardController standardController;

    public User currentUser {
        get{
            if(currentUser == null){
                currentUser = [SELECT Id, Name, IsActive, Segment__c, managerid, manager.managerid, Profile.Name, Title, Zone__c FROM User Where Id = :userInfo.getUserId() AND isActive = true];
            }
            return currentUser;
        }
        set;
    }

    public Change_Owner_Approval_History__c currentChangeOwnerApproval{
        get{
            if(currentChangeOwnerApproval == null){
                try{
                    currentChangeOwnerApproval = [SELECT Id FROM Change_Owner_Approval_History__c WHERE Account__c = :accId AND Change_Owner_Approval_Status__c NOT IN ('Final Approved', 'Rejected', 'Recalled') LIMIT 1];
                }catch (Exception e) {
                    System.debug(e.getMessage());
                }
            }
            return currentChangeOwnerApproval;
        }
        set;
    }

    public Team_Role_Profile_Setting__mdt userTeamRoleProfileSetting {
        get{
            if(userTeamRoleProfileSetting == null){
                // try {
                    userTeamRoleProfileSetting = [SELECT Id, Profile_Name__c, Team_Role__c, Opportunity_Access__c, Case_Access__c, Account_Access__c
                                            FROM Team_Role_Profile_Setting__mdt 
                                            WHERE Profile_Name__c = :currentUser.Profile.Name LIMIT 1];
                // } catch (Exception e) {
                //     System.debug(e.getmessage());
                // }
            }
            return userTeamRoleProfileSetting;
        }
        set;
    }

    public String teamRoleProfile{
        get{
            if(teamRoleProfile == null){
                if(userTeamRoleProfileSetting != null){
                    teamRoleProfile = userTeamRoleProfileSetting.Team_Role__c;
                }
                // else{
                //     teamRoleProfile = 'Mr.Tay error message : Your profile not in Team_Role_Profile_Setting matrix.';
                // }
            }
            return teamRoleProfile;
        }
        set;
    }

    public Account acct {get;set;}

    public List<User> approvers {get;set;}

    public Boolean hasApprover {get;set;}
    public Boolean isInApprovalProcess {get;set;}

    public String errorMessage {get;set;}
    public String accId {get;set;}
    public String remark {get;set;}

    public requestAddAccountTeamExtenstion(ApexPages.StandardController ctrl) {
        System.debug('requestAddAccountTeamExtenstion :::');
        standardController = ctrl;

        hasApprover = false;
        isInApprovalProcess = false;
        
        errorMessage = 'abc';
        remark = '';

        approvers = new List<User>();

        accId = ctrl.getRecord().id;

        acct = [SELECT Id, Name, RecordType.Name, Change_to_be_owner_Name__c, OwnerId, Owner.IsActive, Owner.Profile.Name, Owner.ManagerId, Owner.Segment__c, Owner.Manager.ManagerId, Core_Banking_Suggested_Segment__c FROM Account WHERE Id = :accId];

        List<AccountTeamMember> acctTeamlst = [SELECT Id, AccountId, UserId, TeamMemberRole, AccountAccessLevel, OpportunityAccessLevel, CaseAccessLevel, IsDeleted 
            FROM AccountTeamMember 
            WHERE IsDeleted = false 
            AND AccountId = :accId
            AND UserId = :currentUser.Id LIMIT 1];
        
        List<ProcessInstanceWorkitem> piwi = new List<ProcessInstanceWorkitem>();

        if(currentChangeOwnerApproval != null){
            piwi = [SELECT Id, ProcessInstanceId, ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId = :currentChangeOwnerApproval.Id];
        }

        System.debug('piwi : ' + piwi);
        System.debug('acct : ' + acct);
        System.debug('currentChangeOwnerApproval : ' + currentChangeOwnerApproval);

        if(currentChangeOwnerApproval != null || piwi.size() > 0 || acct.Change_to_be_owner_Name__c != null){
            isInApprovalProcess = true;
        }else if(acctTeamlst.size() > 0){
            errorMessage = Label.RequestAccountteamMessage2;
        }else{
            User u = getSaleManageUserBySegment(currentUser.Segment__c);
            if(u == null || u.IsActive){
                hasApprover = true;
                approvers.add(u);
            }else{
                errorMessage = Label.ChangeOwnerMessage1;
            }
        }
    }

    private User getSaleManageUserBySegment(String segment){
        User u;
        try {
            Sales_Management__mdt saleManage2 = [SELECT Id, Label, EmployeeId__c, Segment__c FROM Sales_Management__mdt WHERE Segment__c = :segment];
            System.debug('saleManage2 : '  + saleManage2);
            u = [SELECT Id, Name, IsActive, Employee_ID__c, Zone__c, Title, Profile.Name FROM User Where Employee_ID__c = :saleManage2.EmployeeId__c];
            System.debug('u : '  + u);
        } catch (Exception e) {
            System.debug(e.getMessage());
            errorMessage = e.getMessage();
        }
        return u;
    }

    public PageReference confirmApprover(){
        if(remark.length() > 100000){
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Record can not be submitted due to Remark field has more than 100000 Characters.'));
            return null;
        }else{
            Change_Owner_Approval_History__c changeOwnerHistory = new Change_Owner_Approval_History__c();
            changeOwnerHistory.Account__c = accId;

            changeOwnerHistory.Approver1__c = Approvers.size() > 0 ? Approvers.get(0).Id : null;
            changeOwnerHistory.Approver1_Profile__c = Approvers.size() > 0 ? Approvers.get(0).Profile.Name : null;
            
            changeOwnerHistory.Approver2__c = Approvers.size() > 1 ? Approvers.get(1).Id : null;
            changeOwnerHistory.Approver2_Profile__c = Approvers.size() > 1 ? Approvers.get(1).Profile.Name : null;
            
            changeOwnerHistory.Approver3__c = Approvers.size() > 2 ? Approvers.get(2).Id : null;
            changeOwnerHistory.Approver3_Profile__c = Approvers.size() > 2 ? Approvers.get(2).Profile.Name : null;
            
            changeOwnerHistory.Approver4__c = Approvers.size() > 3 ? Approvers.get(3).Id : null;
            changeOwnerHistory.Approver4_Profile__c = Approvers.size() > 3 ? Approvers.get(3).Profile.Name : null;
            
            changeOwnerHistory.Current_Owner__c = acct.OwnerId; 
            changeOwnerHistory.Change_to_owner__c = currentUser.Id;

            System.debug('userTeamRoleProfileSetting : ' + userTeamRoleProfileSetting);
            changeOwnerHistory.Team_Role__c = userTeamRoleProfileSetting.Team_Role__c; 
            changeOwnerHistory.Account_Access__c = userTeamRoleProfileSetting.Account_Access__c; 
            changeOwnerHistory.Opportunity_Access__c = userTeamRoleProfileSetting.Opportunity_Access__c; 
            changeOwnerHistory.Case_Access__c = userTeamRoleProfileSetting.Case_Access__c; 
            //changeOwnerHistory.Change_Owner_Approval_Status__c = 'Pending for Approval';
            
            String preFixremark = '';

            // if(acct.Owner.Segment__c != currentUser.Segment__c && !specialProfile.contains(acct.Owner.Profile.Name)){
            //     preFixremark = 'Change owner cross segment from ' + acct.Owner.Segment__c + ' to ' + currentUser.Segment__c;
            // }else if(specialProfile.contains(acct.Owner.Profile.Name) && acct.Core_Banking_Suggested_Segment__c != currentUser.Segment__c ){
            //     preFixremark = 'Change owner cross segment from ' + acct.Core_Banking_Suggested_Segment__c + ' to ' + currentUser.Segment__c;
            // }else{
            //     preFixremark = 'Change owner within segment';
            // }

            changeOwnerHistory.Change_Owner_Remark__c = preFixremark == '' ? remark : preFixremark + ' : ' + remark;
            // changeOwnerHistory.Change_Owner_Remark__c = remark;

            RecordType rt = [SELECT id FROM recordType WHERE DeveloperName = 'Add_Account_Team'];
            changeOwnerHistory.RecordTypeId = rt.Id;

            Savepoint sp = Database.setSavepoint();
            //auto send submit for approval
            try{
                insert changeOwnerHistory;
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                // req.setComments(remark); 
                req.setObjectId(changeOwnerHistory.Id);
                Approval.ProcessResult result = Approval.process(req);
            }catch (Exception ex){
                Database.rollback(sp);
                System.debug(ex.getMessage());
                System.debug('Exception caught');
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
                return null;
            }
            
            PageReference acctPage = new ApexPages.StandardController(acct).view(); 
            acctPage.setRedirect(true);

            return acctPage;
        }
    }

    public PageReference cancelAction(){       
        return standardController.cancel();   
    }
}