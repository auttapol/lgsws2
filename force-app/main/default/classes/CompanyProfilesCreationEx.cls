global without sharing class CompanyProfilesCreationEx {
    private ApexPages.StandardController ctrl;
    public String CompanyID {get;set;}
    public String CompanyPortID {get;set;}
    public Boolean isConsoleMode {get;set;}
    public Boolean isInitiateMode {get;set;}
    public Boolean isValid {get;set;}
    public Boolean isSF1 {get;set;}
    public String warningMsg {get;set;}
    public String notAvaiableOnSF1 {get;set;}
    public String GroupID {get;set;}
    public String mode {get;set;}
    public String AccountID {get;set;}
    public String WalletID {get;set;}
    public String FiscalYearStr {get;set;}
    public AcctPlanCompanyProfile__c companyprofile {get;set;}
    public AcctPlanGroupProfile__c groupprofile {get;set;}
    
    public List<AcctPlanSupplierOrBuyer__c> DistributionList {get;set;}
    public List<AcctPlanSupplierOrBuyer__c> BuyerList {get;set;}
    public List<AcctPlanSupplierOrBuyer__c> SupplierList {get;set;}
    
    public Map<String,List<AcctPlanSupplierOrBuyer__c>> SupplierOrBuyerMap {get;set;}
    public Map<String,List<Account_Plan_Company_Top_5__c>> Top5Map {get;set;}
    
    public String DistributionSegment {get;set;}
    public String Top5BuyersSegment {get;set;}
    public String MajorMaterialSegment {get;set;}
    public String Top5SuppliersSegment {get;set;}
    public String creationMsg {get;set;}
       
    public Account_Plan_Completion__c  Acctplancompletion {get;set;}
    public boolean isDisabled {get;set;}
    public boolean isOwnerAccount {get;set;}
    public boolean isNew {get;set;}
    public boolean isHasGroup {get;set;}
    public boolean isAvailableforAcctPlan {get;set;}
    public boolean isfromSingleView {get;set;}
    public boolean isSegmentNull {get;set;}
    public boolean isHasProdStrategy {get;set;}
    public boolean isHasPermission {get;set;}
    public boolean isHasActionPlan {get;set;}
    public boolean isAccountTeamReadWrite {get;set;}
    public boolean isSystemAdmin {get;set;}
    
    public Account masteracct {get;set;}
    public Set<String>  contributionSet {get;set;}
    public Map<String,List<AcctPlanContribution__c>> ContributionMap {get;set;}
    public List<AcctPlanContribution__c> ContributedByService {get;set;}
    public List<AcctPlanContribution__c> ContributedByBusiness {get;set;}
    public List<AcctPlanContribution__c> ContributedByRegional {get;set;}
    public AcctPlanCompanyPort__c comport {get;set;}
    public AcctPlanGroupPort__c  groupport {get;set;}
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
    

    public String msgShareholding {get;set;}
    public String msgTableMandatory {get;set;}
    
    //constructor
    public CompanyProfilesCreationEx(ApexPages.StandardController controller){
        ctrl = controller;
        isNew = false;
        isHasGroup = false;
        isAvailableforAcctPlan = false;
        isfromSingleView = false;
        isOwnerAccount = true;
        isSegmentNull = false;
        isAccountTeamReadWrite = false;
        isHasPermission = false;
        isInitiateMode = false;
        isValid =true;
        GroupID = ApexPages.currentPage().getParameters().get('GroupID');
        CompanyID = ApexPages.currentPage().getParameters().get('CompanyID');
        AccountID = ApexPages.currentPage().getParameters().get('AccountID');
        WalletID = ApexPages.currentPage().getParameters().get('WalletId');
        mode = ApexPages.currentPage().getParameters().get('mode');
        FiscalYearStr = ApexPages.currentPage().getParameters().get('FiscalYear');
        String strurl = ApexPages.currentPage().getUrl();
                strurl = strurl.split('apex/')[1]; 
                System.debug('strurl : '+strurl);

        
        if(mode=='console'){
            isConsoleMode = true;
        }else{
            isConsoleMode = false;
        }


         msgShareholding = Account_Plan_Status_Code__c.GetValues('2014').Status_Message__c;
         msgTableMandatory = Account_Plan_Status_Code__c.GetValues('9005').Status_Message__c;
         
        
		CompanyPortID = ApexPages.currentPage().getParameters().get('CompanyPortID');
        
        
        if(CompanyID ==null || CompanyID == ''){
           CompanyID = ApexPages.currentPage().getParameters().get('ID');
            if(CompanyID !=null){
                isfromSingleView = true;
            }
        }
        
        
        if(CompanyID !=null && CompanyID !=''){
            
             System.debug(' CompanyID: '+CompanyID);
             System.debug('size='+AccountPlanUtilities.QueryCompanyProfileByID(CompanyID).size());
             companyprofile = AccountPlanUtilities.QueryCompanyProfileByID(CompanyID).get(0);

              System.debug(' companyprofile.id: '+companyprofile.id);
              System.debug(' companyprofile.AccountPlanWalletID__c: '+companyprofile.AccountPlanWalletID__c);
             isMiniView = AccountPlanUtilities.ISMINIVIEW;
               isHasPermission = AccountPlanUtilities.ISHASPERMISSION;       
                ishasProdStrategy = companyprofile.isHasProdStrategy__c;
                isHasActionPlan = companyprofile.isHasActionPlan__c;
                isAccountTeamReadWrite = AccountPlanUtilities.IsAccountTeamReadWrite;
                isSystemAdmin = AccountPlanUtilities.IsSystemAdmin;
            if(Userinfo.getUserId() != companyprofile.Account__r.OwnerID){
                    isOwnerAccount = false;
                }
                 
     
           
            
            if(companyprofile.AcctPlanGroup__c !=null ){
                GroupID = companyprofile.AcctPlanGroup__c ;
            }

            System.debug(' WalletID: '+WalletID);
            
             if(WalletID ==null ||WalletID == ''){
             WalletID = companyprofile.AccountPlanWalletID__c;
            }

            System.debug('WalletID :'+WalletID);
            
            isAvailableforAcctPlan = true;
            
            // Query Completion Percentage
            if(strurl.containsIgnoreCase('View')){
                List<Account_Plan_Completion__c> CompleteList= [SELECT ID,Name,
                     Account_Plan_Company_Profile__c,
                     Step_2_Percentage__c ,
                      Account_Plan_Completion_Percentage__c , 
                      Step_2_Entered_Fields__c ,                                          
                      Step_2_Required_Fields__c
                     FROM Account_Plan_Completion__c 
                     WHERE Account_Plan_Company_Profile__c =: companyprofile.id LIMIT 1]; 
                 if(CompleteList.size()>0){
                 Acctplancompletion = CompleteList.get(0);
             }
            }
            
            
          
          
        //only for View Page - Edit Page use remote object to avoid query limits    
        contributionSet = new Set<String>();
        ContributionMap = new Map<String,List<AcctPlanContribution__c>>();
        contributionSet.add('Contribution by service & product');
        contributionSet.add('Contribution by business unit');
        contributionSet.add('Contribution by regional');
        ContributedByService = new List<AcctPlanContribution__c>();
        ContributedByBusiness = new List<AcctPlanContribution__c>();
        ContributedByRegional = new List<AcctPlanContribution__c>();
        
            if(companyprofile.id!=null){
                for(AcctPlanContribution__c contribute : [SELECT ID, Name, 
            Account_Plan_Company_Profile__c,
            AccountPlanGroupProfile__c,
            BusinessUnit__c ,
            EBITDAContributionPercent__c ,
            Regional__c,
            RevenueContributionPercent__c,
            RevenueContributionType__c 
            FROM AcctPlanContribution__c 
            WHERE Account_Plan_Company_Profile__c =: companyprofile.Id 
            ORDER BY RevenueContributionPercent__c DESC, Name ASC]){
                           
            if(contribute.RevenueContributionType__c =='Contribution by service & product'){
                ContributedByService.add(contribute);
                
            }else if(contribute.RevenueContributionType__c =='Contribution by business unit'){
                ContributedByBusiness.add(contribute);
                
            }else if(contribute.RevenueContributionType__c =='Contribution by regional'){
                ContributedByRegional.add(contribute);
               
            }
        }
            }
        ContributionMap.put('Contribution by service & product', ContributedByService);  
        ContributionMap.put('Contribution by business unit',ContributedByBusiness);
        ContributionMap.put('Contribution by regional',ContributedByRegional);              
     
        //EditTable
        //SupplierOrBuyer
            SupplierOrBuyerMap = new Map<String,List<AcctPlanSupplierOrBuyer__c>>(); 
            List<String> segmentList = new List<String>{'Distribution','Major raw material'};
            DistributionSegment = segmentList.get(0);
            MajorMaterialSegment = segmentList.get(1);
            List<AcctPlanSupplierOrBuyer__c>   SupplierOrBuyerList = [SELECT Id, Percent__c , CCY__c , CCY_Short_Name__c ,Company_Name__c,CreatedDate ,
                                                                      Country__c ,Country_Name__c ,Credit_Term__c ,DataType__c ,
                                                                      EstimateNo__c ,FromDays__c ,Method__c ,Segment__c, ToDays__c 
                                                                      FROM AcctPlanSupplierOrBuyer__c 
                                                                      WHERE Account_Plan_Company_Profile__c = :CompanyID
                                                                     ORDER by Percent__c DESC];
            if(SupplierOrBuyerList.size() >0){
                system.debug('SupplierOrBuyerList='+SupplierOrBuyerList.size());
                for(String segmment : segmentList){
                    List<AcctPlanSupplierOrBuyer__c> SupplierOrBuyerItem = new List<AcctPlanSupplierOrBuyer__c>();
                    for(AcctPlanSupplierOrBuyer__c item :SupplierOrBuyerList){
                        system.debug('SupplierOrBuyerList='+item.Percent__c);
                        if(item.Segment__c == segmment){
                            SupplierOrBuyerItem.add(item);
                        }
                    }
                    system.debug('SupplierOrBuyerList='+segmment);
                    SupplierOrBuyerMap.put(segmment, SupplierOrBuyerItem);     
                }
            }else{
                for(String segmment : segmentList){
                    List<AcctPlanSupplierOrBuyer__c> SupplierOrBuyerItem = new List<AcctPlanSupplierOrBuyer__c>();
                    SupplierOrBuyerMap.put(segmment, SupplierOrBuyerItem);     
                }
            }           
         //Top5   
            Top5Map = new Map<String,List<Account_Plan_Company_Top_5__c>>();
            List<String> typeList = new List<String>{'Buyers','Suppliers'};
            Top5BuyersSegment = typeList.get(0);
            Top5SuppliersSegment = typeList.get(1);
            List<Account_Plan_Company_Top_5__c >   Top5List = [SELECT Id, Credit_Term_Days__c ,Customer_Name__c ,Percent__c, Top_5_Types__c 
                                                                   FROM Account_Plan_Company_Top_5__c 
                                                                   WHERE Account_Plan_Company_Profile__c = :CompanyID
                                                              ORDER by Percent__c DESC,Customer_Name__c ASC];
            if(Top5List.size()>0){
                for(String type : typeList){
                    List<Account_Plan_Company_Top_5__c> Top5Item = new List<Account_Plan_Company_Top_5__c>();
                    for(Account_Plan_Company_Top_5__c item :Top5List){
                        if(item.Top_5_Types__c  == type){
                            Top5Item.add(item);
                        }
                    }
                    Top5Map.put(type, Top5Item);               
                }
            }else{
                for(String type : typeList){
                    List<Account_Plan_Company_Top_5__c> Top5Item = new List<Account_Plan_Company_Top_5__c>();
                    Top5Map.put(type, Top5Item);     
                }
            }
                
        }else if(AccountID!=null && AccountID !=''){
            List<Account> masterAcctList = AccountPlanUtilities.QueryAccountByAcctID(AccountID);
 
            if(masterAcctList.size()>0){
               isNew = true;
               masteracct =  masterAcctList.get(0);
                if(masteracct.Account_Plan_Flag__c == 'Yes'){
                    isAvailableforAcctPlan = true;
                }  
                if(Userinfo.getUserId() != masteracct.OwnerId){
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
               
                
               //CallService
            //AccountCalloutService(masteracct);
               isHasPermission = AccountPlanUtilities.ISHASPERMISSION;        
               //String Firstname = masteracct.First_name__c==null?'':masteracct.First_name__c;
               //String LastName = masteracct.Last_name__c==null?'':masteracct.Last_name__c;
               companyprofile = new AcctPlanCompanyProfile__c();
               //companyprofile.name = Firstname+' '+LastName;
               //companyprofile.name = masteracct.Name;
               companyprofile.Year__c = FiscalYearStr;
               companyprofile.Account__c = masteracct.id;
               //companyprofile.Company_Industry__c = masteracct.Industry;
               companyprofile.Company_Industry_Info__c = masteracct.Industry__c;
               companyprofile.NoOfEmployee__c = masteracct.NumberOfEmployees;
               //companyprofile.AccountName__c =Firstname+' '+LastName;
               companyprofile.AccountName__c =  masteracct.Name;
                companyprofile.EstablishedSince__c  = masteracct.ESTABLISH_DT__c;
              // companyprofile.OwnerId = masteracct.OwnerID;
               companyprofile.OwnerId = Userinfo.getUserId();
               
                /*if(masteracct.Owner.Segment__c !=null){
                    companyprofile.isMiniMode__c = AcctPlanMode__c.GetValues(masteracct.Owner.Segment__c).isMiniMode__c; 
                }else{
                    isSegmentNull = true;
                }*/
                //Account Plan Form support full form & short form : Jantanee Saetung R5.2
                Boolean isMiniMode = AcctPlanMode__c.GetValues(masteracct.Owner.Segment__c).isMiniMode__c;
                Boolean isReferToCSV = AcctPlanMode__c.GetValues(masteracct.Owner.Segment__c).ReferToCSV__c;     
                if(masteracct.Owner.Segment__c !=null){
                    system.debug('masteracct.Owner.Segment__c='+masteracct.Owner.Segment__c);
                    if(isMiniMode){
                        isMiniView = true;
                        companyprofile.isMiniMode__c = true;
                    }else if(isReferToCSV){
                        if(masteracct.Account_Plan_Form__c == 'Short Form'){
                            isMiniView = true;
                            companyprofile.isMiniMode__c = true;
                        }else {
                            isMiniView = false; 
                            companyprofile.isMiniMode__c = false;
                        }
                    }else{
                        isMiniView = false; 
                        companyprofile.isMiniMode__c = false;
                    }
                }else{
                    isSegmentNull = true;
                    companyprofile.isMiniMode__c = false;
                }
                
                companyprofile.CustomerSince__c = masteracct.Customer_Creation_Date__c;
                companyprofile.Parent_Company_Info__c = masteracct.ParentID;
                //companyprofile.Parent_Industry__c = masteracct.Parent_Industry__c;
                companyprofile.Parent_Industry_Info__c = masteracct.Parent_Industry__c;
                companyprofile.Business_Code__c = masteracct.Business_Type_Code__c==null?'':masteracct.Business_Type_Code__c +
                    ' '+
                    masteracct.Business_Type_Description__c==null?'':masteracct.Business_Type_Description__c; 
                companyprofile.Status__c = 'In Progress';
                
                if(masteracct.Group__c !=null){
                    isHasGroup = true;
                   //groupport = new AcctPlanGroupPort(); 
                }
                String userId = UserInfo.getUserId();
                User ownerSegment = [SELECT ID,Segment__c FROM User where ID=:userId LIMIT 1];  
                
                if(ownerSegment.Segment__c == 'SE'){
                    isMiniView = true;
                }else{
                    isMiniView = false; 
                }

            }else{
                isDisabled = true;
                //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Not found any Account record.'));  
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('2003').Status_Message__c));
        
            }
            if(companyprofile.AccountName__c == null || companyprofile.AccountName__c == ' '){
                
                isDisabled = true;
                system.debug('companyprofile.AccountName__c='+companyprofile.AccountName__c);
                //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Cannot create an Account Plan. Customer Name is invalid. Please return to Portfolio Management screen and click Refresh Cust. List again.'));            
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('2013').Status_Message__c));
        
                

            }
            
        }else if(CompanyPortID != null && CompanyPortID != ''){
            AcctPlanCompanyPort__c comport = [SELECT id,Account_Name__c 
                                              FROM AcctPlanCompanyPort__c 
                                              WHERE id = :CompanyPortID];
            if(comport != null){
                if(comport.Account_Name__c == null || comport.Account_Name__c ==''){
                    isDisabled = true;
                    //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Cannot create an Account Plan. Customer Name is invalid. Please return to Portfolio Management screen and click Refresh Cust. List again.'));    
                    ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('2013').Status_Message__c));
                
                }
            }
        }else if(strurl.containsIgnoreCase('Initiate')){
            isInitiateMode =true;
            companyprofile = new AcctPlanCompanyProfile__c();
        }else{ 
            isDisabled = true;
            //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Not found any ID')); 
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('0001').Status_Message__c));
        
        }  
        if(!isAvailableforAcctPlan && (AccountID!=null && AccountID !='')){
            isDisabled = true;
            //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,'This Account is not available for Account Plan.')); 
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('2004').Status_Message__c));
        
        }
        
        if(!isHasPermission&&isNew){
            isDisabled = true;
            //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,'You do not have Permissions to create Account Plan for the selected customer.')); 
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('2005').Status_Message__c));
        
        }

        
        if(!isOwnerAccount && !isAccountTeamReadWrite &&isNew){
            isDisabled = true;
            //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Only the owner of the customer or Account Team with Permission (Read/Write) can create an Account Plan')); 
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('2006').Status_Message__c));
        
        }
        
        
        
        if(isNew && isSegmentNull){
            isDisabled = true;
            //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,'The owner segment cannot be null. ')); 
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('9003').Status_Message__c));
        
        
        }

        System.debug('WalletID : '+walletId);

        /*** user cannot create company profile on tab Account Plan Company Profile ***/
        CannotCreateComProfile();
        isSF1 = isSF1();
        warningMsg = Account_Plan_Status_Code__c.getValues('2001').Status_Message__c;
        notAvaiableOnSF1 = Account_Plan_Status_Code__c.getValues('2002').Status_Message__c;
    }
    
    public pageReference redirect(){
        
         PageReference pr = Page.CompanyprofileEdit;
            pr.setRedirect(true);
            pr.getParameters().put('CompanyID',CompanyID);
            if(GroupID !=null && GroupID !=''){
            pr.getParameters().put('GroupID',GroupID);
            }
            if(walletId !=null && WalletID !=''){
            pr.getParameters().put('WalletID',walletID);
            }
            if(mode !=null && mode !=''){
            pr.getParameters().put('mode',mode);
            }
           return pr; 
    }
    
        public pagereference dosave(){
        
        try{
                        
            if(companyProfile.Parent_Company_Info__c !=null){
                 
                companyProfile.Parent_Company_Name__c = companyProfile.Parent_Company_Info__r.Name;
            }else{
                companyProfile.Parent_Company_Name__c  = null;
            }
            
            if(isNew){
                List<AcctPlanCompanyProfile__c> ExistingComprofile = [SELECT ID,Year__C,Account__c
                                                                     FROM AcctPlanCompanyProfile__c
                                                                     WHERE Year__c =: companyprofile.Year__c
                                                                     AND Account__c =: masteracct.id];
                if(isHasGroup){
                    List<AcctPlanGroupProfile__c> ExistingGroupProfile = [SELECT ID,Year__c,Group__c
                                                                           FROM AcctPlanGroupProfile__c
                                                                           WHERE Year__c =: companyprofile.Year__c
                                                                           AND Group__c =:  masteracct.Group__c];
                    
                        if(ExistingGroupProfile.size()>0){
                            groupprofile = ExistingGroupProfile.get(0);
                        }else{
                            //populate fields R5.2 : Jantanee Saetung
                            groupprofile = new AcctPlanGroupProfile__c ();
                            groupprofile.Group__c = masteracct.Group__c;
                            groupprofile.Group_Industry_Info__c =  masteracct.Group__r.Group_Industry_Info__c;
                            groupprofile.GroupName__c =  masteracct.Group__r.Name;
                            groupprofile.Year__c = companyprofile.Year__c; 
                            groupprofile.Name = masteracct.Group__r.Name;
                            groupprofile.OwnerId = Userinfo.getUserId();
                            //groupprofile.Parent_Industry_Info__c = masteracct.Group__r.ParentIndustry__c;
                            groupprofile.UltimateParent__c = masteracct.Group__r.UltimateParent__c;
                            groupprofile.Parent_Company__c = masteracct.Group__r.Parent_Company__c;
                            
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
            
            
            
            }else{
               companyprofile.Status__c = 'In Progress';
               update companyprofile; 
                
            }
             AccountPlanCompletionEx completionEx = new AccountPlanCompletionEx(companyprofile.id);         
            
        }catch(DMLException e){
              ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
              return null;
        }
          CompanyID = companyprofile.id;
          if(isHasGroup){
            GroupID = groupprofile.id;
          }

             PageReference pr = Page.companyProfileView;
            pr.setRedirect(true);
            pr.getParameters().put('CompanyID',CompanyID);
            if(GroupID !=null && GroupID !=''){
                pr.getParameters().put('GroupID',GroupID);
            }
            if(walletId !=null && WalletID !=''){
                pr.getParameters().put('WalletID',walletID);
            }
            if(mode !=null && mode !=''){
            pr.getParameters().put('mode',mode);
            }
           return pr;
           return  pr;

    }
    
    
    public pagereference validate(){
        boolean isValid = true;
        if(companyprofile.Year__c ==null || companyprofile.Year__c==''){
            //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Year: You must enter a value')); 
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('2007').Status_Message__c));
        
        isValid =false;
        }
        
         Account queryAcct = AccountPlanUtilities.QueryAccountByAcctID(companyprofile.Account__c+'').get(0);
        
        if(queryAcct.Account_Plan_Flag__c != 'Yes'){
            isValid =false;
            //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,'This Account is not available for Account Plan.')); 
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('2004').Status_Message__c));
        
        }
                isHasPermission = AccountPlanUtilities.ISHASPERMISSION;   
                isSystemAdmin = AccountPlanUtilities.IsSystemAdmin;
        
        
        if(!isHasPermission && IsSystemAdmin){
            isValid =false;
            //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,'You do not have Permissions to create Account Plan for the selected customer.')); 
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('2005').Status_Message__c));
        
        }
        
        if(Userinfo.getUserId() != queryAcct.OwnerId){
                    isOwnerAccount = false;
        }else{
            isOwnerAccount = true;
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
        
        if(!isOwnerAccount && !isAccountTeamReadWrite){
            isValid =false;
            //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Only the owner of the customer or Account Team with Permission (Read/Write) can create an Account Plan')); 
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('2006').Status_Message__c));
        
        }
        
        
         List<AcctPlanCompanyProfile__c> ExistingComprofile = [SELECT ID,Year__C,Account__c
                                                                     FROM AcctPlanCompanyProfile__c
                                                                     WHERE Year__c =: companyprofile.Year__c
                                                                     AND Account__c =: companyprofile.Account__c];
        if(ExistingComprofile.size()>0){
            isValid =false;
                    //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR,'This Company Profile in Year :'+companyprofile.Year__c+' has already created. Please select another year.'));
                    ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR ,Account_Plan_Status_Code__c.GetValues('1101a').Status_Message__c +' '+companyprofile.Year__c+' '+ Account_Plan_Status_Code__c.GetValues('1101b').Status_Message__c));
                    
        }
        
        
        if(isValid){
            PageReference pr = Page.CompanyProfileEdit;
            pr.getParameters().put('AccountID',queryAcct.id);
            pr.getParameters().put('FiscalYear',companyprofile.Year__c);
            pr.setRedirect(true);
            return pr;
        }else{
             return null;
        }
       
    }
    
    public pagereference cancel(){
        if(AccountID != null){
            PageReference pr = new PageReference('/'+AccountID);
            pr.setRedirect(true);
            return pr;
        }if(isInitiateMode){
            String returl = ApexPages.currentPage().getParameters().get('retURL');
             PageReference pr = new PageReference('/'+returl);
            pr.setRedirect(true);
            return pr;
        }else{
            PageReference pr = Page.companyProfileView;
            pr.setRedirect(true);
            pr.getParameters().put('CompanyID',CompanyID);
            if(GroupID !=null && GroupID !=''){
                pr.getParameters().put('GroupID',GroupID);
            }
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
    
    
    public void AccountCalloutService(Account acctService){
         //CallService
                TMBAccountPlanServiceProxy.CUSTOMER_INFO[] customerInfos = new List<TMBAccountPlanServiceProxy.CUSTOMER_INFO>(); 
            Map<String,TMBAccountPlanServiceProxy.CUSTOMER_INFO> CustinfoMap = new  Map<String,TMBAccountPlanServiceProxy.CUSTOMER_INFO>();
         
                 customerInfos =   TMBAccountPlanServiceProxy.getCustomerByIds(acctService.id);  
                if(customerInfos!=null && customerInfos.size() >0){ 
                    for( TMBAccountPlanServiceProxy.CUSTOMER_INFO  custinfo :customerInfos ){
                                CustinfoMap.put(custinfo.SF_ID,custinfo);
                    } 
                        if(CustinfoMap.containsKey(acctService.id)){
                             TMBAccountPlanServiceProxy.CUSTOMER_INFO  custinfo = CustinfoMap.get(acctService.id);
                            //acctService.First_name__c = custinfo.FName==null ||custinfo.FName=='null'?'':custinfo.FName;
                            // acctService.Last_name__c = custinfo.LName==null ||custinfo.LName=='null'?'':custinfo.LName;
                            
                             String FirstName = custinfo.FName==null ||custinfo.FName=='null'?'':custinfo.FName;
                             String LastName  = custinfo.LName==null ||custinfo.LName=='null'?'':custinfo.LName;
                             FirstName.trim().replaceAll('null','');
                             LastName.trim().replaceAll('null','');
                            //acctService.First_name__c =FirstName;
                           // acctService.Last_name__c =LastName;
                            
                            
                        }
                }
            
    }

    public void CannotCreateComProfile(){
        if(String.isEmpty(AccountID) && String.isEmpty(CompanyID) && String.isEmpty(GroupID) && String.isEmpty(WalletID))
        ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.WARNING,Account_Plan_Status_Code__c.getValues('2001').Status_Message__c));
        
    }
    // Account Plan cClone : R5.2 Jantanee Saetung
    public PageReference GotoAccountPlanClonePage(){
        PageReference pr = AccountPlanCloneUtils.GotoAccountPlanClonePage('','','',CompanyID,'');
        return pr;
        
    }

    // Account Plan 5.2 : check is SF1
     public Boolean isSF1(){
        if(String.isNotBlank(ApexPages.currentPage().getParameters().get('sfdcIFrameHost')) ||
        String.isNotBlank(ApexPages.currentPage().getParameters().get('sfdcIFrameOrigin')) ||
        ApexPages.currentPage().getParameters().get('isdtp') == 'p1' ||
        (ApexPages.currentPage().getParameters().get('retURL') != null && ApexPages.currentPage().getParameters().get('retURL').contains('projectone') )
        ){
            isSF1 = true;
        }else{
            isSF1 = false;
        }
        system.debug('## isSF1 : '+isSF1);
        return isSF1;
    }
}