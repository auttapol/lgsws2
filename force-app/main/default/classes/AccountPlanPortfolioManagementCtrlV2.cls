public without sharing class AccountPlanPortfolioManagementCtrlV2 {
    public AcctPlanPortfolio__c  portfolio {get;set;}
    private ApexPages.StandardController standardController {get;set;}
    public List<ApprovalWrapper> ApprovalWrapList {get;set;}
    //public Map<ID,AcctPlanCompanyPort__c> MapCompanyValue;
    public Integer tempGroupNum {get;set;} 
    public Integer tempCustomerNum {get;set;}
    public Boolean isPending {get;set;}
    public boolean isSegmentNull {get;set;}
    public boolean isSystemAdmin {get;set;}
    transient public Map<String,List<AcctPlanCompanyPort__c>> MapAccountwithgroup;
    public final String portfolioID;
    public Decimal achievement {get;set;}
    public String alertMsgCustomer {get;set;}
    public String alertMsgWallet {get;set;}
    public String infoMsg {get;set;}
    public String hoverrefreshgroupMsg {get;set;}
    public String clickrefreshgroupMsg {get;set;}
    public String afterrefreshgroupMsg {get;set;}
    //Start Pagination
    Public Integer noOfRecords{get; set;}
    Public Integer size{get;set;}
    public ApexPages.StandardSetController setcon {get;set;}
    public boolean IsRefreshGroup {get;set;}
    public Boolean hasNext {
        get {
            return setCon.getHasNext();
        }
        set;
    }
    public Boolean hasPrevious {
        get {
            return setCon.getHasPrevious();
        }
        set;
    }  
    public Integer pageNumber {
        get {
            return setCon.getPageNumber();
        }
        set;
    }  
    public void first() {
        setCon.first();
    }  
    public void last() {
        setCon.last();
    }  
    public void previous() {
        setCon.previous();
    }  
    public void next() {
        setCon.next();
    }
    
    public  List<CompanyPortWrapper> ComPortListWrapper {get{
        ComPortListWrapper = new List<CompanyPortWrapper>();
        String GroupName = '';
        String LastGroup = '';
        Integer countComPortGroup = 0;
        Integer countComPort = 0;
        for (AcctPlanCompanyPort__c comport : (List<AcctPlanCompanyPort__c>)setcon.getRecords()){
            CompanyPortWrapper comportWrapper = new CompanyPortWrapper();  
            if(comport.AcctPlanGroupPort__c !=null){
                String currentGroupName = comport.AcctPlanGroupPort__r.Group_Name__c;
                if(currentGroupName !=GroupName && GroupName !=''){
                    countComPortGroup = 0;                   
                    if(GroupWrapperMap.containsKey(GroupName)){
                        CompanyPortWrapper SubTotalcomportWrapper = new CompanyPortWrapper();
                        SubTotalcomportWrapper.isSubTotal = true;
                        AcctPlanCompanyPort__c SubComport = new AcctPlanCompanyPort__c();
                        GroupWrapper gw = GroupWrapperMap.get(GroupName);
                        SubComport.Wallet__c = gw.WalletSubTotal;
                        SubComport.Performance__c = gw.ActualSubTotal;
                        SubComport.Target_NI_By_RM__c = gw.TargetSubTotal;
                        SubComport.ExpectedNIbyAccountPlan__c = gw.ExpectedNISubTotal;
                        SubTotalcomportWrapper.Comport = SubComport;
                        SubTotalcomportWrapper.groupName = gw.GroupName;
                        comportWrapper.groupName = currentGroupName;
                        ComPortListWrapper.add(SubTotalcomportWrapper);
                    }    
                }else if(GroupName ==''){
                    comportWrapper.groupName = currentGroupName;  
                    //LastGroup = currentGroupName;
                }
                LastGroup = currentGroupName;
                //check has Group Profile or not
                if(comport.AcctPlanGroupPort__r.Account_Plan_Group_Profile__c != null){
                    if(comport.AcctPlanGroupPort__r.Account_Plan_Group_Profile__r.Name != GroupName && GroupName !=''){
                        comportWrapper.isGroupProfile = true;
                    }else if(GroupName ==''){
                        comportWrapper.isGroupProfile = true;
                    }else{
                        comportWrapper.isGroupProfile = false;
                    }
                }else{
                    comportWrapper.isGroupProfile = false;
                }
                GroupName = comport.AcctPlanGroupPort__r.Group_Name__c;
                countComPortGroup++;  
            }else if(comport.AcctPlanGroupPort__c == null ){
                String currentGroupName = 'None';
                if(currentGroupName !=GroupName && GroupName !=''){
                    GroupWrapper gwCount = GroupWrapperMap.get('None');
                    CompanyPortWrapper SubTotalcomportWrapper = new CompanyPortWrapper();
                    SubTotalcomportWrapper.isSubTotal = true;
                    AcctPlanCompanyPort__c SubComport = new AcctPlanCompanyPort__c();
                    GroupWrapper gw = GroupWrapperMap.get(LastGroup);
                    SubComport.Wallet__c = gw.WalletSubTotal;
                    SubComport.Performance__c = gw.ActualSubTotal;
                    SubComport.Target_NI_By_RM__c = gw.TargetSubTotal;
                    SubComport.ExpectedNIbyAccountPlan__c = gw.ExpectedNISubTotal;
                    SubTotalcomportWrapper.Comport = SubComport;
                    SubTotalcomportWrapper.groupName = gw.GroupName;
                    ComPortListWrapper.add(SubTotalcomportWrapper);
                }
                GroupName = 'None';
                LastGroup = 'None';
                countComPort++;  
            } 
            comportWrapper.Comport = comport;
            ComPortListWrapper.add(comportwrapper);            
        }
        if(LastGroup!=''){
            GroupWrapper gwCount = GroupWrapperMap.get(LastGroup);
            Integer countItem = 0;
            if(LastGroup == 'None'){
                countItem=countComPort;
            }else{
                countItem=countComPortGroup;
            }
            if((gwCount.TotalCustNo == countItem) && LastGroup !=''){
                CompanyPortWrapper SubTotalcomportWrapper = new CompanyPortWrapper();
                SubTotalcomportWrapper.isSubTotal = true;
                AcctPlanCompanyPort__c SubComport = new AcctPlanCompanyPort__c();
                GroupWrapper gw = GroupWrapperMap.get(LastGroup);
                SubComport.Wallet__c = gw.WalletSubTotal;
                SubComport.Performance__c = gw.ActualSubTotal;
                SubComport.Target_NI_By_RM__c = gw.TargetSubTotal;
                SubComport.ExpectedNIbyAccountPlan__c = gw.ExpectedNISubTotal;
                SubTotalcomportWrapper.Comport = SubComport;
                SubTotalcomportWrapper.groupName = gw.GroupName;
                ComPortListWrapper.add(SubTotalcomportWrapper);
                
            }
        }
        return ComPortListWrapper;
    }set;}        
    
    //public List<AcctPlanCompanyPort__c> CompanyPortList; 
    public Map<String,GroupWrapper> GroupWrapperMap; 
    
    public class GroupWrapper {
         public ID groupPortID {get;set;}
         public AcctPlanGroupPort__c groupPort {get;set;}
         public String GroupName {get;set;}
         public Decimal WalletSubTotal {get;set;}
         public Decimal ActualSubTotal {get;set;}
         public Decimal TargetSubTotal {get;set;}
         public Decimal ExpectedNISubTotal {get;set;}
         public Decimal TotalCustNo {get;set;}
    }
    
    public class CompanyPortWrapper {
        transient public AcctPlanCompanyPort__c Comport {get;set;}
        public Boolean isSubTotal {get{
            if(IsSubTotal==null){
                IsSubTotal = false;
            }
            return IsSubTotal;
        }set;}
        public Boolean isGroupProfile {get{
            if(isGroupProfile==null){
                isGroupProfile = false;
            }
            return isGroupProfile;
        }set;}
        transient public String GroupName {get;set;}
        transient public Integer RowNum {get;set;}
        transient public Decimal WalletSubTotal {get;set;}
        transient public Decimal ActualSubTotal {get;set;}
        transient public Decimal TargetSubTotal {get;set;}
        transient public Decimal ExpectedNISubTotal {get;set;}
    }
    //End Pagination
    
    public Integer refreshclick {get;set;}
    public String FiltersOption {get;set;}
    transient public List<Account> AccountList;
    //public Set<ID> ExistingAccountList;
    //public Map<ID,AcctPlanCompanyPort__c> ExistingComportMap;
    //transient public Map<ID,ID> ExistingGRoupPortMap;
    transient public Map<String,AccountPlanRefreshService.CustomerWalletInfo> walletinfoMap;
    
    public AccountPlanPortfolioManagementCtrlV2(ApexPages.StandardController controller){
        standardController = controller;
        // Query Portfolio
        portfolioID = ApexPages.currentPage().getParameters().get('id');
        if(portfolioID !=null && portfolioID !=''){
            portfolio = AccountPlanUtilities.QueryPortfolioByID(portfolioID);
            //CompanyPortList = AccountPlanUtilities.QueryCompanyPortbyPortIDLimit(portfolio.id);   
            
            //Approval Setting
            ApprovalEx();
            refreshclick =0;
            IsRefreshGroup = false;
            isSystemAdmin = AccountPlanUtilities.IsSystemAdmin;
            /*String strurl = ApexPages.currentPage().getUrl();
            strurl = strurl.split('apex/')[1];
            if(strurl.contains('edit')){
                FiltersOption = 'Flag';     
            }else{*/
                FiltersOption = 'Target';
                //FiltersOption = 'Group';
            //}
            AccountPlanFilters();
        }else{
            //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Not found any ID')); 
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, Account_Plan_Status_Code__c.GetValues('0008').Status_Message__c));
        }  

        alertMsgCustomer = Account_Plan_Status_Code__c.GetValues('0011').Status_Message__c;
        alertMsgWallet = Account_Plan_Status_Code__c.GetValues('0012').Status_Message__c;
        infoMsg = Account_Plan_Status_Code__c.GetValues('0013').Status_Message__c;
        hoverrefreshgroupMsg  = Account_Plan_Status_Code__c.GetValues('0015').Status_Message__c;
        clickrefreshgroupMsg  = Account_Plan_Status_Code__c.GetValues('0016').Status_Message__c;
        afterrefreshgroupMsg = Account_Plan_Status_Code__c.GetValues('0017').Status_Message__c;
        
    }
    
    public class ApprovalWrapper implements Comparable{
        public String submitdatetime {get;set;}
        public Datetime submitdatetimeformat {get;set;}
        public String Status {get;set;}
        public User AssignedTo {get;set;}
        public ID DeligatedApprover {get;set;}
        public User ActualApprover {get;set;}
        public String Comments {get;set;}
        public String OverallStatus {get;set;}
        public String StepStatus {get;set;}
        //used to sort
        public Datetime lastupdate{get;set;}
        public Integer compareTo(Object compareTo) {
            // Cast argument to OpportunityWrapper
            ApprovalWrapper compareToOppy = (ApprovalWrapper)compareTo;
            // The return value of 0 indicates that both elements are equal.
            Integer returnValue = 0;
            if (this.lastupdate  > compareToOppy.lastupdate ) {
                // Set return value to a positive value.
                returnValue = -1; 
            } else if (this.lastupdate  < compareToOppy.lastupdate && compareToOppy.status !='Reassigned') {
                // Set return value to a negative value.
                returnValue = 1;   
            }else {
                // First value the same, consider second value
                if (this.status !='Pending') {
                    returnValue = 1;
                } else if (compareToOppy.status !='Pending') {
                    returnValue = -1;
                }       
            }             
            return returnValue;       
        }       
    }
    
    public pageReference InitiateAccountPlan(){
        /*=== Go to clone page : Jantanee Saetung R5.2 ===*/
        String CompanyPortID = ApexPages.currentPage().getParameters().get('acctKey');
        String AccountID = ApexPages.currentPage().getParameters().get('AccountID');
        PageReference pr ;

            AcctPlanCompanyPort__c comport = new AcctPlanCompanyPort__c();
            List<AcctPlanCompanyPort__c> comportlistquery = AccountPlanUtilities.QueryCompanyPortbyID(CompanyPortID);
            if(comportlistquery.size()>0){
                comport = comportlistquery.get(0);
            
                List<AcctPlanCompanyProfile__c> ExistingComprofile = [SELECT ID,Year__C,Account__c,AcctPlanGroup__c 
                                                                      FROM AcctPlanCompanyProfile__c
                                                                      WHERE Year__c =: portfolio.Year__c
                                                                      AND Account__c =: comport.Account__c];
                //Creating CompanyProfile
                if(ExistingComprofile.size()>0){
                    comport.Account_Plan_Company_Profile__c = ExistingComprofile.get(0).id;
                    update comport;
                    System.debug('ExistingComprofile.get(0).AcctPlanGroup__c : '+ExistingComprofile.get(0).AcctPlanGroup__c);
                    System.debug('comport.AcctPlanGroupPort__c : '+comport.AcctPlanGroupPort__c);
                    if(comport.AcctPlanGroupPort__c !=null && ExistingComprofile.get(0).AcctPlanGroup__c !=null){
                        AcctPlanGroupPort__c groupport = [SELECT ID,Account_Plan_Group_Profile__c 
                                                          From AcctPlanGroupPort__c
                                                          WHERE ID=: comport.AcctPlanGroupPort__c
                                                          ORDER BY Group__c,createddate];
                        groupport.Account_Plan_Group_Profile__c = ExistingComprofile.get(0).AcctPlanGroup__c;
                        update groupport;
                    }
                
                    return EditAccountPlan();
                }else{
                    pr = AccountPlanCloneUtils.GotoAccountPlanClonePage('',CompanyPortID,'','','');
                    return pr;
                }
            }else{
                pr = AccountPlanCloneUtils.GotoAccountPlanClonePage('',CompanyPortID,'','','');
                return pr;
            }
        
    }
    
    public pageReference EditAccountPlan(){
        String accountKey = ApexPages.currentPage().getParameters().get('acctKey');
        //AcctPlanCompanyPort__c comport = MapCompanyValue.get(accountKey);
        AcctPlanCompanyPort__c comport = new AcctPlanCompanyPort__c();
        List<AcctPlanCompanyPort__c> comportlistquery = AccountPlanUtilities.QueryCompanyPortbyID(accountKey);
        if(comportlistquery.size()>0){
            comport = comportlistquery.get(0);
        }

        List<AcctPlanCompanyProfile__c> ExistingComprofileList = [SELECT ID,Year__C,Account__c,AcctPlanGroup__c,AcctPlanGroup__r.group__c 
                                                                              FROM AcctPlanCompanyProfile__c
                                                                              WHERE Year__c =: portfolio.Year__c
                                                                              AND Account__c =: comport.Account__r.id];         
        PageReference pr;        
        String companyID = comport.Account_Plan_Company_Profile__c;
        
        List <AcctPlanWallet__c> walletList = AccountPlanWalletUtilities.queryWalletbyCompanyID(companyID);
        if(comport.AcctPlanGroupPort__c !=null){
            AcctPlanGroupPort__c groupport = [SELECT ID,Account_Plan_Group_Profile__c,Group__c,Group__r.Name,
                                                Group__r.Group_Industry_Info__c,Group__r.Parent_Industry__c,
                                                Group__r.UltimateParent__c,Group__r.Parent_Company__c
                                              From AcctPlanGroupPort__c
                                              WHERE ID=: comport.AcctPlanGroupPort__c
                                              ORDER BY Group__c,createddate ];


            //Account Plan 5.2 check Existing or New Group Profile

				System.debug(groupport);

                    if(groupport.Account_Plan_Group_Profile__c ==null){
                       
                    
                        List<AcctPlanGroupProfile__c> GroupProfileList = [SELECT ID,Group__c,Year__c,GroupName__c  
                                                                          FROM AcctPlanGroupProfile__c
                                                                          WHERE Group__c = :groupport.Group__c
                                                                          AND Year__c = : portfolio.Year__c];

                        AcctPlanGroupProfile__c GroupProfile = new AcctPlanGroupProfile__c();
                        Boolean detectedExistinggroup = false;
                        ID existingGroupID;

                        if(GroupProfileList.size() > 0){
                            System.debug('query GroupProfileList');
                            groupport.Account_Plan_Group_Profile__c = GroupProfileList.get(0).id;
                            detectedExistinggroup = true;
                            existingGroupID = GroupProfileList.get(0).id;
                        }else{
                            System.debug('New Group Profile');
                                    
                                    //populate fields R5.2 : Jantanee Saetung 
                                    groupprofile.Group__c = groupport.Group__c;
                                    groupprofile.Group_Industry_Info__c =  groupport.Group__r.Group_Industry_Info__c;
                                    groupprofile.GroupName__c =  groupport.Group__r.Name;
                                    groupprofile.Year__c = portfolio.Year__c; 
                                    groupprofile.Name = groupport.Group__r.Name;
                                    groupprofile.OwnerId = Userinfo.getUserId();
                                    // Group Profile = Parent_Industry_Info__c --> Group Master = Parent_Industry__c
                                    groupprofile.Parent_Industry_Info__c = groupport.Group__r.Parent_Industry__c; //mm
                                    groupprofile.UltimateParent__c = groupport.Group__r.UltimateParent__c;
                                    groupprofile.Parent_Company__c = groupport.Group__r.Parent_Company__c; 


                            insert GroupProfile;
                             groupport.Account_Plan_Group_Profile__c = GroupProfile.id;
                        }

                        if(ExistingComprofileList.size()>0){

                            List<Account_Plan_Completion__c> CompletionList = [SELECT ID,
                                 Account_Plan_Company_Profile__c, 
                                 Account_Plan_Group_Profile__c
                                 FROM Account_Plan_Completion__c 
                                 WHERE  Account_Plan_Company_Profile__c =:ExistingComprofileList.get(0).id ];

                                 Account_Plan_Completion__c completion = CompletionList.get(0);

                            if(detectedExistinggroup &&  ExistingComprofileList.get(0).AcctPlanGroup__c != existingGroupID ){

                                ExistingComprofileList.get(0).AcctPlanGroup__c = existingGroupID;
                                completion.Account_Plan_Group_Profile__c = existingGroupID;
                            }else if(GroupProfile.id !=null){
                                ExistingComprofileList.get(0).AcctPlanGroup__c = GroupProfile.id;
                                completion.Account_Plan_Group_Profile__c = GroupProfile.id;
                            }

                            update ExistingComprofileList;
                            update completion;
                            




                            AccountPlanCompletionEx completionEx = new AccountPlanCompletionEx(ExistingComprofileList.get(0).id);  

                            if(detectedExistinggroup &&  ExistingComprofileList.get(0).AcctPlanGroup__c != existingGroupID ){
                                AcctPlanProStrGrpWalletCtrlV2 grpwallet = new AcctPlanProStrGrpWalletCtrlV2(existingGroupID); 
                            }

                        } 


                       
                    }


                

                    update groupport;
            //AcctPlanGroupPort__c newGroupPort = [SELECT ID,Account_Plan_Group_Profile__c from AcctPlanGroupPort__c WHERE ID =:groupport.id LIMIT 1];
            
            String groupID = groupport.Account_Plan_Group_Profile__c;  
            pr= Page.GroupCompanyViewV2;
            pr.setRedirect(true);
            pr.getParameters().put('GroupID',groupID);
            pr.getParameters().put('CompanyID',companyID);   
        }else{            
            pr= Page.CompanyProfileView;
            pr.setRedirect(true);
            pr.getParameters().put('CompanyID',companyID);
        }        
        if(walletList.size()>0){
            pr.getParameters().put('WalletID',walletList.get(0).id);
        }
        return pr;
    }
    
    //Refresh Button
    public void RefreshFunction(){        
        Set<AcctPlanCompanyPort__c> CompanyPortDelete = new Set<AcctPlanCompanyPort__c>();
        Set<AcctPlanCompanyPort__c> CompanyPortUpdate = new Set<AcctPlanCompanyPort__c>();
        Set<AcctPlanGroupPort__c> GroupPortUpdate = new Set<AcctPlanGroupPort__c>();
        Map<ID,ID> AccountwithGroupMap = new Map<ID,ID>();        
        boolean HasNongroup = false;
        AccountList = AccountPlanUtilities.QueryAccountByOwnerIDLimit(portfolio.SalesOwner__c);        
        List<AcctPlanCompanyPort__c> acctPlanCompanyPortList = AccountPlanUtilities.QueryCompanyPortbyPortIDLimit(portfolio.id);   
        if(AccountList.size() >0){
            List<Account> newAccountList = new List<Account>();
            List<Account> ExistingList = new List<Account>();
            Set<ID> GroupIDLISt = new SET<ID>();
            
            //************ Get Wallet ************
        Set<ID> ExistingAccountList = new Set<ID>();
        Map<ID,AcctPlanCompanyPort__c>   ExistingComportMap = new Map<ID,AcctPlanCompanyPort__c>();
        Map<ID,ID> ExistingGRoupPortMap = new Map<ID,ID>();
        List<AcctPlanCompanyPort__c> CompanyPortListFilter = AccountPlanUtilities.QueryCompanyPortbyPortIDLimit(portfolio.id);
        for(AcctPlanCompanyPort__c cPort : CompanyPortListFilter){
            ExistingAccountList.add(cPort.Account__c);
            ExistingComportMap.put(cPort.Account__c,cPort);
            if(cPort.AcctPlanGroupPort__c !=null){
                ExistingGRoupPortMap.put(cPort.AcctPlanGroupPort__r.GRoup__c,cPort.AcctPlanGroupPort__c);
            }
        }
        
            String tempids = '';
            for(Account acct : AccountList){
                tempids += acct.id+',';  
                if(acct.Group__c !=null){
                    AccountwithGroupMap.put(acct.id,acct.Group__c);
                    GroupIDLISt.add(acct.Group__c);
                }
                if(!ExistingAccountList.contains(acct.id)){
                    newAccountList.add(acct);
                }else{
                    ExistingList.add(acct);
                }
            }               
            String ids = tempids.substring(0,tempids.length()-1);
            walletinfoMap  = new Map<String,AccountPlanRefreshService.CustomerWalletInfo>();
            List<AccountPlanRefreshService.CustomerWalletInfo> WalletInfoList = AccountPlanRefreshService.initialStep0(ids);
            if(WalletInfoList !=null){
                if(WalletInfoList.size()>0){
                    for(AccountPlanRefreshService.CustomerWalletInfo walletInfo : WalletInfoList){
                        walletinfoMap.put(walletInfo.Id,walletInfo);
                    }
                }
            } 
            //Check Groups already has GroupProfile or not
            List<AcctPlanGroupProfile__c> ExistingGroupProfileList = [SELECT ID,Group__c,Year__c,GroupName__c  
                                                                      FROM AcctPlanGroupProfile__c
                                                                      WHERE Group__c IN:GroupIDLISt
                                                                      AND Year__c =:portfolio.Year__c];
            Map<ID,AcctPlanGroupProfile__c> ExistingGroupProfileMap = new Map<ID,AcctPlanGroupProfile__c>();
            for(AcctPlanGroupProfile__c grouppro : ExistingGroupProfileList){
                ExistingGroupProfileMap.put(grouppro.group__c,grouppro); 
            }
            Map<ID,ID> GroupPortIDUpdateMap = new Map<ID,ID>();
            List<ID> newGroupPortIDUpdateMap = new List<ID>();
            Set<ID> pendingGroupPort = new Set<ID>();    
            for(AcctPlanCompanyPort__c comport : acctPlanCompanyPortList){
                if(comport.AcctPlanGroupPort__c !=null){
                    if(ExistingGroupProfileMap.containsKey(comport.AcctPlanGroupPort__r.Group__c)){
                        GroupPortIDUpdateMap.put(comport.AcctPlanGroupPort__c, ExistingGroupProfileMap.get(comport.AcctPlanGroupPort__r.Group__c).id);
                    }else{
                        newGroupPortIDUpdateMap.add(comport.AcctPlanGroupPort__c);
                    }

                    //Tinnakrit 5.2 do not update group port when isneedtoRefresh
                    if(comport.IsNeedtoRefresh__c){
                        pendingGroupPort.add(comport.AcctPlanGroupPort__c);
                    }
                }

                




                //CompanyPort Delete When Changing Owner
                if(comport.Account__r.OwnerId != portfolio.SalesOwner__c ||
                   comport.Account__r.Account_Plan_Flag__c != 'Yes'
                  ){
                      CompanyPortDelete.add(comport);
                  }
            }
            //Map to Group Port
            //Map<ID,ID> ExistingGroupPortMap = new Map<ID,ID>();
            List<AcctPlanGroupPort__c> groupportlist =[SELECT ID,createddate,Group__c,Account_Plan_Portfolio__c  ,Account_Plan_Group_Profile__c
                                                       FROM AcctPlanGroupPort__c
                                                       WHERE Account_Plan_Portfolio__c =: portfolio.id 
                                                       ORDER BY Group__c,createddate ];
            if(GroupPortIDUpdateMap.values().size()>0){
                for(AcctPlanGroupPort__c groupport : groupportlist){
                    groupport.Account_Plan_Group_Profile__c =  GroupPortIDUpdateMap.get(groupport.id);
                    ExistingGroupPortMap.put(groupport.Group__c,groupport.id );                                    
                        
                        //Check if not Pending
                        if(!pendingGroupPort.contains(groupport.id)){
                            GroupPortUpdate.add(groupport);
                        }                         
                } 
            }
            //Check new Accounts already Has Company Profile or not 
            List<AcctPlanCompanyProfile__c> ExistingComprofileList = [SELECT ID,Year__C,Account__c,AcctPlanGroup__c 
                                                                      FROM AcctPlanCompanyProfile__c
                                                                      WHERE Year__c =: portfolio.Year__c
                                                                      AND Account__c IN: AccountList];   
            Map<Id,AcctPlanCompanyProfile__c> ExistingComProfileMap = new Map<Id,AcctPlanCompanyProfile__c>();
            //Add All Existing CompanyProfile to Map
            List<AcctPlanCompanyProfile__c> ExistingCompanyUpdateList = new List<AcctPlanCompanyProfile__c>();
            Map<String,AcctPlanGroupPort__c> MapGroupPort = new Map<String,AcctPlanGroupPort__c>();
            for(AcctPlanCompanyProfile__c actcom : ExistingComprofileList){
                ExistingComProfileMap.put(actcom.Account__c,actcom);
                actcom.Portfolio__c = portfolio.id;
                ExistingCompanyUpdateList.add(actcom);
            }
            //Add New Group Port to Map
            Map<id,AcctPlanGroupPort__c> RefreshNewGroupPortMap = new Map<id,AcctPlanGroupPort__c>();
            Map<id,AcctPlanGroupPort__c> DeleteGroupPortMap = new Map<id,AcctPlanGroupPort__c>();
            List<AcctPlanGroupPort__c> DeleteGroupPortList = new List<AcctPlanGroupPort__c>();
            
            if(newGroupPortIDUpdateMap.size()>0){                
                for(AcctPlanGroupPort__c groupport : groupportlist){
                    ExistingGroupPortMap.put(groupport.Group__c,groupport.id );  
                    DeleteGroupPortMap.put(groupport.Group__c,groupport);
                }         
            }
            
            //Update Existing Company Profile to Portfolio
            for(Account existingAcct : ExistingList){
                boolean isnotdelete = true;
                if(ExistingComProfileMap.containsKey(existingAcct.id)){
                    //Update Existing companyprofile Link
                    ExistingComportMap.get(existingAcct.id).Account_Name__c = existingAcct.Name;
                    ExistingComportMap.get(existingAcct.id).Account_Plan_Company_Profile__c = ExistingComProfileMap.get(existingAcct.id).id;
                }
                // Update Master Group
                if(existingAcct.Group__c !=null){
                    //New GroupPort 
                    if(ExistingGroupPortMap.containsKey(existingAcct.Group__c)){
                        ExistingComportMap.get(existingAcct.id).AcctPlanGroupPort__c = ExistingGroupPortMap.get(existingAcct.Group__c);
                    }else{
                        AcctPlanGroupPort__c  groupport = new AcctPlanGroupPort__c ();
                        groupport.Account_Plan_Portfolio__c = portfolio.id;
                        groupport.Group_Name__c =existingAcct.group__r.Name;
                        groupport.Name =existingAcct.group__r.Name;
                        groupport.Group__c = existingAcct.Group__c;
                        RefreshNewGroupPortMap.put(existingAcct.id,groupport);
                    }
                    
                }else{
                    ExistingComportMap.get(existingAcct.id).AcctPlanGroupPort__c =null;
                }
                if(isnotdelete){
                    CompanyPortUpdate.add(ExistingComportMap.get(existingAcct.id));
                }
            }
            //New GroupPort
            if(RefreshNewGroupPortMap.size()>0){
                insert RefreshNewGroupPortMap.values(); 
                for(Account existingAcct : ExistingList){
                    if(existingAcct.Group__c !=null){
                        if(!ExistingGroupPortMap.containsKey(existingAcct.Group__c)){
                            ExistingComportMap.get(existingAcct.id).AcctPlanGroupPort__c = RefreshNewGroupPortMap.get(existingAcct.id).id;
                        }
                    }
                }   
            }
            if(DeleteGroupPortMap.size()>0){
                for(AcctPlanGroupPort__c item : groupportlist){
                    if(item.createddate != DeleteGroupPortMap.get(item.Group__c).createddate){
                        DeleteGroupPortList.add(item);
                    }
                }
                if(DeleteGroupPortList.size()>0){
                    delete DeleteGroupPortList;
                }
            }
            
            //New Comport 
            MapAccountwithgroup = new Map<String,List<AcctPlanCompanyPort__c>>();
            Map<String,List<AcctPlanCompanyPort__c>> NewCompanyPortwithGroupMap = new Map<String,List<AcctPlanCompanyPort__c>>();
            for(Account acct : newAccountList){
                AcctPlanCompanyPort__c acctCom = new AcctPlanCompanyPort__c ();
                acctCom.Account__c = acct.id;
                acctCom.Account_Name__c = acct.Name;
                acctCom.Account_Plan_Portfolio__c = portfolio.id;
                if(ExistingComProfileMap.containsKey(acct.id)){
                    acctCom.Account_Plan_Company_Profile__c = ExistingComProfileMap.get(acct.id).id;
                }
                if(walletinfoMap.containsKey(acctCom.Account__c )){
                    acctCom.Wallet__c  = walletinfoMap.get(acctCom.Account__c ).Wallet;
                    acctCom.Performance__c  = walletinfoMap.get(acctCom.Account__c ).Annual;
                }
                //Group Assign
                if(acct.Group__c !=null){  
                    //Has group
                    String groupName = acct.Group__r.Name+'';
                    if(MapAccountwithgroup.containsKey(groupName)){
                        acctCom.AcctPlanGroupPort__c = MapGroupPort.get(groupName).id;
                        MapAccountwithgroup.get(groupName).add(acctCom);
                    }else if(ExistingGroupPortMap.containsKey(acct.Group__c)){
                        acctCom.AcctPlanGroupPort__c =  ExistingGRoupPortMap.get(acct.Group__c);                                           
                    }else{
                        //New Group Port
                        List<AcctPlanCompanyPort__c> acctList = new List<AcctPlanCompanyPort__c>();
                        acctlist.add(acctCom);
                        MapAccountwithgroup.put(groupName,acctlist);
                        AcctPlanGroupPort__c  groupport = new AcctPlanGroupPort__c ();
                        groupport.Account_Plan_Portfolio__c = portfolio.id;
                        groupport.Group_Name__c =acct.group__r.Name;
                        groupport.Name =acct.group__r.Name;
                        groupport.Group__c = acct.Group__c;
                        //Existing GroupProfile
                        if(ExistingComProfileMap.containsKey(acct.id)){   
                            if(ExistingComProfileMap.get(acct.id).AcctPlanGroup__c !=null){
                                groupport.Account_Plan_Group_Profile__c =ExistingComProfileMap.get(acct.id).AcctPlanGroup__c;
                            }
                        }
                        MapGroupPort.put(groupname, groupport);
                        GroupPortUpdate.add(groupport);
                    }
                    //Initiate GroupPort                    
                }else{
                    //Non group
                    HasNongroup = true;
                    if(MapAccountwithgroup.containsKey('None')){
                        MapAccountwithgroup.get('None').add(acctCom);
                        acctCom.AcctPlanGroupPort__c = MapGroupPort.get('None').id;
                    }else{
                        //New non group
                        List<AcctPlanCompanyPort__c> acctList = new List<AcctPlanCompanyPort__c>();
                        acctlist.add(acctCom);
                        MapAccountwithgroup.put('None',acctlist); 
                        AcctPlanGroupPort__c  groupport = new AcctPlanGroupPort__c ();
                        groupport.Group_Name__c ='None';
                        groupport.Account_Plan_Portfolio__c = portfolio.id;
                        acctCom.AcctPlanGroupPort__c = groupport.id;
                        MapGroupPort.put('None', groupport);
                    }
                }
                CompanyPortUpdate.add(acctCom);  
            }
            
            
            try{
                portfolio.RefreshAsOf__c = System.Now();
                Map<Id,AcctPlanGroupPort__c> newGroupPortMap = new Map<Id,AcctPlanGroupPort__c>();   
                if(GroupPortUpdate.size()>0){
                    List<AcctPlanGroupPort__c> GroupUpsertList = new List <AcctPlanGroupPort__c>();
                    for(AcctPlanGroupPort__c groupport :GroupPortUpdate){
                        GroupUpsertList.add(groupport);
                    }
                    upsert GroupUpsertList;  
                    
                    for(AcctPlanGroupPort__c groupport :GroupUpsertList){
                        newGroupPortMap.put(groupport.Group__c,groupport);
                    }      
                }
                if(CompanyPortUpdate.size()>0){
                    List<AcctPlanCompanyPort__c> CompanyUpDateList = new List<AcctPlanCompanyPort__c> ();
                    List<AcctPlanCompanyPort__c> CompanyInsertList = new List<AcctPlanCompanyPort__c> ();
                    for(AcctPlanCompanyPort__c comport :CompanyPortUpdate){  
                        
                        if(AccountwithGroupMap.containsKey(comport.Account__c)){                    
                            if(newGroupPortMap.containsKey(AccountwithGroupMap.get(comport.Account__c))){
                                comport.AcctPlanGroupPort__c = newGroupPortMap.get(AccountwithGroupMap.get(comport.Account__c)).id;
                            }
                        }
                        
                        if(comport.ID !=null){
                            if(!comport.IsNeedtoRefresh__c){
                                CompanyUpDateList.add(comport); 
                            }
                        }else{
                           CompanyInsertList.add(comport); 
                        }
                    }
                    //upsert CompanyUpserList;   
                    if(CompanyUpDateList.size()>0){
                       update CompanyUpDateList; 
                    }
                    
                    if(CompanyInsertList.size()>0){
                       insert CompanyInsertList; 
                    }
                }                
                if(ExistingCompanyUpdateList.size()>0){
                    update ExistingCompanyUpdateList;
                }
                if(CompanyPortDelete.size() >0){
                    List<AcctPlanCompanyPort__c> CompanyPortDeleteList = new List <AcctPlanCompanyPort__c>();
                    CompanyPortDeleteList.addAll(CompanyPortDelete);
                    delete CompanyPortDeleteList;
                } 
                List<Target__c> TargetList = AccountPlanUtilities.QueryTargetNIbyOwnerIDandYear(portfolio.SalesOwner__c,Integer.valueof(portfolio.Year__c));
                Decimal TargetNI = 0;
                for(Target__C target : TargetList){
                    TargetNI +=target.NI_Target_Monthly__c;
                }
                portfolio.TargetNI__c =TargetNI;
                update portfolio;
            }catch(Exception e){
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));  
            }    
            
            FiltersOption = 'Flag';
            IsRefreshGroup =false;
            portfolio = AccountPlanUtilities.QueryPortfolioByID(portfolioID);
            //CompanyPortList = AccountPlanUtilities.QueryCompanyPortbyPortIDLimit(portfolio.id);
            AccountPlanFilters(); 
        }    
    }
    
    public void RefreshWalletFunction(){
        try{
            AccountPlanRefreshService.RefreshWalletAndAnnualPerformanceRolling12Month(new Set<ID> {portfolio.id});
            portfolio.RefreshAsOf__c = system.now();
            FiltersOption = 'Flag';
            portfolio = AccountPlanUtilities.QueryPortfolioByID(portfolioID);
            IsRefreshGroup =false;
            //CompanyPortList = AccountPlanUtilities.QueryCompanyPortbyPortIDLimit(portfolio.id);
            AccountPlanFilters();
            update portfolio;
            
        }catch(Exception e){
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));  
        }
    }
    

         //Account Plan 5.2 Refresh Group
    public pageReference RefreshGroupFunction(){
         String ComportKey = ApexPages.currentPage().getParameters().get('acctKey');


                System.debug('ComportKey : '+ComportKey);
        
        List<AcctPlanCompanyPort__c> comportkeylist = [SELECT ID,Name,Account__c,
                                                        Account_Name__c,
                                                        AcctPlanGroupPort__c,
                                                        AcctPlanGroupPort__r.Group__c,
                                                        Account_Plan_Company_Profile__c,
                                                        IsNeedtoRefresh__c,
                                                        ExpectedNIbyAccountPlan__c,
                                                        Performance__c,
                                                        Wallet__c
                                                        FROM AcctPlanCompanyPort__c
                                                        WHERE ID =: ComportKey];
            if(comportkeylist.size()>0){
                
                AcctPlanCompanyPort__c comport = comportkeylist.get(0);
                List<Account> AcctkeyList = AccountPlanUtilities.QueryAccountByAcctID(comport.Account__c);
                Account acct = AcctkeyList.get(0);


                /******************************************************************
                 * Clean Group Wallet
                 *******************************************************************/
                             //Check new Accounts already Has Company Profile or not 
                    List<AcctPlanCompanyProfile__c> ExistingComprofileList = [SELECT ID,Year__C,Account__c,AcctPlanGroup__c,AcctPlanGroup__r.group__c 
                                                                              FROM AcctPlanCompanyProfile__c
                                                                              WHERE Year__c =: portfolio.Year__c
                                                                              AND Account__c =: acct.id]; 

                                                                



             /******************************************************************
                 * 1) Calculat Annual Performance
                 *******************************************************************/

                 datetime currentDt = datetime.now();
                 Set<ID> AcctkeySet = new Set<ID>();
                 acctKeySet.add(Acct.id);
                 decimal totalPerformance = 0;
                 AccountPlanAnnualPerformanceSelector.AccountPlanAnnualPerformanceInfo item
                 = AccountPlanAnnualPerformanceSelector.selectAnnualPerformanceLast12MonthByIdAndDateInGroupMap(acctKeySet, currentDt).get(acct.id);
                if(item !=null){
                    Decimal niic = item.NIIc == null ? 0 : item.NIIc;
                    Decimal niid = item.NIId == null ? 0 : item.NIId;
                    Decimal fee = item.Fee == null ? 0 : item.Fee;
                    totalPerformance = niic + niid + fee;
                }

                decimal TotalPortFolioPerformance = totalPerformance;

                   /******************************************************************
                     * 2) Query Wallet
                     *******************************************************************/
       
       
                Decimal val1 = acct.Fee_Wallet__c == null ? 0 : acct.Fee_Wallet__c;
                Decimal val2 = acct.Fee_Wallet__c == null ? 0 : acct.NIIc_Wallet__c;
                Decimal val3 = acct.NIId_Wallet__c == null ? 0 : acct.NIId_Wallet__c;

                decimal TotalPortFoliowalllet = val1 + val2 + val3;


                /******************************************************************
                 * 3)   Update Update Expected NI
                 ********************************************************************/

                  Decimal Expectedtotal =0;

                 if(ExistingComprofileList.size()>0){

                   Set<ID> CompanyIDSet = new Set<ID>();
                   CompanyIDSet.add(ExistingComprofileList.get(0).id);

                   List<Decimal> valueList = new List<Decimal> ();
                    for (AcctPlanProdStrategy__c proStrategy :
                 AccountPlanProductStrategySelector.selectProductStrategyByIds(CompanyIDSet)) {

                    if (proStrategy.SEQ__c <= 14) {

                        Decimal expectedNI = proStrategy.TotalCompanyNI__c == null ? 0 : proStrategy.TotalCompanyNI__c;


                        valueList.add(expectedNI);

                        
                    }


                }

                if(valueList.size()>0){
                    Decimal feeTotal = valueList[4] +
                    valueList [5] +
                    valueList [6] +
                    valueList [7] +
                    valueList [8] +
                    valueList [10] +
                    valueList [11] +
                    valueList [12] +
                    valueList[13];

                   ExpectedTotal=
                    /*1. NIIc */ valueList [0] +
                    /*2. NIId */ valueList [1]+
                    /*3. Fee  */ feeTotal; //mapCompaniesList.get(comid)[2];
                }

                 }

                /******************************************************************
                 * 4)   Update AcctPlanCompanyPort__c
                 ********************************************************************/
               
                     comport.Wallet__c = TotalPortFoliowalllet== null ? 0 : TotalPortFoliowalllet;
                     comport.Performance__c = TotalPortFolioPerformance== null ? 0 : TotalPortFolioPerformance;
                     comport.ExpectedNIbyAccountPlan__c = Expectedtotal== null ? 0 : Expectedtotal;

                     update comport;


            comport = [SELECT ID,Name,Account__c,
                                                        Account_Name__c,
                                                        AcctPlanGroupPort__c,
                                                        AcctPlanGroupPort__r.Group__c,
                                                        Account_Plan_Company_Profile__c,
                                                        IsNeedtoRefresh__c,
                                                        ExpectedNIbyAccountPlan__c,
                                                        Performance__c,
                                                        Wallet__c
                                                        FROM AcctPlanCompanyPort__c
                                                        WHERE ID =: comport.id LIMIT 1];










                /******************************************************************
                 * Group Profile
                 *******************************************************************/

                 Boolean isHasNewGroupProfiletoLink = false;
                 Id newGroupProfileID;
                 List<String> GroupProfileIDToRefreshWallet = new List<String>();
                if(acct.Group__c !=null){
                    //Existing Group Port 
                    List<AcctPlanGroupPort__c> existinggroupPortList = [SELECT ID,createddate,Group__c,Account_Plan_Portfolio__c  ,Account_Plan_Group_Profile__c
                                                       FROM AcctPlanGroupPort__c
                                                       WHERE Group__c =: acct.Group__c
                                                       AND Year__c =: portfolio.Year__c
                                                       ORDER BY Group__c,createddate DESC LIMIT 1];

                        List<AcctPlanGroupProfile__c> existingGroupProfileList = [SELECT ID,Group__c  
                                                                      FROM AcctPlanGroupProfile__c
                                                                      WHERE Group__c =: acct.Group__c
                                                                      AND Year__c =:portfolio.Year__c];

                                                                      
                        AcctPlanGroupPort__c groupport  ;                                            
                        if(existinggroupPortList.size()>0){
                             groupport =existinggroupPortList.get(0);
                            comport.AcctPlanGroupPort__c = groupport.id;
                            
                            if(groupPort.Account_Plan_Group_Profile__c ==null){
								   isHasNewGroupProfiletoLink = true;
                                Group__C newGroupMaster = [SELECT ID,Name,Group_Industry_Info__c,Parent_Industry__c,UltimateParent__c,Parent_Company__c 
                                                            from group__C
                                                           WHERE ID=: acct.group__c LIMIT 1];
                              		AcctPlanGroupProfile__c GroupProfile = new AcctPlanGroupProfile__c();
                                    groupprofile.Group__c = newGroupMaster.id;
                                    groupprofile.Group_Industry_Info__c =  newGroupMaster.Group_Industry_Info__c;
                                    groupprofile.GroupName__c =  newGroupMaster.Name;
                                    groupprofile.Year__c = portfolio.Year__c; 
                                    groupprofile.Name = newGroupMaster.Name;
                                    groupprofile.OwnerId = Userinfo.getUserId();
                                    // Group Profile = Parent_Industry_Info__c --> Group Master = Parent_Industry__c
                                    groupprofile.Parent_Industry_Info__c = newGroupMaster.Parent_Industry__c;
                                    groupprofile.UltimateParent__c = newGroupMaster.UltimateParent__c;
                                    groupprofile.Parent_Company__c = newGroupMaster.Parent_Company__c; 

								
                            		insert GroupProfile;
                            		newGroupProfileID = groupProfile.id;
                                groupPort.Account_Plan_Group_Profile__c = GroupProfile.id;
                                update groupPort;
                            }

                        }else{
                            		isHasNewGroupProfiletoLink = true;
                              		AcctPlanGroupProfile__c GroupProfile = new AcctPlanGroupProfile__c();
                                    Group__C newGroupMaster = [SELECT ID,Name,Group_Industry_Info__c,Parent_Industry__c,UltimateParent__c,Parent_Company__c 
                                                            from group__C
                                                           WHERE ID=: acct.group__c LIMIT 1];
                                    groupprofile.Group__c = newGroupMaster.id;
                                    groupprofile.Group_Industry_Info__c =  newGroupMaster.Group_Industry_Info__c;
                                    groupprofile.GroupName__c =  newGroupMaster.Name;
                                    groupprofile.Year__c = portfolio.Year__c; 
                                    groupprofile.Name = newGroupMaster.Name;
                                    groupprofile.OwnerId = Userinfo.getUserId();
                                    // Group Profile = Parent_Industry_Info__c --> Group Master = Parent_Industry__c
                                    groupprofile.Parent_Industry_Info__c = newGroupMaster.Parent_Industry__c;
                                    groupprofile.UltimateParent__c = newGroupMaster.UltimateParent__c;
                                    groupprofile.Parent_Company__c = newGroupMaster.Parent_Company__c; 

								
                            		insert GroupProfile;
                            newGroupProfileID = groupProfile.id;
                            
                                groupport = new AcctPlanGroupPort__c ();
                                groupport.Account_Plan_Portfolio__c = portfolio.id;
                                groupport.Group_Name__c =acct.group__r.Name;
                                groupport.Name =acct.group__r.Name;
                                groupport.Group__c = acct.Group__c;
                            	groupport.Account_Plan_Group_Profile__c =GroupProfile.id;
                               
                            insert groupport;

                            comport.AcctPlanGroupPort__c =groupport.id;
                        }

                         if(existingGroupProfileList.size()>0){
                             System.debug(existingGroupProfileList.get(0).id);
                                    groupport.Account_Plan_Group_Profile__c = existingGroupProfileList.get(0).id;
                                    newGroupProfileID = existingGroupProfileList.get(0).id;
                                    isHasNewGroupProfiletoLink = true;
                                    update groupport;

                         }

                        if(existingGroupProfileList.size()>0){
                             System.debug('Refresh New group to add');
                             IsRefreshGroup =true;
                            //AcctPlanProStrGrpWalletCtrlV2 grpwallet = new AcctPlanProStrGrpWalletCtrlV2(existingGroupProfileList.get(0).id); 
                            GroupProfileIDToRefreshWallet.add(existingGroupProfileList.get(0).id);
   
                      }  

                     


                    }else{
                        //Clear group

                        comport.AcctPlanGroupPort__c = null;
                    }


                      /******************************************************************
                         *  Company Profile
                        *******************************************************************/

            
                     if(ExistingComprofileList.size()>0){
                        AcctPlanCompanyProfile__c ExistingComProfile = ExistingComprofileList.get(0);
                        List<Account_Plan_Completion__c> CompletionList = [SELECT ID,
                                 Account_Plan_Company_Profile__c, 
                                 Account_Plan_Group_Profile__c
                                 FROM Account_Plan_Completion__c 
                                 WHERE  Account_Plan_Company_Profile__c =:ExistingComProfile.id ];    

                         Account_Plan_Completion__c Acctplancompletion = CompletionList.get(0);
                         comport.Account_Plan_Company_Profile__c = ExistingComProfile.id;
                         Id  oldGroupWallettoRefresh;
                         


                                if(ExistingComProfile.AcctPlanGroup__c !=null){

                                    oldGroupWallettoRefresh= ExistingComProfile.AcctPlanGroup__c;
                                }

                                if(isHasNewGroupProfiletoLink){
                                            ExistingComProfile.AcctPlanGroup__c = newGroupProfileID;
                                            Acctplancompletion.Account_Plan_Group_Profile__c  = newGroupProfileID;
                                            System.debug('Group has been changed');
                                 }   


                                if(acct.Group__c == null){
                                       System.debug('Group is null');
                                     ExistingComProfile.AcctPlanGroup__c =null;
                                     Acctplancompletion.Account_Plan_Group_Profile__c =null;

                                                    //When Group has been Changed
                                 }

                                 System.debug('ExistingComProfiles Group Profie  '+ExistingComProfile.AcctPlanGroup__c );

                                 update ExistingComProfile;
                                 update Acctplancompletion;

                                  AccountPlanCompletionEx completionEx = new AccountPlanCompletionEx(ExistingComProfile.id);  


                                           if(oldGroupWallettoRefresh !=null){
                                             System.debug('Refresh old group to remove');
                                             IsRefreshGroup =true;
                                                //AcctPlanProStrGrpWalletCtrlV2 grpwallet = new AcctPlanProStrGrpWalletCtrlV2(oldGroupWallettoRefresh);
                                                 GroupProfileIDToRefreshWallet.add(oldGroupWallettoRefresh);

                                           }
                         }  

                
               update comport;         

               if(GroupProfileIDToRefreshWallet.size()>0){
                    for(String GroupProfileID : GroupProfileIDToRefreshWallet){
                        AcctPlanProStrGrpWalletCtrlV2 grpwallet = new AcctPlanProStrGrpWalletCtrlV2(GroupProfileID);
                    }

               }   

        }
         FiltersOption = 'Flag';
         
         AccountPlanFilters();

             return null;


    }





    public void AccountPlanFilters(){
        List<AcctPlanCompanyPort__c> FilterList = new List<AcctPlanCompanyPort__c>();        
        //ExistingAccountList = new Set<ID>();
        //ExistingComportMap = new Map<ID,AcctPlanCompanyPort__c>();
        //ExistingGRoupPortMap = new Map<ID,ID>();
        List<AcctPlanCompanyPort__c> CompanyPortListFilter = AccountPlanUtilities.QueryCompanyPortbyPortIDLimit(portfolio.id);
        //limit 1000
        
        
        if(FiltersOption=='Flag'){
            for(AcctPlanCompanyPort__c cPort : CompanyPortListFilter){
                if(cport.Available_for_Account_Plan__c){
                    FilterList.add(cPort);
                }
            }
        }else if(FiltersOption=='Target'){
            for(AcctPlanCompanyPort__c cPort : CompanyPortListFilter){
                if(cport.Target_NI_By_RM__c !=null && cport.Target_NI_By_RM__c !=0){
                    FilterList.add(cPort);
                }
            }
        }else if(FiltersOption=='Group'){
            for(AcctPlanCompanyPort__c cPort : CompanyPortListFilter){
                if(cport.AcctPlanGroupPort__c !=null){
                    FilterList.add(cPort);
                }
            }
        }
       
        size = 100; 
        setcon = new ApexPages.StandardSetController(FilterList);
        setCon.setPageSize(size);
        noOfRecords = setCon.getResultSize();
        SetPortTabledata(FilterList);
    }


    
    public void SetPortTabledata(List<AcctPlanCompanyPort__c> ComList){
        //MapCompanyValue = new Map<ID,AcctPlanCompanyPort__c>(); 
        GroupWrapperMap = new Map<String,GroupWrapper>();        
        portfolio.SumOfWallet__c  = 0;
        portfolio.SumOfTargetNIByRM__c = 0;
        portfolio.SumOfPerformance__c = 0;
        portfolio.SumOfExpectedNIByAcctPlan__c = 0;
        tempCustomerNum =0;
        tempGroupNum = 0;        
        MapAccountwithgroup = new Map<String,List<AcctPlanCompanyPort__c>>();
        
        //GroupCompanySequenceSet = new Set<String>();
        for(AcctPlanCompanyPort__c comport : ComList){            
            if(comport.Wallet__c != null){
                portfolio.SumOfWallet__c +=comport.Wallet__c;
            }
            if(comport.Target_NI_By_RM__c !=null){
                portfolio.SumOfTargetNIByRM__c +=comport.Target_NI_By_RM__c;
            }
            if(comport.Performance__c !=null){
                portfolio.SumOfPerformance__c += comport.Performance__c;
            }
            if(comport.ExpectedNIbyAccountPlan__c != null){
                portfolio.SumOfExpectedNIByAcctPlan__c += comport.ExpectedNIbyAccountPlan__c;
            } 
            
            //MapCompanyValue.put(comport.id,comport);
            if(comport.AcctPlanGroupPort__c !=null){
                String groupname = comport.AcctPlanGroupPort__r.Group_Name__c;
                if(MapAccountwithgroup.containsKey(comport.AcctPlanGroupPort__c)){
                    MapAccountwithgroup.get(comport.AcctPlanGroupPort__c).add(comport);
                    //getGroupWrapper
                    GroupWrapper groupW = GroupWrapperMap.get(comport.AcctPlanGroupPort__r.Group_Name__c);
                    groupW.WalletSubTotal += comport.Wallet__c==null?0:comport.Wallet__c;
                    groupW.ActualSubTotal += comport.Performance__c==null?0:comport.Performance__c;
                    groupW.TargetSubTotal += comport.Target_NI_By_RM__c==null?0:comport.Target_NI_by_RM__c;
                    groupW.ExpectedNISubTotal += comport.ExpectedNIbyAccountPlan__c==null?0:comport.ExpectedNIbyAccountPlan__c;
                    groupW.TotalCustNo ++;
                    GroupWrapperMap.put(comport.AcctPlanGroupPort__r.Group_Name__c,groupW);
                }else{
                    List<AcctPlanCompanyPort__c > comportList = new List<AcctPlanCompanyPort__c >();
                    comportList.add(comport);
                    MapAccountwithgroup.put(comport.AcctPlanGroupPort__c,comportList);
                    tempGroupNum++;
                    //NewGroupWrapper
                    GroupWrapper groupW = new GroupWrapper();
                    groupW.groupPortID = comport.AcctPlanGroupPort__c;
                    groupW.GroupName = comport.AcctPlanGroupPort__r.Group_Name__c;
                    groupW.WalletSubTotal = comport.Wallet__c==null?0:comport.Wallet__c;
                    groupW.ActualSubTotal = comport.Performance__c==null?0:comport.Performance__c;
                    groupW.TargetSubTotal = comport.Target_NI_By_RM__c==null?0:comport.Target_NI_by_RM__c;
                    groupW.ExpectedNISubTotal = comport.ExpectedNIbyAccountPlan__c==null?0:comport.ExpectedNIbyAccountPlan__c;
                    groupW.TotalCustNo = 1;
                    GroupWrapperMap.put(comport.AcctPlanGroupPort__r.Group_Name__c,groupW);
                }                
            }else{
                if(MapAccountwithgroup.containsKey('None')){
                    MapAccountwithgroup.get('None').add(comport);
                    GroupWrapper groupW = GroupWrapperMap.get('None');
                    groupW.WalletSubTotal += comport.Wallet__c==null?0:comport.Wallet__c;
                    groupW.ActualSubTotal += comport.Performance__c==null?0:comport.Performance__c;
                    groupW.TargetSubTotal += comport.Target_NI_By_RM__c==null?0:comport.Target_NI_by_RM__c;
                    groupW.ExpectedNISubTotal += comport.ExpectedNIbyAccountPlan__c==null?0:comport.ExpectedNIbyAccountPlan__c;
                    groupW.TotalCustNo ++;
                    GroupWrapperMap.put('None',groupW);
                }else{
                    List<AcctPlanCompanyPort__c > comportList = new List<AcctPlanCompanyPort__c >();
                    comportList.add(comport);
                    MapAccountwithgroup.put('None',comportList);
                    //NewGroupWrapper
                    GroupWrapper groupW = new GroupWrapper();
                    groupW.groupPortID = comport.AcctPlanGroupPort__c;
                    groupW.GroupName = comport.AcctPlanGroupPort__r.Group_Name__c;
                    groupW.WalletSubTotal = comport.Wallet__c==null?0:comport.Wallet__c;
                    groupW.ActualSubTotal = comport.Performance__c==null?0:comport.Performance__c;
                    groupW.TargetSubTotal = comport.Target_NI_By_RM__c==null?0:comport.Target_NI_by_RM__c;
                    groupW.ExpectedNISubTotal = comport.ExpectedNIbyAccountPlan__c==null?0:comport.ExpectedNIbyAccountPlan__c;
                    groupW.TotalCustNo = 1;
                    GroupWrapperMap.put('None',groupW);
                }                
            }             
        }
        tempCustomerNum =ComList.size(); 
        if(portfolio.TargetNI__c != null && portfolio.TargetNI__c > 0){
            achievement = (portfolio.SumOfTargetNIByRM__c *100) / portfolio.TargetNI__c;
        }
        
    }    
    
    
    public PageReference ApprovalExRemoteAction(){
        // Refresh data        
        if(portfolioID !=null && portfolioID !=''){
            portfolio = AccountPlanUtilities.QueryPortfolioByID(portfolioID);
        }
        ApprovalEx();
        refreshclick++;
        return null;
    }
    
    public void ApprovalEx(){
        Set<String> UsersSet = new Set<String>();
        ApprovalWrapList = new List<ApprovalWrapper>();        
        System.debug(portfolio);
        for(Sobject sobj : portfolio.ProcessSteps){            
            UsersSet.add(String.valueof(sobj.get('ActorId')));
            UsersSet.add(String.valueof(sobj.get('OriginalActorId')));            
        }
        
        Map<ID,User> UserMap = new Map<ID,User>([SELECT id,Firstname,LastName,DelegatedApproverId   FROM USER
                                                 WHERE ID =: UsersSet]);
        
        isPending = false;            
        for(Sobject sobj : portfolio.ProcessSteps){
            ApprovalWrapper app = new ApprovalWrapper();
            app.lastupdate = (DateTime)sobj.get('CreatedDate');
            app.submitdatetime = String.valueof(sobj.get('CreatedDate'));
            TimeZone tz = UserInfo.getTimeZone();
            DateTime correctedDateTime = app.lastupdate;
            app.submitdatetime = correctedDateTime.format(app.lastupdate.format(),tz.getDisplayName());
            app.status = String.valueof(sobj.get('StepStatus'))=='Started'?'Submitted': String.valueof(sobj.get('StepStatus'));
            app.comments = String.valueof(sobj.get('Comments'));
            app.AssignedTo = UserMap.get(String.valueof(sobj.get('ActorId')));
            if(UserMap.get(String.valueof(sobj.get('ActorId'))).DelegatedApproverId !=null){
                app.DeligatedApprover = UserMap.get(String.valueof(sobj.get('ActorId'))).DelegatedApproverId;
            }
            app.ActualApprover = UserMap.get(String.valueof(sobj.get('OriginalActorId')));
            //app.OverallStatus = String.valueof(sobj.get('IsPending'));
            
            if(app.Status =='Submitted'){
                app.Stepstatus = 'Approval Request Submitted';
            }else{
                app.Stepstatus = 'Step: Step1';
            }
            
            if(String.valueof(sobj.get('IsPending')) =='true'){
                app.OverallStatus  = 'Pending';
                app.Stepstatus += ' (Pending for first approval)';
                isPending = true;  
            }
            if(app.status =='Removed'){
                app.OverallStatus  = 'Recalled';
                app.Stepstatus = 'Approval Request Recalled';
                app.status = 'Recalled';
            }
            ApprovalWrapList.add(app);
        }
        
        ApprovalWrapList.sort();        
    }
    
    public pageReference redirect(){
        PageReference pr = Page.AccountPlanPortfolioManagementEditV2;
        pr.setRedirect(true);
        pr.getParameters().put('id',portfolio.id);
        return pr; 
    }
    
}