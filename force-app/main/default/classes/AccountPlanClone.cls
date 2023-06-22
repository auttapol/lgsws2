public class AccountPlanClone {
    public ApexPages.StandardController ctrl {get; set;}
    public String GroupID {get;set;}
    public String CompanyID {get;set;}
    public String CompanyIDClone{get;set;}
    public String AccountID {get;set;}
    public String CompanyPortID {get;set;}
    public String WalletID {get;set;}
    public String FiscalYearStr {get;set;}
    
    public Account acct {get;set;}
    public Boolean isValid {get;set;}
    public boolean isDisabled {get;set;}
    public boolean isClone {get;set;}
    public boolean isCloneAction {get;set;}
    public boolean isDup {get;set;}
    public boolean isActiveIcon {get;set;}
    public AcctPlanCompanyProfile__c companyprofile {get;set;}
    public AcctPlanCompanyProfile__c companyprofileDetail {get;set;}
    public AcctPlanPortfolio__c  portfolio {get;set;}
    public List <AcctPlanCompanyProfile__c> CompanyProfileList {get;set;} 
    public AcctPlanCompanyPort__c comport {get;set;}
    public AcctPlanGroupProfile__c groupProfile {get;set;}
    public String YearStr {get;set;}

    
    public boolean isAvailableforAcctPlan {get;set;}
    public boolean isfromSingleView {get;set;}
    public boolean isOwnerAccount {get;set;}
    public boolean isSegmentNull {get;set;}
    public boolean isAccountTeamReadWrite {get;set;}
    public boolean isHasPermission {get;set;}

    public boolean isPortfolio {get;set;}
    public boolean isGroupProfile {get;set;}
    public boolean isCompanyProfile {get;set;}
    public boolean isHideSection {get;set;}

    //Lock Clone Account Plan
    public boolean IsLock { get; set; }
    public AcctPlanGroupWalletLock__c LockAccountPlan {get;set;}
    public List<AcctPlanGroupWalletLock__c> lock {get;set;}
    
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
    public String CloneMessage {get;set;}
    public String AlertCloneMessage {get;set;}
    public String MsgCreateByCSV {get;set;}
    
    public AccountPlanClone(ApexPages.StandardController controller){
        ctrl = controller;
        isValid = false;
        isDisabled = false;
        isDup = false;
        isCloneAction = false;
        isHideSection = false;
        
        isAvailableforAcctPlan = false;
        isOwnerAccount = true;
        isSegmentNull = false;
        isAccountTeamReadWrite = false;
        isHasPermission = false;

        isfromSingleView = false;
        isPortfolio = false;
        isGroupProfile = false;
        isCompanyProfile = false;
        
        AccountID = ApexPages.currentPage().getParameters().get('AccountID');
        CompanyPortID = ApexPages.currentPage().getParameters().get('CompanyPortID');
        GroupID = ApexPages.currentPage().getParameters().get('GroupID');
        CompanyID = ApexPages.currentPage().getParameters().get('CompanyID');
        WalletID = ApexPages.currentPage().getParameters().get('WalletID');
        FiscalYearStr = ApexPages.currentPage().getParameters().get('FiscalYearStr');
        
        companyprofile = new AcctPlanCompanyProfile__c();
        comport = new AcctPlanCompanyPort__c();
        
        // From Porfolio Management
        if(CompanyPortID !=null && CompanyPortID != ''){
            List<AcctPlanCompanyPort__c> comportlistquery = AccountPlanUtilities.QueryCompanyPortbyID(CompanyPortID);
            if(comportlistquery.size()>0){
                comport = comportlistquery.get(0);
                AccountID = comport.Account__c;
                YearStr = comport.Account_Plan_Portfolio__r.Year__c;
            }
                isfromSingleView = false;
                isPortfolio = true;
                isGroupProfile = false;
                isCompanyProfile = false;
            
            // From Group Profile
        }else if(GroupID !=null && GroupID != ''){
            List<AcctPlanGroupProfile__c> groupProfilelistquery = AccountPlanUtilities.QueryGroupProfileByID(GroupID);
            if(groupProfilelistquery.size()>0){
                groupProfile = groupProfilelistquery.get(0);
                //AccountID from get parameter
                YearStr = groupProfile.Year__c;
            }
                isfromSingleView = false;
                isPortfolio = false;
                isGroupProfile = true;
                isCompanyProfile = false;

            // From Company Profile
        }else if(CompanyID != null && CompanyID != ''){
            AcctPlanCompanyProfile__c CompanyParam = AccountPlanUtilities.QueryAcctPlanCompanyProfileByID(CompanyID);
            AccountID = CompanyParam.Account__c;
            //YearStr = CompanyParam.Year__c; 
            CompanyIDClone = CompanyID;
                isfromSingleView = true;
                isPortfolio = false;
                isGroupProfile = false;
                isCompanyProfile = true;
            
        }else if(AccountID !=null && AccountID != ''){
                isfromSingleView = true;
                isPortfolio = false;
                isGroupProfile = false;
                isCompanyProfile = false;
        }
        
        // From Customer Single View
        if(AccountID !=null && AccountID != ''){
            CompanyProfileList = [SELECT ID,AccountName__c,Account__c,AcctPlanGroup__c,Name,AcctPlanGroup__r.Name,LastModifiedDate,
                                  Year__c,Status__c,OwnerID,Owner.Name,LastModifiedByID,LastModifiedBy.name,Account__r.Owner.Segment__c
                                  FROM AcctPlanCompanyProfile__c
                                  WHERE Account__c =:AccountID 
                                  ORDER BY Year__c DESC];
            
            List<Account> acctList = AccountPlanUtilities.QueryAccountByAcctID(AccountID);
            if(acctList.size() > 0){
                acct = acctList.get(0);
                if(acct.Account_Plan_Flag__c == 'Yes'){
                    isAvailableforAcctPlan = true;
                }   
                if(Userinfo.getUserId() != acct.OwnerId){
                    isOwnerAccount = false;
                }
                List<AccountTeamMember> acctTeam = [SELECT ID,AccountAccessLevel,AccountId,
                                                    IsDeleted, TeamMemberRole, UserId FROM  AccountTeamMember
                                                    WHERE AccountId =: AccountID
                                                    AND USerId=: Userinfo.getUserId()
                                                    LIMIT 1];               
                if(acctTeam.size()>0){
                    if(acctTeam.get(0).AccountAccessLevel=='Edit' || acctTeam.get(0).AccountAccessLevel=='All'){
                        IsAccountTeamReadWrite = true;
                    }
                }
                isHasPermission = AccountPlanUtilities.ISHASPERMISSION;        
                
                if(acct.Owner.Segment__c ==null){
                    isSegmentNull = true;
                }   
            }
        }

        if(!isAvailableforAcctPlan && (AccountID!=null && AccountID !='')){
            isHideSection = true;
            //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,'This Account is not available for Account Plan.')); 
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('2004').Status_Message__c));
        
        }
        
        if(!isHasPermission){
            isHideSection = true;
            //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,'You do not have Permissions to create Account Plan for the selected customer.')); 
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('2005').Status_Message__c));
        
        }

        
        if(!isOwnerAccount && !isAccountTeamReadWrite && isHasPermission){
            isHideSection = true;
            //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Only the owner of the customer or Account Team with Permission (Read/Write) can create an Account Plan')); 
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('2006').Status_Message__c));
        
        }
        
        
        
        if(isSegmentNull){
            isHideSection = true;
            //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,'The owner segment cannot be null. ')); 
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('9003').Status_Message__c));
        
        
        }
        CloneMessage = Account_Plan_Status_Code__c.GetValues('1104').Status_Message__c;
        AlertCloneMessage = Account_Plan_Status_Code__c.GetValues('1105').Status_Message__c;
        MsgCreateByCSV = Account_Plan_Status_Code__c.GetValues('1106').Status_Message__c;

        //Lock clone Account Plan
        IsLock = false;
        lock  = [SELECT Id,Account__c,AccountPlanLockClone__c   
                                                FROM AcctPlanGroupWalletLock__c 
                                                Where Account__c =: AccountID];
        if(lock.size()>0){
            LockAccountPlan = lock.get(0);
            IsLock = LockAccountPlan.AccountPlanLockClone__c;
        }
        
    }
    
    public PageReference getParameterIsClone(){
        CompanyIDClone = ApexPages.currentPage().getParameters().get('CompanyIDClone');

        system.debug('CompanyIDClone = '+CompanyIDClone);
        system.debug('AccountID = '+AccountID);
        system.debug('YearStr = '+YearStr);
        
        List<AcctPlanCompanyProfile__c> CompanyProfileDuplicateList = [SELECT ID,AccountName__c,Account__c,Year__c
                                                                       FROM AcctPlanCompanyProfile__c 
                                                                       WHERE Account__c =:AccountID 
                                                                       AND Year__c =: YearStr
                                                                       ORDER BY Year__c DESC];
        if(CompanyProfileDuplicateList.size() > 0){
            isDup = true;
            //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Account Plan in Year : '+YearStr+' has already created.')); 
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('1101a').Status_Message__c +' '+YearStr+''+ Account_Plan_Status_Code__c.GetValues('1101b').Status_Message__c));
        
        return null;
        }else{
            isDup = false;
            isValid = true;
        }
        isCloneAction = true;
        return null;   
    }
    
    
    public PageReference AccountPlanCloneAction(){
        //Savepoint sp = Database.setSavepoint();

        system.debug('CompanyIDClone = '+CompanyIDClone);
        if(YearStr == null || YearStr == ''){
            //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Year: Validation Error: Value is required.'));
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('1102').Status_Message__c));
            isValid = false;
            return null;
        }
        if(CompanyIDClone == null || CompanyIDClone == ''){
            //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Cannot clone an Account Plan. Please select an Account Plan at least one for clone.'));            
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('1103').Status_Message__c));
            isValid = false;
            return null;
        }
        if(CompanyProfileList.size()>0){
            AcctPlanCompanyProfile__c CompanyProfileItem = CompanyProfileList.get(0);
            if(CompanyProfileItem.Account__r.Owner.Segment__c ==null){
                //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,'The owner segment cannot be null. '));
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('9003').Status_Message__c));
        
                isValid = false;
                return null;
            }
        }
        
        if(isValid){
            isDisabled = true;
            //if(false){
            AcctPlanGroupWalletLock__c LockRecord= new AcctPlanGroupWalletLock__c();
            LockRecord.AccountPlanLockClone__c =true;
            if(!IsLock){
                //Lock
                if(lock.size() > 0){
                    for(AcctPlanGroupWalletLock__c item : lock){
                       item.AccountPlanLockClone__c = true;   
                    }           
                    update lock;
                }
                else{
                    AcctPlanGroupWalletLock__c item = new AcctPlanGroupWalletLock__c(AccountPlanLockClone__c = true,Account__c = AccountID);
                    insert item;
                }

                AccountPlanCloneBatch batch = new AccountPlanCloneBatch(CompanyIDClone,YearStr);  
                Database.executeBatch(batch ,100);
            }
            //Database.executeBatch(batch ,1); 
            //AccountPlanCloneUtils.AccountPlanClone(CompanyIDClone,YearStr);
            //}
             
            
        }
        return null;
    }
    
    public PageReference AccountPlanNewAction(){  
        //try{
            if(YearStr == null || YearStr == ''){
                //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Year: Validation Error: Value is required.'));
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('1102').Status_Message__c));
                return null;
            }
            List<AcctPlanCompanyProfile__c> CompanyProfileDuplicateList = [SELECT ID,AccountName__c,Account__c,Year__c
                                                                           FROM AcctPlanCompanyProfile__c 
                                                                           WHERE Account__c =:AccountID 
                                                                           AND Year__c =: YearStr
                                                                           ORDER BY Year__c DESC];
            if(CompanyProfileDuplicateList.size() > 0){
                isDup = true;
                //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Account Plan in Year : '+YearStr+' has already created. Please select another Year.')); 
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('1101a').Status_Message__c +' '+YearStr+' '+ Account_Plan_Status_Code__c.GetValues('1101b').Status_Message__c));
        
                return null;
            }else{
                isDup = false;
                isValid = true;
            }
            
            system.debug('CompanyPortID = '+CompanyPortID);
            system.debug('GroupID = '+GroupID);
            
            List<Account> masterAcctList = AccountPlanUtilities.QueryAccountByAcctID(AccountID);
            Boolean isHasGroup = false;
            Account masteracct  = new Account();
            AcctPlanGroupProfile__c groupprofile = new AcctPlanGroupProfile__c();
            
            companyprofile = new AcctPlanCompanyProfile__c();
            
            if(masterAcctList.size()>0){
                //isNew = true;
                masteracct =  masterAcctList.get(0);
                
                system.debug(masteracct.Business_Type_Code__c);
                String BusinessTypeCode ='';
                String BusinessTypeDESC ='';
                if(masteracct.Business_Type_Code__c !=null && masteracct.Business_Type_Code__c!=''){
                    BusinessTypeCode = masteracct.Business_Type_Code__c;
                }
                if(masteracct.Business_Type_Description__c !=null && masteracct.Business_Type_Description__c!=''){
                    BusinessTypeDESC = masteracct.Business_Type_Description__c;
                }

                companyprofile.Year__c = YearStr;
                companyprofile.Account__c = masteracct.id;
                //companyprofile.Company_Industry__c = masteracct.Industry;
                companyprofile.Company_Industry_Info__c = masteracct.Industry__c;
                companyprofile.NoOfEmployee__c = masteracct.NumberOfEmployees;
                companyprofile.AccountName__c =  masteracct.Name;
                companyprofile.EstablishedSince__c  = masteracct.ESTABLISH_DT__c;
                companyprofile.OwnerId = Userinfo.getUserId();
                
                //Account Plan Form support full form & short form : Jantanee Saetung R5.2
                Boolean isMiniMode = AcctPlanMode__c.GetValues(masteracct.Owner.Segment__c).isMiniMode__c;
                Boolean isReferToCSV = AcctPlanMode__c.GetValues(masteracct.Owner.Segment__c).ReferToCSV__c;     
                if(masteracct.Owner.Segment__c !=null){
                    system.debug('masteracct.Owner.Segment__c='+masteracct.Owner.Segment__c);
                    if(isMiniMode){
                        companyprofile.isMiniMode__c = true;
                    }else if(isReferToCSV){
                        if(masteracct.Account_Plan_Form__c == 'Short Form'){
                            companyprofile.isMiniMode__c = true;
                        }else {
                            companyprofile.isMiniMode__c = false;
                        }
                    }else{
                        companyprofile.isMiniMode__c = false;
                    }
                }else{
                    companyprofile.isMiniMode__c = false;
                }
                
                companyprofile.CustomerSince__c = masteracct.Customer_Creation_Date__c;
                companyprofile.Parent_Company_Info__c = masteracct.ParentID;
                //companyprofile.Parent_Industry__c = masteracct.Parent_Industry__c;
                companyprofile.Parent_Industry_Info__c = masteracct.Parent_Industry__c;
                companyprofile.Business_Code__c = BusinessTypeCode+' '+BusinessTypeDESC; 
                
                
                if(masteracct.Group__c !=null){
                    isHasGroup = true;
                }
                String userId = UserInfo.getUserId(); 

                //Poppulate Group Profile
                groupprofile = new AcctPlanGroupProfile__c ();
                                    groupprofile.Group__c = masteracct.Group__c;
                                    //groupprofile.GroupIndustry__c =  masteracct.Group__r.GroupIndustry__c;
                                    groupprofile.Group_Industry_Info__c =  masteracct.Group__r.Group_Industry_Info__c;
                                    groupprofile.GroupName__c =  masteracct.Group__r.Name;
                                    groupprofile.Year__c = YearStr; 
                                    groupprofile.Name = masteracct.Group__r.Name;
                                    groupprofile.OwnerId = Userinfo.getUserId();
                                    //groupprofile.ParentIndustry__c = masteracct.Group__r.ParentIndustry__c;
                                    // Group Profile = Parent_Industry_Info__c --> Group Master = Parent_Industry__c
                                    groupprofile.Parent_Industry_Info__c = masteracct.Group__r.Parent_Industry__c; //mm commented for deleted field
                                    groupprofile.UltimateParent__c = masteracct.Group__r.UltimateParent__c;
                                    groupprofile.Parent_Company__c = masteracct.Group__r.Parent_Company__c;  
            }
            
            PageReference pr = ApexPages.currentPage();
            pr = Page.CompanyprofileView;
            
            // New from Protfolio
            if(CompanyPortID != null && CompanyPortID != ''){
                
        
                system.debug('CompanyPortID='+CompanyPortID);
                AcctPlanCompanyPort__c comport = new AcctPlanCompanyPort__c();
                List<AcctPlanCompanyPort__c> comportlistquery = [ SELECT ID,Name,Account__c, Account_Name__c,
                                                        Account__r.Account_Plan_Flag__c,
                                                        Account__r.Customer_Creation_Date__c,
                                                        Account__r.No_of_Staff__c,
                                                        Account__r.ParentID,
                                                        Account__r.Sic,
                                                        account__r.OwnerID,
                                                        account__r.NumberOfEmployees,
                                                        Account__r.Owner.Segment__c,
                                                        Account__r.ESTABLISH_DT__c,
                                                        Account__r.SicDesc,
                                                        Account__r.No_of_years_business_run__c,
                                                        Account__r.Industry,
                                                        Account__r.Business_Type_Code__c,
                                                        Account__r.Business_Type_Description__c,
                                                        Account__r.Account_Plan_Form__c,
                                                        Account_Plan_Portfolio__c,
                                                        Account_Plan_Portfolio__r.Year__c,
                                                        AcctPlanGroupPort__c,
                                                        AcctPlanGroupPort__r.Group_Name__c,
                                                        Available_for_Account_Plan__c,
                                                        IsNeedtoRefresh__c,
                                                        Target_NI_By_RM__c,Wallet__c ,Performance__c ,
                                                        Account_Plan_Company_Profile__c,
                                                        Account_Plan_Company_Profile__r.AccountName__c ,
                                                        AcctPlanGroupPort__r.Account_Plan_Group_Profile__c,
                                                        AcctPlanGroupPort__r.Group__c, 
                                                        AcctPlanGroupPort__r.Name,
                                                        AcctPlanGroupPort__r.Account_Plan_Group_Profile__r.Group__c,
                                                        AcctPlanGroupPort__r.Account_Plan_Group_Profile__r.Name
                                                        ,ExpectedNIbyAccountPlan__c,
                                                        Account__r.Group__c
                                                        FROM AcctPlanCompanyPort__c
                                                        WHERE Account_Plan_Portfolio__r.Year__c =: YearStr
                                                        AND Account__c =:masteracct.id];
                if(comportlistquery.size()>0){
                    comport = comportlistquery.get(0);
                    //Portfolio = AccountPlanUtilities.QueryPortfolioByID(comport.Account_Plan_Portfolio__c);
                }
                
                //if(comport.Account_Name__c != null && comport.Account_Name__c != ''){ 
                List<AcctPlanCompanyProfile__c> ExistingComprofile = [SELECT ID,Year__C,Account__c,AcctPlanGroup__c 
                                                                      FROM AcctPlanCompanyProfile__c
                                                                      WHERE Year__c =: YearStr 
                                                                      AND Account__c =: masteracct.id
                                                                     ];
                //Update Group Port and Company Port : Case not refresh cust list
                if(ExistingComprofile.size()>0){
                    comport.Account_Plan_Company_Profile__c = ExistingComprofile.get(0).id;
                    update comport;
                    System.debug('ExistingComprofile.get(0).AcctPlanGroup__c : '+ExistingComprofile.get(0).AcctPlanGroup__c);
                    System.debug('comport.AcctPlanGroupPort__c : '+comport.AcctPlanGroupPort__c);
                    if(comport.Account__r.group__c !=null){
                        if(comport.AcctPlanGroupPort__c !=null && ExistingComprofile.get(0).AcctPlanGroup__c !=null){
                            AcctPlanGroupPort__c groupport = [SELECT ID,Account_Plan_Group_Profile__c 
                                                              From AcctPlanGroupPort__c
                                                              WHERE Group__c =: masteracct.Group__c
                                                              AND Year__c = :YearStr
                                                              ORDER BY Group__c,createddate];
                            if(groupport!=null){
                                groupport.Account_Plan_Group_Profile__c = ExistingComprofile.get(0).AcctPlanGroup__c;
                                update groupport;
                            }  
                        }
                    }
                }

                
                //Create Company Profile
                if(comport.Account_Plan_Company_Profile__c ==null){
                    companyprofile.Portfolio__c = comport.Account_Plan_Portfolio__c;
                    //Binding GroupProfile
                    if(comport.Account__r.group__c !=null){
                        if(comport.AcctPlanGroupPort__c !=null && comport.Account__r.group__c !=null){
                            //Has Group - new Group Profile
                            if(comport.AcctPlanGroupPort__r.Account_Plan_Group_Profile__c ==null){
                                system.debug('comport.Account_Plan_Portfolio__r.Year__c='+comport.Account_Plan_Portfolio__r.Year__c);
                                system.debug('comport.AcctPlanGroupPort__r.Group__c='+comport.AcctPlanGroupPort__r.Group__c);
                                List<AcctPlanGroupProfile__c> groupProfileList = [SELECT ID,Year__c,
                                                                                  Group__c
                                                                                  FROM AcctPlanGroupProfile__c
                                                                                  WHERE Year__c =: YearStr
                                                                                  AND Group__c =: masteracct.Group__c];
                                if(groupProfileList.size()>0){
                                    companyprofile.AcctPlanGroup__c = groupProfileList.get(0).id;
                                }else{
                                    /*groupprofile = new AcctPlanGroupProfile__c ();
                                    groupprofile.Group__c = comport.AcctPlanGroupPort__r.Group__c;
                                    groupprofile.GroupName__c = comport.AcctPlanGroupPort__r.Group_Name__c;
                                    groupprofile.Name = comport.AcctPlanGroupPort__r.Group_Name__c;
                                    groupprofile.Year__c = comport.Account_Plan_Portfolio__r.Year__c;*/


                                    insert groupprofile;
                                    AcctPlanGroupPort__c groupport = [SELECT ID,Account_Plan_Group_Profile__c 
                                                                      From AcctPlanGroupPort__c
                                                                      WHERE ID=: comport.AcctPlanGroupPort__c
                                                                      ORDER BY Group__c,createddate];
                                    groupport.Account_Plan_Group_Profile__c = groupprofile.id;
                                    update groupport;
                                    companyprofile.AcctPlanGroup__c = groupprofile.id;
                                }
                            }
                            //Has Group - Existing Group Profile
                            else{
                                companyprofile.AcctPlanGroup__c = comport.AcctPlanGroupPort__r.Account_Plan_Group_Profile__c;
                            }                
                        }
                    }
                    
                    insert companyprofile; 
                    comport.Account_Plan_Company_Profile__c =companyprofile.id;
                    update comport;
                    
                    if(companyprofile.AcctPlanGroup__c !=null){
                        pr= Page.groupcompanyviewV2;
                        pr.getParameters().put('GroupID',companyprofile.AcctPlanGroup__c);   
                    }
                    pr.getParameters().put('CompanyID',companyprofile.id);
                    
                    AcctPlanWallet__c wallet = AccountPlanUtilities.QueryAccountByCompanyProfile(companyprofile.Id);
                    if(wallet != null){
                        insert wallet;
                        companyprofile.AccountPlanWalletID__c = wallet.id;
                        update companyprofile;
                        pr.getParameters().put('WalletID', wallet.id);
                    }
                    AccountPlanCompletionEx completionEx = new AccountPlanCompletionEx(companyprofile.id);
                    pr.setRedirect(true);
                    return pr;                    
                }else{       
                    String companyID = comport.Account_Plan_Company_Profile__c;
                    
                    List <AcctPlanWallet__c> walletList = AccountPlanWalletUtilities.queryWalletbyCompanyID(companyID);
                    if(comport.AcctPlanGroupPort__c !=null){
                        AcctPlanGroupPort__c groupport = [SELECT ID,Account_Plan_Group_Profile__c 
                                                          From AcctPlanGroupPort__c
                                                          WHERE ID=: comport.AcctPlanGroupPort__c
                                                          ORDER BY Group__c,createddate ];
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
                
            }else if((GroupID != null && GroupID != '')  ){
                //New from group
               

                system.debug('AccountID = '+AccountID);   
                groupprofile = AccountPlanUtilities.QueryGroupProfileByID(GroupID).get(0);

                
                if(companyprofile.AccountName__c != null && companyprofile.AccountName__c != ' ' && !companyprofile.AccountName__c.contains('null')){               
                    companyprofile.Status__c = 'Open';               
                    companyprofile.AcctPlanGroup__c = groupprofile.id;
                
                    insert companyprofile;

                    /*List<AcctPlanGroupProfile__c> groupProfileList = [SELECT ID,Year__c,
                                                                      Group__c
                                                                      FROM AcctPlanGroupProfile__c
                                                                      WHERE Year__c =: YearStr
                                                                      AND Group__c =: masteracct.Group__c];
                    if(groupProfileList.size()>0){
                        companyprofile.AcctPlanGroup__c = groupProfileList.get(0).id;
                    }else{
                        groupprofile = new AcctPlanGroupProfile__c ();
                        groupprofile.Group__c = masteracct.Group__c;
                        groupprofile.GroupName__c = masteracct.Group__r.Name;
                        groupprofile.Name = masteracct.Group__r.Name;
                        groupprofile.Year__c = YearStr;
                        
                        insert groupprofile;
                        AcctPlanGroupPort__c groupport = [SELECT ID,Account_Plan_Group_Profile__c 
                                                          From AcctPlanGroupPort__c
                                                          WHERE ID=: comport.AcctPlanGroupPort__c
                                                          ORDER BY Group__c,createddate];
                        groupport.Account_Plan_Group_Profile__c = groupprofile.id;
                        update groupport;
                        companyprofile.AcctPlanGroup__c = groupprofile.id;
                        
                    }
                    
                    update companyprofile;*/
                    
                    AcctPlanWallet__c wallet = AccountPlanUtilities.QueryAccountByCompanyProfile(companyprofile.Id);
                    pr= Page.groupcompanyviewV2;
                    if(wallet != null){
                        insert wallet;
                        companyprofile.AccountPlanWalletID__c = wallet.id;
                        update companyprofile;
                        pr.getParameters().put('WalletID', wallet.id);
                    }
                    
                    pr.getParameters().put('GroupID',GroupID);
                    pr.getParameters().put('CompanyID',companyprofile.id);
                    
                    pr.setRedirect(true);
                    system.debug('pr = '+pr);
                    return pr;
                }else{
                    pr.getParameters().put('AccountID',masteracct.id);

                    AccountPlanCompletionEx completionEx = new AccountPlanCompletionEx(companyprofile.id);
                    pr.setRedirect(true);
                    return pr;
                }
                
            }else if(AccountID != null && AccountID != '' ){
                //New from Customer Single View 


                String GroupProfileID;
                if(companyProfile.Parent_Company_Info__c !=null){               
                    companyProfile.Parent_Company_Name__c = companyProfile.Parent_Company_Info__r.Name;
                }else{
                    companyProfile.Parent_Company_Name__c  = null;
                }
                
                List<AcctPlanCompanyProfile__c> ExistingComprofile = [SELECT ID,Year__C,Account__c
                                                                      FROM AcctPlanCompanyProfile__c
                                                                      WHERE Year__c =: YearStr
                                                                      AND Account__c =: masteracct.id];
                if(isHasGroup){
                    List<AcctPlanGroupProfile__c> ExistingGroupProfile = [SELECT ID,Year__c,Group__c
                                                                          FROM AcctPlanGroupProfile__c
                                                                          WHERE Year__c =: YearStr
                                                                          AND Group__c =:  masteracct.Group__c];               
                    if(ExistingGroupProfile.size()>0){
                        groupprofile = ExistingGroupProfile.get(0);
                        GroupProfileID = groupprofile.id;
                    }else{
                        /*groupprofile = new AcctPlanGroupProfile__c ();
                        groupprofile.Group__c = masteracct.Group__c;
//                        groupprofile.GroupIndustry__c =  masteracct.Group__r.GroupIndustry__c;
                        groupprofile.GroupName__c =  masteracct.Group__r.Name;
                        groupprofile.Year__c = YearStr; 
                        groupprofile.Name = masteracct.Group__r.Name;
                        groupprofile.OwnerId = Userinfo.getUserId();
//                        groupprofile.ParentIndustry__c = masteracct.Group__r.ParentIndustry__c;
                        groupprofile.UltimateParent__c = masteracct.Group__r.UltimateParent__c;
                        groupprofile.Parent_Company__c = masteracct.Group__r.Parent_Company__c;*/
                        
                        insert groupprofile;   
                    }
                    
                }
                
                if(ExistingComprofile.size()>0){
                    //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Company Profile in Year :'+companyprofile.Year__c+' has already created. Please select another year.'));
                    ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('1101a').Status_Message__c +' '+companyprofile.Year__c+' '+ Account_Plan_Status_Code__c.GetValues('1101b').Status_Message__c));
        
                    return null; 
                }else{
                    if(isHasGroup){
                        companyprofile.AcctPlanGroup__c = groupprofile.id;      
                    }
                    insert companyprofile;
                    
                    AcctPlanWallet__c wallet = AccountPlanUtilities.QueryAccountByCompanyProfile(companyprofile.Id);
                    if(wallet != null ){
                        insert wallet;
                        companyprofile.AccountPlanWalletID__c = wallet.id;
                        update companyprofile;
                        WalletID = wallet.id;
                    }  
                }
                
                
                if(isHasGroup){
                    pr= Page.groupcompanyviewV2;
                    pr.getParameters().put('GroupID',groupprofile.id);
                }
                pr.getParameters().put('CompanyID',companyprofile.id);
                if(walletId !=null && WalletID !=''){
                    pr.getParameters().put('WalletID',walletID);
                }
            }
            

            AccountPlanCompletionEx completionEx = new AccountPlanCompletionEx(companyprofile.id);
            pr.setRedirect(true);
            return pr;
        /*}catch(Exception e){
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));  
        }*/
        return null;
    }
    
    public PageReference CancelAction(){
        PageReference pr;
        if(CompanyPortID != null && CompanyPortID != ''){
            //Portfolio Management
            pr = Page.AccountPlanPortfolioManagementV2;
            pr.getParameters().put('id',comport.Account_Plan_Portfolio__r.id);       
            return pr;
        }else if(GroupID != null && GroupID != ''){
            //Group Profile
            pr = Page.GroupCompanyViewV2;
            pr.getParameters().put('GroupID',GroupID); 
            
            if(CompanyID != null && CompanyID != ''){
                pr.getParameters().put('CompanyID',CompanyID);
            }
            if(WalletID != null && WalletID != ''){
                pr.getParameters().put('WalletID',WalletID);
            }
            
        }else if(CompanyID != null && CompanyID != ''){
            //Company Profile
            pr = Page.CompanyProfileView;
            pr.getParameters().put('CompanyID',CompanyID);
        }else if(AccountID != null && AccountID != ''){
            pr = new PageReference('/'+AccountID);
        }else{
            pr = new PageReference('/'+AccountID);
        }
        pr.setRedirect(true);        
        return pr;
    }
}