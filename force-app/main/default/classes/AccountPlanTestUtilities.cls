@istest
public with sharing class AccountPlanTestUtilities { 
    public static final Id SYSADMIN_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
    public static final Id TMB_RM_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB RM Profile' LIMIT 1].Id;
    public static final Id TMB_BDM_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB BDM Profile' LIMIT 1].Id;
    public static final Id TMB_SEGMENTHEAD_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'TMB Segment Head Profile' LIMIT 1].Id; 
    public static Id niTargetId {get;set;}

    public static List<Account> accountList {
        get
        {
            if(accountList == null){ 
                accountList = new List<Account>();
            }
            return accountList;
            
        }set;
    }
    public static List<User> userList {
        get
        {
            if(userList == null){
                userList = new List<User>();
            }
            return userList;
            
        }set;
    }   
    public static List<Group__c> groupList {get{
        if(groupList ==null){
            groupList = new List <Group__c>();
        }
        return groupList;
    }set;} 

    public static List<Target__c> targetList { 
        get
        {
            if(targetList == null){
                targetList = new List<Target__c>();
            }
            return targetList;
                
                }set;
    
    }

    public static AcctPlanPortfolio__c portfolio {get;set;}
    
    public static List<Account_Plan_Fiscal_Year__c> getFiscalYear{get;set;}
    
    public static void getAcctPlanMode (){
        
            AcctPlanMode__C semode = new AcctPlanMode__C();
            semode.Name ='SE';
            seMode.isMiniMode__c = true;
            insert seMode;
            AcctPlanMode__C BBmode = new AcctPlanMode__C();
            BBmode.Name ='BB';
            BBmode.isMiniMode__c = false;
            insert BBmode;
    }



    public static List<User> createUsers(Integer size,String FName,String LName,String Email,ID setProfileID,Boolean isSESegment,Boolean doInsert) {
        List<User> userToCreate = new List<User>();
        for(Integer i = 0;i<size;i++){
            String segment;
            if(isSESegment){
                segment = 'SE';
            }else{
                Segment = 'BB';
            }
            User newUser = new User(FirstName=FName+i, LastName=LName+i, 
                                    UserName=FName+i+LName+i+'_TMBTestTMB@tmbbank.com',
                                    Email=Email, Alias='Testtmb'+i,Segment__c =segment,
                                    LocaleSidKey='en_US', LanguageLocaleKey='en_US', EmailEncodingKey='ISO-8859-1', 
                                    CommunityNickname=Fname+i+'_'+LName+i+'TMBTesttmb'+i,
                                    ProfileId = SYSADMIN_PROFILE_ID, TimeZoneSidKey='America/New_York',isActive = true,
                                    Employee_ID__c ='T001'+i);
            userToCreate.add(newUser);
        }
        
        
        if(doInsert){            
            insert userToCreate;
            userList.addAll(userToCreate);
        }
        
        return userToCreate;
    }


    public static List<Account> createAccounts(Integer size , String Fname,String CType,ID SalesOwner,Boolean AccountPlanFlag, Boolean doInsert)
    {
        List<Account> newAccountList = new List<Account>();
        for(Integer i =0 ; i<size ;++i)
        {   
            Account Acct = new Account(); 
            Acct.Name = 'Test Account CUS-'+i;
            //Acct.Company_Name_Temp__c  =  'TestCompanyAccount'+i;
            Acct.ID_Type_PE__c  = 'Passport ID';
            Acct.ID_Number_PE__c  = '1510'+i;
            //Acct.Fax_No_Temp__c  = '1001';
            Acct.Office_Address_Line_1_PE__c  = 'Address1';
            Acct.Office_Address_Line_2_PE__c  = 'Address2';
            Acct.Office_Address_Line_3_PE__c  = 'Address3';
            Acct.Primary_Address_Line_1_PE__c  = 'Primary Address1';
            Acct.Primary_Address_Line_2_PE__c  = 'Primary Address2';
            Acct.Primary_Address_Line_3_PE__c  = 'Primary Address3';
            Acct.Province_Primary_PE__c  = 'Chiang Mai';
            Acct.Zip_Code_Primary_PE__c  = '50000';
            Acct.Zip_Code_Office_PE__c   = '1001';
            Acct.Customer_Type__c = CType;
            Acct.First_name_PE__c  = Fname+''+i;
            Acct.First_Name_ENG_PE__c = Fname+''+i;
            Acct.Last_name_PE__c  = 'TestMock'+i;
            Acct.Last_Name_PE_Eng__c   = 'TestMock'+i;
            //Acct.Office_Number_Temp__c = '0876213284';
            Acct.Phone ='050111222';
            Acct.Mobile_Number_PE__c  = '0801112233';
            Acct.Rating = 'Hot';
            Acct.IsDisqualified__c = false;
            Acct.OwnerId = SalesOwner;
            Acct.Owner_name_ID__c = SalesOwner+'OWN-'+i;
            if(AccountPlanFlag){
                 acct.Account_Plan_Flag__c = 'Yes';
            }
            
            
            
            
            newAccountList.add(acct);
            
        }
      
        if(doInsert){

                insert newAccountList;
            accountList.addAll(newAccountList);
        }
        
        return newAccountList;
    }

    public static List<Target__c> createTargetNI(Integer size, ID SalesOwnerID,boolean isInsert){
        
         List<RecordType> recordTypeId = [select Id from RecordType where name = 'NI Target' limit 1];
        niTargetId = recordTypeId[0].Id;
        
        for(integer i=0;i<size;i++){
            Target__c targetNI = new Target__c();
            targetNI.OwnerId = SalesOwnerID;
            targetNI.Monthly_Target_Date__c = System.today();
            targetNI.NI_Target_Monthly__c = 1000000;
            targetNI.RecordTypeId = niTargetId;
            targetList.add(targetNI);
        }
        
        if(isInsert){
            insert targetList;
        }
        
        return targetList;
    }
    
    
    
    public static AcctPlanPortfolio__c createAccountPlanPortfolio(ID SalesOwnerID,String PortYear,double TargetNI,boolean isInsert){
        portfolio = new AcctPlanPortfolio__c();
        portfolio.SalesOwner__c = SalesOwnerID;     
        portfolio.Year__c =PortYear;
        portfolio.TargetNI__c = TargetNI;
        
        if(isInsert){
            insert portfolio;
        }
        return portfolio;
    }
    
    public static List<Group__c> createGroupMaster(Integer size,String GroupName,boolean hasParent,boolean isInsert){
        List <group__c> Newgroup = new List<group__c>();
        for(integer i=0;i<size;i++){
             Group__c groupmaster = new Group__c ();
            groupmaster.Name = GroupName;
            groupmaster.GroupCompany__c  ='GroupCompany'+i;
            if(hasParent){
            groupmaster.Parent_Company__c  = createAccounts(1,'GroupParent','Juristic',Userinfo.getUserId(),true,true).get(0).id;
            
            }
        Newgroup.add(groupmaster);
        }
        if(isInsert){
            insert Newgroup;
            groupList.addall(Newgroup);
        }
        
        return NewGroup;
    }

    public static List<AcctPlanGroupPort__c> createGroupPortbyGroupMaster(List<Group__c> groupmasterlist,AcctPlanPortfolio__c existingportfolio,boolean isInsert){
        List <AcctPlanGroupPort__c> groupportList = new List<AcctPlanGroupPort__c>();
        for(Group__c groupmaster : groupmasterlist){
            AcctPlanGroupPort__c groupport = new AcctPlanGroupPort__c ();
            groupport.Group__c = groupmaster.id;
            groupport.Group_Name__c = groupmaster.Name;
            groupport.Account_Plan_Portfolio__c = existingportfolio.id;
            groupportList.add(groupport);
        }
        
        if(isInsert){
            insert groupportList;
        }
        return groupportList;
    }

    public static List<AcctPlanCompanyPort__c> createCompanyPortByAccount(List<Account> existingAccountList,AcctPlanPortfolio__c existingportfolio,boolean isInsert){
       List <AcctPlanCompanyPort__c> comportList = new List<AcctPlanCompanyPort__c>();
        for(Account existingaccount : existingAccountList){
            AcctPlanCompanyPort__c  comport = new AcctPlanCompanyPort__c();
            comport.Account__c = existingaccount.id;
            comport.Account_Name__c = existingaccount.First_name_PE__c +' '+existingaccount.Last_Name_PE__c;
            comport.Account_Plan_Portfolio__c = existingportfolio.id;
            comportList.add(comport);
        }
        
        if(isInsert){
            insert comportList;
        }
        return comportList;
    }
    
    public static List< AcctPlanCompanyProfile__c> createCompanyProfileByAccount(List<Account> existingAccountList,boolean isInsert){
        
        List< AcctPlanCompanyProfile__c> companyprofileList = new List< AcctPlanCompanyProfile__c>();
        for(Account masteracct : existingAccountList){
             AcctPlanCompanyProfile__c companyprofile = new AcctPlanCompanyProfile__c();
                //companyprofile.name = masteracct.First_Name__c+' '+masteracct.Last_Name__c;
                companyprofile.Account__c = masteracct.id;
                companyprofile.NoOfEmployee__c = masteracct.NumberOfEmployees;
                companyprofile.AccountName__c =masteracct.First_Name_PE__c+' '+masteracct.Last_Name_PE__c;
                companyprofile.EstablishedSince__c  = masteracct.ESTABLISH_DT__c;
                companyprofile.OwnerId = masteracct.OwnerID;
                //companyprofile.isMiniMode__c = AcctPlanMode__c.GetValues(masteracct.Owner.Segment__c).isMiniMode__c;
                Boolean isMiniMode = AcctPlanMode__c.GetValues(masteracct.Owner.Segment__c).isMiniMode__c;
                    if(isMiniMode){
                        companyprofile.isMiniMode__c = true;
                    }else if(masteracct.Account_Plan_Form__c == 'Short Form'){
                        companyprofile.isMiniMode__c = true;
                    }else{
                        companyprofile.isMiniMode__c = false;
                    }
                companyprofile.CustomerSince__c = masteracct.Customer_Creation_Date__c;
                companyprofile.Parent_Company_Info__c = masteracct.ParentID;
                companyprofile.Business_Code__c = masteracct.Business_Type_Code__c==null?'':masteracct.Business_Type_Code__c +
                    ' '+
                    masteracct.Business_Type_Description__c==null?'':masteracct.Business_Type_Description__c; 
                companyprofile.Status__c = 'In Progress';
                companyprofile.Parent_Company_Name__c = masteracct.ParentID;
            
                    
              companyprofileList.add(companyprofile);  
        }
        if(isInsert){
            insert companyprofileList;
        }
        
        return companyprofileList;
    }
    
    public static List<AcctPlanGroupProfile__c> createGroupProfilebyGroup (List<Group__c> mGroupList,boolean isInsert){
            List<AcctPlanGroupProfile__c> groupProfileList = new List<AcctPlanGroupProfile__c>();
        for(Group__c mGroup : mGroupList){
            AcctPlanGroupProfile__c groupprofile = new AcctPlanGroupProfile__c(); 
            groupprofile.Group__c = mGroup.id;
            groupprofile.GroupName__c = mGroup.Name;
            groupprofile.Name = mGroup.Name; 
            groupprofile.UltimateParent__c = mGroup.UltimateParent__c;
            groupprofile.Parent_Company__c = mGroup.Parent_Company__c; 
            groupProfileList.add(groupprofile);
        }
        
        if(isInsert){
         Insert groupProfileList; 
        }
        
        return groupProfileList;
    }
   
    public static List<AcctPlanContribution__c> createRenevueContribution (integer size,ID GroupID,ID CompanyID){
        List<AcctPlanContribution__c> contributionList = new List<AcctPlanContribution__c>();
        
        for(integer i=0;i<size;i++){
            AcctPlanContribution__c contri = new AcctPlanContribution__c();
            contri.EBITDAContributionPercent__c = 10;
            contri.RevenueContributionPercent__c = 10;
            
            if(CompanyID !=null){
                contri.Account_Plan_Company_Profile__c =CompanyID;
            }
            if(GroupID !=null){
              contri.AccountPlanGroupProfile__c =GroupID;   
            }
           
            contri.RevenueContributionType__c = 'Contribution by service & product';
            contributionList.add(contri);
        }
        
        insert contributionList;
        return contributionList;
    }
    
    public static List<AcctPlanSupplierOrBuyer__c> CreateSupplierOrBuyer (integer size,ID CompanyID){
        List<AcctPlanSupplierOrBuyer__c> supOrbuyList = new List<AcctPlanSupplierOrBuyer__c>();
        for(integer i=0;i<size;i++){
        AcctPlanSupplierOrBuyer__c suporbuy = new AcctPlanSupplierOrBuyer__c();
            suporbuy.Account_Plan_Company_Profile__c = companyID;
            suporbuy.Segment__c = 'Distribution';
            suporbuy.Percent__c = 10;
            supOrbuyList.add(suporbuy);
        }
        
        insert supOrbuyList;
        
        return supOrbuyList;
    }
    
    
    public static List<Account_Plan_Company_Top_5__c> CreateTop5 (integer size,ID CompanyID){
        List<Account_Plan_Company_Top_5__c> top5List = new List<Account_Plan_Company_Top_5__c>();
        for(integer i=0;i<size;i++){
        Account_Plan_Company_Top_5__c top5 = new Account_Plan_Company_Top_5__c();
            top5.Account_Plan_Company_Profile__c = companyID;
            top5.Top_5_Types__c = 'Buyers';
            top5.Percent__c = 10;
            top5List.add(top5); 
        } 
        
        insert top5List;
        
        return top5List;
    }
    
    
   public static List<Account_Plan_Status_Code__c> AccountPlanStatusCode(){
        List< Account_Plan_Status_Code__c > statuscodelist = new List< Account_Plan_Status_Code__c >();
        Account_Plan_Status_Code__c acctstatus1 = new Account_Plan_Status_Code__c(Name='0001',Status_Message__c='Error message 0001');
        Account_Plan_Status_Code__c acctstatus2 = new Account_Plan_Status_Code__c(Name='0002',Status_Message__c='Error message 0002');
        Account_Plan_Status_Code__c acctstatus3 = new Account_Plan_Status_Code__c(Name='0003A',Status_Message__c='Error message 0003A');
        Account_Plan_Status_Code__c acctstatus4 = new Account_Plan_Status_Code__c(Name='0003B',Status_Message__c='Error message 0003b');
        Account_Plan_Status_Code__c acctstatus5 = new Account_Plan_Status_Code__c(Name='0004',Status_Message__c='Error message 0004');
        Account_Plan_Status_Code__c acctstatus6 = new Account_Plan_Status_Code__c(Name='0005',Status_Message__c='Error message 0005');
        Account_Plan_Status_Code__c acctstatus7 = new Account_Plan_Status_Code__c(Name='0006',Status_Message__c='Error message 0006');
        Account_Plan_Status_Code__c acctstatus8 = new Account_Plan_Status_Code__c(Name='0007',Status_Message__c='Error message 0007');
        Account_Plan_Status_Code__c acctstatus9 = new Account_Plan_Status_Code__c(Name='0008',Status_Message__c='Error message 0008');
        Account_Plan_Status_Code__c acctstatus10 = new Account_Plan_Status_Code__c(Name='0009',Status_Message__c='Error message 0009');
        Account_Plan_Status_Code__c acctstatus11 = new Account_Plan_Status_Code__c(Name='0011',Status_Message__c='Error message 0011');
        Account_Plan_Status_Code__c acctstatus12 = new Account_Plan_Status_Code__c(Name='0012',Status_Message__c='Error message 0012');
        Account_Plan_Status_Code__c acctstatus13 = new Account_Plan_Status_Code__c(Name='0013',Status_Message__c='Error message 0013');
        Account_Plan_Status_Code__c acctstatus14 = new Account_Plan_Status_Code__c(Name='0014',Status_Message__c='Error message 0014');
        Account_Plan_Status_Code__c acctstatus15 = new Account_Plan_Status_Code__c(Name='0015',Status_Message__c='Error message 0015');
        Account_Plan_Status_Code__c acctstatus16 = new Account_Plan_Status_Code__c(Name='0016',Status_Message__c='Error message 0016');
        Account_Plan_Status_Code__c acctstatus17 = new Account_Plan_Status_Code__c(Name='0017',Status_Message__c='Error message 0017');

        Account_Plan_Status_Code__c acctstatus18 = new Account_Plan_Status_Code__c(Name='1001',Status_Message__c='Error message 1001');
        Account_Plan_Status_Code__c acctstatus19 = new Account_Plan_Status_Code__c(Name='1002',Status_Message__c='Error message 1002');
        Account_Plan_Status_Code__c acctstatus20 = new Account_Plan_Status_Code__c(Name='1003',Status_Message__c='Error message 1003');
        Account_Plan_Status_Code__c acctstatus21 = new Account_Plan_Status_Code__c(Name='1004',Status_Message__c='Error message 1004');
        Account_Plan_Status_Code__c acctstatus22 = new Account_Plan_Status_Code__c(Name='1005a',Status_Message__c='Error message 1005a');
        Account_Plan_Status_Code__c acctstatus23 = new Account_Plan_Status_Code__c(Name='1005b',Status_Message__c='Error message 1005b');
        Account_Plan_Status_Code__c acctstatus24 = new Account_Plan_Status_Code__c(Name='1006',Status_Message__c='Error message 1006');
        Account_Plan_Status_Code__c acctstatus25 = new Account_Plan_Status_Code__c(Name='1007',Status_Message__c='Error message 1007');
        Account_Plan_Status_Code__c acctstatus26 = new Account_Plan_Status_Code__c(Name='1008',Status_Message__c='Error message 1008');
        Account_Plan_Status_Code__c acctstatus27 = new Account_Plan_Status_Code__c(Name='1009',Status_Message__c='Error message 1009');
        Account_Plan_Status_Code__c acctstatus28 = new Account_Plan_Status_Code__c(Name='1010',Status_Message__c='Error message 1010');
        Account_Plan_Status_Code__c acctstatus29 = new Account_Plan_Status_Code__c(Name='1011',Status_Message__c='Error message 1011');
        Account_Plan_Status_Code__c acctstatus30 = new Account_Plan_Status_Code__c(Name='1012a',Status_Message__c='Error message 1012a');
        Account_Plan_Status_Code__c acctstatus31 = new Account_Plan_Status_Code__c(Name='1012b',Status_Message__c='Error message 1012b');
        Account_Plan_Status_Code__c acctstatus32 = new Account_Plan_Status_Code__c(Name='1013',Status_Message__c='Error message 1013');
        Account_Plan_Status_Code__c acctstatus33 = new Account_Plan_Status_Code__c(Name='1014',Status_Message__c='Error message 1014');
        Account_Plan_Status_Code__c acctstatus34 = new Account_Plan_Status_Code__c(Name='1015',Status_Message__c='Error message 1015');
        Account_Plan_Status_Code__c acctstatus35 = new Account_Plan_Status_Code__c(Name='1016a',Status_Message__c='Error message 1016a');
        Account_Plan_Status_Code__c acctstatus36 = new Account_Plan_Status_Code__c(Name='1016b',Status_Message__c='Error message 1016b');
        Account_Plan_Status_Code__c acctstatus37 = new Account_Plan_Status_Code__c(Name='1017',Status_Message__c='Error message 1017');
        Account_Plan_Status_Code__c acctstatus38 = new Account_Plan_Status_Code__c(Name='1018',Status_Message__c='Error message 1018');
        Account_Plan_Status_Code__c acctstatus39 = new Account_Plan_Status_Code__c(Name='1019',Status_Message__c='Error message 1019');
        Account_Plan_Status_Code__c acctstatus40 = new Account_Plan_Status_Code__c(Name='1020',Status_Message__c='Error message 1020');
        Account_Plan_Status_Code__c acctstatus41 = new Account_Plan_Status_Code__c(Name='1021',Status_Message__c='Error message 1021');

        Account_Plan_Status_Code__c acctstatus42 = new Account_Plan_Status_Code__c(Name='1101a',Status_Message__c='Error message 1101a');
        Account_Plan_Status_Code__c acctstatus43 = new Account_Plan_Status_Code__c(Name='1101b',Status_Message__c='Error message 1101b');
        Account_Plan_Status_Code__c acctstatus44 = new Account_Plan_Status_Code__c(Name='1102',Status_Message__c='Error message 1102');
        Account_Plan_Status_Code__c acctstatus45 = new Account_Plan_Status_Code__c(Name='1103',Status_Message__c='Error message 1103');
        Account_Plan_Status_Code__c acctstatus46 = new Account_Plan_Status_Code__c(Name='1104',Status_Message__c='Error message 1104');
        Account_Plan_Status_Code__c acctstatus47 = new Account_Plan_Status_Code__c(Name='1105',Status_Message__c='Error message 1105');
        Account_Plan_Status_Code__c acctstatus48 = new Account_Plan_Status_Code__c(Name='1106',Status_Message__c='Error message 1106');
        
        Account_Plan_Status_Code__c acctstatus49 = new Account_Plan_Status_Code__c(Name='2001',Status_Message__c='Error message 2001');
        Account_Plan_Status_Code__c acctstatus50 = new Account_Plan_Status_Code__c(Name='2002',Status_Message__c='Error message 2002');
        Account_Plan_Status_Code__c acctstatus51 = new Account_Plan_Status_Code__c(Name='2003',Status_Message__c='Error message 2003');
        Account_Plan_Status_Code__c acctstatus52 = new Account_Plan_Status_Code__c(Name='2004',Status_Message__c='Error message 2004');
        Account_Plan_Status_Code__c acctstatus53 = new Account_Plan_Status_Code__c(Name='2005',Status_Message__c='Error message 2005');
        Account_Plan_Status_Code__c acctstatus54 = new Account_Plan_Status_Code__c(Name='2006',Status_Message__c='Error message 2006');
        Account_Plan_Status_Code__c acctstatus55 = new Account_Plan_Status_Code__c(Name='2007',Status_Message__c='Error message 2007');
        Account_Plan_Status_Code__c acctstatus56 = new Account_Plan_Status_Code__c(Name='2008',Status_Message__c='Error message 2008');
        Account_Plan_Status_Code__c acctstatus57 = new Account_Plan_Status_Code__c(Name='2009',Status_Message__c='Error message 2009');
        Account_Plan_Status_Code__c acctstatus58 = new Account_Plan_Status_Code__c(Name='2010',Status_Message__c='Error message 2010');
        Account_Plan_Status_Code__c acctstatus59 = new Account_Plan_Status_Code__c(Name='2011',Status_Message__c='Error message 2011');
        Account_Plan_Status_Code__c acctstatus60 = new Account_Plan_Status_Code__c(Name='2013',Status_Message__c='Error message 2013');
        Account_Plan_Status_Code__c acctstatus61 = new Account_Plan_Status_Code__c(Name='2014',Status_Message__c='Error message 2014');

        Account_Plan_Status_Code__c acctstatus62 = new Account_Plan_Status_Code__c(Name='3001',Status_Message__c='Error message 3001');
        Account_Plan_Status_Code__c acctstatus63 = new Account_Plan_Status_Code__c(Name='3002',Status_Message__c='Error message 3002');
        Account_Plan_Status_Code__c acctstatus64 = new Account_Plan_Status_Code__c(Name='3003',Status_Message__c='Error message 3003');
        Account_Plan_Status_Code__c acctstatus65 = new Account_Plan_Status_Code__c(Name='3004',Status_Message__c='Error message 3004');
        Account_Plan_Status_Code__c acctstatus66 = new Account_Plan_Status_Code__c(Name='3005',Status_Message__c='Error message 3005');
        Account_Plan_Status_Code__c acctstatus67 = new Account_Plan_Status_Code__c(Name='3006',Status_Message__c='Error message 3006');
        Account_Plan_Status_Code__c acctstatus68 = new Account_Plan_Status_Code__c(Name='3007',Status_Message__c='Error message 3007');
        Account_Plan_Status_Code__c acctstatus69 = new Account_Plan_Status_Code__c(Name='3008',Status_Message__c='Error message 3008');
        Account_Plan_Status_Code__c acctstatus70 = new Account_Plan_Status_Code__c(Name='3009',Status_Message__c='Error message 3009');
        Account_Plan_Status_Code__c acctstatus71 = new Account_Plan_Status_Code__c(Name='3010',Status_Message__c='Error message 3010');
        Account_Plan_Status_Code__c acctstatus72 = new Account_Plan_Status_Code__c(Name='3011',Status_Message__c='Error message 3011');
        Account_Plan_Status_Code__c acctstatus73 = new Account_Plan_Status_Code__c(Name='3012',Status_Message__c='Error message 3012');
        Account_Plan_Status_Code__c acctstatus74 = new Account_Plan_Status_Code__c(Name='3013',Status_Message__c='Error message 3013');
        Account_Plan_Status_Code__c acctstatus75 = new Account_Plan_Status_Code__c(Name='3015',Status_Message__c='Error message 3015');
        Account_Plan_Status_Code__c acctstatus76 = new Account_Plan_Status_Code__c(Name='3018',Status_Message__c='Error message 3018');
        Account_Plan_Status_Code__c acctstatus77 = new Account_Plan_Status_Code__c(Name='3019',Status_Message__c='Error message 3019');
        Account_Plan_Status_Code__c acctstatus78 = new Account_Plan_Status_Code__c(Name='3020',Status_Message__c='Error message 3020');
        Account_Plan_Status_Code__c acctstatus79 = new Account_Plan_Status_Code__c(Name='3021',Status_Message__c='Error message 3021');
        Account_Plan_Status_Code__c acctstatus80 = new Account_Plan_Status_Code__c(Name='3022',Status_Message__c='Error message 3022');
        Account_Plan_Status_Code__c acctstatus81 = new Account_Plan_Status_Code__c(Name='3023',Status_Message__c='Error message 3023');
        Account_Plan_Status_Code__c acctstatus82 = new Account_Plan_Status_Code__c(Name='3024',Status_Message__c='Error message 3024');
        Account_Plan_Status_Code__c acctstatus83 = new Account_Plan_Status_Code__c(Name='3025',Status_Message__c='Error message 3025');
        Account_Plan_Status_Code__c acctstatus84 = new Account_Plan_Status_Code__c(Name='3026',Status_Message__c='Error message 3026');
        Account_Plan_Status_Code__c acctstatus85 = new Account_Plan_Status_Code__c(Name='3027',Status_Message__c='Error message 3027');


        Account_Plan_Status_Code__c acctstatus86 = new Account_Plan_Status_Code__c(Name='3102',Status_Message__c='Error message 3102');
        Account_Plan_Status_Code__c acctstatus87 = new Account_Plan_Status_Code__c(Name='3103',Status_Message__c='Error message 3103');
        Account_Plan_Status_Code__c acctstatus88 = new Account_Plan_Status_Code__c(Name='3104',Status_Message__c='Error message 3104');
        Account_Plan_Status_Code__c acctstatus89 = new Account_Plan_Status_Code__c(Name='3105',Status_Message__c='Error message 3105');
        Account_Plan_Status_Code__c acctstatus90 = new Account_Plan_Status_Code__c(Name='3106',Status_Message__c='Error message 3106');
        Account_Plan_Status_Code__c acctstatus91 = new Account_Plan_Status_Code__c(Name='3107',Status_Message__c='Error message 3107');
        Account_Plan_Status_Code__c acctstatus92 = new Account_Plan_Status_Code__c(Name='3108',Status_Message__c='Error message 3108');

        Account_Plan_Status_Code__c acctstatus93 = new Account_Plan_Status_Code__c(Name='3201',Status_Message__c='Error message 3201');
        Account_Plan_Status_Code__c acctstatus94 = new Account_Plan_Status_Code__c(Name='3202',Status_Message__c='Error message 3202');
        Account_Plan_Status_Code__c acctstatus95 = new Account_Plan_Status_Code__c(Name='3203',Status_Message__c='Error message 3203');
        Account_Plan_Status_Code__c acctstatus96 = new Account_Plan_Status_Code__c(Name='3204',Status_Message__c='Error message 3204');
        Account_Plan_Status_Code__c acctstatus97 = new Account_Plan_Status_Code__c(Name='3205',Status_Message__c='Error message 3205');

        Account_Plan_Status_Code__c acctstatus98 = new Account_Plan_Status_Code__c(Name='4001',Status_Message__c='Error message 4001');
        Account_Plan_Status_Code__c acctstatus99 = new Account_Plan_Status_Code__c(Name='4002',Status_Message__c='Error message 4002');
        Account_Plan_Status_Code__c acctstatus100 = new Account_Plan_Status_Code__c(Name='4003',Status_Message__c='Error message 4003');
        
        Account_Plan_Status_Code__c acctstatus101 = new Account_Plan_Status_Code__c(Name='5001',Status_Message__c='Error message 5001');
        Account_Plan_Status_Code__c acctstatus102 = new Account_Plan_Status_Code__c(Name='5002',Status_Message__c='Error message 5002');
        Account_Plan_Status_Code__c acctstatus103 = new Account_Plan_Status_Code__c(Name='5003',Status_Message__c='Error message 5003');
        Account_Plan_Status_Code__c acctstatus104 = new Account_Plan_Status_Code__c(Name='5004',Status_Message__c='Error message 5004');
        Account_Plan_Status_Code__c acctstatus105 = new Account_Plan_Status_Code__c(Name='5005',Status_Message__c='Error message 5005');
        Account_Plan_Status_Code__c acctstatus106 = new Account_Plan_Status_Code__c(Name='5006',Status_Message__c='Error message 5006');
        Account_Plan_Status_Code__c acctstatus107 = new Account_Plan_Status_Code__c(Name='5007',Status_Message__c='Error message 5007');
        Account_Plan_Status_Code__c acctstatus108 = new Account_Plan_Status_Code__c(Name='5008',Status_Message__c='Error message 5008');
        Account_Plan_Status_Code__c acctstatus109 = new Account_Plan_Status_Code__c(Name='5009',Status_Message__c='Error message 5009');
        Account_Plan_Status_Code__c acctstatus110 = new Account_Plan_Status_Code__c(Name='5010',Status_Message__c='Error message 5010');
        Account_Plan_Status_Code__c acctstatus111 = new Account_Plan_Status_Code__c(Name='5011',Status_Message__c='Error message 5011');
        Account_Plan_Status_Code__c acctstatus112 = new Account_Plan_Status_Code__c(Name='5012',Status_Message__c='Error message 5012');
        Account_Plan_Status_Code__c acctstatus113 = new Account_Plan_Status_Code__c(Name='5013',Status_Message__c='Error message 5013');
        Account_Plan_Status_Code__c acctstatus114 = new Account_Plan_Status_Code__c(Name='5014',Status_Message__c='Error message 5014');
        Account_Plan_Status_Code__c acctstatus115 = new Account_Plan_Status_Code__c(Name='5015',Status_Message__c='Error message 5015');
        Account_Plan_Status_Code__c acctstatus116 = new Account_Plan_Status_Code__c(Name='5016',Status_Message__c='Error message 5016');
        Account_Plan_Status_Code__c acctstatus117 = new Account_Plan_Status_Code__c(Name='5017',Status_Message__c='Error message 5017');
        Account_Plan_Status_Code__c acctstatus118 = new Account_Plan_Status_Code__c(Name='5018',Status_Message__c='Error message 5018');
        Account_Plan_Status_Code__c acctstatus119 = new Account_Plan_Status_Code__c(Name='5019',Status_Message__c='Error message 5019');
        Account_Plan_Status_Code__c acctstatus120 = new Account_Plan_Status_Code__c(Name='5020',Status_Message__c='Error message 5020');
        Account_Plan_Status_Code__c acctstatus121 = new Account_Plan_Status_Code__c(Name='5022',Status_Message__c='Error message 5022');
        Account_Plan_Status_Code__c acctstatus122 = new Account_Plan_Status_Code__c(Name='5023',Status_Message__c='Error message 5023');
        Account_Plan_Status_Code__c acctstatus123 = new Account_Plan_Status_Code__c(Name='5024',Status_Message__c='Error message 5024');
        Account_Plan_Status_Code__c acctstatus124 = new Account_Plan_Status_Code__c(Name='5025',Status_Message__c='Error message 5025');
        Account_Plan_Status_Code__c acctstatus125 = new Account_Plan_Status_Code__c(Name='5026',Status_Message__c='Error message 5026');
        Account_Plan_Status_Code__c acctstatus126 = new Account_Plan_Status_Code__c(Name='5027',Status_Message__c='Error message 5027');
        Account_Plan_Status_Code__c acctstatus127 = new Account_Plan_Status_Code__c(Name='5028',Status_Message__c='Error message 5028');
        Account_Plan_Status_Code__c acctstatus128 = new Account_Plan_Status_Code__c(Name='5030',Status_Message__c='Error message 5030');
        Account_Plan_Status_Code__c acctstatus129 = new Account_Plan_Status_Code__c(Name='5031',Status_Message__c='Error message 5031');
        Account_Plan_Status_Code__c acctstatus130 = new Account_Plan_Status_Code__c(Name='5032',Status_Message__c='Error message 5032');
        Account_Plan_Status_Code__c acctstatus131 = new Account_Plan_Status_Code__c(Name='5033',Status_Message__c='Error message 5033');
        Account_Plan_Status_Code__c acctstatus132 = new Account_Plan_Status_Code__c(Name='5034',Status_Message__c='Error message 5034');
        Account_Plan_Status_Code__c acctstatus133 = new Account_Plan_Status_Code__c(Name='5035',Status_Message__c='Error message 5035');
        Account_Plan_Status_Code__c acctstatus134 = new Account_Plan_Status_Code__c(Name='5036',Status_Message__c='Error message 5036');
        Account_Plan_Status_Code__c acctstatus135 = new Account_Plan_Status_Code__c(Name='5037',Status_Message__c='Error message 5037');
        Account_Plan_Status_Code__c acctstatus136 = new Account_Plan_Status_Code__c(Name='5038',Status_Message__c='Error message 5038');
        Account_Plan_Status_Code__c acctstatus137 = new Account_Plan_Status_Code__c(Name='5039',Status_Message__c='Error message 5039');
       
        Account_Plan_Status_Code__c acctstatus138 = new Account_Plan_Status_Code__c(Name='6001',Status_Message__c='Error message 6001');
       
        Account_Plan_Status_Code__c acctstatus139 = new Account_Plan_Status_Code__c(Name='7001',Status_Message__c='Error message 7001');
        Account_Plan_Status_Code__c acctstatus140= new Account_Plan_Status_Code__c(Name='7002',Status_Message__c='Error message 7002');
        Account_Plan_Status_Code__c acctstatus141 = new Account_Plan_Status_Code__c(Name='7003',Status_Message__c='Error message 7003');
        Account_Plan_Status_Code__c acctstatus142 = new Account_Plan_Status_Code__c(Name='7004',Status_Message__c='Error message 7004');

        Account_Plan_Status_Code__c acctstatus143 = new Account_Plan_Status_Code__c(Name='9001',Status_Message__c='Error message 9001');
        Account_Plan_Status_Code__c acctstatus144 = new Account_Plan_Status_Code__c(Name='9002',Status_Message__c='Error message 9002');
        Account_Plan_Status_Code__c acctstatus145 = new Account_Plan_Status_Code__c(Name='9003',Status_Message__c='Error message 9003');
        Account_Plan_Status_Code__c acctstatus146 = new Account_Plan_Status_Code__c(Name='9004',Status_Message__c='Error message 9004');
        Account_Plan_Status_Code__c acctstatus147 = new Account_Plan_Status_Code__c(Name='9005',Status_Message__c='Error message 9005');

        statuscodelist.add(acctstatus1);
        statuscodelist.add(acctstatus2);
        statuscodelist.add(acctstatus3);
        statuscodelist.add(acctstatus4);
        statuscodelist.add(acctstatus5);
        statuscodelist.add(acctstatus6);
        statuscodelist.add(acctstatus7);
        statuscodelist.add(acctstatus8);
        statuscodelist.add(acctstatus9);
        statuscodelist.add(acctstatus10);
        statuscodelist.add(acctstatus11);
        statuscodelist.add(acctstatus12);
        statuscodelist.add(acctstatus13);
        statuscodelist.add(acctstatus14);
        statuscodelist.add(acctstatus15);
        statuscodelist.add(acctstatus16);
        statuscodelist.add(acctstatus17); 
        statuscodelist.add(acctstatus18);
        statuscodelist.add(acctstatus19);
        statuscodelist.add(acctstatus20);
        statuscodelist.add(acctstatus21);
        statuscodelist.add(acctstatus22);
        statuscodelist.add(acctstatus23);
        statuscodelist.add(acctstatus24);
        statuscodelist.add(acctstatus25);
        statuscodelist.add(acctstatus26);
        statuscodelist.add(acctstatus27);
        statuscodelist.add(acctstatus28);
        statuscodelist.add(acctstatus29);
        statuscodelist.add(acctstatus30);
        statuscodelist.add(acctstatus31);
        statuscodelist.add(acctstatus32);
        statuscodelist.add(acctstatus33);
        statuscodelist.add(acctstatus34);
        statuscodelist.add(acctstatus35);
        statuscodelist.add(acctstatus36);
        statuscodelist.add(acctstatus37);
        statuscodelist.add(acctstatus38);
        statuscodelist.add(acctstatus39);
        statuscodelist.add(acctstatus40);
        statuscodelist.add(acctstatus41);
        statuscodelist.add(acctstatus42);
        statuscodelist.add(acctstatus43);
        statuscodelist.add(acctstatus44);
        statuscodelist.add(acctstatus45);
        statuscodelist.add(acctstatus46);
        statuscodelist.add(acctstatus47);
        statuscodelist.add(acctstatus48);
        statuscodelist.add(acctstatus49);
        statuscodelist.add(acctstatus50);
        statuscodelist.add(acctstatus51);
        statuscodelist.add(acctstatus52);
        statuscodelist.add(acctstatus53);
        statuscodelist.add(acctstatus54);
        statuscodelist.add(acctstatus55);
        statuscodelist.add(acctstatus56);
        statuscodelist.add(acctstatus57);
        statuscodelist.add(acctstatus58);
        statuscodelist.add(acctstatus59);
        statuscodelist.add(acctstatus60);
        statuscodelist.add(acctstatus61);
        statuscodelist.add(acctstatus62);
        statuscodelist.add(acctstatus63);
        statuscodelist.add(acctstatus64);
        statuscodelist.add(acctstatus65);
        statuscodelist.add(acctstatus66);
        statuscodelist.add(acctstatus67);
        statuscodelist.add(acctstatus68);
        statuscodelist.add(acctstatus69);
        statuscodelist.add(acctstatus70);
        statuscodelist.add(acctstatus71);
        statuscodelist.add(acctstatus72);
        statuscodelist.add(acctstatus73);
        statuscodelist.add(acctstatus74);
        statuscodelist.add(acctstatus75);
        statuscodelist.add(acctstatus76);
        statuscodelist.add(acctstatus77);
        statuscodelist.add(acctstatus78);
        statuscodelist.add(acctstatus79);
        statuscodelist.add(acctstatus80);
        statuscodelist.add(acctstatus81);
        statuscodelist.add(acctstatus82);
        statuscodelist.add(acctstatus83);
        statuscodelist.add(acctstatus84);
        statuscodelist.add(acctstatus85);
        statuscodelist.add(acctstatus86);
        statuscodelist.add(acctstatus87);
        statuscodelist.add(acctstatus88);
        statuscodelist.add(acctstatus89);
        statuscodelist.add(acctstatus90);
        statuscodelist.add(acctstatus91);
        statuscodelist.add(acctstatus92);
        statuscodelist.add(acctstatus93);
        statuscodelist.add(acctstatus94);
        statuscodelist.add(acctstatus95);
        statuscodelist.add(acctstatus96);
        statuscodelist.add(acctstatus97);
        statuscodelist.add(acctstatus98);
        statuscodelist.add(acctstatus99);
    statuscodelist.add(acctstatus100);
        statuscodelist.add(acctstatus101);
        statuscodelist.add(acctstatus102);
        statuscodelist.add(acctstatus103);
        statuscodelist.add(acctstatus104);
        statuscodelist.add(acctstatus105);
        statuscodelist.add(acctstatus106);
        statuscodelist.add(acctstatus107);
        statuscodelist.add(acctstatus108);
        statuscodelist.add(acctstatus109);
        statuscodelist.add(acctstatus110);
        statuscodelist.add(acctstatus111);
        statuscodelist.add(acctstatus112);
        statuscodelist.add(acctstatus113);
        statuscodelist.add(acctstatus114);
        statuscodelist.add(acctstatus115);
        statuscodelist.add(acctstatus116);
        statuscodelist.add(acctstatus117);
        statuscodelist.add(acctstatus118);
        statuscodelist.add(acctstatus119);
        statuscodelist.add(acctstatus120);
        statuscodelist.add(acctstatus121);
        statuscodelist.add(acctstatus122);
        statuscodelist.add(acctstatus123);
        statuscodelist.add(acctstatus124);
        statuscodelist.add(acctstatus125);
        statuscodelist.add(acctstatus126);
        statuscodelist.add(acctstatus127);
        statuscodelist.add(acctstatus128);
        statuscodelist.add(acctstatus129);
        statuscodelist.add(acctstatus130);
        statuscodelist.add(acctstatus131);
        statuscodelist.add(acctstatus132);
        statuscodelist.add(acctstatus133);
        statuscodelist.add(acctstatus134);
        statuscodelist.add(acctstatus135);
        statuscodelist.add(acctstatus136);
        statuscodelist.add(acctstatus137);
        statuscodelist.add(acctstatus138);
        statuscodelist.add(acctstatus139);
        statuscodelist.add(acctstatus140);
        statuscodelist.add(acctstatus141);
        statuscodelist.add(acctstatus142);
        statuscodelist.add(acctstatus143);
        statuscodelist.add(acctstatus144);
        statuscodelist.add(acctstatus145);
        statuscodelist.add(acctstatus146);
        statuscodelist.add(acctstatus147);

        insert statuscodelist;
        return statuscodelist;
    }
}