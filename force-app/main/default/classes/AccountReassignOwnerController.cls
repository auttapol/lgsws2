public class AccountReassignOwnerController {
    public Map <Id, Account> accMap {get; set;}

    public String lastAccountSorting {get;set;}
    public String firstAccountSorting {get;set;}

    public Integer accCountAll {get; set;}
    public Integer QaccOffset {get; set;} //User for switch hyperlink NEXT, PREVIOUS to enable or disable AND display pagination number 
    public Integer lastOffset {get; set;} //temp value to compare with current offset use for query account NEXT or Previous

    public Boolean isToggleSelectAll {get;set;}
    public Boolean isSearchScreen {get;set;}
    public Boolean isReassignFinish {get;set;}
    public Boolean paginationHavePrev {get;set;}
    public Boolean paginationHaveNext {get;set;}

    //FILLTER SET
    public String filterCustomer {get; set;}
    public String filterIsApprovalPending {get; set;}
    public String custSegmentFilter {get; set;}
    public String custRegionFilter {get; set;}
    public String custZoneFilter {get; set;}
    public String customerStageFilter {get; set;}
    public String customerPrimProvince {get; set;}
    public Id previoseOwnerFilter {get; set;}
    public Id currentOwnerFilter {get; set;}
    public Id groupFilter {get; set;}

    public List<AccountWrapper> accShowlst {get;set;}

    public User assignToUser {get;set;}
    
    public Set<Id> selectdAccIdlst {
        get{
            if(selectdAccIdlst == null){
                selectdAccIdlst = new Set<Id>();
            }
            return selectdAccIdlst;
        } 
        set;
    }

    public Account tmpAcct {
        get{
            if(tmpAcct == null){
                try {
                    tmpAcct = [SELECT Id, Name, Change_to_owner__c, Previous_Owner__c, Current_Owner__c, Group__c FROM Account LIMIT 1];
                } catch (Exception e) {
                    tmpAcct = new Account();
                }
            }
            return tmpAcct;
        }
        set;
    }

    public Account_Reassign_Profile_Setting__mdt UserProfilepermission {
        get{
            if(UserProfilepermission == null){
                List<Account_Reassign_Profile_Setting__mdt> acctReassignProfileSettinglst = new List<Account_Reassign_Profile_Setting__mdt>();
                try {
                    acctReassignProfileSettinglst = [SELECT Id, Segment__c, Profile_Name__c, Reassign_Within_Segment__c, Reassign_Within_Region_Group__c, Reassign_Within_Zone_Team__c, Role__c
                                            FROM Account_Reassign_Profile_Setting__mdt 
                                            WHERE Profile_Name__c = :currentUser.Profile.Name];
                    
                    if(acctReassignProfileSettinglst.size() > 1){
                        Account_Reassign_Profile_Setting__mdt defultProfileSetting = new Account_Reassign_Profile_Setting__mdt();

                        for(Account_Reassign_Profile_Setting__mdt acctReassignProfileSetting : acctReassignProfileSettinglst){
                            if(acctReassignProfileSetting.Role__c == null){
                                defultProfileSetting = acctReassignProfileSetting;
                            }else if(acctReassignProfileSetting.Role__c == currentUser.UserRole.Name){
                                UserProfilepermission = acctReassignProfileSetting;
                                break;
                            }
                        }

                        if(UserProfilepermission == null){
                            UserProfilepermission = defultProfileSetting;
                        }
                    }else{
                        UserProfilepermission = acctReassignProfileSettinglst.get(0);
                    }
                } catch (Exception e) {
                    System.debug(e.getmessage());
                }
            }
            return UserProfilepermission;
        }
        set;
    }

    public List<String> reassignSegmentAllow {
        get{
            if(reassignSegmentAllow == null){
                reassignSegmentAllow = new List<String>();

                if(UserProfilepermission != null && UserProfilepermission.Segment__c != null){

                    String segmentStr = UserProfilepermission.Segment__c;
                    System.debug('segmentStr : ' + segmentStr);

                    List<String> segmentLst = segmentStr.split(',');
                    System.debug('segmentLst : ' + segmentLst);

                    for(String segment : segmentLst){
                        reassignSegmentAllow.add(segment);
                    }
                }else{
                    reassignSegmentAllow.add(currentUser.Segment__c);
                }
                reassignSegmentAllow.sort();

            }
            return reassignSegmentAllow;
        }
        set;
    }

    public Integer limitSelect {
        get{
            if(limitSelect == null){
                limitSelect = 200;
            }
            return limitSelect;
        }
        set;
    }

    public String sfadmSystemAccount{
        get{
            if(sfadmSystemAccount == null){
                AppConfig__c ac = AppConfig__c.getValues('sfadm Account Name');
                if(ac != null){
                    sfadmSystemAccount = ac.Value__c;
                }else{
                    sfadmSystemAccount = 'sfadm System Account';
                }
            }
            return sfadmSystemAccount;
        }
        set;
    }

    public User currentUser {
        get{
            if(currentUser == null){
                currentUser = [SELECT Id, Name, UserRoleId, UserRole.Name, FirstName, LastName, ProfileId, Profile.Name, Segment__c, Region__c, Region_Code__c, Zone__c, Zone_Code__c FROM User WHERE Id = :UserInfo.getUserId()];
            }
            return currentUser;
        }
        set;
    }

    public List<SelectOption> filterCustomerSegmentOption {
        get{
            if(filterCustomerSegmentOption == null){
                List<SelectOption> selectOptlst = new List<SelectOption>();
                
                if(reassignSegmentAllow != null){
                    for(String segment : reassignSegmentAllow){
                        selectOptlst.add(new SelectOption(segment, segment));
                    }
                }else{
                    selectOptlst.add(new SelectOption(currentUser.Segment__c, currentUser.Segment__c));
                }
                
                filterCustomerSegmentOption = selectOptlst;
            }
            return filterCustomerSegmentOption;
        }
        set;
    }

    public List<SelectOption> filterCustomerSelectValue {
        get{
            if(filterCustomerSelectValue == null){
                List<SelectOption> selectOptlst = new List<SelectOption>();
                selectOptlst.add(new SelectOption('myTeamsCustomers', 'My Team\'s Customers'));
                selectOptlst.add(new SelectOption('myCustomer', 'My Customer'));
                selectOptlst.add(new SelectOption('myTeamsInactiveOwner', 'My Team\'s Inactive Owner'));
                if(UserProfilepermission.Reassign_Within_Segment__c){
                    selectOptlst.add(new SelectOption('newCustomer', 'New Customer'));
                }
                filterCustomerSelectValue = selectOptlst;
            }
            return filterCustomerSelectValue;
        }
        set;
    }
    
    public List<SelectOption> filterApprovalPendingValue {
        get{
            if(filterApprovalPendingValue == null){
                List<SelectOption> selectOptlst = new List<SelectOption>();
                selectOptlst.add(new SelectOption('all', 'All'));
                selectOptlst.add(new SelectOption('pendingapproval', 'Pending Approval'));
                selectOptlst.add(new SelectOption('nopending', 'No Pending'));
                filterApprovalPendingValue = selectOptlst;
            }
            return filterApprovalPendingValue;
        }
        set;
    }

    public List<SelectOption> selectedValue {
        get{
            if(selectedValue == null){
                List<SelectOption> selectOptlst = new List<SelectOption>();

                selectOptlst.add(new SelectOption('All', 'All'));

                List<String> optionlst = getPickListValuesAccStage();
                
                for(String s : optionlst) {
                    selectOptlst.add(new SelectOption(s, s));
                }
                selectedValue = selectOptlst;
            }
            return selectedValue;
        }
        set;
    }

    public String queryAccountField{
        get{
            if(queryAccountField == null){
                queryAccountField = ' Id, Name, Segment__c, TMB_Customer_ID_PE__c, OwnerId, Owner.Name, Previous_Owner_ID__c, NI_Actual__c, Account_Type__c, OutStanding__c, Stamp_Owner_Zone_Code_Team_C__c, Stamp_Owner_Region_Code_Group_Code__c, Stamp_Owner_Segment__c, Previous_Owner_Name__c, Stamp_Owner_Region_Group__c, Stamp_Owner_Zone_Team__c, Account_Sorting_Order__c, Core_Banking_Suggested_Segment__c,Change_to_be_segment__c, Total_Deposit__c, Total_Limit__c, Is_Pending_for_Approval__c  ';
            }
            return queryAccountField;
        }
        set;
    }

    public class AccountWrapper{
        public Integer RowNumber {get;set;}
        public Account acct {get;set;}
        // public User previousOwner {get;set;}
        public boolean isSelected {get;set;}
        public Decimal custTotalLimit {get;set;}
        public Decimal custOutstanding {get;set;}
        public Decimal custTotalDeposit {get;set;}
    }

    public AccountReassignOwnerController() {
        accShowlst = new List<AccountWrapper>();

        isSearchScreen = true;
        isReassignFinish = false;
        isToggleSelectAll = false;
        paginationHavePrev = false;

        // tmpAcct.Approver1__c = null;
        // tmpAcct.Approver1__c = null;
        tmpAcct.Change_to_owner__c = null;
        tmpAcct.Previous_Owner__c = null;
        tmpAcct.Current_Owner__c = null;
        tmpAcct.Group__c = null;

        accCountAll = 0;
        QaccOffset = 0;
        lastOffset = 0;

        filterCustomer = 'myTeamsCustomers';
        filterIsApprovalPending = 'all';
        customerStageFilter = 'All';
        customerPrimProvince = 'All';
        
        custSegmentFilter = reassignSegmentAllow[0];
        custRegionFilter = currentUser.Region_Code__c;
        custZoneFilter = currentUser.Zone_Code__c;

        if(UserProfilepermission != null){
            generateAccountShowlst ();
        }
    }

    public void generateAccountShowlst(){
        List<Account> accLst = new List<Account>();

        accShowlst = new List<AccountWrapper>();

        List<String> acctStage = new List<String>();

        if(customerStageFilter == 'All'){
            acctStage.add('Qualified Prospect');
            acctStage.add('Existing Customer');
        }else{
            acctStage.add(customerStageFilter);
        }

        try {
            String fields = queryAccountField;
            String obj = ' Account ';
            String criteria = ' Account_Type__c IN :acctStage';
            String Ordering = ' ORDER BY Account_Sorting_Order__c NULLS LAST ';

            System.debug('filterCustomer : ' + filterCustomer);

            if(customerStageFilter == 'Existing Customer'){
                criteria += ' AND Core_Banking_Suggested_Segment__c = :custSegmentFilter ';
            }

            if(filterCustomer == 'myTeamsCustomers' || filterCustomer == 'myCustomer' || filterCustomer == 'myTeamsInactiveOwner'){
                criteria += ' AND Stamp_Owner_Segment__c = :custSegmentFilter ';
                
                if(UserProfilepermission.Reassign_Within_Region_Group__c){
                    criteria += ' AND Stamp_Owner_Region_Code_Group_Code__c = :custRegionFilter ';
                }else if(UserProfilepermission.Reassign_Within_Zone_Team__c){
                    criteria += ' AND Stamp_Owner_Zone_Code_Team_C__c = :custZoneFilter ';
                }

                if(filterCustomer == 'myCustomer'){
                    criteria += ' AND OwnerId = ' + '\'' + UserInfo.getUserId() + '\' ';
                }

                else if(filterCustomer == 'myTeamsInactiveOwner'){
                    criteria += ' AND Owner.Isactive = false ';
                }
            } else if(filterCustomer == 'newCustomer' && UserProfilepermission.Reassign_Within_Segment__c){
                criteria += ' AND Owner.Name = :sfadmSystemAccount ';
                criteria += ' AND Core_Banking_Suggested_Segment__c = :custSegmentFilter ';
            }

            if(previoseOwnerFilter != null){
                User u = [SELECT Id, Name, FirstName, LastName, Employee_ID__c FROM User WHERE Id = :previoseOwnerFilter];
                criteria += ' AND Previous_Owner_Name__c = \'' + u.FirstName + ' ' + u.LastName + '\' ' ;
            }

            if(currentOwnerFilter != null){
                criteria += ' AND OwnerId = :currentOwnerFilter ';
            }

            if(groupFilter != null){
                criteria += ' AND Group__c = :groupFilter ';
            }

            if(filterIsApprovalPending != 'all'){
                if(filterIsApprovalPending == 'pendingapproval'){
                    criteria += ' AND Is_Pending_for_Approval__c = true ';
                }else if(filterIsApprovalPending == 'nopending'){
                    criteria += ' AND Is_Pending_for_Approval__c = false ';
                }
            }

            String queryStrCount = 'SELECT COUNT() FROM ' + obj + ' WHERE ' + criteria;
            System.debug('queryStrCount : ' + queryStrCount);
            
            if(QaccOffset > 0){
                if(lastOffset < QaccOffset){
                    criteria += ' AND Account_Sorting_Order__c > :lastAccountSorting ';
                }else{
                    criteria += ' AND Account_Sorting_Order__c < :firstAccountSorting ';
                    Ordering = ' ORDER BY Account_Sorting_Order__c DESC NULLS LAST ';
                }
            }
            
            String queryStr = 'SELECT ' + fields + ' FROM ' + obj + ' WHERE ' + criteria + Ordering + ' LIMIT ' + limitSelect;
            System.debug('queryStr : ' + queryStr);

            accCountAll = Database.countQuery(queryStrCount);

            accMap = new Map<Id, Account>( (List<Account>)Database.query(queryStr));
            accLst = accMap.values();

        } catch (Exception e) {
            accLst = new List<Account>();
            System.debug(e.getMessage());
        }

        if(lastOffset > QaccOffset && accLst.size() > 0){
            List<Account> TmpaccLst = new List<Account>();
            TmpaccLst = reverseList(accLst);
            accLst = TmpaccLst;
        }

        if(accMap.size() > 0 && accLst.size() > 0){
            firstAccountSorting =  accLst.get(0).Account_Sorting_Order__c;
            lastAccountSorting = accLst.get( accLst.size() - 1 ).Account_Sorting_Order__c;
            accShowlst = wrapAccountMap(accMap);
        }

        System.debug('(accShowlst.size() + QaccOffset) : ' + (accShowlst.size() + QaccOffset));
        System.debug('accCountAll : ' + accCountAll);

        if((accShowlst.size() + QaccOffset) >= accCountAll){
            paginationHaveNext = false;
        }else{
            paginationHaveNext = true;
        }

        if(QaccOffset <= 0){
            paginationHavePrev = false;
        }else{
            paginationHavePrev = true;
        }

        lastOffset = QaccOffset;
    }
    public List<AccountWrapper> wrapAccountMap(Map<Id, Account> acctMap){
        List<AccountWrapper> resultWrapAcc = new List<AccountWrapper>();
        
        if(acctMap.size() > 0){
            Set<Id> AccIdset = new Set<Id>();

            AccIdset = acctMap.keySet();
            List<Account> accLst = acctMap.values();

            Map<Id, List<Product_Information_Detail__c>> acclstProdInfoDetailMap = new Map<Id, List<Product_Information_Detail__c>>();

            for (Product_Information_Detail__c prodInfoDetail : [SELECT Id, Name, Customer__c, Product_Information__c, Account_Name__c, Account_id__c, Limit_Balance__c, Product_Domain__c, Ending_out_Ending_Balance__c, TMB_Account_ID__c FROM Product_Information_Detail__c WHERE Customer__c IN :AccIdset]) {
                List<Product_Information_Detail__c> tmplst = new List<Product_Information_Detail__c>();

                if(acclstProdInfoDetailMap.containsKey(prodInfoDetail.Customer__c)){
                    tmplst = acclstProdInfoDetailMap.get(prodInfoDetail.Customer__c);
                }

                tmplst.add(prodInfoDetail);
                acclstProdInfoDetailMap.put(prodInfoDetail.Customer__c, tmplst);
            }

            Integer i = 0;

            for (Account acct : accLst) {
                AccountWrapper acctWrap = new AccountWrapper();
                Decimal tmpcustTotalLimit = 0;
                Decimal tmpcustOutstanding = 0;
                Decimal tmpcustTotalDeposit = 0;

                i += 1;
                acctWrap.acct = acct;
                acctWrap.isSelected = false;
                acctWrap.RowNumber = i;

                if(selectdAccIdlst.contains(acct.Id)){
                    acctWrap.isSelected = true;
                }

                if(acclstProdInfoDetailMap.containsKey(acct.Id)){
                    System.debug('acct : ' + acct);
                    System.debug('acclstProdInfoDetailMap.get(acct.Id) : ' + acclstProdInfoDetailMap.get(acct.Id).size());

                    for (Product_Information_Detail__c prodInfoDetail : acclstProdInfoDetailMap.get(acct.Id)) {
                        if(prodInfoDetail.Product_Domain__c != 'Deposit & investment'){
                            tmpcustTotalLimit += prodInfoDetail.Limit_Balance__c;

                            // if(prodInfoDetail.Product_Domain__c == 'Funding & Borrowing'){
                            //     tmpcustOutstanding += prodInfoDetail.Limit_Balance__c;
                            // }
                        }else {
                            tmpcustTotalDeposit += prodInfoDetail.Ending_out_Ending_Balance__c;
                        }
                    }
                }

                // acctWrap.custTotalLimit = tmpcustTotalLimit;
                acctWrap.custTotalLimit = acct.Total_Limit__c;
                // acctWrap.custOutstanding = tmpcustOutstanding;
                acctWrap.custOutstanding = acct.OutStanding__c;
                // acctWrap.custTotalDeposit = tmpcustTotalDeposit;
                acctWrap.custTotalDeposit = acct.Total_Deposit__c;

                resultWrapAcc.add(acctWrap);
            }
        }

        return resultWrapAcc;
    }

    public static List<String> getPickListValuesAccStage(){
        List<String> pickListValuesList= new List<String>();

        Schema.DescribeFieldResult fieldResult = Account.Account_Type__c.getDescribe();
        
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry pickListVal : ple){
            if(pickListVal.getLabel() == 'Qualified Prospect' || pickListVal.getLabel() == 'Existing Customer'){
                pickListValuesList.add(pickListVal.getLabel());
            }
        }     
        return pickListValuesList;
    }

    public void searchAccountByfilter(){
        System.debug('searchAccountByfilter::::');
        previoseOwnerFilter = tmpAcct.Previous_Owner__c;
        currentOwnerFilter = tmpAcct.Current_Owner__c;
        groupFilter = tmpAcct.Group__c;

        isToggleSelectAll = false;
        selectdAccIdlst = new Set<Id>();
        QaccOffset = 0;

        if(UserProfilepermission != null){
            generateAccountShowlst();
        }
    }
            
    public void toggleSelectAll(){
        for(AccountWrapper accWrap : accShowlst){   
            accWrap.isSelected = isToggleSelectAll;
        }
    }

    public void selectAcc(){
        Boolean isSelectd = false;
        
        selectdAccIdlst = new Set<Id>();
        List<AccountWrapper> acctWraptmplst = new List<AccountWrapper>();

        for(AccountWrapper accWrap : accShowlst){
            if(accWrap.isSelected == true){
                isSelectd = true;
                selectdAccIdlst.add(accWrap.acct.id);
                acctWraptmplst.add(accWrap);
            }
        }

        if(isSelectd){
            accShowlst = acctWraptmplst;
            isSearchScreen = false;
        }else{
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ReassingAccountOwnerMessage3));
        }
    }

    public void reassignAccount(){
        System.debug('tmpAcct : ' + tmpAcct);

        if(tmpAcct.Change_to_owner__c == null){
           ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ReassingAccountOwnerMessage2));
           return ; 
        }

        String assignErrMsg = Label.ReassingAccountOwnerMessage1;
        
        assignToUser = [SELECT Id, Name, UserRoleId, FirstName, LastName, ProfileId, Profile.Name, Segment__c, Region__c, Region_Code__c, Zone__c, Zone_Code__c FROM User WHERE Id = :tmpAcct.Change_to_owner__c];

        if(UserProfilepermission.Reassign_Within_Segment__c){
            if(assignToUser.Segment__c == custSegmentFilter){
                UpdateAccountOwner();
            }else{
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, assignErrMsg));
            }
        }else if(UserProfilepermission.Reassign_Within_Region_Group__c){
            if(assignToUser.Region_Code__c == currentUser.Region_Code__c){
                UpdateAccountOwner();
            }else{
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, assignErrMsg));
            }
        }else if(UserProfilepermission.Reassign_Within_Zone_Team__c){
            if(assignToUser.Zone_Code__c == currentUser.Zone_Code__c){
                UpdateAccountOwner();
            }else{
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, assignErrMsg));
            }
        }else{
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ReassingAccountOwnerMessage4));
        }
    }

    public void UpdateAccountOwner(){
        List<Account> updateAcclst = new List<Account>();
        
        for(AccountWrapper accWrap : accShowlst){
            if(accWrap.isSelected == true){
                accWrap.acct.OwnerId = assignToUser.Id;
                updateAcclst.add(accWrap.acct);
                if(accWrap.acct.Change_to_be_segment__c != null && accWrap.acct.Change_to_be_segment__c != accWrap.acct.Stamp_Owner_Segment__c){
                    ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ReassingAccountOwnerMessage5));
                    return ;
                }
            }
        }

        System.debug('updateAcclst : ' + updateAcclst);

        if(!validateToAccountApprovalFlow(updateAcclst)){
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ReassingAccountOwnerMessage6));
            return ;
        }
        
        try {
            update updateAcclst;
            isToggleSelectAll = false;
            isReassignFinish = true;
            selectdAccIdlst = new Set<Id>();
            QaccOffset = 0;


            System.debug('updateAcclst : ' + updateAcclst);
            Map<Id, Account> acctMaptmp = new Map<Id, Account>(updateAcclst);
            Set<Id> acctIdlst = acctMaptmp.keySet();

            String fields = queryAccountField;
            String obj = ' Account ';
            String criteria = ' Id IN :acctIdlst ';
            String Ordering = ' ORDER BY Account_Sorting_Order__c NULLS LAST ';

            String queryStr = 'SELECT ' + fields + ' FROM ' + obj + ' WHERE ' + criteria + Ordering + ' LIMIT ' + limitSelect;
            System.debug('queryStr : ' + queryStr);
            Map<Id, Account> acctMap = new Map<Id, Account>( (List<Account>)Database.query(queryStr));


            System.debug('acctMap : ' + acctMap);

            accShowlst = wrapAccountMap(acctMap);
            System.debug('acctMap : ' + acctMap);

            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Reassign owner finish : ' + assignToUser.Name));
        } catch (Exception e) {
            System.debug(e.getMessage());
            //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
    }

    public Boolean validateToAccountApprovalFlow(List<Account> acctlst){
        Boolean result = true;

        Map<Id, Account> mapAcct = new Map<Id, Account> (acctlst);

        Map<Id, Change_Owner_Approval_History__c> changeownerHis = new Map<Id, Change_Owner_Approval_History__c> ([SELECT Id, Account__c, Account__r.Name, Change_Owner_Approval_Status__c FROM Change_Owner_Approval_History__c WHERE Account__c IN :mapAcct.keySet() AND Change_Owner_Approval_Status__c NOT IN ('Final Approved', 'Rejected', 'Recalled')]);

        List<ProcessInstanceWorkitem> piwi = [SELECT Id, ProcessInstanceId, ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId IN :changeownerHis.keySet()];
        
        if(piwi.size() > 0 ){
            result = false;
        }
        return result;
    }

    public void PaginationNext(){
        if((accShowlst.size() + QaccOffset) < accCountAll){
            isToggleSelectAll = false;
            selectdAccIdlst = new Set<Id>();
            QaccOffset += limitSelect;
            generateAccountShowlst();
        }
    }

    public void PaginationPrev(){
        if(QaccOffset >= limitSelect){
            isToggleSelectAll = false;
            selectdAccIdlst = new Set<Id>();
            QaccOffset -= limitSelect;
            generateAccountShowlst();
        }
    }

    public void backToSelectAcc(){
        System.debug('backToSelectAcc:::');
        isSearchScreen = true;
        isReassignFinish = false;
        tmpAcct.Change_to_owner__c = null;
        generateAccountShowlst();
    }

    public List<sObject> reverseList(List<sObject> Inlist){
        List<sObject> resultList = new List<sObject>();

        for(Integer i = Inlist.size() - 1; i >= 0 ; i--){
            resultList.add(Inlist[i]);
        }

        return resultList;
    }
}