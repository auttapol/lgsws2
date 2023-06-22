public without sharing class AcctPlanProStrGrpWalletCtrlV2 {
    
    private ApexPages.StandardController standardController;
    public  ViewState ViewState {get;set;}
    public String InfoMessage {get;set;}
    public String step {get;set;}
    public Boolean isStep4 {get;set;} 
    
    public boolean IsLock {get;set;}
    public String mode {get;set;}
    public Boolean isConsoleMode {get;set;}
    public boolean isHasProdStrategy {get;set;}
    public boolean isHasActionPlan {get;set;}
    public Boolean isMiniView {get;set;} 
    
    /*Account Team*/
    //public List<Account> AccountList ;
    //public Set<Account> AccountSet ;
    public Set<ID> AuthorizedSet ;
    public AcctPlanGroupProfile__c groupprofile {get;set;}
    //public  List<AcctPlanCompanyProfile__c> CustomerProfileList ;
    public String MasterGroupID {get;set;}
    public boolean isDisabled {get;set;}
    public boolean isHasPermission {get;set;}
    //Map<ID,String> AccountTeamMap ;
    public Group__c mGroup {get;set;}
    public boolean isHasAuthorized {get{
        
        isHasAuthorized = false;
        if(AuthorizedSet.contains(Userinfo.getUserId())){
            isHasAuthorized = true;
        }
        
        return isHasAuthorized;
        
    }set;}
    /*End Account Team*/
    
    /*******************************************************
        Start Group Wallet Customer 1000+
    *******************************************************/
    public Boolean isInitial {get;set;}
    public Boolean isPagiantion {get;set;}
    public String Year {get;set;}
    public String GroupProfileID {get;set;}
    public Decimal TotalGroupTargetNIByRm {get;set;}
    public Decimal TotalGroupExitingSOWGroup {get;set;}
    public Decimal EndCASA  {get;set;}
    public Decimal AvgCASA {get;set;}
    public Decimal AvgLoan {get;set;}
    public Decimal EndLoan {get;set;}
    public Decimal FXvolume {get;set;}
    public Decimal TFVolume {get;set;}
    //public Set<Id> AccountWithAccountPlan ;
    //public Set<Id> AccountWithoutAccountPlan ;
    public  String confirmMsg {get;set;}
    public  String waitBatch {get;set;}
    public String initialBatch {get;set;}
    public boolean isRefresh {get;set;}
    public  String Overlimit {get;set;} 
    
    public class walletWrapper{
        
        public  transient String HelpText {get;set;}
        public  transient String SummaryType {get;set;}
        public  transient String SummaryTypeForExcel {get;set;}
        public  transient AccountPlanWalletSizing__c WalletSizing {get;set;}
        public  transient List<AccountPlanWalletSizing__c> WalletSizingItem {get;set;}
        public  transient List<AccountPlanWalletSizing__c> Summary {get;set;}
    }
    Public Integer noOfRecords{get; set;}
    Public Integer size {get;set;}
    public ApexPages.StandardSetController setCon {get{
        if(setCon ==null){
            size = 100; 
            setCon = new ApexPages.StandardSetController([SELECT CashFee__c,CreditFee__c,DerivativeFee__c,Fee__c,FXFee__c,Group__c,ASFee__c ,BAFee__c,
                                                          IBFee__c,LGFee__c,Name,NIIc__c,NIId__c  ,AccountNamePE__c,
                                                          TFFee__c,SummaryType__c, GrandTotal__c,
                                                          IsGroupPerformance__c,IsGroupWallet__c,IsProductStrategy__c,TargetbyGroup__c
                                                          FROM AccountPlanWalletSizing__c
                                                          WHERE Group__c = :groupProfile.Group__c 
                                                          AND Year__c = :Year 
                                                          AND SummaryType__c = 'None' 
                                                          ORDER BY SummaryType__c,GrandTotal__c DESC,Account__c
                                                          LIMIT 1500]);
            setCon.setPageSize(size);
            noOfRecords = setCon.getResultSize();
        } 
        return setCon; 
        
    }set;} 

    
    /*Section 1 Summary Wallet Sizing*/
    public walletWrapper SummaryWalletSizingReport {
        get{ 
            SummaryWalletSizingReport = new walletWrapper();
            for(AccountPlanWalletSizing__c item : [SELECT Account__c,AccountId_PE__c,Account__r.Name,CashFee__c,CreditFee__c,DerivativeFee__c,Fee__c,FXFee__c,Group__c,ASFee__c ,BAFee__c,
                                                   IBFee__c,Id,LGFee__c,Name,NIIc__c,NIId__c,RefreshDate__c ,
                                                   NonRecurringFee__c,RecurringFee__c,TFFee__c,Year__c,SummaryType__c, GrandTotal__c,
                                                   IsGroupPerformance__c,IsGroupWallet__c,IsProductStrategy__c,TargetbyGroup__c
                                                   FROM AccountPlanWalletSizing__c
                                                   WHERE Group__c = :groupProfile.Group__c 
                                                   AND Year__c = :Year 
                                                   AND SummaryType__c != 'None' 
                                                   AND SummaryType__c = 'WalletSizing'
                                                   AND IsGroupWallet__c = true
                                                   ORDER BY SummaryType__c LIMIT 1])
            {
                SummaryWalletSizingReport.WalletSizing = item;
                SummaryWalletSizingReport.SummaryType = 'Group Wallet Sizing<br/>(Yearly)';
            }
            return SummaryWalletSizingReport;
        }set;
    }
    /*Section 2 Wallet Sizing Item for Pagination*/
    public List<AccountPlanWalletSizing__c> walletSizingList {
        get{ 
            walletSizingList = new List<AccountPlanWalletSizing__c>();
            walletSizingList.addAll((List<AccountPlanWalletSizing__c>)setcon.getRecords());
            return walletSizingList;
        }set;
    }
    
    /*Section 3 Summary Report*/
    public List<walletWrapper> SummaryReport {
        get{ 
            SummaryReport = new List<walletWrapper>();
            for(AccountPlanWalletSizing__c item : [SELECT Account__c,AccountId_PE__c,Account__r.Name,CashFee__c,CreditFee__c,DerivativeFee__c,Fee__c,FXFee__c,Group__c,ASFee__c ,BAFee__c,
                                                   IBFee__c,Id,LGFee__c,Name,NIIc__c,NIId__c,RefreshDate__c ,
                                                   NonRecurringFee__c,RecurringFee__c,TFFee__c,Year__c,SummaryType__c, GrandTotal__c,
                                                   IsGroupPerformance__c,IsGroupWallet__c,IsProductStrategy__c,TargetbyGroup__c
                                                   FROM AccountPlanWalletSizing__c
                                                   WHERE Group__c = :groupProfile.Group__c 
                                                   AND Year__c = :Year 
                                                   AND SummaryType__c != 'None' 
                                                   AND SummaryType__c != 'WalletSizing'
                                                   AND IsGroupWallet__c = true
                                                   //AND IsGroupPerformance__c = true 
                                                   ORDER BY SummaryType__c])
            {
                walletWrapper w = new walletWrapper();
                w.WalletSizing = item;
                if(item.SummaryType__c == 'WalletSizing'){
                    w.SummaryType = 'Group Wallet Sizing<br/>(Yearly)';
                    w.SummaryTypeForExcel = 'Group Wallet Sizing<br/>(Yearly)<br/>&nbsp;';
                }else if(item.SummaryType__c == 'TargetbyGroup'){
                    w.SummaryType = 'Target by Group';
                    w.SummaryTypeForExcel = 'Target by Group<br/>&nbsp;<br/>&nbsp;';
                }else if(item.SummaryType__c == 'ActualNI'){
                    w.SummaryType = 'Group\'s Actual NI<br/>(12-mth Rolling)';
                    w.SummaryTypeForExcel = 'Group\'s Actual NI<br/>(12-mth Rolling)<br/>&nbsp;';
                }else if(item.SummaryType__c == 'AdjustedNI'){
                    w.SummaryType = 'Group\'s Adjusted NI<br/>(12-mth Rolling)';
                    w.SummaryTypeForExcel = 'Group\'s Adjusted NI<br/>(12-mth Rolling)<br/>&nbsp;';
                }else if(item.SummaryType__c == 'ExistingSOW'){
                    w.SummaryType = '% Existing SOW<br/>Group';
                    w.SummaryTypeForExcel = '% Existing SOW<br/>Group<br/>&nbsp;';
                }else if(item.SummaryType__c == 'AspirationSOW'){
                    w.SummaryType = '% Aspiration<br/>SOW';
                    w.SummaryTypeForExcel = '% Aspiration<br/>SOW<br/>&nbsp;';
                }else if(item.SummaryType__c == 'ExpectedIncrementalNI'){
                    w.SummaryType = 'Expected<br/>Incremental NI<br/>(Unit: THB)';
                    w.SummaryTypeForExcel = 'Expected<br/>Incremental NI<br/>(Unit: THB)';
                }else if(item.SummaryType__c == 'ExpectedIncrementalNIStep5'){
                    w.SummaryType = 'Expected<br/>Incremental NI<br/>from Step 5';
                    w.SummaryTypeForExcel = 'Expected<br/>Incremental NI<br/>from Step 5';
                }else if(item.SummaryType__c == 'TotalCompanyNI'){
                    w.SummaryType = 'Total Group NI';
                    w.SummaryTypeForExcel = 'Total Group NI<br/>&nbsp;<br/>&nbsp;';
                }else if(item.SummaryType__c == 'ExpectedSOW'){
                    w.SummaryType = '% Expected SOW<br/>Group';
                    w.SummaryTypeForExcel = '% Expected SOW<br/>Group<br/>&nbsp;';
                }else if(item.SummaryType__c == 'AspirationSOWStep6'){
                    w.SummaryType = '% Aspiration<br/>SOW';
                    w.SummaryTypeForExcel = '% Aspiration<br/>SOW<br/>&nbsp;';
                }else if(item.SummaryType__c == 'CompareExpectedtoAspirationSOW'){
                    w.SummaryType = 'Compare %<br/>Aspiration SOW<br/> and % Expected<br/>SOW';
                    w.SummaryTypeForExcel = 'Compare %<br/>Aspiration SOW<br/> and % Expected<br/>SOW';
                }else if(item.SummaryType__c == 'ExpectedIncrementalNIStep6'){
                    w.SummaryType = 'ExpectedIncrementalNIStep6';
                    w.SummaryTypeForExcel = 'ExpectedIncrementalNIStep6<br/>&nbsp;<br/>&nbsp;';
                }
                SummaryReport.add(w);
            }
            return SummaryReport;
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
        setCon.next();
    }
    /*******************************************************
        End Group Wallet Customer 1000+
    *******************************************************/


    /**************************************************************
        Start Customer Understanding breakdown for each customer
    ***************************************************************/
    Public Integer noOfRecords2 {get;set;}
    public ApexPages.StandardSetController setCon2 {get{
         Set<Id> AccountWithAccountPlan = new Set<Id>();
                Set<Id> AccountWithoutAccountPlan = new Set<Id>();
                List<AcctPlanCompanyProfile__c> acctCompanyProfile = [SELECT id,AccountName__c,Account__c,isHasProdStrategy__c 
                                                                  FROM AcctPlanCompanyProfile__c 
                                                                  WHERE Account__r.Group__c = :groupProfile.Group__c
                                                                  //AND isHasProdStrategy__c = TRUE
                                                                  //AND isActive__c = true
                                                                  AND Year__c = :groupProfile.year__c];
                
                for(AcctPlanCompanyProfile__c item : acctCompanyProfile){
                    AccountWithAccountPlan.add(item.Account__c);
                }
                List<Account> accountListInitial = [SELECT Id, Name,Group__c,Group__r.Name 
                                                    FROM Account 
                                                    WHERE Group__c = :groupProfile.Group__c
                                                    AND Id NOT IN : AccountWithAccountPlan ];
                for(Account item : accountListInitial){
                    AccountWithoutAccountPlan.add(item.id);
                }
        if(setCon2 ==null){
            size = 100; 
            setCon2 = new ApexPages.StandardSetController([SELECT   Ending_CASA__c ,                       
                                                                    Average_CASA__c ,
                                                                    Average_loan_outstanding__c,
                                                                    Ending_loan_outstanding__c,
                                                                    FX_volume__c,
                                                                    TF_Volume__c,
                                                                    AcctPlanWallet__r.AcctPlanCompanyProfile__r.AccountName__c,
                                                                    Account__c,Year__c,AccountName__c
                                                             FROM    AcctPlanCusUnderstanding__c
                                                             WHERE   Year__c = :Year  
                                                             AND (Account__c IN : AccountWithoutAccountPlan
                                                             OR Account__c IN : AccountWithAccountPlan  )
                                                             ORDER BY GrandTotal__c DESC ,Account__c
                                                             LIMIT 1500
                                                             ] );

            setCon2.setPageSize(size);
            noOfRecords2 = setCon2.getResultSize();
        } 
        return setCon2; 
        
    }set;} 
    public List<AcctPlanCusUnderstanding__c> customerUnderstandingList {
        get{ 
            customerUnderstandingList = new List<AcctPlanCusUnderstanding__c>();
            System.debug(loggingLevel.Error, '*** setCon2.getRecords().size(): ' + setCon2.getRecords().size());
            customerUnderstandingList.addAll((List<AcctPlanCusUnderstanding__c>)setCon2.getRecords());
            return customerUnderstandingList;
        }set;
    }

    public Boolean hasNext2 {
        get {
            return setCon2.getHasNext();
        }
        set;
    }
    public Boolean hasPrevious2 {
        get {
            return setCon2.getHasPrevious();
        }
        set;
    }  
    public Integer pageNumber2 {
        get {
            return setCon2.getPageNumber();
        }
        set;
    }  
    public void first2() {
        setCon2.first();
    }  
    public void last2() {
        setCon2.last();
    }  
    public void previous2() {
        setCon2.previous();
    }  
    public void next2() {
        setCon2.next();
    }
    
    /**************************************************************
        End Customer Understanding breakdown for each customer
    ***************************************************************/
    
    public AcctPlanCompanyProfile__c companyprofile {get;set;}
    public DateTime  RefreshAsOf {get;set;}
    public Boolean isOverlimit {get;set;}
    //public Integer counter {get;set;}
    public AcctPlanProStrGrpWalletCtrlV2(ApexPages.StandardController controller){
        this.ViewState = new ViewState();        
        this.standardController = controller;   
        isOverlimit = false;
        getUrlParams();
        createViewModel();
        List<AccountPlanWalletSizing__c> CountCustomerList = [SELECT Id FROM AccountPlanWalletSizing__c
                                                      WHERE Group__c = :groupProfile.Group__c 
                                                      AND Year__c = :Year 
                                                      AND SummaryType__c = 'None' 
                                                      ];
        Integer counter = Integer.valueOf(CountCustomerList.size());
        System.debug('counter='+counter);
        if(counter > 1500){
            isOverlimit = true;
        }                                      
        /*List<AccountPlanWalletSizing__c> walletWrapperListQuery = [SELECT Id ,RefreshDate__c 
                                                                           FROM AccountPlanWalletSizing__c
                                                                           WHERE Group__c = :groupProfile.Group__c
                                                                           AND Year__c = :groupProfile.Year__c
                                                                           //AND SummaryType__c  != 'None' 
                                                                           ];
        if(walletWrapperListQuery.size()>0){
            AccountPlanWalletSizing__c refreshDate = walletWrapperListQuery.get(0);  
            RefreshAsOf = refreshDate.RefreshDate__c; 
        }*/
    }
    
    private void getUrlParams(){
        List<Account> AccountList = new  List<Account>();
        Set<Account> AccountSet = new Set<Account>();
        ViewState.CompanyID = ApexPages.currentPage().getParameters().get('CompanyID');
        ViewState.GroupID   = ApexPages.currentPage().getParameters().get('GroupID');
        ViewState.WalletID  = ApexPages.currentPage().getParameters().get('WalletID');
        MasterGroupID = ApexPages.currentPage().getParameters().get('MasterGroup');
        step = ApexPages.currentPage().getParameters().get('step');
        isStep4 = false;
        if(step == '4'){
            isStep4 = true;
        }
        
        mode = ApexPages.currentPage().getParameters().get('mode');
        if(mode=='console'){
            isConsoleMode = true;
        }else{
            isConsoleMode = false;
        }
        
        if(ViewState.CompanyID !=null && ViewState.CompanyID !=''){
            companyprofile = AccountPlanUtilities.QueryAcctPlanCompanyProfileByID(ViewState.CompanyID);
            
            ishasProdStrategy = companyprofile.isHasProdStrategy__c;
            isHasActionPlan = companyprofile.isHasActionPlan__c;
            System.debug(AccountPlanUtilities.OWNERSEGMENT);
            if(AccountPlanUtilities.OWNERSEGMENT != null){
                isMiniView = AccountPlanUtilities.ISMINIVIEW;
            }else{
                isMiniView = false;
            }
        }
        /*Account Team*/
        
        //Check Permission
        isHasPermission = false;
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
        Map<ID,String> AccountTeamMap = new Map<ID,String>();
        system.debug('ViewState.GroupID='+ViewState.GroupID);
        if(ViewState.GroupID  !=null && ViewState.GroupID !='' ){
            groupprofile = AccountPlanUtilities.QueryGroupProfileByID(ViewState.GroupID).get(0);            
            AccountList = AccountPlanUtilities.QueryAccountByGroupID(groupprofile.Group__c);     
            
            if(AccountList.size()>0){ 
                AccountSet = new Set<Account>();
                AccountSet.addAll(AccountList);
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
                    System.System.debug(loggingLevel.Error, '*** acct.id: ' + acct.id);
                    AuthorizedSet.add(acct.OwnerId); 
                } 
            }
        }else if(MasterGroupID !=null &&MasterGroupID !=''){ 
            isDisabled = false;
            List<Group__c> mastergroup = [SELECT ID,Name, GroupCompany__c 
                                          /*, GroupIndustry__c */
                                          , Parent_Company__c 
                                          /*, ParentIndustry__c */
                                          ,UltimateParent__c 
                                          FROM Group__c
                                          WHERE ID =:MasterGroupID];
            if(mastergroup.size()<=0){
                isDisabled=true;
            }
            
        }else{
            isDisabled=true;
        }
        system.debug('isDisabled='+isDisabled);
        system.debug('isHasPermission='+isHasPermission);
        system.debug('isHasAuthorized='+isHasAuthorized);

        confirmMsg =  Account_Plan_Status_Code__c.GetValues('1017').Status_Message__c;
        waitBatch = Account_Plan_Status_Code__c.GetValues('1018').Status_Message__c;
        initialBatch = Account_Plan_Status_Code__c.GetValues('1019').Status_Message__c;
        Overlimit = Account_Plan_Status_Code__c.GetValues('6001').Status_Message__c;
        isRefresh = false;
    }
    
    private void createViewModel(){
        try{
                isPagiantion = true;
                List<AccountPlanWalletSizing__c> walletWrapperListQuery = [SELECT Id 
                                                                           FROM AccountPlanWalletSizing__c
                                                                           WHERE Group__c = :groupProfile.Group__c
                                                                           AND Year__c = :groupProfile.Year__c];
                
                if(walletWrapperListQuery.size() >0){
                    isInitial = false;
                    isDisabled = false;                    
                }else{
                    isInitial = true;
                }
                 
                
                GroupProfileID = ApexPages.currentPage().getParameters().get('GroupID');
                //groupprofile = [SELECT Id,Name,Year__c,Group__c,Group__r.Name,GroupName__c  FROM AcctPlanGroupProfile__c WHERE Id = :GroupProfileID];
                Year = groupProfile.Year__c;


                /*Get Customer with/without Account Plan*/
                Set<Id> AccountWithAccountPlan = new Set<Id>();
                Set<Id> AccountWithoutAccountPlan = new Set<Id>();
                List<AcctPlanCompanyProfile__c> acctCompanyProfile = [SELECT id,AccountName__c,Account__c,isHasProdStrategy__c 
                                                                  FROM AcctPlanCompanyProfile__c 
                                                                  WHERE AcctPlanGroup__r.Group__c = :groupProfile.Group__c
                                                                  //AND isHasProdStrategy__c = TRUE
                                                                  //AND isActive__c = true
                                                                  AND Year__c = :groupProfile.year__c];
                
                for(AcctPlanCompanyProfile__c item : acctCompanyProfile){
                    AccountWithAccountPlan.add(item.Account__c);
                }
                List<Account> accountListInitial = [SELECT Id, Name,Group__c,Group__r.Name 
                                                    FROM Account 
                                                    WHERE Group__c = :groupProfile.Group__c
                                                    AND Id NOT IN : AccountWithAccountPlan ];
                for(Account item : accountListInitial){
                    AccountWithoutAccountPlan.add(item.id);
                }
                
                System.System.debug(loggingLevel.Error, '*** AccountWithAccountPlan.size(): ' + AccountWithAccountPlan.size());
                
                TotalGroupTargetNIByRm = 0;
                for (AcctPlanCompanyPort__c item :AccountPlanCompanyPortSelector.getAllCompanyPortUnderGroupByGroupProfolioId(ViewState.GroupID)) {
                    TotalGroupTargetNIByRm = TotalGroupTargetNIByRm +(item.Target_NI_By_RM__c == null ? 0 : item.Target_NI_By_RM__c);
                }
                
                List<AccountPlanWalletSizing__c> GrandTotalAdjustedNIList =[SELECT GrandTotal__c FROM AccountPlanWalletSizing__c
                                                                            WHERE Group__c = :groupProfile.Group__c 
                                                                            AND Year__c = :Year
                                                                            AND SummaryType__c = 'AdjustedNI' LIMIT 1];
                AccountPlanWalletSizing__c GrandTotalAdjustedNI = new AccountPlanWalletSizing__c();
                if(GrandTotalAdjustedNIList.size() > 0){
                    GrandTotalAdjustedNI = GrandTotalAdjustedNIList.get(0);
                    
                }
                List<AccountPlanWalletSizing__c> GrandTotalWalletSizingList =[SELECT GrandTotal__c FROM AccountPlanWalletSizing__c
                                                                              WHERE Group__c = :groupProfile.Group__c 
                                                                              AND Year__c = :Year
                                                                              AND SummaryType__c = 'WalletSizing' LIMIT 1];
                AccountPlanWalletSizing__c GrandTotalWalletSizing = new AccountPlanWalletSizing__c();
                if(GrandTotalWalletSizingList.size() > 0){
                    GrandTotalWalletSizing = GrandTotalWalletSizingList.get(0);
                }
                if(GrandTotalAdjustedNIList.size() > 0 && GrandTotalWalletSizingList.size() > 0){
                    if(GrandTotalWalletSizing.GrandTotal__c != null && GrandTotalWalletSizing.GrandTotal__c !=0 && GrandTotalAdjustedNI.GrandTotal__c != null){
                        TotalGroupExitingSOWGroup = (GrandTotalAdjustedNI.GrandTotal__c / GrandTotalWalletSizing.GrandTotal__c )*100;
                    }else{
                        TotalGroupExitingSOWGroup = 0;
                    }
                }
                IsLock =  AcctPlanGroupWalletLockService.IsLock(groupProfile.Group__c);
                System.debug('::: IsLock = ' + IsLock);
                
                /********************************************************************
                    Understanding only account with wallet
                ********************************************************************/
                /*Set<Id> AccountWithAccountPlan = new Set<Id>();
                List<AcctPlanCompanyProfile__c> acctCompanyProfile = [SELECT id,AccountName__c,Account__c,isHasProdStrategy__c 
                                                                      FROM AcctPlanCompanyProfile__c 
                                                                      WHERE AcctPlanGroup__c = :groupProfile.id
                                                                      //AND isHasProdStrategy__c = TRUE
                                                                      //AND isActive__c = true
                                                                      AND Year__c = :groupProfile.year__c];
            
                
                for(AcctPlanCompanyProfile__c item : acctCompanyProfile){
                    AccountWithAccountPlan.add(item.Account__c);
                }*/
                EndCASA = 0;
                AvgCASA = 0;
                AvgLoan = 0;
                EndLoan = 0;
                FXvolume = 0;
                TFVolume = 0;
                if (customerUnderstandingList.size() > 0) {
                    for(AcctPlanCusUnderstanding__c item : customerUnderstandingList){
                        EndCASA += (item.Ending_CASA__c == null ? 0 : item.Ending_CASA__c);
                        AvgCASA += (item.Average_CASA__c== null ? 0 : item.Average_CASA__c);
                        AvgLoan += (item.Average_loan_outstanding__c== null ? 0 : item.Average_loan_outstanding__c);
                        EndLoan += (item.Ending_loan_outstanding__c== null ? 0 : item.Ending_loan_outstanding__c);
                        FXvolume += (item.FX_volume__c== null ? 0 : item.FX_volume__c);
                        TFVolume += (item.TF_Volume__c== null ? 0 : item.TF_Volume__c);
                    }
                }else {
                    EndCASA = 0;
                    AvgCASA = 0;
                    AvgLoan = 0;
                    EndLoan = 0;
                    FXvolume = 0;
                    TFVolume = 0;
                }
                /*if (AccountWithAccountPlan.size() > 0) {
                    AggregateResult[] ar = AccountPlanCustomerUnderstandingSelector.getSummaryByAccountIdsAndYear(AccountWithAccountPlan, groupProfile.Year__c);
                    if(ar.size() > 0){
                        EndCASA = (decimal) ar[0].get('EndCASA');
                        AvgCASA = (decimal) ar[0].get('AvgCASA');
                        AvgLoan = (decimal) ar[0].get('AvgLoan');
                        EndLoan = (decimal) ar[0].get('EndLoan');
                        FXvolume = (decimal) ar[0].get('FXvolume');
                        TFVolume = (decimal) ar[0].get('TFVolume');
                    }else{
                        EndCASA = 0;
                        AvgCASA = 0;
                        AvgLoan = 0;
                        EndLoan = 0;
                        FXvolume = 0;
                        TFVolume = 0;
                    }
                }else {
                    EndCASA = 0;
                    AvgCASA = 0;
                    AvgLoan = 0;
                    EndLoan = 0;
                    FXvolume = 0;
                    TFVolume = 0;
                }*/
                          
            
        }catch(QueryException ex){
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage())); 
            system.debug(ex.getMessage()  );
        }     
    }



    public AcctPlanProStrGrpWalletCtrlV2(ID GroupProfileID){
        system.debug('=========GroupProfileID='+GroupProfileID);
         this.ViewState = new ViewState();
        ViewState.GroupID = GroupProfileID;
        Refresh();
    }
    

    public PageReference Refresh(){
        InfoMessage ='';


        try{
                groupProfile = [SELECT Id,Name,Year__c,Group__c,Group__r.Name  FROM AcctPlanGroupProfile__c WHERE Id = :ViewState.GroupID];
                Set<Id> AccountWithAccountPlan = new Set<Id>();
                Set<Id> AccountWithoutAccountPlan = new Set<Id>();
                Set<Id> AccountIdAll = new Set<Id>();

                 Set<Id> AcctPlanCompanyProfileIDSet = new Set<Id>();
                List<AcctPlanCompanyProfile__c> acctCompanyProfile = [SELECT id,AccountName__c,Account__c,isHasProdStrategy__c 
                                                                  FROM AcctPlanCompanyProfile__c 
                                                                  WHERE AcctPlanGroup__r.Group__c = :groupProfile.Group__c
                                                                  AND isHasProdStrategy__c = TRUE
                                                                  //AND isActive__c = true
                                                                  AND Year__c = :groupProfile.year__c];
            
                system.debug('acctCompanyProfile='+acctCompanyProfile.size());
                for(AcctPlanCompanyProfile__c item : acctCompanyProfile){
                    AcctPlanCompanyProfileIDSet.add(item.id);
                }
            
                AggregateResult[] ProdStrategyList = [SELECT AccountId__c 
                                                              FROM AcctPlanProdStrategy__c 
                                                              WHERE AcctPlanCompanyProfileID__c IN : AcctPlanCompanyProfileIDSet
                                                              AND AcctPlanCompanyProfileID__r.Year__c = :groupProfile.year__c
                                                              GROUP BY AccountId__c];
            
                system.debug('ProdStrategyList='+ProdStrategyList.size());
                /*for(AcctPlanProdStrategy__c item : ProdStrategyList){
                    AccountWithAccountPlan.add(item.AccountId__c);
                }*/
                for (AggregateResult ar : ProdStrategyList){

                    Id accountId = (ID) ar.get('AccountId__c');
                    system.debug('accountId='+accountId);
                    AccountWithAccountPlan.add(accountId);
                }
                        
                List<Account> accountListInitial = [SELECT Id, Name,Group__c,Group__r.Name 
                                                    FROM Account 
                                                    WHERE Group__c = :groupProfile.Group__c
                                                    AND Id NOT IN : AccountWithAccountPlan ];
                system.debug('accountListInitial='+accountListInitial.size());
                for(Account item : accountListInitial){
                    AccountWithoutAccountPlan.add(item.id);
                }
                IsLock =  AcctPlanGroupWalletLockService.IsLock(groupProfile.Group__c);

                List<Account> accountListAll = [SELECT Id, Name,Group__c,Group__r.Name 
                                                    FROM Account 
                                                    WHERE Group__c = :groupProfile.Group__c];
                  for(Account item : accountListAll){
                    AccountIdAll.add(item.id);
                  } 
                   System.debug(loggingLevel.Error, '*** AccountIdAll: ' + AccountIdAll);

                if(!IsLock){
                    AcctPlanGroupWalletLockService.Lock(groupProfile.Group__c);
                    List<AccountPlanWalletSizing__c> walletWrapperListQuery = [SELECT Id 
                                                                               FROM AccountPlanWalletSizing__c
                                                                               WHERE Group__c = :groupProfile.Group__c
                                                                               AND Year__c = :groupProfile.Year__c
                                                                               //AND SummaryType__c  != 'None' 
                                                                               ];
                    
                    if(walletWrapperListQuery.size() >0){
                        delete walletWrapperListQuery;
                        walletWrapperListQuery.clear();
                    }

                    List<AcctPlanCusUnderstanding__c> AcctPlanCusUnderstandingList = [SELECT ID
                                                                                        FROM AcctPlanCusUnderstanding__c
                                                                                        WHERE Year__c =: groupProfile.Year__c
                                                                                        AND AcctPlanWallet__c = null
                                                                                        AND Account__c IN :AccountIdAll ];

                    if(AcctPlanCusUnderstandingList.size() >0){ 
                        delete AcctPlanCusUnderstandingList;
                        AcctPlanCusUnderstandingList.clear();
                    }
                    if(walletWrapperListQuery.size() <=0){
                        System.debug(loggingLevel.Error, '*** object: ' + AccountWithAccountPlan.size());
                        
                        System.debug(loggingLevel.Error, '*** AccountWithoutAccountPlan: ' + AccountWithoutAccountPlan.size());
                        GroupWalletRefreshEntranceBatch1 batch = 
                            new GroupWalletRefreshEntranceBatch1( AccountWithAccountPlan
                                                                 , AccountWithoutAccountPlan
                                                                 , groupProfile.Group__c
                                                                 , groupProfile.Year__c
                                                                 , groupProfile.Id ,true);  
                        Database.executeBatch(batch ,100);  
                         //Set<id> accountIds = (new Map<Id,SObject>(scope)).keySet();
       /* Set<id> acctCompanyProfileIds = new Set<id>();
        Set<id> walletIds = new Set<id>();
        // Logic to be Executed batch wise    
        List<AcctPlanCompanyProfile__c> acctCompanyProfileteest = [SELECT id,AccountName__c,Account__c,isHasProdStrategy__c ,AccountPlanWalletID__c
                                                                  FROM AcctPlanCompanyProfile__c 
                                                                  WHERE Account__c IN :AccountWithAccountPlan
                                                                  AND Year__c = :groupProfile.Year__c
                                                                  AND isHasProdStrategy__c = true];  
        if(acctCompanyProfileteest.size()>0){
          for(AcctPlanCompanyProfile__c item : acctCompanyProfileteest){
            acctCompanyProfileIds.add(item.id);
            walletIds.add(item.AccountPlanWalletID__c);
          }
          
        }                                                        

        AccountPlanRefreshService.RefreshProductStrategyGroupWalletGroupPerformance(AccountWithAccountPlan, acctCompanyProfileIds, walletIds, groupProfile.id);
      
*/

                        IsLock = true; 
                        
                    }
                }
                groupProfile.RefreshAsOf__c = datetime.now();
                update groupprofile;
            
        }catch(QueryException ex){
            createNotificationMessageError(ex.getMessage());        
        }        
        createNotificationMessage();      
        return null;
    }
    
    public void createNotificationMessageError(string message){
        InfoMessage =  ' <div class="alert alert-danger"> '
            + '     <a href="#" class="close" data-dismiss="alert">&times;</a> '
            + '    <b>'+message+'</b>'
            + ' </div> ';    
    }
    
    private void createNotificationMessage(){    
        /*InfoMessage =  ' <div class="alert alert-danger" style="clear:both;   text-align: left;    color: white;    background-color: #FF4000;"> '
            + '<a href="#" class="close" data-dismiss="alert">&times;</a> '
            + '<p><b>System will take approx 5-10 mins to refresh data. Email notification will be sent after finished. Please click the link from an email or Press F5 on screen.</b></p> '
            + '<p><b>(ระบบได้รับ request แล้ว  จะใช้เวลาประมาณ 5-10 นาที คุณจะได้รับอีเมล์หลังจากระบบประมวลผลเสร็จ   กรุณาคลิกลิงค์จากอีเมล์ หรือ กด F5 จากหน้าจอเพื่อดูข้อมูลใหม่)</b> </p> '
            + ' </div><script> jsHideToggle();  </script> ';*/
       /* InfoMessage =  ' <div class="alert alert-danger" style="clear:both;   text-align: left;    color: white;    background-color: #FF4000;"> '
            + '<a href="#" class="close" data-dismiss="alert">&times;</a> '
            + '<p><b>'+Account_Plan_Status_Code__c.GetValues('1016a').Status_Message__c+'</b></p> '
            + '<p><b>'+Account_Plan_Status_Code__c.GetValues('1016b').Status_Message__c+'</b> </p> '
            + ' </div><script> jsHideToggle();  </script> ';*/


              InfoMessage = '<div class="alert alert-info text-left" role="alert"'
                                                                        +'style="width:100%;float:left;margin-right:25px;background-color: #FFFFCC;color:#000000;border-color:#3399FF;padding: 8px 20px 15px 20px;">'
                                                                        +'<i class="glyphicon glyphicon-info-sign" '
                                                                        +'style="float:left;color: #006DCC;font-size: 24px;margin-right: 10px;'
                                                                        +'top: 5px;"></i><span>'
                                                                        + '<p>'+Account_Plan_Status_Code__c.GetValues('1016a').Status_Message__c+'</p> '
        + '<p>'+Account_Plan_Status_Code__c.GetValues('1016b').Status_Message__c+'</p> '
        +'</span></div>';
        
            isRefresh = true;
    }
    /*  Data Model For This Page */
    public class ViewState{
        //Account Navigation information
        public  String CompanyID {get;set;}
        public  String GroupID {get;set;} 
        public  String WalletID {get;set;}
        //DTO
        public  AccountPlanProductStrategyService.AcctPlanProdStrategyCompanyInfo ViewModel {get;set;} 
    }  
    public List<AccountPlanWalletSizing__c> getWalletSizingListFull () { 
            return [SELECT Account__c,AccountId_PE__c,Account__r.Name,CashFee__c,CreditFee__c,DerivativeFee__c,Fee__c,FXFee__c,Group__c,ASFee__c ,BAFee__c,
                                                          IBFee__c,Id,LGFee__c,Name,NIIc__c,NIId__c,RefreshDate__c  ,
                                                          NonRecurringFee__c,RecurringFee__c,TFFee__c,Year__c,SummaryType__c, GrandTotal__c,
                                                          IsGroupPerformance__c,IsGroupWallet__c,IsProductStrategy__c,TargetbyGroup__c,
                                                          Account_Plan_Company_Profile__r.AccountName__c ,Account_Plan_Company_Profile__c
                                                          FROM AccountPlanWalletSizing__c
                                                          WHERE Group__c = :groupProfile.Group__c 
                                                          AND Year__c = :Year 
                                                          AND SummaryType__c = 'None' 
                                                          ORDER BY SummaryType__c,GrandTotal__c DESC,Account__c
                                                          LIMIT 1500
                                                          ];
    }
    public List<AcctPlanCusUnderstanding__c> getCustomerUnderstandingListFull () {
                Set<Id> AccountWithAccountPlan = new Set<Id>();
                Set<Id> AccountWithoutAccountPlan = new Set<Id>();
                List<AcctPlanCompanyProfile__c> acctCompanyProfile = [SELECT id,AccountName__c,Account__c,isHasProdStrategy__c 
                                                                  FROM AcctPlanCompanyProfile__c 
                                                                  WHERE Account__r.Group__c = :groupProfile.Group__c
                                                                  //AND isHasProdStrategy__c = TRUE
                                                                  //AND isActive__c = true
                                                                  AND Year__c = :groupProfile.year__c];
                
                for(AcctPlanCompanyProfile__c item : acctCompanyProfile){
                    AccountWithAccountPlan.add(item.Account__c);
                }
                List<Account> accountListInitial = [SELECT Id, Name,Group__c,Group__r.Name 
                                                    FROM Account 
                                                    WHERE Group__c = :groupProfile.Group__c
                                                    AND Id NOT IN : AccountWithAccountPlan ];
                for(Account item : accountListInitial){
                    AccountWithoutAccountPlan.add(item.id);
                }
            return [SELECT   Ending_CASA__c ,                       
                                            Average_CASA__c ,
                                            Average_loan_outstanding__c,
                                            Ending_loan_outstanding__c,
                                            FX_volume__c,
                                            TF_Volume__c,
                                            AcctPlanWallet__r.AcctPlanCompanyProfile__r.AccountName__c,
                                            Account__c,Year__c,AccountName__c
                                     FROM    AcctPlanCusUnderstanding__c
                                     WHERE   Year__c = :Year  
                                     AND (Account__c IN : AccountWithoutAccountPlan
                                     OR Account__c IN : AccountWithAccountPlan  )
                                     ORDER BY GrandTotal__c DESC ,Account__c
                                                             LIMIT 1500
                                                             ];
    }
}