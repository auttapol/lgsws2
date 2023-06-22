public without sharing class GroupCompanyExControllerV2 {
    private ApexPages.StandardController ctrl;
    public String GroupID {get;set;}
    public String CompanyID {get;set;}
    public String CompanyPortID {get;set;}
    public String walletID {get;set;}
    public String mode {get;set;}
    public Boolean isConsoleMode {get;set;}
    public String MasterGroupID {get;set;}
    public boolean isDisabled {get;set;}
    public boolean isNew {get;set;}
    public boolean isHasProdStrategy {get;set;}
    public boolean isHasActionPlan {get;set;}
    public boolean isHasPermission {get;set;}
    public Group__c mGroup {get;set;}
    public Account_Plan_Completion__c  Acctplancompletion {get;set;}
    public AcctPlanPortfolio__c  portfolio {get;set;}
    public AcctPlanGroupProfile__c groupprofile {get;set;}
    public Set<String>  contributionSet {get;set;}
    public Boolean  isHasContribution {get{
        if(ContributedByService.size() > 0 || ContributedByBusiness.size()>0 || ContributedByRegional.size()>0){
            isHasContribution =  true;      
        }else{
            isHasContribution =  false;      
        }
        return isHasContribution;
    }set;}   
    public List<String> CustomerProfilesMessage {get;set;}
    public List<Account> AccountList {get;set;}
    public Set<Account> AccountSet {get;set;}
    public Set<ID> AuthorizedSet {get;set;}
    public AcctPlanCompanyProfile__c companyprofile {get;set;}
    public List<AcctPlanContribution__c> ContributedByService {get;set;}
    public Map<String,List<AcctPlanContribution__c>> ContributionMap {get;set;}
    public List<AcctPlanContribution__c> ContributedByBusiness {get;set;}
    public List<AcctPlanContribution__c> ContributedByRegional {get;set;}
    public List<AcctPlanCompanyProfile__c> CustomerProfileList {get;set;}
    public Map<ID,AccountPlanWrapper> AccountwithWrapperMap {get;set;}
    //public List<AccountPlanWrapper> AcctWrapperList {get;set;}
    public List<Opportunity> OpptyList {get;set;}
    Map<ID,String> AccountTeamMap {get;set;}
    public boolean isHasAuthorized {get{
        
        isHasAuthorized = false;
        if(AuthorizedSet.contains(Userinfo.getUserId())){
            isHasAuthorized = true;
        }
        
        return isHasAuthorized;
        
    }set;}
    //public Map<String,TMBAccountPlanServiceProxy.CUSTOMER_INFO> custinfoMap {get;set;}
    public Boolean isMiniView {get;set;}
    public List<SelectOption> getFiscalYear(){
        List<SelectOption> fiscalyearoption = new List<SelectOption>();
        List<Account_Plan_Fiscal_Year__c> yearlistitem = [SELECT ID,Name,AD_Year__c,BE_Year__c
                                                FROM Account_Plan_Fiscal_Year__c 
                                                WHERE ID!=null
                                                ORDER BY Name];
        fiscalyearoption.add(new SelectOption('','None'));
        for(Account_Plan_Fiscal_Year__c year : yearlistitem){
            fiscalyearoption.add(new SelectOption(year.AD_Year__c,year.AD_Year__c));
        }         
        return fiscalyearoption;
    }
    
    public class AccountPlanWrapper {
        public AcctPlanCompanyProfile__c ComProfile {get;set;}
        public boolean isAccountTeam {get;set;}
        public Account Acct {get;set;}
        public boolean isNewGroup {get;set;}
    }
    
    //Start Pagination
    Public Integer noOfRecords{get; set;}
    Public Integer size{get;set;}
    public ApexPages.StandardSetController setcon;
    public List<AccountPlanWrapper> AcctWrapperList {
        get{
            AcctWrapperList  = new List<AccountPlanWrapper>();
            for(Account acct: (List<Account>)setcon.getRecords()){
                AcctWrapperList.add(AccountwithWrapperMap.get(acct.id));               
            }
            return AcctWrapperList;
        }set;
    }
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
        system.debug('= next = ');
        setCon.next();
    }
    public String msgShareholding {get;set;}
    public String msgTransactional {get;set;}
    public String msgTableMandatory {get;set;}
    public Boolean isSystemAdmin {get;set;}

    public GroupCompanyExControllerV2(ApexPages.StandardController controller) {
         isSystemAdmin = AccountPlanUtilities.IsSystemAdmin;
         size = 100; 
         msgShareholding = Account_Plan_Status_Code__c.GetValues('1020').Status_Message__c;
         msgTransactional = Account_Plan_Status_Code__c.GetValues('1021').Status_Message__c;
         msgTableMandatory = Account_Plan_Status_Code__c.GetValues('9005').Status_Message__c;
         
        CustomerProfilesMessage = new List<String>();
        String msg1 = null;
        String msg2 = null;
        isNew = false;
        isHasPermission = false;
        
        msg1 = Account_Plan_Status_Code__c.GetValues('1022').Status_Message__c;   
        msg2 = Account_Plan_Status_Code__c.GetValues('1023').Status_Message__c;    
        CustomerProfilesMessage.add(msg1);  
        CustomerProfilesMessage.add(msg2); 
        
        ctrl = controller;
        GroupID = ApexPages.currentPage().getParameters().get('Groupid');
        if(groupID ==null || groupID==''){
            GroupID = ApexPages.currentPage().getParameters().get('id');
        }
        
        mode= ApexPages.currentPage().getParameters().get('mode');
         if(mode=='console'){
            isConsoleMode = true;
        }else{
            isConsoleMode = false;
        }
        CompanyID = ApexPages.currentPage().getParameters().get('Companyid');
        walletID = ApexPages.currentPage().getParameters().get('WalletId');
        MasterGroupID = ApexPages.currentPage().getParameters().get('MasterGroup');
        CompanyPortID = ApexPages.currentPage().getParameters().get('CompanyPortID');
                      //  isHasPermission = AccountPlanUtilities.ISHASPERMISSION;           
               //Check Permission
               //
                 List<Profile> PROFILE = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
                String MyProflieName = PROFILE[0].Name;
                List<ObjectPermissions> obplist = [SELECT Id, SObjectType, PermissionsRead,PermissionsEdit, PermissionsCreate
                FROM ObjectPermissions
                WHERE SObjectType =:'AcctPlanGroupProfile__c' AND parentid in (select id from permissionset where
                PermissionSet.Profile.Name =: MyProflieName) ];
                
            if( obplist.get(0).PermissionsEdit || obplist.get(0).PermissionsCreate){
                isHasPermission = true;
            }
        AuthorizedSet = new Set<ID>();   
        if(groupID !=null && groupID!='' ){
            
        //Query Portfolio
        
        //Query Group Profile
        groupprofile = AccountPlanUtilities.QueryGroupProfileByID(groupID).get(0);
            

            
             
        // Query Completion Percentage
          String strurl = ApexPages.currentPage().getUrl();
            strurl = strurl.split('apex/')[1];


            System.debug('groupprofile.id :'+groupprofile.id);
            System.debug('CompanyID : '+Companyid);
            if((strurl.contains('view') ||strurl.contains('View')  ) && Companyid !=null && Companyid !=''){
                List<Account_Plan_Completion__c> CompleteList= [SELECT ID,Name,
                     Account_Plan_Company_Profile__c, 
                     Account_Plan_Group_Profile__c,                                           
                     Step_1_Percentage__c , 
                      Account_Plan_Completion_Percentage__c , 
                      Step_1_Entered_Fields__c ,                                          
                      Step_1_Required_Fields__c
                     FROM Account_Plan_Completion__c 
                     WHERE Account_Plan_Group_Profile__c  =: groupprofile.id
                     AND Account_Plan_Company_Profile__c =:Companyid ]; 
                     System.debug('CompleteList: '+CompleteList.size());
                 if(CompleteList.size()>0){
                 Acctplancompletion = CompleteList.get(0);
                 
                System.debug('Acctplancompletion: '+Acctplancompletion.id);
             }
                companyprofile = AccountPlanUtilities.QueryAcctPlanCompanyProfileByID(CompanyID);
                isMiniView = AccountPlanUtilities.ISMINIVIEW;
                ishasProdStrategy = companyprofile.isHasProdStrategy__c;
                isHasActionPlan = companyprofile.isHasActionPlan__c;
                
            }  
            
            
                
        //only for View Page - Edit Page use remote object to avoid query limits
        contributionSet = new Set<String>();
         contributionSet.add('Contribution by service & product');
         contributionSet.add('Contribution by business unit');
         contributionSet.add('Contribution by regional');
        ContributedByService = new List<AcctPlanContribution__c>();
        ContributedByBusiness = new List<AcctPlanContribution__c>();
        ContributedByRegional = new List<AcctPlanContribution__c>();
        ContributionMap = new Map<String,List<AcctPlanContribution__c>>();
            
            
        for(AcctPlanContribution__c contribute : AccountPlanUtilities.QueryContributionByGroupProfileID(groupprofile.id)){
                               
            if(contribute.RevenueContributionType__c =='Contribution by service & product'){
                ContributedByService.add(contribute);
                
            }else if(contribute.RevenueContributionType__c =='Contribution by business unit'){
                ContributedByBusiness.add(contribute);
                
            }else if(contribute.RevenueContributionType__c =='Contribution by regional'){
                ContributedByRegional.add(contribute);
               
            }
            
        }
        
        ContributionMap.put('Contribution by service & product',ContributedByService);
        ContributionMap.put('Contribution by business unit',ContributedByBusiness);
        ContributionMap.put('Contribution by regional',ContributedByRegional);
        //
        
        //Query Account for Customer Profile
        //CustomerProfileList = AccountPlanUtilities.QueryCompanyProfileByGroupID(groupprofile.id);
        //limit 1000
      
           AccountList = AccountPlanUtilities.QueryAccountByGroupIDLimit(groupprofile.Group__c);   
            
                   System.debug(AccountList.size());      
            if(AccountList.size()>0){ 
                    AccountSet = new Set<Account>();
                    AccountSet.addAll(AccountList);

                      CustomerProfileList =[SELECT ID,Name,Wallet__c ,              
                            AcctPlanGroup__c ,
                            Status__c, 
                            Account__r.industry,
                            Account__r.Industry__c,
                            Account__c,
                            AccountName__c ,
                              Company_Industry_Info__c,
                              Owner.Name,
                            Account__r.ESTABLISH_DT__c, 
                            Account__r.OwnerID, 
                             Account__r.Owner.Name,                             
                            Account__r.Owner.Segment__c,                              
                            Account__r.LastModifiedBy.Name,
                            Account__r.LastModifiedDate,
                            LastModifiedBy.Name,LastModifiedDate, 
                            Account__r.Group__r.Name,
                            Account__r.Name
                                               
                           FROM AcctPlanCompanyProfile__c  
                           WHERE Account__c  IN: AccountList
                           AND Year__c =: groupprofile.Year__c ORDER BY Name ASC LIMIT 1500];
                    
                 //paging//AcctWrapperList  = new List<AccountPlanWrapper>();
                
           //Opportunity List   
                OpptyList = [SELECT ID,Name,AccountID , RecordTypeID, 
                             Actual_Complete_Date__c  , StageName , Application_Status__c ,Opportunity_amount_adjust__c, 
                             CreatedBy.Name ,OwnerID ,Amount
                 From Opportunity 
                 WHERE   AccountID  IN:AccountSet 
                 AND Probability > 0 AND Probability  <100
                 AND Amount >0
                ORDER BY Amount DESC,Actual_Complete_Date__c ASC LIMIT  5];
                

                
            AccountwithWrapperMap = new Map<Id,AccountPlanWrapper>();
            /*TMBAccountPlanServiceProxy.CUSTOMER_INFO[] customerInfos = new List<TMBAccountPlanServiceProxy.CUSTOMER_INFO>(); 
            String tempids = '';
            for(Account acct : AccountList){
                tempids += acct.id+',';
            }          
            
            String ids = tempids.substring(0,tempids.length()-1);*/
            //customerInfos = TMBAccountPlanServiceProxy.getCustomerByIds(ids);
            /*custinfoMap = new Map<String,TMBAccountPlanServiceProxy.CUSTOMER_INFO>();
            if(customerInfos !=null){
                if(customerInfos.size()>0){
                     for( TMBAccountPlanServiceProxy.CUSTOMER_INFO  custinfo :customerInfos ){
                    
                    custinfoMap.put(custinfo.SF_ID,custinfo);
                    } 
                }
            }*/
            
            AccountTeamMap = new Map<ID,String>();
                
             List<AccountTeamMember> acctTeam = [SELECT ID,AccountAccessLevel,AccountId,
                             IsDeleted, TeamMemberRole, UserId FROM  AccountTeamMember
                             WHERE AccountId IN: AccountSet 
                             AND USerId=: Userinfo.getUserId()
                             ];
                
                for(AccountTeamMember acctT : AcctTeam){
                  AccountTeamMap.put(acctT.AccountId,acctT.AccountAccessLevel);
                    if(acctT.AccountAccessLevel == 'Edit' || acctT.AccountAccessLevel =='All'){
                        AuthorizedSet.add(acctT.UserId);
                    }
                }
                
            for(Account acct: AccountSet){
                AccountPlanWrapper wrapp = new AccountPlanWrapper();
                wrapp.Acct = acct;
                AuthorizedSet.add(acct.OwnerId);
                if(AccountTeamMap.containsKey(acct.id)){
                    
                    if(AccountTeamMap.get(acct.id)=='Edit' || AccountTeamMap.get(acct.id)=='All'){
                        wrapp.isAccountTeam = true;
                    }else{
                        wrapp.isAccountTeam = false;
                    }
                    
                }else{
                     wrapp.isAccountTeam = false;
                }
                AccountwithWrapperMap.put(acct.id,wrapp);
                 /*if(custinfoMap.containsKey(acct.id)){
                        acct.First_name__c = custinfoMap.get(acct.id).FNAME==null ||custinfoMap.get(acct.id).FNAME =='null'?'':custinfoMap.get(acct.id).FNAME ;
                        acct.Last_name__c = custinfoMap.get(acct.id).LNAME==null ||custinfoMap.get(acct.id).LNAME =='null'?'':custinfoMap.get(acct.id).LNAME ;
                 }*/
            }
            
            for(AcctPlanCompanyProfile__c compro : CustomerProfileList){
                if(AccountwithWrapperMap.containsKey(compro.Account__c)){
                     AccountwithWrapperMap.get(compro.Account__c).ComProfile = compro;
                }
            }
            
            //paging//AcctWrapperList.addAll(AccountwithWrapperMap.values());
         //paging//System.debug(AcctWrapperList.size());
            }
            if(CompanyPortID != null && CompanyPortID != ''){
                AcctPlanCompanyPort__c comport = [SELECT id,Account_Name__c 
                                                  FROM AcctPlanCompanyPort__c 
                                                  WHERE id = :CompanyPortID];
                if(comport != null){
                    if(comport.Account_Name__c == null || comport.Account_Name__c ==''){
                        isDisabled = true;
                        //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Cannot create an Account Plan. Customer Name is invalid. Please return to Portfolio Management screen and click Refresh Cust. List again.'));      
                        ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('1001').Status_Message__c));
              
                    }
                }
            }
         //Initiate Group Profile from Group Master
        
        }else if(MasterGroupID !=null &&MasterGroupID !=''){
            
            AccountwithWrapperMap = new Map<Id,AccountPlanWrapper>();
            isDisabled = false;
            isNew = true;
            List<Group__c> mastergroup = [SELECT ID,Name, GroupCompany__c 
                                          , Parent_Company__c 
                                          ,UltimateParent__c 
                                          ,Group_Industry_Info__c
                                          ,Parent_Industry__c
                                   FROM Group__c
                                   WHERE ID =:MasterGroupID];
            if(mastergroup.size()>0){
            mGroup = mastergroup.get(0);
            groupprofile = new AcctPlanGroupProfile__c(); 
            /*groupprofile.Group__c = mGroup.id;
            groupprofile.GroupName__c = mGroup.Name;
            groupprofile.Name = mGroup.Name;
//            groupprofile.GroupIndustry__c = mGroup.GroupIndustry__c;  
//            groupprofile.ParentIndustry__c = mGroup.ParentIndustry__c;
            groupprofile.UltimateParent__c = mGroup.UltimateParent__c;
            groupprofile.Parent_Company__c = mGroup.Parent_Company__c; */

                                    //populate fields R5.2 : Jantanee Saetung 
                                    groupprofile.Group__c = mGroup.id;
                                    groupprofile.Group_Industry_Info__c =  mGroup.Group_Industry_Info__c;
                                    groupprofile.GroupName__c =  mGroup.Name;
                                    //groupprofile.Year__c = portfolio.Year__c; 
                                    groupprofile.Name = mGroup.Name;
                                    groupprofile.OwnerId = Userinfo.getUserId();
                                    // Group Profile = Parent_Industry_Info__c --> Group Master = Parent_Industry__c
                                    groupprofile.Parent_Industry_Info__c = mGroup.Parent_Industry__c;
                                    groupprofile.UltimateParent__c = mGroup.UltimateParent__c;
                                    groupprofile.Parent_Company__c = mGroup.Parent_Company__c; 

             AccountList = AccountPlanUtilities.QueryAccountByGroupIDLimit(Mgroup.id);   
                
                if(AccountList.size() >0){
                AccountSet = new Set<Account>();
                    AccountSet.addAll(AccountList);

                    for(Account acct : AccountSet){
                        AccountPlanWrapper wrapp = new AccountPlanWrapper();
                        wrapp.Acct = acct;
                        AuthorizedSet.add(acct.OwnerId);
                        AccountwithWrapperMap.put(acct.id,wrapp);
                    }
                
                    if(!AuthorizedSet.contains(userinfo.getUserId())){
                         //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,'A new Account Plan Group Profile cannot be created. You do not have a customer belongining to the group.'));
                        ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('1002').Status_Message__c));
        
                    }
                    
                //Callout for Customer information
                
                
                /*TMBAccountPlanServiceProxy.CUSTOMER_INFO[] customerInfos = new List<TMBAccountPlanServiceProxy.CUSTOMER_INFO>(); 
            String tempids = '';
            for(Account acct : AccountSet){
                tempids += acct.id+',';
            }          
            
            String ids = tempids.substring(0,tempids.length()-1);
            customerInfos = TMBAccountPlanServiceProxy.getCustomerByIds(ids);*/
            /*custinfoMap = new Map<String,TMBAccountPlanServiceProxy.CUSTOMER_INFO>();
            if(customerInfos !=null){
                if(customerInfos.size()>0){
                     for( TMBAccountPlanServiceProxy.CUSTOMER_INFO  custinfo :customerInfos ){
                    
                    custinfoMap.put(custinfo.SF_ID,custinfo);
                    } 
                }
            }*/
                    
                  
            
            
            /*for(Account acct: AccountList){
                 if(custinfoMap.containsKey(acct.id)){
                        acct.First_name__c = custinfoMap.get(acct.id).FNAME==null ||custinfoMap.get(acct.id).FNAME =='null'?'':custinfoMap.get(acct.id).FNAME ;
                        acct.Last_name__c = custinfoMap.get(acct.id).LNAME==null ||custinfoMap.get(acct.id).LNAME =='null'?'':custinfoMap.get(acct.id).LNAME ;
                    }
            }*/
                }
                
                
                
                
            }else{
            //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Not found any master Group record.'));
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('1003').Status_Message__c));
        
            isDisabled=true;
            }
             
            
            
            
        
        }else{
             //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Not found any Group profile record.'));
             ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('1004').Status_Message__c));
        
            isDisabled=true;
        }
        //paging
        setCon = new ApexPages.StandardSetController(AccountList);
        setCon.setPageSize(size);
        noOfRecords = setCon.getResultSize();
    }
    
    public GroupCompanyExControllerV2(){
        
       
        
    }
     public pageReference EditAccountPlan(){
         
         String ComProParameter = ApexPages.currentPage().getParameters().get('ComProParameter');
        
        
         PageReference pr = Page.CompanyProfileView;
        pr.setRedirect(true);
        pr.getParameters().put('GroupID', groupprofile.id);
        pr.getParameters().put('CompanyID',ComProParameter); 
        if(mode !=null && mode !=''){
            pr.getParameters().put('mode',mode);
            }
         if(ComProParameter !=null){
             List<AcctPlanWallet__c>  walletList = AccountPlanWalletUtilities.queryWalletbyCompanyID(ComProParameter);
             if(walletList.size()>0){
                pr.getParameters().put('WalletId',walletList.get(0).id); 
             }
         }
         
        return pr;
     }
    
        public pageReference InitiateAccountPlan(){
            /*=== Get size of Company Profile for create new or go to clone page : Jantanee Saetung R5.2 ===*/
            String accountKey = ApexPages.currentPage().getParameters().get('acctKey');
            Account mAcct = AccountwithWrapperMap.get(accountKey).acct;  
            
            PageReference pr ;
            pr = AccountPlanCloneUtils.GotoAccountPlanClonePage(mAcct.id,'',groupprofile.Id,CompanyID,WalletID);           
            return pr;
            
        /*try{
        String accountKey = ApexPages.currentPage().getParameters().get('acctKey');
        PageReference pr = Page.CompanyprofileView;
        //Creating CompanyProfile
            AcctPlanCompanyProfile__c comprofile = new AcctPlanCompanyProfile__c ();
                Account mAcct = AccountwithWrapperMap.get(accountKey).acct;
            
            comprofile.AccountName__c = mAcct.Name;
            if(comprofile.AccountName__c != null && comprofile.AccountName__c != ' ' && !comprofile.AccountName__c.contains('null')){
                comprofile.Account__c = mAcct.id;
                comprofile.AccountName__c = mAcct.Name;
                //comprofile.AccountName__c = mAcct.First_name__c+' '+mAcct.Last_name__c;
                //comprofile.Name = mAcct.First_name__c+' '+mAcct.Last_name__c;
                comprofile.Year__c = groupprofile.Year__c;
                comprofile.Status__c = 'Open';
                if(mAcct.Owner.Segment__c !=null){
                    //Account Plan Form support full form & short form : Jantanee Saetung R5.2
                    Boolean isMiniMode = AcctPlanMode__c.GetValues(mAcct.Owner.Segment__c).isMiniMode__c;
                    if(isMiniMode){
                        comprofile.isMiniMode__c = true;
                    }else if(mAcct.Account_Plan_Form__c == 'Short Form'){
                        comprofile.isMiniMode__c = true;
                    }else{
                        comprofile.isMiniMode__c = false;
                    }
                    //comprofile.isMiniMode__c = AcctPlanMode__c.GetValues(mAcct.Owner.Segment__c).isMiniMode__c;;
                }else{
                    ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,'The owner segment cannot be null. ')); 
                    return null;
                }
                comprofile.AcctPlanGroup__c = groupprofile.id;             
                
                insert comprofile;
                
                
                AcctPlanWallet__c wallet = AccountPlanUtilities.QueryAccountByCompanyProfile(comprofile.Id);
                AccountPlanCompletionEx completionEx = new AccountPlanCompletionEx(comprofile.id);
                if(wallet != null){
                    insert wallet;
                    comprofile.AccountPlanWalletID__c = wallet.id;
                    update comprofile;
                    pr.getParameters().put('WalletID', wallet.id);
                }
                
                pr.getParameters().put('GroupID',groupprofile.id);
                pr.getParameters().put('CompanyID',comprofile.id);
                if(mode !=null && mode !=''){
                    pr.getParameters().put('mode',mode);
                }
                pr.setRedirect(true);
                return pr;
            }else{
                pr.getParameters().put('AccountID',mAcct.id);
                if(mode !=null && mode !=''){
                    pr.getParameters().put('mode',mode);
                }
                pr.setRedirect(true);
                return pr;
            }
        }catch(DMLException e){
             ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));  
             return null;
        }*/
    }
    
    
    
    
    
    
    
    
    public pageReference redirect(){
        
         PageReference pr = Page.GroupCompanyEditV2;
            pr.setRedirect(true);
            pr.getParameters().put('GroupID',GroupID);
            pr.getParameters().put('CompanyID',CompanyID);
            if(walletId !=null && WalletID !=''){
            pr.getParameters().put('WalletID',walletID);
            }
         if(mode !=null && mode !=''){
            pr.getParameters().put('mode',mode);
            }
           return pr; 
    }
    
    public pageReference cancel(){      
        if(MasterGroupID != null){
            PageReference pr = new PageReference('/'+MasterGroupID);
            pr.setRedirect(true);
            return pr;
        }else{
            PageReference pr = Page.GroupCompanyViewV2;
            pr.setRedirect(true);
            pr.getParameters().put('GroupID',GroupID);
            pr.getParameters().put('CompanyID',CompanyID);
            if(walletId !=null && WalletID !=''){
                pr.getParameters().put('WalletID',walletID);
            }          
            if(mode !=null && mode !=''){
            pr.getParameters().put('mode',mode);
            }
            return pr;
        }
        
        return null; 
    }
    
    public pagereference dosave(){
        
        try{
            if(isNew){
                List<AcctPlanGroupProfile__c> ExistingProfile = [SELECT ID,Group__c,Year__c
                                                                From AcctPlanGroupProfile__c
                                                                WHERE Group__c =:MasterGroupID
                                                                AND Year__c =: groupprofile.Year__c];
                
                                 
                if(ExistingProfile.size()>0){
                      //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Group Profile in Year :'+groupprofile.Year__c+' has already created. Please select another year.'));
                        ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('1005a').Status_Message__c +' '+groupprofile.Year__c+' '+ Account_Plan_Status_Code__c.GetValues('1005b').Status_Message__c));
        
                    return null;
                }else{
                    if(groupprofile.Year__c != null && groupprofile.Year__c != ''){
                        insert groupprofile;
                    }else{
                        //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Year: Validation Error: Value is required.'));
                        ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('1006').Status_Message__c));
        
                        return null;
                    }
                    
                     AcctPlanGroupPort__c groupport = new AcctPlanGroupPort__c();
                    groupport.Group__c = mgroup.id;
                    groupport.Group_Name__c = mgroup.Name;
                    
                }
             
            }else{
                
              
             update groupprofile;   
                
                
                if(CustomerProfileList.size()>0){
                    //Update All Completions
               
                    //Group Profile Completion
                    //
        Integer FieldCount = 0;
        Integer FieldTotal = 0;
        if (groupprofile.Name != null) { FieldCount++; FieldTotal++;} else { FieldTotal++; }
        if (groupprofile.Year__c != null) { FieldCount++; FieldTotal++; } else { FieldTotal++; }
        //if (groupprofile.GroupIndustry__c != null) { FieldCount++; FieldTotal++; } else { FieldTotal++; }
        if (groupprofile.GroupRevenue__c != null) { FieldCount++; FieldTotal++; } else { FieldTotal++; }
        if (groupprofile.ShareholdingStructure__c != null) { FieldCount++; FieldTotal++; } else { FieldTotal++; }
        if (groupprofile.BusinessFlow__c != null) { FieldCount++; FieldTotal++; } else { FieldTotal++; }
        if (groupprofile.BargainingPowerOfSupplier__c != null) { FieldCount++; FieldTotal++; } else { FieldTotal++; }
        if (groupprofile.BargainingPowerOfBuyer__c != null) { FieldCount++; FieldTotal++; } else { FieldTotal++; }
        if (groupprofile.BarrierOfNewEntrant__c != null) { FieldCount++; FieldTotal++; } else { FieldTotal++; }
        if (groupprofile.ThreatOfSubstituteProduct__c != null) { FieldCount++; FieldTotal++;} else { FieldTotal++; }
        if (groupprofile.IndustryCompetition__c != null) { FieldCount++; FieldTotal++;} else { FieldTotal++; }
        if (groupprofile.FactorType1__c != null) { FieldCount++; FieldTotal++; } else { FieldTotal++; }
        List<AcctPlanContribution__c> contributionlist = [SELECT ID,
                                                          AccountPlanGroupProfile__c
                                                          FROM AcctPlanContribution__c
                                                          WHERE AccountPlanGroupProfile__c = :groupprofile.Id
                                                          AND Account_Plan_Company_Profile__c =null];
        if (contributionlist.size() > 0) { FieldCount++; FieldTotal++;} else { FieldTotal++; }

                     List<Account_Plan_Completion__c> CompletionList =  [SELECT ID, Name, Account_Plan_Company_Profile__c,
                                  Step_1_Percentage__c, Step_1_Required_Fields__c,Step_1_Entered_Fields__c,
                                  Account_Plan_Completion_Percentage__c
                                  FROM Account_Plan_Completion__c
                                  WHERE Account_Plan_Company_Profile__c IN: CustomerProfileList];
                    
                    for(Account_Plan_Completion__c completion : CompletionList){
                        completion.Step_1_Entered_Fields__c = FieldCount;
                        completion.Step_1_Required_Fields__c = FieldTotal;
                    }
                    
                    update CompletionList;
                    //
                    //End Group Profile Completion
                    
                    
                    
                }
                
                
                
                //When open with CompanyProfile
                if(CompanyID !=null && CompanyID !=''){
                    AccountPlanCompletionEx completionEx = new AccountPlanCompletionEx(CompanyID);  
                }
                
                
                
                
            }
            
            
        }catch(DMLException e){
              ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
              return null;
        }
         PageReference pr = Page.GroupCompanyViewV2;
            pr.setRedirect(true);
            pr.getParameters().put('CompanyID',CompanyID);
            pr.getParameters().put('GroupID',groupprofile.id);
            if(walletId !=null && WalletID !=''){
            pr.getParameters().put('WalletID',walletID);
            }
        if(mode !=null && mode !=''){
            pr.getParameters().put('mode',mode);
            }
           return pr; 
    }
    
    
    
  
}