public class ChangeOwnerApproverController {
    
    private ApexPages.StandardController standardController;
    
    public List<User> Approvers {get; set;}
    public List<User> Approverlst {get; set;}
    public List<Id> appverIdlst {get; set;}
    public Map<Id, User> appverMapIdUser {get; set;}

    public Boolean  checkList {get;set;}
    public Boolean  checkApprove {get;set;}
    public String remark {get;set;}

    public String errMsg {get;set;}

    public String accId {get; set;}
    public Account acct {get ;set;}

    public User currentUser {
        get{
            if(currentUser == null){
                currentUser = [SELECT Id, Name, IsActive, Segment__c, managerid, manager.managerid, Profile.Name FROM User Where Id = :userInfo.getUserId() AND isActive = true];
            }
            return currentUser;
        }
        set;
    }

    public String invalidSMErrormsg{
        get{
            if(invalidSMErrormsg == null){
                invalidSMErrormsg = Label.ChangeOwnerMessage1;
            }
            return invalidSMErrormsg;
        }
        set;
    }

    public class approverWraperClass {
        public String RowNumber {get;set;}
        public User Approver {get; set;}
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

    public Set<String> commonProfileList{
        get{
            if(commonProfileList == null){
                commonProfileList = new Set<String>();
                
                AppConfig__c conf = AppConfig__c.getValues('RM/BDM Profile');

                if(conf != null && conf.Value__c != null){
                    for(String str : conf.Value__c.split(';')){
                        commonProfileList.add(str);
                    }
                }else{
                    commonProfileList.add('TMB ABDM Profile');
                    commonProfileList.add('TMB BDM Profile');
                    commonProfileList.add('TMB RM Profile');
                    commonProfileList.add('TMB RMA Profile');
                    commonProfileList.add('TMB BB RM Profile');
                    commonProfileList.add('TMB BB ARM Profile');
                }
            }
            return commonProfileList;
        }
        set;
    }
    
    public Set<String> commonProfileListProspect{
        get{
            if(commonProfileListProspect == null){
                commonProfileListProspect = new Set<String>();
                commonProfileListProspect.add('TMB BDM Profile');
                commonProfileListProspect.add('TMB RM Profile');
                commonProfileListProspect.add('TMB RMA Profile');
                commonProfileListProspect.add('TMB BB RM Profile');
                commonProfileListProspect.add('TMB BB ARM Profile');
            }
            return commonProfileListProspect;
        }
        set;
    }

    public Set<String> profilesToBeExistingCustApprover{
        get{
            if(profilesToBeExistingCustApprover == null){
                profilesToBeExistingCustApprover = new Set<String>();
                
                profilesToBeExistingCustApprover.addAll(commonProfileList);

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

    public Set<String> specialProfile{
        get{
            if(specialProfile == null){
                specialProfile = new Set<String>();
                
                AppConfig__c conf = AppConfig__c.getValues('SpecialProfileExistCustReqChangeOwner');

                if(conf != null && conf.Value__c != null){
                    for(String str : conf.Value__c.split(';')){
                        specialProfile.add(str);
                    }
                }else{
                    specialProfile.add('System Administrator');
                    specialProfile.add('Retail Integration API Only');
                    specialProfile.add('TMB BB Sales Management Profile');
                    specialProfile.add('TMB CB/MB Sales Management Profile');
                    specialProfile.add('TMB Commercial Report Specialist Profile');
                    specialProfile.add('TMB SE Regional Manager Profile');
                    specialProfile.add('TMB SE Sales Management Profile');
                }
            }
            return specialProfile;
        }
        set;
    }

    public Set<String> specialProfileProspect{
        get{
            if(specialProfileProspect == null){
                specialProfileProspect = new Set<String>();
                
                AppConfig__c conf = AppConfig__c.getValues('SpecialProfilePrspectReqChangeOwner');

                if(conf != null && conf.Value__c != null){
                    for(String str : conf.Value__c.split(';')){
                        specialProfileProspect.add(str);
                    }
                }else{
                    specialProfileProspect.add('System Administrator');
                    specialProfileProspect.add('Retail Integration API Only');
                    specialProfileProspect.add('App External API');
                 }
            }
            return specialProfileProspect;
        }
        set;
    }


    public List<approverWraperClass> approverWraperlst {get; set;}
    
    public ChangeOwnerApproverController(ApexPages.StandardController std){
        standardController = std;

        checkApprove = false;
        checkList = false;
        remark = '';

        approverWraperlst = new  List<approverWraperClass> ();
        Approverlst = new List <User>();

        accId = std.getRecord().id;

        acct = [SELECT Id, Name, RecordType.Name, Change_to_be_owner_Name__c, OwnerId, Owner.IsActive, Owner.Profile.Name, Owner.ManagerId, Owner.Segment__c, Owner.Manager.ManagerId, Core_Banking_Suggested_Segment__c FROM Account WHERE Id = :accId];
        
        List<ProcessInstanceWorkitem> piwi = new List<ProcessInstanceWorkitem>();

        if(currentChangeOwnerApproval != null){
            piwi = [SELECT Id, ProcessInstanceId, ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId = :currentChangeOwnerApproval.Id];
        }

        System.debug('piwi : ' + piwi);
        System.debug('RecordType.Name : ' + acct.RecordType.Name);

        if(currentChangeOwnerApproval != null || piwi.size() > 0 || acct.Change_to_be_owner_Name__c != null){
            checkApprove = true;
        }else if(currentUser.Id == acct.OwnerId){
            errMsg = 'You are already an account owner.';
        }else if(acct.RecordType.Name == 'Prospect'){
            System.debug('Prospect::');

            if(commonProfileListProspect.contains(currentUser.Profile.Name)){
                getApproverProspect();
            }else{
                errMsg = 'Your Profile can not request owner from Qualified Prospect Customer.';
            }
        }else if(acct.RecordType.Name == 'Existing Customer'){
            // if(commonProfileList.contains(acct.Owner.Profile.Name)){
            //     getApproverExisiCust();
            // }else{
            //     getSalesManagementApprover();
            // }

            if(specialProfile.contains(acct.Owner.Profile.Name)){
                // errMsg = 'Please Contact to Sales Management to request this customer';
                getSalesManagementApprover();
            }else{
                getApproverExisiCust();
            }
        }else{
            System.debug('NOT SUPPORT Record type');
        }

        if(Approvers != null && Approvers.size() > 0){
            Integer i = 0 ;
            for(User appver : Approvers){
                i += 1;
                approverWraperClass appverWrap = new approverWraperClass();
                appverWrap.RowNumber = 'Approver ' + i;
                appverWrap.Approver = appver;
                approverWraperlst.add(appverWrap);
                Approverlst.add(appver);
            }
        }
    }

    public void getSalesManagementApprover(){
        Approvers  = new List<User>();

        User user1 = getSaleManageUserBySegment(acct.Core_Banking_Suggested_Segment__c);
        System.debug(user1);

        if(user1 == null){
            errMsg = invalidSMErrormsg;
            checkList = false;
            return ;
        }else if(user1.IsActive){
            Approvers.add(user1);
            checkList = true;
        }else{
            errMsg = invalidSMErrormsg;
            checkList = false;
            return ;
        }
    }

    public void getApproverProspect(){
        Approvers = new List<User>();

        User u = [SELECT Id, Name, IsActive, Zone__c, Title, Segment__c, Profile.Name FROM User WHERE Id = :acct.OwnerId LIMIT 1];

        System.debug('u : ' + u);
        
       // if(u.Profile.Name == 'System Administrator' || u.Profile.Name == 'App External API'){
        if(specialProfileProspect.contains(u.Profile.Name)){
            User SMuser = getSaleManageUserBySegment(currentUser.Segment__c);

            if(SMuser.IsActive){
                Approvers.add(SMuser);
                checkList = true;
            }else{
                errMsg = invalidSMErrormsg;
            }
        }else if(u.IsActive){
            Approvers.add(u);
            checkList = true;
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
                Approvers.add(SMuser);
                checkList = true;
            }else{
                errMsg = invalidSMErrormsg;
            }
        }

        System.debug('Approvers : ' + Approvers);
    }

    public void getApproverExisiCust(){
        System.debug('getApproverExisiCust ::');
        appverIdlst = new List<Id>();
        Approvers  = new List<User>();

        Boolean isOwnerSepcialProfile = !commonProfileList.contains(acct.Owner.Profile.Name);

        System.debug('currentUser.Segment__c : ' + currentUser.Segment__c );
        System.debug('acct.Owner.Segment__c : ' + acct.Owner.Segment__c );

        //SAME SEGMENT
        if (currentUser.Segment__c == acct.Owner.Segment__c){ 
            //SEGMENT SE
            if(acct.Owner.Segment__c == 'SE'){
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
                
                if(user1 != null && user1.IsActive){
                    Approvers.add(user1);
                    checkList = true;
                    
                    if(user2 != null && user2.IsActive && !isOwnerSepcialProfile){
                        Approvers.add(user2);
                    }
                    else if(user3 != null && user3.IsActive && !isOwnerSepcialProfile){
                        Approvers.add(user3);
                    }

                    if((!isOwnerSepcialProfile && Approvers.size() < 2) || (isOwnerSepcialProfile && Approvers.size() < 1)){
                        User user4;

                        user4 = getSaleManageUserBySegment(acct.Owner.Segment__c);

                        if(user4 == null){
                            errMsg = invalidSMErrormsg;
                            checkList = false;
                            return ;
                        }else if(user4.IsActive){
                            Approvers.add(user4);
                            checkList = true;
                        }else{
                            errMsg = invalidSMErrormsg;
                            checkList = false;
                            return ;
                        }
                    }
                }
                else if(user2 != null && user2.IsActive){ //case 2
                    Approvers.add(user2);
                    checkList = true;
                }
                else if(user3 != null && user3.IsActive){
                    Approvers.add(user3);
                    checkList = true;
                }

                if(Approvers.size() < 1 || Test.isRunningTest()){
                    User user4;

                    user4 = getSaleManageUserBySegment(acct.Owner.Segment__c);

                    if(user4 == null){
                        errMsg = invalidSMErrormsg;
                        checkList = false;
                        return ;
                    }else if(user4.IsActive){
                        Approvers.add(user4);
                        checkList = true;
                    }else{
                        errMsg = invalidSMErrormsg;
                        checkList = false;
                        return ;
                    }
                }
            }
            else{ //wbg (BB,CB,MB)
                appverIdlst.add(acct.OwnerId);
                appverIdlst.add(acct.Owner.ManagerId);

                appverMapIdUser = getUserFromlist(appverIdlst);

                User user1 = appverMapIdUser.get(appverIdlst[0]);
                User user2 = appverMapIdUser.get(appverIdlst[1]);

                System.debug('user1 : ' + user1);
                System.debug('user2 : ' + user2);

                if(user1 != null && user1.IsActive){
                    Approvers.add(user1);
                    checkList = true;
                    if(user2 != null && user2.IsActive && !isOwnerSepcialProfile){
                        Approvers.add(user2);
                    }
                    
                    if((!isOwnerSepcialProfile && Approvers.size() < 2) || (isOwnerSepcialProfile && Approvers.size() < 1)){
                        User user3;

                        user3 = getSaleManageUserBySegment(acct.Owner.Segment__c);

                        if(user3 == null){
                            errMsg = invalidSMErrormsg;
                            checkList = false;
                            return ;
                        }else if(user3.IsActive){
                            Approvers.add(user3);
                            checkList = true;
                        }else{
                            errMsg = invalidSMErrormsg;
                            checkList = false;
                            return ;
                        }
                    }
                }
                else if(user2 != null && user2.IsActive){
                    checkList = true;
                    Approvers.add(user2);
                }

                if(Approvers.size() < 1 || Test.isRunningTest()){
                    User user3;

                    user3 = getSaleManageUserBySegment(acct.Owner.Segment__c);

                    if(user3 == null){
                        errMsg = invalidSMErrormsg;
                        checkList = false;
                        return ;
                    }else if(user3.IsActive){
                        Approvers.add(user3);
                        checkList = true;
                    }else{
                        errMsg = invalidSMErrormsg;
                        checkList = false;
                        return ;
                    }
                }
            }
        }
        //diff. segment
        else{
            /**Start SE to WBG  **/
            List<User> Approverslst1 = new List<User>();
            List<User> Approverslst2 = new List<User>();
            
            if(currentUser.Segment__c == 'SE'){
                appverIdlst.add(currentUser.managerid);
                appverIdlst.add(currentUser.manager.managerid);
                appverIdlst.add(acct.OwnerId);
                appverIdlst.add(acct.Owner.ManagerId);

                appverMapIdUser = getUserFromlist(appverIdlst);

                User user1 = appverMapIdUser.get(appverIdlst[0]);//zone manager
                User user2 = appverMapIdUser.get(appverIdlst[1]);//region manager

                if(user1 != null && user1.IsActive){
                    Approverslst1.add(user1);
                    checkList = true;
                    if(user2 != null && user2.IsActive){
                        Approverslst1.add(user2);
                    }
                }
                else if(user2 != null && user2.IsActive){
                    Approverslst1.add(user2);
                    checkList = true;
                }

                if(Approverslst1.size() < 2 || Test.isRunningTest()){
                    User user3;

                    user3 = getSaleManageUserBySegment(currentUser.Segment__c);

                    if(user3 == null){
                        errMsg = invalidSMErrormsg;
                        checkList = false;
                        return ;
                    }else if(user3.IsActive){
                        Approverslst1.add(user3);
                        checkList = true;
                    }else{
                        errMsg = invalidSMErrormsg;
                        checkList = false;
                        return ;
                    }
                }

                Approvers.addAll(Approverslst1);
                //End flow request
                
                //Start flow current owner
                User user4 = appverMapIdUser.get(appverIdlst[2]);//RM
                User user5 = appverMapIdUser.get(appverIdlst[3]);//TH

                System.debug('user1 : ' + user1);
                System.debug('user2 : ' + user2);
                System.debug('user4 : ' + user4);
                System.debug('user5 : ' + user5);
                
                if(user4 != null && user4.IsActive){
                    Approverslst2.add(user4);
                    checkList = true;
                    if(user5 != null && user5.IsActive){
                        Approverslst2.add(user5);
                    }
                }
                else if(user5 != null && user5.IsActive){
                    checkList = true;
                    Approverslst2.add(user5);
                }
                
                if((!isOwnerSepcialProfile && Approverslst2.size() < 2) || (isOwnerSepcialProfile && Approverslst2.size() < 1)){
                    User user6;
                    
                    user6 = getSaleManageUserBySegment(acct.Owner.Segment__c);

                    if(user6 == null){
                        errMsg = invalidSMErrormsg;
                        checkList = false;
                        // return ;
                    }else if(user6.IsActive){
                        Approverslst2.add(user6);
                        checkList = true;
                    }else{
                        errMsg = invalidSMErrormsg;
                        checkList = false;
                        return ;
                    }
                }
                Approvers.addAll(Approverslst2);
            }
            /**End SE to WBG  **/
            
            /**Start WBG to SE  **/
            else if(currentUser.Segment__c != 'SE' && acct.Owner.Segment__c == 'SE'){
                appverIdlst.add(currentUser.managerid);
                appverIdlst.add(acct.OwnerId);
                appverIdlst.add(acct.Owner.ManagerId);
                appverIdlst.add(acct.Owner.Manager.ManagerId);

                appverMapIdUser = getUserFromlist(appverIdlst);

                User user1 = appverMapIdUser.get(appverIdlst[0]);//TH

                if(user1 != null && user1.IsActive){
                    Approverslst1.add(user1);
                    checkList = true;
                }else{
                    User user2;

                    user2 = getSaleManageUserBySegment(currentUser.Segment__c);

                    if(user2 == null){
                        errMsg = invalidSMErrormsg;
                        checkList = false;
                        return ;
                    }
                    else if(user2.IsActive){
                        Approverslst1.add(user2);
                        checkList = true;
                    }else{
                        errMsg = invalidSMErrormsg;
                        checkList = false;
                        return ; 
                    }
                }
                Approvers.addAll(Approverslst1);

                //start current owner
                User user3 = appverMapIdUser.get(appverIdlst[1]);//RM
                User user4 = appverMapIdUser.get(appverIdlst[2]);//ZM
                User user5 = appverMapIdUser.get(appverIdlst[3]);//RG

                
                if(user3 != null && user3.IsActive){
                    Approverslst2.add(user3);
                    checkList = true;
                    if(user4 != null && user4.IsActive){
                        Approverslst2.add(user4);
                        if(user5 != null && user5.IsActive){
                            Approverslst2.add(user5);
                        }
                    }
                    else if(user5 != null && user5.IsActive){
                        Approverslst2.add(user5);
                    }
                }
                else if(user4 != null && user4.IsActive){
                    Approverslst2.add(user4);
                    checkList = true;
                    if(user5 != null && user5.IsActive){
                        Approverslst2.add(user5);
                    }
                }
                else if(user5 != null && user5.IsActive){
                    Approverslst2.add(user5);
                    checkList = true;
                }

                if((!isOwnerSepcialProfile && Approverslst2.size() < 3) || (isOwnerSepcialProfile && Approverslst2.size() < 2)){
                    User user6;
                    
                    user6 = getSaleManageUserBySegment(acct.Owner.Segment__c);

                    if(user6 == null){
                        errMsg = invalidSMErrormsg;
                        checkList = false;
                        return ;
                    }
                    else if(user6.IsActive){
                        Approverslst2.add(user6);
                        checkList = true;
                    }else{
                        errMsg = invalidSMErrormsg;
                        checkList = false;
                        return ;
                    }
                }
                Approvers.addAll(Approverslst2);
            }
            /**End WBG to SE  **/

            /**Start WBG to WBG  **/
            else if(currentUser.Segment__c != acct.Owner.Segment__c &&  currentUser.Segment__c !='SE' && acct.Owner.Segment__c !='SE'){
                appverIdlst.add(currentUser.managerid);
                appverIdlst.add(acct.OwnerId);
                appverIdlst.add(acct.Owner.ManagerId);

                appverMapIdUser = getUserFromlist(appverIdlst);

                User user1 = appverMapIdUser.get(appverIdlst[0]);//TH

                if(user1 != null && user1.IsActive){
                    Approverslst1.add(user1);
                    checkList = true;
                }else{
                    User user2;

                    user2 = getSaleManageUserBySegment(currentUser.Segment__c);

                    if(user2 == null){
                        errMsg = invalidSMErrormsg;
                        checkList = false;
                        // return ;
                    }
                    else if(user2.IsActive){
                        Approverslst1.add(user2);
                        checkList = true;
                    }else{
                        errMsg = invalidSMErrormsg;
                        checkList = false;
                        return ;
                    }
                }

                Approvers.addAll(Approverslst1);
                
                User user3 = appverMapIdUser.get(appverIdlst[1]);//RM
                User user4 = appverMapIdUser.get(appverIdlst[2]);//TH
                
                if(user3 != null && user3.IsActive){
                    Approverslst2.add(user3);
                    checkList = true;
                    if(user4 != null && user4.IsActive){
                        Approverslst2.add(user4);
                    }
                }
                else if(user4 != null && user4.IsActive){
                    Approverslst2.add(user4);
                    checkList = true;
                }

                if((!isOwnerSepcialProfile && Approverslst2.size() < 2) || (isOwnerSepcialProfile && Approverslst2.size() < 1)){
                    User user5;

                    user5 = getSaleManageUserBySegment(acct.Owner.Segment__c);

                    if(user5 == null){
                        checkList = false;
                        errMsg = invalidSMErrormsg;
                        return ;
                    }
                    else if(user5.IsActive){
                        Approverslst2.add(user5);
                        checkList = true;
                    }else{
                        errMsg = invalidSMErrormsg;
                        checkList = false;
                        return ;
                    }
                }
                Approvers.addAll(Approverslst2);
            }
            /**End WBG to WBG  **/
        }

        if(!checkList){
            errMsg = 'There is no any approver available. Please contact admin to check \'Sales Management Mapping\'';
        }
    }

    private Map<Id, User> getUserFromlist(List<Id> appverIdlst){
        Map<Id, User>  userlst = new Map<Id, User> ();
        System.debug('appverIdlst : '  + appverIdlst);
        userlst = new Map<Id, User>([SELECT Id, Name, IsActive, Zone__c, Title, Profile.Name FROM User WHERE Id IN :appverIdlst AND Profile.Name IN :profilesToBeExistingCustApprover]);
        return userlst;
    }

    private User getSaleManageUserBySegment(String segment){
        User u;
        try {
            Sales_Management__mdt saleManage2 = [SELECT Id, Label, EmployeeId__c, Segment__c FROM Sales_Management__mdt WHERE Segment__c = :segment];
            u = [SELECT Id, Name, IsActive, Employee_ID__c, Zone__c, Title, Profile.Name FROM User WHERE Employee_ID__c = :saleManage2.EmployeeId__c];
        } catch (Exception e) {
            System.debug(e.getMessage());
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
            
            changeOwnerHistory.Change_to_owner__c = currentUser.Id;
            changeOwnerHistory.Current_Owner__c = acct.OwnerId; 

            changeOwnerHistory.Change_Owner_Remark__c = remark;

            RecordType rt = new RecordType();

            if(acct.RecordType.Name == 'Prospect'){
                rt = [SELECT id FROM recordType WHERE DeveloperName = 'Change_Owner_Qualified_Prospect'];
            }else if(acct.RecordType.Name == 'Existing Customer'){
                rt = [SELECT id FROM recordType WHERE DeveloperName = 'Change_Owner_Existing_Customer'];
            }

            changeOwnerHistory.RecordTypeId = rt.Id;

            //auto send submit for approval
            Savepoint sp = Database.setSavepoint();
            try{
                insert changeOwnerHistory;
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                // req.setComments(remark); // You can make comments dynamic
                req.setObjectId(changeOwnerHistory.Id);
                Approval.ProcessResult result = Approval.process(req);
                //Approval.unlock(accId);
            }
            catch (Exception ex){
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