public without sharing  class AccountPlanUtilities {
    public static AcctPlanPortfolio__c portfolio {get{
        if(portfolio == null){
            portfolio = new AcctPlanPortfolio__c();
        }
        return portfolio; 
    }set;}
    
    public static List <Account>  AccountList {get{
        if(AccountList == null){
            AccountList = new List<Account>();
        }
        return AccountList;
    }set;}
    
    public static List <AcctPlanCompanyProfile__c>  companyProfileList {get{
        if(companyProfileList == null){
            companyProfileList = new List<AcctPlanCompanyProfile__c>();
        }
        return companyProfileList;
    }set;}
    
    public static List <AcctPlanGroupProfile__c>  groupProfileList {get{
        if(groupProfileList == null){
            groupProfileList = new List<AcctPlanGroupProfile__c>();
        }
        return groupProfileList;
    }set;}
    
    public static List <AcctPlanProdStrategy__c>  AcctPlanProdStrategyList {get{
        if(AcctPlanProdStrategyList == null){
            AcctPlanProdStrategyList = new List<AcctPlanProdStrategy__c>();
        }
        return AcctPlanProdStrategyList;
    }set;}
    
        public static List <AcctPlanQuestionnaire__c >  QuestionnaireList {get{
        if(QuestionnaireList == null){
            QuestionnaireList = new List<AcctPlanQuestionnaire__c >();
        }
        return QuestionnaireList;
    }set;}
    
    
    public static AcctPlanCompanyProfile__c CompanyProfile {get{
        if(CompanyProfile == null){
            CompanyProfile = new AcctPlanCompanyProfile__c();
        }
        return CompanyProfile; 
    }set;}
    
   public static String  GroupProfileID {get{
        if(GroupProfileID == null){
           
        }
        return GroupProfileID;
    }set;}
    
    public static String  CompanyProfileID {get{
        if(CompanyProfileID == null){
           
        }
        return CompanyProfileID;
    }set;}
    
    public static Boolean isSystemAdmin {get{
        if(isSystemAdmin == null){
            String profileName=[Select Id,Name from Profile where Id=:userinfo.getProfileId()].Name;
            if(profileName =='System Administrator'|| profileName=='TMB CRM Admin Profile'){
                isSystemAdmin = true;
            }else{
                isSystemAdmin = false;
            }
             
        }
        return isSystemAdmin;
    }set;}
    
    public static boolean ISHASPERMISSION {get{
        //Check Permissions
            //
        if(ISHASPERMISSION ==null){
            //system.debug('userinfo.getProfileId()='+userinfo.getProfileId());
            List<Profile> PROFILE = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
            
            String MyProflieName = PROFILE[0].Name;
            //system.debug('MyProflieName='+MyProflieName);
            
            List<ObjectPermissions> obplist = [SELECT Id, SObjectType, PermissionsRead,PermissionsEdit, PermissionsCreate
                                               FROM ObjectPermissions
                                               WHERE SObjectType =:'AcctPlanCompanyProfile__c' AND parentid in (select id from permissionset where
                                                                                                                PermissionSet.Profile.Name =: MyProflieName)
                                              ];
            //system.debug('ObjectPermissions='+obplist);
            //system.debug('obplist.get(0).PermissionsEdit='+obplist.get(0).PermissionsEdit);
            return obplist.get(0).PermissionsEdit;
            
                
        }else{
            return ISHASPERMISSION;
        }
    }set;}
    
    
    public static boolean IsAccountTeamReadWrite {get{
        if(IsAccountTeamReadWrite ==null){ 
        IsAccountTeamReadWrite = false;
        }
        
        return IsAccountTeamReadWrite;
    }set;}
    
    public static  String OWNERSEGMENT;
    public static  boolean ISMINIVIEW;
    public static  boolean ISACTIVE;
    
    public static boolean ISSTEP5AVAILABLE;
    public static boolean ISSTEP6AVAILABLE;
    
    public AccountPlanUtilities (){
        
    }
    
    public static AcctPlanPortfolio__c QueryPortfolioByID (String salesId){
        
        portfolio = [SELECT ID,Name,OwnerID,
                   AsOF__c,
                   SalesOwner__c,
                   SalesOwner__r.Name,
                   Status__c,
                   SumOfExpectedNIByAcctPlan__c,
                   isPendingForApproval__c,
                   SumOfPerformance__c,
                   SumOfTargetNIByRM__c, 
                   SumOfWallet__c ,
                   TargetNI__c,
                   RefreshAsOF__C,
                   DataAsOf__c,
                   Achievement__c,
                   Year__c,
                   (Select Id, Status From ProcessInstances), 
                    (Select ActorId, Comments, CreatedById, CreatedDate, 
                    Id, IsPending, OriginalActorId, RemindersSent, StepStatus From ProcessSteps)   
                     FROM AcctPlanPortfolio__c 
                  // WHERE SalesOwner__c =: salesId
                    WHERE ID =: salesId
                    ];
        return portfolio;
    }
    
    public static List<AcctPlanGroupProfile__c>  QueryGroupProfileByID (id groupID){
        
        groupProfileList = [SELECT ID,Name,
                        GroupName__c ,
                        GroupRevenue__c ,
                        GroupStrategy__c ,
                        ParentCompany__c,
                        Parent_Company__c,
                        ShareholdingStructure__c ,
                        BusinessFlow__c,
                        Year__c,
                        BargainingPowerOfSupplier__c,
                        BargainingPowerOfSupplierDescription__c  ,
                        BargainingPowerOfBuyer__c ,
                        BargainingPowerOfBuyerDescription__c ,
                        BarrierOfNewEntrant__c,
                        BarrierOfNewEntrantDescription__c  ,
                        ThreatOfSubstituteProduct__c ,
                        ThreatOfSubstituteProductDescription__c ,
                        IndustryCompetition__c ,
                        IndustryCompetitionDescription__c ,
                        FactorType1__c,FactorType2__c,FactorType3__c,FactorType4__c,FactorType5__c,
                        FactorType1Description__c,FactorType2Description__c,FactorType3Description__c,
                        FactorType4Description__c,FactorType5Description__c,FinancialHighlight__c ,FinancialHighlightByMajor__c ,
                        Group__c , Group_Industry_Info__c ,
                        Parent_Industry_Info__c,RefreshAsOf__c 
                        FROM AcctPlanGroupProfile__c 
                       WHERE ID =:groupID];
        return groupProfileList;
    }
    
    public static List<AcctPlanCompanyProfile__c> QueryCompanyProfileByID (id comID){
        
        companyProfileList = [SELECT ID, Name,OwnerId,
            SubIndustry__c,
            isMinimode__c,
            AccountName__c ,
            AcctPlanGroup__r.id,                 
            EstablishedSince__c,
            CustomerSince__c,                
            NoOfEmployee__c,
            UltimateCompany__c,
            ShareholdingStructure__c,
            BusinessFlow__c,
            isAvailableforApproval__c ,
            isHasProdStrategy__c,
            isHasActionPlan__c,
            isPendingForApproval__c,                 
            CompanyStrategy__c,              
            Account__r.First_Name_PE__c,
            Account__r.Parent.Name,
            Account__r.OwnerId,
            Account__r.Parent.Industry,
            Account__r.Owner.Segment__c, 
            //Account__r.Parent_Company_Name__c , 
             Parent_Company_Info__c ,
             Parent_Company_Info__r.Name ,
            Parent_Company_Name__c,                
            //DA :cancel comment Year__c,
            AccountPlanWalletID__c,
            Year__c,
            Status__c,                  
            Business_Code__c,
            BargainingPowerOfSupplier__c,
            BargainingPowerOfSupplierDescription__c,
            BargainingPowerOfBuyer__c,
            BargainingPowerOfBuyerDescription__c,
            BarrierOfNewEntrant__c,
            BarrierOfNewEntrantDescription__c,
            ThreatOfSubstituteProduct__c,
            ThreatOfSubstituteProductDescription__c,
            IndustryCompetition__c,
            IndustryCompetitionDescription__c,
            FactorType1__c,
            FactorType1Description__c,
            FactorType2__c,
            FactorType2Description__c,
            FactorType3__c,
            FactorType3Description__c,
            FactorType4__c,
            FactorType4Description__c,
            FactorType5__c,
            FactorType5Description__c,
            FinancialHighlight__c,
            LastModifiedBy.Name,                 
            Top5BuyerNote__c,AcctPlanGroup__c ,
            Top5SupplierNote__c,
            Account__r.Account_Plan_Form__c,
            Other_Information__c ,
             TMB_Business__c , Company_Industry_Info__c ,
             Parent_Industry_Info__c                
            FROM AcctPlanCompanyProfile__c 
            WHERE ID =:comID];
        if(companyProfileList.size()>0){
            companyprofile = companyProfileList.get(0);
       
            ISMINIVIEW = companyprofile.isMiniMode__c;
            
            User owner = [SELECT ID,Segment__c FROM User where id=:companyProfile.OwnerId LIMIT 1];
             
            if(owner.Segment__c !=null){
                OWNERSEGMENT = Owner.Segment__c;
            }
            
             List<AccountTeamMember> acctTeam = [SELECT ID,AccountAccessLevel,AccountId,
                             IsDeleted, TeamMemberRole, UserId FROM  AccountTeamMember
                             WHERE AccountId =: companyprofile.Account__c
                             AND USerId=: Userinfo.getUserId()
                             LIMIT 1];
            
            if(acctTeam.size()>0){
                 if(acctTeam.get(0).AccountAccessLevel=='Edit' || acctTeam.get(0).AccountAccessLevel=='All'){
                        IsAccountTeamReadWrite = true;
                    }
            }
            
         }
        
        return companyProfileList;
    }
    
       public static List<AcctPlanCompanyProfile__c> QueryCompanyProfileByGroupID (id Groupid){
        
       List<AcctPlanCompanyProfile__c> comprofileList =[SELECT ID,Name,Wallet__c ,              
                            AcctPlanGroup__c ,
                            Status__c,                           
                            Account__c, 
                            Account__r.ESTABLISH_DT__c, 
                            Account__r.OwnerID, 
                             Account__r.Owner.Name,                             
                            Account__r.Owner.Segment__c,                              
                            Account__r.LastModifiedBy.Name,
                            Account__r.LastModifiedDate,                         
                            Account__r.First_Name_PE__c,
                            Account__r.Last_Name_PE__c,
                            LastModifiedBy.Name,LastModifiedDate, 
                            Account__r.Group__r.Name,                         
                            Account__r.Account_Plan_Form__c,
                            Other_Information__c
                             ,TMB_Business__c,Company_Industry_Info__c
                           FROM AcctPlanCompanyProfile__c  
                           WHERE AcctPlanGroup__c  =:Groupid ORDER BY Name ASC];

        return comprofileList;
    }

    public static List<Account> QueryAccountByOwnerID (String OwnerID){
        
        AccountList = [SELECT ID,Name,First_Name_PE__c,Industry ,Last_Name_PE__c ,Group__c,Account_Plan_Flag__c,
                       Group__r.Name,
                       Group__r.GroupCompany__c ,
                       Group__r.Parent_Company__c ,
                       Group__r.UltimateParent__c 
                      FROM Account
                      WHERE OwnerId =: OwnerID
                      AND Account_Plan_Flag__c ='Yes'
                      ORDER BY Group__r.Name];
        return AccountList;
    }
    public static List<Account> QueryAccountByOwnerIDLimit (String OwnerID){
        //limit 1000
        AccountList = [SELECT ID,Name,First_Name_PE__c,Industry ,Group__c,Account_Plan_Flag__c,
                       Group__r.Name,
                       Group__r.GroupCompany__c ,
                       Group__r.Parent_Company__c ,
                       Group__r.UltimateParent__c 
                      FROM Account
                      WHERE OwnerId =: OwnerID
                      AND Account_Plan_Flag__c ='Yes'
                      ORDER BY Group__r.Name ASC NULLS LAST,Id LIMIT 1500];
        return AccountList;
    }
    
        public static List<Account> QueryAccountByAcctID (String AcctId){
        
        AccountList = [SELECT ID,Name,First_Name_PE__c,Last_Name_PE__c,Group__c,Account_Plan_Flag__c,
                       Group__r.Name,Owner.Segment__c,
                       No_of_years_business_run__c,
                       NumberOfEmployees,
                       Customer_Creation_Date__c,
                       ParentID,ESTABLISH_DT__c ,OwnerID,
                       Business_Type_Code__c,
                       Business_Type_Description__c,
                       Industry,No_of_Staff__c,
                       Parent_Industry__c,
                       Group__r.Parent_Industry__c,//mm
                       //Group__r.ParentIndustry__c, //mm
                       Group__r.GroupCompany__c ,
                       Group__r.Parent_Company__c ,
                       Group__r.UltimateParent__c,
                       Fee_Wallet__c,
                       NIIc_Wallet__c,
                       NIId_Wallet__c,
                       Account_Plan_Form__c,
                       Industry__c,
                       Group__r.Group_Industry_Info__c,
                       Parent.Industry__r.Name,
                       Group__r.Group_Industry_Info__r.Name
                      FROM Account
                      WHERE ID = :AcctId
                     ];
        return AccountList;
    }
    
    public static List<Account> QueryAccountByGroupID (String MGroupID){
        AccountList = [SELECT ID,Name,First_Name_PE__c,Industry,Last_Name_PE__c ,Group__c,Account_Plan_Flag__c,
                       Group__r.Name,LastModifiedDate,LastModifiedBy.Name,                 
                       Group__r.GroupCompany__c ,
                       Group__r.Parent_Company__c ,
                       Group__r.UltimateParent__c,
                       Owner.Name, Owner.Id, Owner.Segment__c,
                        Account_Plan_Form__c 
                      FROM Account
                      WHERE Group__c =: MGroupID
                      AND Account_Plan_Flag__c ='Yes'
                      ORDER BY Group__r.Name]; 
        return Accountlist;
    }
    public static List<Account> QueryAccountByGroupIDLimit (String MGroupID){
        AccountList = [SELECT ID,Name,First_Name_PE__c,Industry,Last_Name_PE__c ,Group__c,Account_Plan_Flag__c,
                       Group__r.Name,LastModifiedDate,LastModifiedBy.Name,                 
                       Group__r.GroupCompany__c ,
                       Group__r.Parent_Company__c ,
                       Group__r.UltimateParent__c,
                       Industry__c,
                       Owner.Name, Owner.Id, Owner.Segment__c,
                        Account_Plan_Form__c 
                      FROM Account
                      WHERE Group__c =: MGroupID
                      AND Account_Plan_Flag__c ='Yes'
                      ORDER BY Group__r.Name,id 
                      Limit 1500]; 
        return Accountlist;
    }
    
    
   public static List<Target__c> QueryTargetNI12monthsbyOwnerID (String OwnerID){
        Date tempDate = System.today();
        Date twelvemonths = tempDate.addMonths(-12);  
        List<Target__c> TargetList = [SELECT ID,RecordTypeID, Monthly_Target_Date__c, NI_Target_Monthly__c
                     FROM Target__c
                     WHERE OwnerId =: OwnerID
                     AND Monthly_Target_Date__c >:twelvemonths
                     AND Monthly_Target_Date__c <:tempDate
                     AND RecordTypeID =: [SELECT Name, id 
                                          FROM RecordType 
                                          WHERE sObjectType='Target__c' 
                                          and Name='NI Target'].id];
        return TargetList;
    }
   
       public static List<Target__c> QueryTargetNIbyOwnerIDandYear (String OwnerID,Integer year){ 
        List<Target__c> TargetList = [SELECT ID,RecordTypeID, Monthly_Target_Date__c, NI_Target_Monthly__c
                     FROM Target__c
                     WHERE OwnerId =: OwnerID
                     AND  CALENDAR_YEAR(Monthly_Target_Date__c) =: year
                     AND RecordTypeID =: [SELECT Name, id 
                                          FROM RecordType 
                                          WHERE sObjectType='Target__c' 
                                          and Name='NI Target'].id];
        return TargetList;
    }
    public static List<AcctPlanCompanyPort__c> QueryCompanyPortbyID(String comportID){
       List<AcctPlanCompanyPort__c > CompanyPortList = [SELECT ID,Name,Account__c,
                                                        Account_Name__c,
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
                                                        WHERE ID = :comportID];
        return CompanyPortList;
    }
    
    
    public static List<AcctPlanCompanyPort__c> QueryCompanyPortbyPortID(String portID){
       List<AcctPlanCompanyPort__c > CompanyPortList = [SELECT ID,Name,Account__c,
                                                        Account_Name__c,
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
                                                        AcctPlanGroupPort__c,
                                                        IsNeedtoRefresh__c,
                                                        AcctPlanGroupPort__r.Group_Name__c,
                                                        Available_for_Account_Plan__c,
                                                        Target_NI_By_RM__c,Wallet__c ,Performance__c ,
                                                        Account_Plan_Company_Profile__c,
                                                        Account_Plan_Company_Profile__r.AccountName__c ,
                                                        AcctPlanGroupPort__r.Account_Plan_Group_Profile__c,
                                                        AcctPlanGroupPort__r.Group__c, 
                                                        AcctPlanGroupPort__r.Name,
                                                        AcctPlanGroupPort__r.Account_Plan_Group_Profile__r.Group__c,
                                                        AcctPlanGroupPort__r.Account_Plan_Group_Profile__r.Name
                                                        ,ExpectedNIbyAccountPlan__c
                                                        FROM AcctPlanCompanyPort__c
                                                        WHERE Account_Plan_Portfolio__c =:portID];
        return CompanyPortList;
    }
    public static List<AcctPlanCompanyPort__c> QueryCompanyPortbyPortIDLimit(String portID){
        //limit 1000
        AcctPlanPortfolio__c portfolioItem = QueryPortfolioByID(portId);
        String PortfolioOwnerId = portfolioItem.OwnerId;
       List<AcctPlanCompanyPort__c> CompanyPortList = [SELECT ID,Name,Account__c,
                                                        Account_Name__c,
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
                                                        AcctPlanGroupPort__c,
                                                        AcctPlanGroupPort__r.Group_Name__c,
                                                        Available_for_Account_Plan__c,
                                                        Target_NI_By_RM__c,Wallet__c ,
                                                        Performance__c ,
                                                        IsNeedtoRefresh__c,
                                                        Account_Plan_Company_Profile__c,
                                                        Account_Plan_Company_Profile__r.AccountName__c ,
                                                        AcctPlanGroupPort__r.Account_Plan_Group_Profile__c,
                                                        AcctPlanGroupPort__r.Group__c, 
                                                        AcctPlanGroupPort__r.Name,
                                                        AcctPlanGroupPort__r.Account_Plan_Group_Profile__r.Group__c,
                                                        AcctPlanGroupPort__r.Account_Plan_Group_Profile__r.Name,
                                                        ExpectedNIbyAccountPlan__c,
                                                        OwnerId
                                                        FROM AcctPlanCompanyPort__c
                                                        WHERE Account_Plan_Portfolio__c =:portID
                                                        AND OwnerId = :PortfolioOwnerId 
                                                        ORDER BY AcctPlanGroupPort__r.Group__r.Name ASC NULLS LAST,Account__r.id
                                                       LIMIT 1500];
        return CompanyPortList;
    }
    public static List<AcctPlanCompanyPort__c> QueryCompanyPortbyPortIDFlag(String portID){
        //limit 1000
        AcctPlanPortfolio__c portfolioItem = QueryPortfolioByID(portId);
        String PortfolioOwnerId = portfolioItem.OwnerId;
       List<AcctPlanCompanyPort__c > CompanyPortList = [SELECT ID,Name,Account__c,Account_Name__c,
                                                        Account__r.Account_Plan_Flag__c,Account_Plan_Portfolio__c,
                                                        AcctPlanGroupPort__c,AcctPlanGroupPort__r.Group_Name__c,
                                                        Available_for_Account_Plan__c,Target_NI_By_RM__c,Wallet__c ,Performance__c ,
                                                        Account_Plan_Company_Profile__c,Account_Plan_Company_Profile__r.AccountName__c ,
                                                        AcctPlanGroupPort__r.Account_Plan_Group_Profile__c,
                                                        AcctPlanGroupPort__r.Group__c,AcctPlanGroupPort__r.Name,
                                                        AcctPlanGroupPort__r.Account_Plan_Group_Profile__r.Group__c,
                                                        AcctPlanGroupPort__r.Account_Plan_Group_Profile__r.Name,
                                                        ExpectedNIbyAccountPlan__c,OwnerId
                                                        FROM AcctPlanCompanyPort__c
                                                        WHERE Account_Plan_Portfolio__c =:portID
                                                        AND Available_for_Account_Plan__c = true
                                                        AND OwnerId = :PortfolioOwnerId
                                                      ORDER BY AcctPlanGroupPort__r.Group__r.Name ASC NULLS LAST,Account__r.id
                                                       LIMIT 1500];
        return CompanyPortList;
    }
    public static List<AcctPlanCompanyPort__c> QueryCompanyPortbyPortIDTarget(String portID){
        //limit 1000
        AcctPlanPortfolio__c portfolioItem = QueryPortfolioByID(portId);
        String PortfolioOwnerId = portfolioItem.OwnerId;
       List<AcctPlanCompanyPort__c > CompanyPortList = [SELECT ID,Name,Account__c,Account_Name__c,
                                                        Account__r.Account_Plan_Flag__c,Account_Plan_Portfolio__c,
                                                        AcctPlanGroupPort__c,AcctPlanGroupPort__r.Group_Name__c,
                                                        Available_for_Account_Plan__c,Target_NI_By_RM__c,Wallet__c ,Performance__c ,
                                                        Account_Plan_Company_Profile__c,Account_Plan_Company_Profile__r.AccountName__c ,
                                                        AcctPlanGroupPort__r.Account_Plan_Group_Profile__c,
                                                        AcctPlanGroupPort__r.Group__c,AcctPlanGroupPort__r.Name,
                                                        AcctPlanGroupPort__r.Account_Plan_Group_Profile__r.Group__c,
                                                        AcctPlanGroupPort__r.Account_Plan_Group_Profile__r.Name,
                                                        ExpectedNIbyAccountPlan__c,ownerId
                                                        FROM AcctPlanCompanyPort__c
                                                        WHERE Account_Plan_Portfolio__c =:portID
                                                        AND OwnerId = :PortfolioOwnerId
                                                        AND Target_NI_By_RM__c != null AND Target_NI_By_RM__c !=0
                                                        ORDER BY AcctPlanGroupPort__r.Group__r.Name ASC NULLS LAST,Account__r.id
                                                       LIMIT 1500];
        return CompanyPortList;
    }
    public static List<AcctPlanCompanyPort__c> QueryCompanyPortbyPortIDGroup(String portID){
        //limit 1000
        AcctPlanPortfolio__c portfolioItem = QueryPortfolioByID(portId);
        String PortfolioOwnerId = portfolioItem.OwnerId;
       List<AcctPlanCompanyPort__c > CompanyPortList = [SELECT ID,Name,Account__c,Account_Name__c,
                                                        Account__r.Account_Plan_Flag__c,Account_Plan_Portfolio__c,
                                                        AcctPlanGroupPort__c,AcctPlanGroupPort__r.Group_Name__c,
                                                        Available_for_Account_Plan__c,Target_NI_By_RM__c,Wallet__c ,Performance__c ,
                                                        Account_Plan_Company_Profile__c,Account_Plan_Company_Profile__r.AccountName__c ,
                                                        AcctPlanGroupPort__r.Account_Plan_Group_Profile__c,
                                                        AcctPlanGroupPort__r.Group__c,AcctPlanGroupPort__r.Name,
                                                        AcctPlanGroupPort__r.Account_Plan_Group_Profile__r.Group__c,
                                                        AcctPlanGroupPort__r.Account_Plan_Group_Profile__r.Name,
                                                        ExpectedNIbyAccountPlan__c, OwnerId
                                                        FROM AcctPlanCompanyPort__c
                                                        WHERE Account_Plan_Portfolio__c =:portID
                                                        AND AcctPlanGroupPort__c!= null
                                                        AND OwnerId = :PortfolioOwnerId
                                                        ORDER BY AcctPlanGroupPort__r.Group__r.Name ASC NULLS LAST,Account__r.id
                                                       LIMIT 1500];
        return CompanyPortList;
    }
    
    public static List<AcctPlanContribution__c> QueryContributionByGroupProfileID(String groupID){
        List <AcctPlanContribution__c> ContributionList = [SELECT ID,Name,
                            Account_Plan_Company_Profile__c,
                            AccountPlanGroupProfile__c,
                            BusinessUnit__c ,
                            EBITDAContributionPercent__c ,
                            Regional__c,
                            RevenueContributionPercent__c,
                            RevenueContributionType__c 
                           FROM AcctPlanContribution__c 
                           WHERE AccountPlanGroupProfile__c =:groupID
                           AND Account_Plan_Company_Profile__c =null ORDER BY Name ASC];
        
        return ContributionList;
    }
    
    
    public static List<AcctPlanProdStrategy__c> QueryProductStrategyByCompanyProfileID(String comID){
        List <AcctPlanProdStrategy__c> prodStrategyList = [SELECT ID, Name,
                                    AccountPlanYear__c, 
                                    AcctPlanWallet__c, 
                                    AcctPlanGroupProfileID__c,
                                    AcctPlanCompanyProfileID__c,
                                    WalletSizing__c, 
                                    AnnualizedPerformance__c, 
                                   AspirationSOW__c, 
                                    ExistingSOW__c,
                                    ExpectedIncrementalNI__c,
                                    ExpectedIncrementalNIFromStep5__c,
                                    ExpectedSOWPercent__c,
                                    CompareSOW__c,
                                    
                                    SEQ__c
                                    FROM AcctPlanProdStrategy__c 
                                    WHERE AcctPlanCompanyProfileID__c =: comID ORDER BY SEQ__c ASC];
        
        return prodStrategyList;
    }
    
    public static List<AcctPlanProdStrategy__c> QueryProductStrategyByGroupProfileID(String groupID){
        List <AcctPlanProdStrategy__c> prodStrategyList = [SELECT ID, Name,
                                    AccountPlanYear__c, 
                                    AcctPlanWallet__c, 
                                    AcctPlanGroupProfileID__c,
                                    AcctPlanCompanyProfileID__c,
                                    WalletSizing__c, 
                                    AnnualizedPerformance__c, 
                                    AspirationSOW__c, 
                                    ExistingSOW__c,
                                    ExpectedIncrementalNI__c,
                                    ExpectedSOWPercent__c,
                                    CompareSOW__c,
                                    
                                    SEQ__c
                                    FROM AcctPlanProdStrategy__c 
                                    WHERE AcctPlanGroupProfileID__c=: groupID ORDER BY SEQ__c ASC];
        
        return prodStrategyList;
    }
     
    public static AcctPlanCompanyProfile__c QueryAcctPlanCompanyProfileByID (id comID){
        CompanyProfile = [SELECT ID, Name,OwnerID,
            SubIndustry__c,
            AccountName__c ,
            EstablishedSince__c,
            CustomerSince__c,
            NoOfEmployee__c,
            UltimateCompany__c,
            ShareholdingStructure__c,
            BusinessFlow__c,
            CompanyStrategy__c,
            isAvailableforApproval__c , 
            isMiniMode__c,
            isHasProdStrategy__c,
            isHasActionPlan__c,
            isPendingForApproval__c ,              
            Account__r.First_Name_PE__c,
            Account__r.Parent.Name,
            Account__r.Parent.Industry,
            Account__r.Owner.Segment__c,  
            Year__c,              
            Business_Code__c,
            BargainingPowerOfSupplier__c,
            BargainingPowerOfSupplierDescription__c,
            BargainingPowerOfBuyer__c,
            BargainingPowerOfBuyerDescription__c,
            BarrierOfNewEntrant__c,
            BarrierOfNewEntrantDescription__c,
            ThreatOfSubstituteProduct__c,
            ThreatOfSubstituteProductDescription__c,
            IndustryCompetition__c,
            IndustryCompetitionDescription__c,
            FactorType1__c,
            FactorType1Description__c,
            FactorType2__c,
            FactorType2Description__c,
            FactorType3__c,
            FactorType3Description__c,
            FactorType4__c,
            FactorType4Description__c,
            FactorType5__c,
            FactorType5Description__c,
            FinancialHighlight__c,          
            Top5BuyerNote__c,AcctPlanGroup__c ,
            Top5SupplierNote__c,
                          (Select Id, Status From ProcessInstances), 
                    (Select ActorId, Comments, CreatedById, CreatedDate, 
                    Id, IsPending, OriginalActorId, RemindersSent, StepStatus From ProcessSteps Order By CreatedDate DESC Limit 30)   
            TargetNIByRM__c,
            Account__r.Account_Plan_Form__c,
            Other_Information__c,
            TMB_Business__c,Company_Industry_Info__c,
            Portfolio__c 
            FROM AcctPlanCompanyProfile__c 
            WHERE ID =:comID];
        
       if(CompanyProfile !=null){
           
           
               ISMINIVIEW = companyprofile.isMiniMode__c;
           
            User owner = [SELECT ID,Segment__c FROM User where id=:companyProfile.OwnerId LIMIT 1];
            
            if(owner.Segment__c !=null){
                OWNERSEGMENT = Owner.Segment__c;
            }
                 List<AccountTeamMember> acctTeam = [SELECT ID,AccountAccessLevel,AccountId,
                             IsDeleted, TeamMemberRole, UserId FROM  AccountTeamMember
                             WHERE AccountId =: companyprofile.Account__c
                             AND USerId=: Userinfo.getUserId()
                             LIMIT 1];
            
            
            if(acctTeam.size()>0){
                 if(acctTeam.get(0).AccountAccessLevel=='Edit' || acctTeam.get(0).AccountAccessLevel=='All'){
                        IsAccountTeamReadWrite = true;
                    } 
            }
            
        }
        
        return CompanyProfile;
    }
    public static AcctPlanCompanyProfile__c QueryAcctPlanCompanyProfileByIDLimit (id comID){
        //LIMIT 1000
        CompanyProfile = [SELECT ID, Name,OwnerID,
            SubIndustry__c,
            AccountName__c ,
            EstablishedSince__c,
            CustomerSince__c,
            NoOfEmployee__c,
            UltimateCompany__c,
            ShareholdingStructure__c,
            BusinessFlow__c,
            CompanyStrategy__c, 
            isAvailableforApproval__c , 
            isMiniMode__c,
            isHasProdStrategy__c,
            isHasActionPlan__c,
            isPendingForApproval__c ,              
            Account__r.First_Name_PE__c,
            Account__r.Parent.Name,
            Account__r.Parent.Industry,
            Account__r.Owner.Segment__c,  
            Year__c,              
            Business_Code__c,
            BargainingPowerOfSupplier__c,
            BargainingPowerOfSupplierDescription__c,
            BargainingPowerOfBuyer__c,
            BargainingPowerOfBuyerDescription__c,
            BarrierOfNewEntrant__c,
            BarrierOfNewEntrantDescription__c,
            ThreatOfSubstituteProduct__c,
            ThreatOfSubstituteProductDescription__c,
            IndustryCompetition__c,
            IndustryCompetitionDescription__c,
            FactorType1__c,
            FactorType1Description__c,
            FactorType2__c,
            FactorType2Description__c,
            FactorType3__c,
            FactorType3Description__c,
            FactorType4__c,
            FactorType4Description__c,
            FactorType5__c,
            FactorType5Description__c,
            FinancialHighlight__c,          
            Top5BuyerNote__c,AcctPlanGroup__c ,
            Top5SupplierNote__c,
                          (Select Id, Status From ProcessInstances), 
                    (Select ActorId, Comments, CreatedById, CreatedDate, 
                    Id, IsPending, OriginalActorId, RemindersSent, StepStatus From ProcessSteps Order By CreatedDate DESC Limit 30)   
            TargetNIByRM__c,
            Account__r.Account_Plan_Form__c,
            Other_Information__c,
            TMB_Business__c ,Company_Industry_Info__c             
            FROM AcctPlanCompanyProfile__c 
            WHERE ID =:comID LIMIT 1500];
        
       if(CompanyProfile !=null){
           
           
               ISMINIVIEW = companyprofile.isMiniMode__c;
           
            User owner = [SELECT ID,Segment__c FROM User where id=:companyProfile.OwnerId LIMIT 1];
            
            if(owner.Segment__c !=null){
                OWNERSEGMENT = Owner.Segment__c;
            }
                   List<AccountTeamMember> acctTeam = [SELECT ID,AccountAccessLevel,AccountId,
                             IsDeleted, TeamMemberRole, UserId FROM  AccountTeamMember
                             WHERE AccountId =: companyprofile.Account__c
                             AND USerId=: Userinfo.getUserId()
                             LIMIT 1];
            
            
            if(acctTeam.size()>0){
                 if(acctTeam.get(0).AccountAccessLevel=='Edit' || acctTeam.get(0).AccountAccessLevel=='All'){
                        IsAccountTeamReadWrite = true;
                    } 
            }
            
        }
        
        return CompanyProfile;
    }
    
    public static List<AcctPlanQuestionnaire__c > QueryQuestionnaireByWalletID(String walletid){
        QuestionnaireList = [SELECT ID,AcctPlanWallet__c,isStandard__c ,Comment__c,
                            Product_Label__c,
                             Sub_Domain__c,
                             Answer__c ,Opportunity__c, OptionBank__c,OptionBank__r.Name, OptionFleetCard__c ,
                             OptionPercent__c ,OptionText__c , Question__c, Question_TH__c  , QuestionnaireTag1__c, 
                             QuestionnaireTag2__c ,QuestionnaireUniqueName__c , Segment__c , SEQ__c , Answer_Type__c , 
                             OptionNumber__c ,Sub_Segment_SEQ__c
                            FROM AcctPlanQuestionnaire__c 
                            WHERE AcctPlanWallet__c =:Walletid
                            ORDER BY  SEQ__c ASC,Sub_Segment_SEQ__c ASC];
        
        return QuestionnaireList;
    } 
    
    
    
    public static AcctPlanWallet__c QueryAccountByCompanyProfile(String companyID){
        QueryCompanyProfileByID(companyID).get(0);
        if(ISMINIVIEW == null){
            ISMINIVIEW = false;
        }
        
        AcctPlanWallet__c wallet = new AcctPlanWallet__c();
        if(ISMINIVIEW){
            List<AcctPlanCompanyProfile__c > companyList = [SELECT ID,Account__r.NIIc_Wallet__c,Account__r.NIId_Wallet__c,Account__r.Fee_Wallet__c
                                                            FROM AcctPlanCompanyProfile__c  
                                                            WHERE ID  = :companyID];
            if(companyList.size()>0){
                AcctPlanCompanyProfile__c acct = companyList.get(0);
                wallet.SumOfWalletNiicYearly__c = acct.Account__r.NIIc_Wallet__c;
                wallet.TotalWalletNIID_Mini__c = acct.Account__r.NIId_Wallet__c;
                wallet.Total_Fee_Mini__c = acct.Account__r.Fee_Wallet__c;
                wallet.AcctPlanCompanyProfile__c = companyID;               
            }
        }else{
            wallet = null;
        }
        return wallet;
    }
  //Executive Summary for PDF : Jantanee Saetung R5.2
    public static List<Executive_Summary__c> QueryExecutiveSummaryByCompanyProfile(String companyID){
        List<Executive_Summary__c> ExecutiveSummaryList = [SELECT Account_Plan_Company_Profile__c,Action__c,Business_Code__c,
                                                           Business_Established_Since__c,CreatedById,
                                                           CreatedDate,Customer_Name__c,Customer_Name__r.Name,Customer_Strategy__c,Expected_Incremental_Fees__c,
                                                           Expected_Incremental_NIIc__c,Expected_Incremental_NIId__c,Financial_Highlight__c,Id,
                                                           LastModifiedById,LastModifiedDate,Last_Year__c,Name,No_of_Employee__c,
                                                           Other_Information__c,RM_Owner_Name__c,Run_Rate_Fees_This_Year__c,
                                                           Run_Rate_NIIc_This_Year__c,Run_Rate_NIId_This_Year__c,
                                                           Shareholding_Structure__c,SystemModstamp,Talk_Point__c,
                                                           Team_Head__c,Team_Head__r.Name,This_Year__c,TMB_Business__c,TMB_Customer_Since__c,
                                                           TMB_Guests_2__c,TMB_Guests__c,Total_Expected_Incremental__c,
                                                           Total_Run_Rate_This_Year__c,Total_Wallet_Last_Year__c,
                                                           Total_Wallet_This_Year__c,Wallet_Fees_Last_Year__c,
                                                           Wallet_Fees_This_Year__c,Wallet_NIIc_Last_Year__c,
                                                           Wallet_NIIc_This_Year__c,Wallet_NIId_Last_Year__c,
                                                           Wallet_NIId_This_Year__c,Team_Head__r.fullphotourl ,
                                                           RM_Owner_Name__r.fullphotourl,RM_Owner_Name__r.Name,
                                                           TMB_Guests_2__r.Photo__c,TMB_Guests_2__r.Name,
                                                           TMB_Guests_2__r.Age__c, TMB_Guests_2__r.Personal_Information__c ,
                                                           TMB_Guests_2__r.Position__c, TMB_Guests_2__r.Authorized_person_of_signature__c,
                                                           TMB_Guests__r.Photo__c,TMB_Guests__r.Name,
                                                           TMB_Guests__r.Age__c, TMB_Guests__r.Personal_Information__c ,
                                                           TMB_Guests__r.Position__c, TMB_Guests__r.Authorized_person_of_signature__c,
                                                           Company_Industry_Info__c,Company_Industry_Info__r.Name,TMB_Guests__r.Description2__c,
                                                           TMB_Guests_2__r.Description2__c,TMB_Guests_3__r.Description2__c,TMB_Guests_4__r.Description2__c
                                                           FROM Executive_Summary__c
                                                           WHERE Account_Plan_Company_Profile__c = :companyID];
        return ExecutiveSummaryList;
    }
    
    public static List<Executive_Summary__c> QueryExecutiveSummaryByAccount(String AccountID){
        List<Executive_Summary__c> ExecutiveSummaryList = [SELECT Account_Plan_Company_Profile__c,Action__c,Business_Code__c,
                                                           Business_Established_Since__c,CreatedById,
                                                           CreatedDate,Customer_Name__c,Customer_Name__r.Name,Customer_Strategy__c,Expected_Incremental_Fees__c,
                                                           Expected_Incremental_NIIc__c,Expected_Incremental_NIId__c,Financial_Highlight__c,Id,
                                                           LastModifiedById,LastModifiedDate,Last_Year__c,Name,No_of_Employee__c,
                                                           Other_Information__c,RM_Owner_Name__c,Run_Rate_Fees_This_Year__c,
                                                           Run_Rate_NIIc_This_Year__c,Run_Rate_NIId_This_Year__c,
                                                           Shareholding_Structure__c,SystemModstamp,Talk_Point__c,
                                                           Team_Head__c,Team_Head__r.Name,This_Year__c,TMB_Business__c,TMB_Customer_Since__c,
                                                           TMB_Guests_2__c,TMB_Guests__c,Total_Expected_Incremental__c,
                                                           Total_Run_Rate_This_Year__c,Total_Wallet_Last_Year__c,
                                                           Total_Wallet_This_Year__c,Wallet_Fees_Last_Year__c,
                                                           Wallet_Fees_This_Year__c,Wallet_NIIc_Last_Year__c,
                                                           Wallet_NIIc_This_Year__c,Wallet_NIId_Last_Year__c,
                                                           Wallet_NIId_This_Year__c ,Team_Head__r.fullphotourl ,
                                                           RM_Owner_Name__r.fullphotourl,RM_Owner_Name__r.Name,
                                                           TMB_Guests_2__r.Photo__c,TMB_Guests_2__r.Name,
                                                           TMB_Guests_2__r.Age__c, TMB_Guests_2__r.Personal_Information__c ,
                                                           TMB_Guests_2__r.Position__c, TMB_Guests_2__r.Authorized_person_of_signature__c,
                                                           TMB_Guests__r.Photo__c,TMB_Guests__r.Name,
                                                           TMB_Guests__r.Age__c, TMB_Guests__r.Personal_Information__c ,
                                                           TMB_Guests__r.Position__c, TMB_Guests__r.Authorized_person_of_signature__c,
                                                           Company_Industry_Info__c,Company_Industry_Info__r.Name,TMB_Guests__r.Description2__c,
                                                           TMB_Guests_2__r.Description2__c,TMB_Guests_3__r.Description2__c,TMB_Guests_4__r.Description2__c
                                                           FROM Executive_Summary__c
                                                           WHERE Customer_Name__c = :AccountID];
        return ExecutiveSummaryList;
    }
        public static List<Executive_Summary__c> QueryExecutiveSummaryByID(String ExecutiveSummaryID){
        List<Executive_Summary__c> ExecutiveSummaryList = [SELECT Account_Plan_Company_Profile__c,Action__c,Business_Code__c,
                                                           Business_Established_Since__c,CreatedById,
                                                           CreatedDate,Customer_Name__c,Customer_Name__r.Name,Customer_Name__r.TMB_Customer_ID_PE__c,
                                                           Customer_Name__r.Opened_Complaint__c,Customer_Strategy__c,Expected_Incremental_Fees__c,
                                                           Expected_Incremental_NIIc__c,Expected_Incremental_NIId__c,Financial_Highlight__c,Id,
                                                           LastModifiedById,LastModifiedDate,Last_Year__c,Name,No_of_Employee__c,
                                                           Other_Information__c,RM_Owner_Name__c,Run_Rate_Fees_This_Year__c,
                                                           Run_Rate_NIIc_This_Year__c,Run_Rate_NIId_This_Year__c,
                                                           Shareholding_Structure__c,SystemModstamp,Talk_Point__c,
                                                           Team_Head__c,Team_Head__r.Name,This_Year__c,TMB_Business__c,TMB_Customer_Since__c,
                                                           TMB_Guests_2__c,TMB_Guests__c,Total_Expected_Incremental__c,
                                                           Total_Run_Rate_This_Year__c,Total_Wallet_Last_Year__c,
                                                           Total_Wallet_This_Year__c,Wallet_Fees_Last_Year__c,
                                                           Wallet_Fees_This_Year__c,Wallet_NIIc_Last_Year__c,
                                                           Wallet_NIIc_This_Year__c,Wallet_NIId_Last_Year__c,
                                                           Wallet_NIId_This_Year__c ,Team_Head__r.fullphotourl ,
                                                           RM_Owner_Name__r.fullphotourl,RM_Owner_Name__r.Name,
                                                           TMB_Guests_2__r.Photo__c,TMB_Guests_2__r.Name,
                                                           TMB_Guests_2__r.Age__c, TMB_Guests_2__r.Personal_Information__c ,
                                                           TMB_Guests_2__r.Position__c, TMB_Guests_2__r.Authorized_person_of_signature__c,
                                                           TMB_Guests__r.Photo__c,TMB_Guests__r.Name,
                                                           TMB_Guests__r.Age__c, TMB_Guests__r.Personal_Information__c ,
                                                           TMB_Guests__r.Position__c, TMB_Guests__r.Authorized_person_of_signature__c,
                                                           TMB_Guests_3__c,
                                                           TMB_Guests_3__r.Photo__c,TMB_Guests_3__r.Name,
                                                           TMB_Guests_3__r.Age__c, TMB_Guests_3__r.Personal_Information__c ,
                                                           TMB_Guests_3__r.Position__c, TMB_Guests_3__r.Authorized_person_of_signature__c,
                                                           TMB_Guests_4__c,
                                                           TMB_Guests_4__r.Photo__c,TMB_Guests_4__r.Name,
                                                           TMB_Guests_4__r.Age__c, TMB_Guests_4__r.Personal_Information__c ,
                                                           TMB_Guests_4__r.Position__c, TMB_Guests_4__r.Authorized_person_of_signature__c,
                                                           Master_Scale__c,Actual_Fees_Last_Year__c,Actual_NIIc_Last_Year__c,Actual_NIId_Last_Year__c,Total_Actual_Last_Year__c,
                                                           Company_Industry_Info__c,Company_Industry_Info__r.Name,TMB_Guests__r.Description2__c,
                                                           TMB_Guests_2__r.Description2__c,TMB_Guests_3__r.Description2__c,TMB_Guests_4__r.Description2__c
                                                           FROM Executive_Summary__c
                                                           WHERE Id = :ExecutiveSummaryID];
        return ExecutiveSummaryList;
    }
}