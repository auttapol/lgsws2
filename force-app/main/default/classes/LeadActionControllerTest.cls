@istest
public class LeadActionControllerTest {
    static List<Branch_And_Zone__c> branchAndZoneList;
    static List<RTL_Referral__c> referralList;
    static User ComUser1 = [select ID from user where isactive = true and ProfileId in (SELECT Id FROM Profile WHERE Name like '%BDM%' ) LIMIT 1];
    static {
         TestUtils.createIdType();
        TestUtils.createAppConfig();
        TestUtils.createStatusCode();
        TestUtils.createDisqualifiedReason();
        TestUtils.createDateOfBirth();
        TestUtils.CreateProceBookAccess();
        /**********CR Referral *************/
        TestUtility_Referral.createAppConfigReferralAssignment();
        TestUtility_Referral.createReferralAssignment();
        TestUtility_Referral.createAppConfigCallMeNowBH();
        branchAndZoneList = RTL_TestUtility.createBranchZone(9,true);
        
        RTL_Branch_Manager_Title__c branchtitle  = new RTL_Branch_Manager_Title__c();
        branchtitle.Name =  'Branch Manager';
        branchtitle.RTL_Value__c ='Branch Manager (Service and Relationship)';
       insert branchtitle;
            
            
        
    }
    
        public static RecordType CommercialLeadRecordType {get{
        if(CommercialLeadRecordType ==null){
           CommercialLeadRecordType = [SELECT id,Name FROM RecordType 
                                 WHERE Name='Commercial Lead' 
                                 AND sObjectType='Lead' LIMIT 1];
        }
        return CommercialLeadRecordType;
    }set;}

    
    public static testmethod void ConvertLeadCommercialLead(){

        
        
        
        Id commercialProfile = [SELECT Id FROM Profile WHERE Name = 'TMB RM Profile' LIMIT 1].Id;
        User commercialUser = new User(FirstName = 'NewUser' , LastName = 'Commercial', 
                                    UserName='newUserCommercial@tmbbank.com',
                                    Email='newUserCommercial@tmbbank.com', Alias='Testtmb',
                                    LocaleSidKey='en_US', LanguageLocaleKey='en_US', EmailEncodingKey='ISO-8859-1', 
                                    CommunityNickname='commercialUser',
                                    ProfileId = commercialProfile, TimeZoneSidKey='America/New_York',isActive = true,
                                    Employee_ID__c ='MM101');
                                    
                                    
                                    System.runAs(commercialUser){
                                        
                                        
            
          Lead leadRec = new Lead();
        leadRec.Phone = '0877874871';
        leadRec.Company = 'LeadExtension';
        leadRec.ID_Type__c = 'BRN ID';
        leadRec.ID_Number__c = '13255555';
        leadRec.Mobile_No__c = '053532198';
        leadRec.Customer_Type__c = 'Juristic';
        leadRec.FirstName =  'LeadExFirst';
        leadRec.LastName = 'LeadExLast';
        leadRec.RecordTypeId = CommercialLeadRecordType.id;
        leadRec.Interest_result__c = 'Yes';
        
        ///**********  CR Referral   *************///
        referralList = TestUtility_Referral.createReferralsWithoutAccount(1,branchAndZoneList[0].id,'Loan','Sell (เพื่อนำเสนอขาย)',true);
        leadRec.RTL_Referral__c = referralList[0].id;
         
        insert leadRec;
         
        //Recommended Product
        //
        //
        //
        //
        //
        
         Pricebook2 pb = new Pricebook2(Name = 'Commercial Pricebook', 
                                           TMB_Pricebook__c ='TMB5412',
                                           Description = 'Price Book 2009 Products', IsActive = true);
            insert pb;
            
            Product2 prod = new Product2(Name = 'Laptop X200',
                                    Family = 'Hardware',
                                    Product_Level__c ='1',
                                        IsActive = true);
            
        
            insert prod;
        
        Product2 prod2 = new Product2(Name = 'Laptop X100',
                                    Family = 'Hardware',
                                    Product_Level__c ='1',
                                     IsActive = true);
            
        
            insert prod2;
        
        PricebookEntry standardPBE 
            = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),
                                 Product2Id = prod.Id, UnitPrice = 1000, IsActive = true);
        insert standardPBE;
        
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = pb.Id, 
                                                Product2Id = prod.Id, 
                                                UnitPrice = 1000, IsActive = true);
        insert pbe;
        
        
        PricebookEntry standardPBE2 
            = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),
                                 Product2Id = prod2.Id, UnitPrice = 1000, IsActive = true);
        insert standardPBE2;
        
        PricebookEntry pbe2 = new PricebookEntry(Pricebook2Id = pb.Id, 
                                                Product2Id = prod2.Id, 
                                                UnitPrice = 1000, IsActive = true);
        insert pbe2;
        
        
        List<Product_Interest__c> PIList = new List<Product_Interest__c>();
        
         Product_Interest__c PINonCreDit = new Product_Interest__c();
            PINonCreDit.Opportunity_Type__c ='Non-Credit';
            PINonCreDit.Amount__c =500000;
            PINonCreDit.Product__c = prod.id;
            PINonCreDit.Lead__c = leadRec.id;
            PIList.add(PINonCreDit);
            
        
        Product_Interest__c PICreDit = new Product_Interest__c();
            PICreDit.Opportunity_Type__c ='Credit';
            PICreDit.Amount__c =500000;
            PICreDit.Product__c = prod2.id;
            PICreDit.Lead__c = leadRec.id;
            PIList.add(PICreDit);
         
            insert PIList;
        
        
        
        
        
        
        
        //VisitPlan
        //
                Call_Report__c report = new Call_Report__c();
       
        report.Lead__c = leadRec.id;
        report.Status__c ='2 - Completed';
        report.Categories__c = 'Pre boarding';
        report.Main_purpose__c ='First visit';
        report.Date_of_Visit__c  = System.today();
        report.Complete_Date__c = System.today();
        report.Outcome__c ='Win Deal';
        report.OwnerId = Userinfo.getUserId();
        report.Actual_Visit_Date__c = System.today();
        report.Sub_Purpose__c = 'Credit';
        
        insert report;
        
    
        Test.startTest();

         PageReference leadconvert = Page.LeadConvertCutomized;
        Test.setCurrentPage(leadconvert);
         
        
            
      
        ApexPages.StandardController controllerinsert = new ApexPages.StandardController(leadRec);
            LeadActionController leadconvertPage = new LeadActionController(controllerinsert);
            String convertLeadWarning = leadconvertPage.convertLeadWarning;
            String convertOppornuityMessage= leadconvertpage.convertOppornuityMessage;
            
            leadConvertPage.convertLead();
            
            leadConvertPage.oppty.Expected_submit_date__c = System.today();
            leadConvertPage.oppty.CloseDate = System.today();
                for(LeadActionController.ProductWrapper Pwrapper : leadconvertpage.ProductWrapperList){
                    Pwrapper.IsSelected = true;
                }
        
            leadConvertPage.oppty.Pricebook2ID = pb.id;
            leadConvertPage.ConvertAction();
            Test.stopTest();
        }
        
        
    }
    
    
    public static testmethod void UninterestedLead(){
        Test.startTest();
        
        
        LisT<Account> acct =  TestUtils.createAccounts(2,'testDisqualified','Juristic', false);
            Account firstAcct = acct.get(0);
            firstAcct.ID_Type_PE__c = 'BRN ID';
            firstAcct.ID_Number_PE__c = '13255555';
            firstAcct.Phone = '0877874871';
            insert firstacct;
         
            Contact con = new Contact(Firstname='uninterest',LastName = 'test contact' ,AccountId = firstacct.id,
                                      Photo__c = '<img alt="User-added image" src="test"></img>');
            insert con;
            
         
         
         
          Lead leadRec = new Lead();
        leadRec.Phone = '0877874871';
        leadRec.Company = 'LeadExtension';
        leadRec.ID_Type__c = 'BRN ID';
        leadRec.ID_Number__c = '13255555';
        leadRec.Mobile_No__c = '053532198';
        leadRec.Customer_Type__c = 'Juristic';
        leadRec.FirstName =  'LeadExFirst';
        leadRec.LastName = 'LeadExLast';
        leadRec.Account__c = firstacct.id;
        leadRec.RecordTypeId = CommercialLeadRecordType.id;
        leadRec.Interest_result__c = 'No';
        leadRec.Unqualified_Reasons__c = 'Already has product';
        leadRec.Sub_Unqualified_Reason__c = 'Product feature does not meet the requirement';
        leadRec.ownerid = ComUser1.id; 
         
        insert leadRec;
         
         
          Pricebook2 pb = new Pricebook2(Name = 'Commercial Pricebook', 
                                           TMB_Pricebook__c ='TMB5412',
                                           Description = 'Price Book 2009 Products', IsActive = true);
            insert pb;
            
            Product2 prod = new Product2(Name = 'Laptop X200',
                                    Family = 'Hardware',
                                    Product_Level__c ='1',
                                        IsActive = true);
            
        
            insert prod;
        
        Product2 prod2 = new Product2(Name = 'Laptop X100',
                                    Family = 'Hardware',
                                    Product_Level__c ='1', 
                                     IsActive = true);
            
        
            insert prod2;
        
        PricebookEntry standardPBE 
            = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),
                                 Product2Id = prod.Id, UnitPrice = 1000, IsActive = true);
        insert standardPBE;
        
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = pb.Id, 
                                                Product2Id = prod.Id, 
                                                UnitPrice = 1000, IsActive = true);
        insert pbe;
        
        
        PricebookEntry standardPBE2 
            = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),
                                 Product2Id = prod2.Id, UnitPrice = 1000, IsActive = true);
        insert standardPBE2;
        
        PricebookEntry pbe2 = new PricebookEntry(Pricebook2Id = pb.Id, 
                                                Product2Id = prod2.Id, 
                                                UnitPrice = 1000, IsActive = true);
        insert pbe2;
        
         
         
        
         
            List<Product_Interest__c> PIList = new List<Product_Interest__c>();
        
         Product_Interest__c PINonCreDit = new Product_Interest__c();
            PINonCreDit.Opportunity_Type__c ='Non-Credit';
            
            PINonCreDit.Amount__c =500000;
            PINonCreDit.Product__c = prod.id;
            PINonCreDit.Lead__c = leadRec.id;
            PIList.add(PINonCreDit);
            
        
        Product_Interest__c PICreDit = new Product_Interest__c();
            PICreDit.Opportunity_Type__c ='Credit';
            PICreDit.Amount__c =500000;
            PICreDit.Product__c = prod2.id;
            PICreDit.Lead__c = leadRec.id;
            PIList.add(PICreDit);
         
            insert PIList;
         
         
         //VisitPlan
        //
                Call_Report__c report = new Call_Report__c();
       
        report.Lead__c = leadRec.id;
        report.Status__c ='2 - Completed';
        report.Categories__c = 'Pre boarding';
        report.Main_purpose__c ='First visit';
        report.Date_of_Visit__c  = System.today();
        report.Complete_Date__c = System.today();
        report.Outcome__c ='Win Deal';
        report.OwnerId = ComUser1.id;
        report.Actual_Visit_Date__c = System.today();
        report.Sub_Purpose__c = 'Credit';
        
        insert report;
         
         
        
         PageReference leadconvert = Page.LeadConvertCutomized;
        Test.setCurrentPage(leadconvert);
                     
        ApexPages.StandardController controllerinsert = new ApexPages.StandardController(leadRec);
        LeadActionController leadconvertPage = new LeadActionController(controllerinsert);
            
            LeadConvertPage.leadobj.Interest_result__c = 'Yes';
            leadConvertPage.confirmContacted();
            leadConvertPage.interestAction();
            LeadConvertPage.leadobj.Interest_result__c = 'No';
            leadConvertPage.interestAction();
            LeadConvertPage.leadobj.Unqualified_Reasons__c = 'Already have a product';
            leadConvertPage.convertLead();
        

        Test.stopTest();
        
    }
    
    
     public static testmethod void ConvertLeadCommercialAccount(){
         
        
           Id commercialProfile = [SELECT Id FROM Profile WHERE Name = 'TMB RM Profile' LIMIT 1].Id;
        User commercialUser = new User(FirstName = 'NewUser' , LastName = 'Commercial', 
        UserName='newUserCommercial@tmbbank.com',
                                    Email='newUserCommercial@tmbbank.com', Alias='Testtmb',
                                    LocaleSidKey='en_US', LanguageLocaleKey='en_US', EmailEncodingKey='ISO-8859-1', 
                                    CommunityNickname='commercialUser',
                                    ProfileId = commercialProfile, TimeZoneSidKey='America/New_York',isActive = true,
                                    Employee_ID__c ='MM101');
                                    
        System.runAs(commercialUser){
            insert new PermissionSetAssignment(PermissionSetId=TestUtils.SetupPermissionSet().Id,AssigneeId=commercialUser.Id);
        }          
        System.runAs(commercialUser){
            
            
          LisT<Account> acct =  TestUtils.createAccounts(1,'testDisqualified','Juristic', false);
            Account firstAcct = acct.get(0);
            firstAcct.ID_Type_PE__c = 'BRN ID';
            firstAcct.ID_Number_PE__c = '13255555';
            firstAcct.Phone = '0877874871';
            firstAcct.Last_name_PE__c='';
            insert firstacct;
         
          Contact con = new Contact(Firstname='testdis',LastName = 'test contact' ,AccountId = firstacct.id,
                                      Photo__c = '<img alt="User-added image" src="test"></img>');
            insert con;

         
            
            
         
             Id [] fixedSearchResults= new Id[1];
           fixedSearchResults[0] = firstacct.id;
           Test.setFixedSearchResults(fixedSearchResults);
            
         
         
          Lead leadRec = new Lead();
        leadRec.Phone = '0877874871';
        leadRec.Company = 'LeadExtension';
        leadRec.Account__c = firstAcct.id;
        leadRec.ID_Type__c = 'BRN ID';
        leadRec.ID_Number__c = '13255555';
        leadRec.Mobile_No__c = '053532198';
        leadRec.Customer_Type__c = 'Juristic';
        leadRec.FirstName =  'LeadExFirst';
        leadRec.LastName = 'LeadExLast';
        leadRec.RecordTypeId = CommercialLeadRecordType.id;
        leadRec.Interest_result__c = 'Yes';
            
                        
         
              referralList = TestUtility_Referral.createReferralsWithoutAccount(1,branchAndZoneList[0].id,'Loan','Sell (เพื่อนำเสนอขาย)',true);
        leadRec.RTL_Referral__c = referralList[0].id;
        insert leadRec;
         
        //Recommended Product
        //
        //
        //
        //
        //
        
         Pricebook2 pb = new Pricebook2(Name = 'Commercial Pricebook', 
                                           TMB_Pricebook__c ='TMB5412',
                                           Description = 'Price Book 2009 Products', IsActive = true);
            insert pb;
            
            Product2 prod = new Product2(Name = 'Laptop X200',
                                    Family = 'Hardware',
                                    Product_Level__c ='1',
                                        IsActive = true);
            
        
            insert prod;
        
        Product2 prod2 = new Product2(Name = 'Laptop X1000',
                                    Family = 'Hardware',
                                    Product_Level__c ='1',
                                     IsActive = true);
            
        
            insert prod2;
        
        PricebookEntry standardPBE 
            = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),
                                 Product2Id = prod.Id, UnitPrice = 1000, IsActive = true);
        insert standardPBE;
        
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = pb.Id, 
                                                Product2Id = prod.Id, 
                                                UnitPrice = 1000, IsActive = true);
        insert pbe;
        
        
        PricebookEntry standardPBE2 
            = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),
                                 Product2Id = prod2.Id, UnitPrice = 1000, IsActive = true);
        insert standardPBE2;
        
        PricebookEntry pbe2 = new PricebookEntry(Pricebook2Id = pb.Id, 
                                                Product2Id = prod2.Id, 
                                                UnitPrice = 1000, IsActive = true);
        insert pbe2;
        
        
        List<Product_Interest__c> PIList = new List<Product_Interest__c>();
        
         Product_Interest__c PINonCreDit = new Product_Interest__c();
            PINonCreDit.Opportunity_Type__c ='Non-Credit';
            PINonCreDit.Amount__c =500000;
            PINonCreDit.Product__c = prod.id;
            PINonCreDit.Lead__c = leadRec.id;
            PIList.add(PINonCreDit);
            
        
         Opportunity opp = new Opportunity();
        opp.Expected_submit_date__c = System.today();
        opp.CloseDate = System.today();
        opp.StageName = 'Analysis';
        Opp.Description = 'Test';
        opp.Name = 'Test';
        opp.AccountId = firstAcct.id;
        opp.OwnerId = firstAcct.OwnerID;
        RecordType rts = [SELECT ID, name,SObjectType FROM RecordType 
                                     WHERE SObjectType = 'Opportunity'
                                     AND Name ='SE Credit Product'
                                      LIMIT 1];
         
         
         insert opp;
        Product_Interest__c PICreDit = new Product_Interest__c();
            PICreDit.Opportunity_Type__c ='Credit';
            PICreDit.Amount__c =500000;
            PICreDit.Product__c = prod2.id;
            PICreDit.Lead__c = leadRec.id;
            PICredit.Opportunity__c = opp.id;
            //PIList.add(PICreDit);
         
            insert PIList;
        
        
        
        
        
        
        
        //VisitPlan
        //
                Call_Report__c report = new Call_Report__c();
       
        report.Lead__c = leadRec.id;
        report.Status__c ='2 - Completed';
        report.Categories__c = 'Pre boarding';
        report.Main_purpose__c ='First visit';
        report.Date_of_Visit__c  = System.today();
        report.Complete_Date__c = System.today();
        report.Outcome__c ='Win Deal';
        report.OwnerId = Userinfo.getUserId();
        report.Actual_Visit_Date__c = System.today();
        report.Sub_Purpose__c = 'Credit';
        
        insert report;
        
        
        Test.startTest();
         PageReference leadconvert = Page.LeadConvertCutomized;
        Test.setCurrentPage(leadconvert);
         
        
            
        ApexPages.StandardController controllerinsert = new ApexPages.StandardController(leadRec);
            LeadActionController leadconvertPage = new LeadActionController(controllerinsert);
            
            leadConvertPage.convertLead();
        
            leadConvertPage.oppty.Expected_submit_date__c = System.today();
            leadConvertPage.oppty.CloseDate = System.today();
        for(LeadActionController.ProductWrapper Pwrapper : leadconvertpage.ProductWrapperList){
            Pwrapper.IsSelected = true;
        }
        
        leadConvertPage.oppty.Pricebook2ID = pb.id;
        leadConvertPage.ConvertAction();
        Test.stopTest();
        
    }
    
    
}

public static testmethod void ConvertLeadDuplicated(){
    
    Test.startTest();
            
            
            
          Lead leadRec = new Lead();
        leadRec.Phone = '0877874871';
        leadRec.Company = 'LeadExtension';
        leadRec.ID_Type__c = 'BRN ID';
        leadRec.ID_Number__c = '13255555';
        leadRec.Mobile_No__c = '053532198';
        leadRec.Customer_Type__c = 'Juristic';
        leadRec.FirstName =  'LeadExFirst';
        leadRec.LastName = 'LeadExLast';
        leadRec.Pre_screening_Result__c = 'Passed';
        leadRec.RecordTypeId = [SELECT id,Name FROM RecordType 
                                 WHERE Name='Commercial Account' 
                                 AND sObjectType='Lead' LIMIT 1].get(0).id;
            
        leadRec.Interest_result__c = 'Yes';
             ///**********  CR Referral   *************///
        referralList = TestUtility_Referral.createReferralsWithoutAccount(1,branchAndZoneList[0].id,'สินเชื่อเพื่อธุรกิจ - Loan','Sell (เพื่อนำเสนอขาย)',true);
        leadRec.RTL_Referral__c = referralList[0].id;         
        leadRec.ownerid = ComUser1.id;
            
        insert leadRec;
         
          LisT<Account> acct =  TestUtils.createAccounts(2,'testDisqualified','Juristic', false);
            Account firstAcct = acct.get(0);
            firstAcct.ID_Type_PE__c = 'BRN ID';
            firstAcct.ID_Number_PE__c = '13255555';
            firstAcct.Phone = '0877874871';
            
            insert firstacct;
            
            
            Contact con = new Contact(Firstname='duplicate',LastName = 'test contact' ,AccountId = firstacct.id,
                                      Photo__c = '<img alt="User-added image" src="test"></img>');
            insert con;
            
             Id [] fixedSearchResults= new Id[1];
           fixedSearchResults[0] = firstacct.id;
           Test.setFixedSearchResults(fixedSearchResults);
            
        //Recommended Product
        //
        //
        //
        //
        //
        
         Pricebook2 pb = new Pricebook2(Name = 'Commercial Pricebook', 
                                           TMB_Pricebook__c ='TMB5412',
                                           Description = 'Price Book 2009 Products', IsActive = true);
            insert pb;
            
            Product2 prod = new Product2(Name = 'Laptop X200',
                                    Family = 'Hardware',
                                    Product_Level__c ='1',
                                        IsActive = true);
            
        
            insert prod;
        
        Product2 prod2 = new Product2(Name = 'Laptop X100',
                                    Family = 'Hardware',
                                    Product_Level__c ='1',
                                     IsActive = true);
            
        
            insert prod2;
        
        PricebookEntry standardPBE 
            = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),
                                 Product2Id = prod.Id, UnitPrice = 1000, IsActive = true);
        insert standardPBE;
        
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = pb.Id, 
                                                Product2Id = prod.Id, 
                                                UnitPrice = 1000, IsActive = true);
        insert pbe;
        
        
        PricebookEntry standardPBE2 
            = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),
                                 Product2Id = prod2.Id, UnitPrice = 1000, IsActive = true);
        insert standardPBE2;
        
        PricebookEntry pbe2 = new PricebookEntry(Pricebook2Id = pb.Id, 
                                                Product2Id = prod2.Id, 
                                                UnitPrice = 1000, IsActive = true);
        insert pbe2;
        
        
        List<Product_Interest__c> PIList = new List<Product_Interest__c>();
        
         Product_Interest__c PINonCreDit = new Product_Interest__c();
            PINonCreDit.Opportunity_Type__c ='Non-Credit';
            PINonCreDit.Amount__c =500000;
            PINonCreDit.Product__c = prod.id;
            PINonCreDit.Lead__c = leadRec.id;
            PIList.add(PINonCreDit);
            
        
        Product_Interest__c PICreDit = new Product_Interest__c();
            PICreDit.Opportunity_Type__c ='Credit';
            PICreDit.Amount__c =500000;
            PICreDit.Product__c = prod2.id;
            PICreDit.Lead__c = leadRec.id;
            PIList.add(PICreDit);
         
            insert PIList;
        
        
        
        
        
        
        
        //VisitPlan
        //
                Call_Report__c report = new Call_Report__c();
       
        report.Lead__c = leadRec.id;
        report.Status__c ='2 - Completed';
        report.Categories__c = 'Pre boarding';
        report.Main_purpose__c ='First visit';
        report.Date_of_Visit__c  = System.today();
        report.Complete_Date__c = System.today();
        report.Outcome__c ='Win Deal';
        report.OwnerId = ComUser1.id;
        report.Actual_Visit_Date__c = System.today();
        report.Sub_Purpose__c = 'Credit';
        
        insert report;
        
        
        
         PageReference leadconvert = Page.LeadConvertCutomized;
        Test.setCurrentPage(leadconvert);
         
        
            
        ApexPages.StandardController controllerinsert = new ApexPages.StandardController(leadRec);
            LeadActionController leadconvertPage = new LeadActionController(controllerinsert);
            
            leadConvertPage.convertLead();
        
            leadConvertPage.oppty.Expected_submit_date__c = System.today();
            leadConvertPage.oppty.CloseDate = System.today();
        for(LeadActionController.ProductWrapper Pwrapper : leadconvertpage.ProductWrapperList){
            Pwrapper.IsSelected = true;
        }
        
            leadConvertPage.oppty.Pricebook2ID = pb.id;
            leadConvertPage.leadObj.Exception_Flag__c = true;
            
            leadConvertPage.ConvertAction();
        
        Test.stopTest();
        
    }
    
    
     public static testmethod void ConvertLeadNegative(){
          Lead leadRec = new Lead();
        leadRec.Company = 'LeadExtension';
        leadRec.LastName = 'N/A';
        leadRec.RecordTypeId = CommercialLeadRecordType.id;        
        leadRec.Interest_result__c = 'Yes';
         insert leadRec;
        
        
         PageReference leadconvert = Page.LeadConvertCutomized;
        Test.setCurrentPage(leadconvert);
         Test.startTest();
        ApexPages.StandardController controllerinsert = new ApexPages.StandardController(leadRec);
            LeadActionController leadconvertPage = new LeadActionController(controllerinsert);
            
            leadConvertPage.convertLead();
        
        Test.stopTest();
        
    }
    
    
    public static testmethod void ConvertLeadfromNPS(){
        Test.startTest();
        
         
           Id commercialProfile = [SELECT Id FROM Profile WHERE Name = 'TMB RM Profile' LIMIT 1].Id;
        User commercialUser = new User(FirstName = 'NewUser' , LastName = 'Commercial', 
                                    UserName='newUserCommercial@tmbbank.com',
                                    Email='newUserCommercial@tmbbank.com', Alias='Testtmb',
                                    LocaleSidKey='en_US', LanguageLocaleKey='en_US', EmailEncodingKey='ISO-8859-1', 
                                    CommunityNickname='commercialUser',
                                    ProfileId = commercialProfile, TimeZoneSidKey='America/New_York',isActive = true,
                                    Employee_ID__c ='MM101');
        
        
        System.runAs(commercialUser){
          Lead leadRec = new Lead();
        leadRec.Phone = '0877874871';
        leadRec.Company = 'LeadExtension';
        leadRec.ID_Type__c = 'Juristic ID';
        leadRec.ID_Number__c = '13255555';
        leadRec.Mobile_No__c = '053532198';
        leadRec.Customer_Type__c = 'Juristic';
        leadRec.FirstName =  'LeadExFirst';
        leadRec.LastName = 'LeadExLast';
        leadRec.RecordTypeId = CommercialLeadRecordType.id;
        leadRec.Interest_result__c = 'Yes';
        leadREc.Pre_screening_Result__c ='Passed';
            
             ///**********  CR Referral   *************///
        referralList = TestUtility_Referral.createReferralsWithoutAccount(1,branchAndZoneList[0].id,'Loan','Sell (เพื่อนำเสนอขาย)',true);
        leadRec.RTL_Referral__c = referralList[0].id;
            
         insert leadRec;
         
        //Recommended Product
        //
        //
        //
        //
        //
        
         Pricebook2 pb = new Pricebook2(Name = 'Commercial Pricebook', 
                                           TMB_Pricebook__c ='TMB5412',
                                           Description = 'Price Book 2009 Products', IsActive = true);
            insert pb;
            
            Product2 prod = new Product2(Name = 'Laptop X200',
                                    Family = 'Hardware',
                                    Product_Level__c ='1',
                                        IsActive = true);
            
        
            insert prod;
        
        Product2 prod2 = new Product2(Name = 'Laptop X100',
                                    Family = 'Hardware',
                                    Product_Level__c ='1',
                                     IsActive = true);
            
        
            insert prod2;
        
        PricebookEntry standardPBE 
            = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),
                                 Product2Id = prod.Id, UnitPrice = 1000, IsActive = true);
        insert standardPBE;
        
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = pb.Id, 
                                                Product2Id = prod.Id, 
                                                UnitPrice = 1000, IsActive = true);
        insert pbe;
        
        
        PricebookEntry standardPBE2 
            = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),
                                 Product2Id = prod2.Id, UnitPrice = 1000, IsActive = true);
        insert standardPBE2;
        
        PricebookEntry pbe2 = new PricebookEntry(Pricebook2Id = pb.Id, 
                                                Product2Id = prod2.Id, 
                                                UnitPrice = 1000, IsActive = true);
        insert pbe2;
        
        
        List<Product_Interest__c> PIList = new List<Product_Interest__c>();
        
         Product_Interest__c PINonCreDit = new Product_Interest__c();
            PINonCreDit.Opportunity_Type__c ='Non-Credit';
            PINonCreDit.Amount__c =500000;
            PINonCreDit.Product__c = prod.id;
            PINonCreDit.Lead__c = leadRec.id;
            PIList.add(PINonCreDit);
            
        
        Product_Interest__c PICreDit = new Product_Interest__c();
            PICreDit.Opportunity_Type__c ='Credit';
            PICreDit.Amount__c =500000;
            PICreDit.Product__c = prod2.id;
            PICreDit.Lead__c = leadRec.id;
            PIList.add(PICreDit);
         
            //insert PIList;
        
         Status_Code__c error622 = new Status_Code__c();
        error622.isError__c = false;
        error622.Name = '6202';
        error622.Status_Message__c = 'Test2';
         insert error622;
        
        
        
        
        
        //Survey
        //
         SurveyMaster__c svmt = NPSSurveyControllerTest.CreateSurveyMaster();      
            PageReference npssurveyPage = Page.NPS_Survey;
            Test.setCurrentPage(npssurveyPage);
            
            ApexPages.currentPage().getParameters().put('id', leadRec.id);
            NPSSurveyController npscon = new NPSSurveyController();
           
            npscon.SurveyID = svmt.id;
            npscon.SelectedSurveyMaster();
            npscon.dosave();
            Survey__c existingsurvey = npscon.tempSurveyDetail;
            existingsurvey.Answer2__c = '2;3;4';
            update existingsurvey;
        
        
         PageReference npsConvert = Page.NPS_Survey_Convert;
        Test.setCurrentPage(npsConvert);
         
        
          Test.setCurrentPage(npsConvert);   
         ApexPages.currentPage().getParameters().put('SurveyID', existingsurvey.id);
         
        ApexPages.StandardController controllerinsert = new ApexPages.StandardController(leadRec);
            LeadActionController leadconvertPage = new LeadActionController(controllerinsert);
            String convertLeadWarning = leadconvertPage.convertLeadWarning;
            String convertOppornuityMessage= leadconvertpage.convertOppornuityMessage;
            leadConvertPage.completeSurvey();
            leadConvertPage.surveyobj.result__c ='Completed ';
            leadConvertPage.completeSurvey();           
            
        }        
        Test.stopTest();
        
    }
    

    
}