@isTest
public class ReportMobileExtensionTest {
    
    static{
        TestUtils.CreateProceBookAccess();
        TestUtils.createAppConfig();
        TestUtils.createStatusCode();        
        TestUtils.createIdType();
        TestUtils.createTriggerMsg();
        TestUtils.createObjUserPermission();
    }
    
    

    public static testMethod void ProductInfo_Report1() {
        //Create Account
        Account  testAccount1 = new Account();
        testAccount1.Name='Test Report1' ;
        testAccount1.Phone ='050111222';
        testAccount1.Mobile_Number_PE__c  = '0801112233';
        insert testAccount1;
        
         Product2 prod = new Product2(Name = 'ReportMobileProduct',Product_Domain__c ='Transactional Banking',
            Family = 'Hardware',IsActive=true);
        insert prod;
        
        
        
        Id productId1 = prod.id;
        Product_Information_On_Hand__c onhand1 = new Product_Information_On_Hand__c();
        onhand1.Account__c = testAccount1.Id;
        onhand1.Product_Hierachy_Code__c = String.valueOf(productId1);
        insert onhand1;
        
        Product_Information_Detail__c detail1 = new Product_Information_Detail__c();
        detail1.Product_Information__c = onhand1.id;
        insert detail1;
        
        PageReference pageRef1 = Page.ProductInfo_Domain1_Mobile;
        pageRef1.getParameters().put('Id', String.valueOf(testAccount1.Id));
        Test.setCurrentPage(pageRef1);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(testAccount1);
        ReportMobileExtension ReportEx1= new ReportMobileExtension(sc);
        ReportEx1.report1();
        Decimal Rc = ReportEx1.RecordCountP;
        Decimal Stagec = ReportEx1.StageCount;
        Double SumA = ReportEx1.SumAmt;
        Product_Information_On_Hand__c onhand2 = new Product_Information_On_Hand__c();
        onhand2.Account__c = testAccount1.Id;
        onhand2.Product_Hierachy_Code__c = String.valueOf(productId1);
        insert onhand2;
        
        Product_Information_Detail__c detail2 = new Product_Information_Detail__c();
        detail2.Product_Information__c = onhand2.id;
        insert detail2;
        
        ReportEx1.report1();
    }
    
    public static testMethod void ProductInfo_Report2() {
        //Create Account
        Account  testAccount1 = new Account();
        testAccount1.Name='Test Report2' ;
        testAccount1.Phone ='050111222';
        testAccount1.Mobile_Number_PE__c  = '0801112233';
        insert testAccount1;
        
        Product2 prodtwo = new Product2(Name = 'ReportMobileDeposit',Product_Domain__c ='Deposit',
            Family = 'Hardware',IsActive=true);
        insert prodtwo;
        
        Id productId1 = prodtwo.Id;
        Product_Information_On_Hand__c onhand1 = new Product_Information_On_Hand__c();
        onhand1.Account__c = testAccount1.Id;
        onhand1.Product_Hierachy_Code__c = String.valueOf(productId1);
        insert onhand1;
        
        Product_Information_Detail__c detail1 = new Product_Information_Detail__c();
        detail1.Product_Information__c = onhand1.id;
        insert detail1;
        
        PageReference pageRef1 = Page.ProductInfo_Domain1_Mobile;
        pageRef1.getParameters().put('Id', String.valueOf(testAccount1.Id));
        Test.setCurrentPage(pageRef1);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(testAccount1);
        ReportMobileExtension ReportEx1= new ReportMobileExtension(sc);
        ReportEx1.report2();
        
    }
    
    public static testMethod void ProductInfo_Report3() {
        //Create Account
        Account  testAccount1 = new Account();
        testAccount1.Name='Test Report3' ;
        testAccount1.Phone ='050111222';
        testAccount1.Mobile_Number_PE__c  = '0801112233';
        insert testAccount1;
        
         Product2 prodthree = new Product2(Name = 'ReportMobileDeposit',Product_Domain__c ='Funding',
            Family = 'Hardware',IsActive=true);
        insert prodthree;
        
        
        Id productId1 = prodthree.Id;
        Product_Information_On_Hand__c onhand1 = new Product_Information_On_Hand__c();
        onhand1.Account__c = testAccount1.Id;
        onhand1.Product_Hierachy_Code__c = String.valueOf(productId1);
        insert onhand1;
        
        Product_Information_Detail__c detail1 = new Product_Information_Detail__c();
        detail1.Product_Information__c = onhand1.id;
        insert detail1;
        
        PageReference pageRef1 = Page.ProductInfo_Domain1_Mobile;
        pageRef1.getParameters().put('Id', String.valueOf(testAccount1.Id));
        Test.setCurrentPage(pageRef1);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(testAccount1);
        ReportMobileExtension ReportEx1= new ReportMobileExtension(sc);
        ReportEx1.report3();
    }
    
    public static testMethod void ProductInfo_Report4() {
        //Create Account
        Account  testAccount1 = new Account();
        testAccount1.Name='Test Report4' ;
        testAccount1.Phone ='050111222';
        testAccount1.Mobile_Number_PE__c  = '0801112233';
        insert testAccount1;
        
        PageReference pageRef1 = Page.ProductInfo_Domain1_Mobile;
        pageRef1.getParameters().put('Id', String.valueOf(testAccount1.Id));
        Test.setCurrentPage(pageRef1);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(testAccount1);
        ReportMobileExtension ReportEx1= new ReportMobileExtension(sc);
        ReportEx1.report4();
        
        
         Product2 prodfour = new Product2(Name = 'ReportMobileDeposit',Product_Domain__c ='Risk',
            Family = 'Hardware',IsActive=true);
        insert prodfour;
        
        
        Id productId1 = prodfour.Id;
        Product_Information_On_Hand__c onhand1 = new Product_Information_On_Hand__c();
        onhand1.Account__c = testAccount1.Id;
        onhand1.Product_Hierachy_Code__c = String.valueOf(productId1);
        insert onhand1;
        
        
        Product_Information_Detail__c detail1 = new Product_Information_Detail__c();
        detail1.Product_Information__c = onhand1.id;
        insert detail1;
        
        ApexPages.StandardController sc1 = new ApexPages.StandardController(testAccount1);
        ReportMobileExtension ReportEx2= new ReportMobileExtension(sc1);
        ReportEx2.report4();
        
    }
    
    public static testMethod void Credit_Report() {
        // [Fah] create user
        //TestInit.createUser(false);
        User u =  TestUtils.createUsers(1,'FName-credit','LName-credit','credit@tmbbank.com',False).get(0);
        u.Zone_Code__c = '9999';
        u.Region_Code__c = '9990';
        u.Segment__c = 'SS';
        u.Employee_ID__c ='99391';
        insert u;
        
        //Create Account
        Account  testAccount1 = new Account();
        testAccount1.Name='Test Report5' ;
        testAccount1.Phone ='050111222';
        testAccount1.Mobile_Number_PE__c  = '0801112233';
        testAccount1.ownerId = u.id;
        insert testAccount1;
        
        PageReference pageRef1 = Page.Credit_Pipeline_Mobile;
        pageRef1.getParameters().put('Id', String.valueOf(testAccount1.Id));
        Test.setCurrentPage(pageRef1);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(testAccount1);
        ReportMobileExtension ReportEx1= new ReportMobileExtension(sc);
        ReportEx1.credit();
        System.runAs(u){
        Opportunity opp = new Opportunity();
        opp.AccountId = testAccount1.id;
        // [fah] Assign opp owner
        //opp.ownerId = u.id;
        opp.Expected_submit_date__c = System.today();
        opp.CloseDate = System.today();
        opp.Opportunity_Type__c = 'Credit';
        opp.StageName = 'Analysis';
        opp.Probability = 10;
        opp.Description = 'Test';
        opp.Name = 'Test';
        
        insert opp;
        
        ReportEx1.credit();  
        system.assertEquals(testAccount1.Id, ReportEx1.acct.ID);
        
        Opportunity opp1 = new Opportunity();
        opp1.AccountId = testAccount1.id;
        opp1.Expected_submit_date__c = System.today();
        opp1.CloseDate = System.today();
        opp1.Opportunity_Type__c = 'Credit';
        opp1.StageName = 'Analysis';
        opp1.Probability = 10;
        opp1.Description = 'Test';
        opp1.Name = 'Test';
        insert opp1;
        ReportEx1.credit();
        }
    }
    
    public static testMethod void NonCredit_Report() {
         // [Fah] create user
        //TestInit.createUser(false);
        User u =  TestUtils.createUsers(1,'FName-credit','LName-credit','credit@tmbbank.com',False).get(0);
        u.Zone_Code__c = '9999';
        u.Region_Code__c = '9990';
        u.Segment__c = 'SS';
        u.Employee_ID__c ='99291';
        insert u;
        
        //Create Account
        Account  testAccount1 = new Account();
        testAccount1.Name='Test Report6' ;
        testAccount1.OwnerId = u.id;
        testAccount1.Phone ='050111222';
        testAccount1.Mobile_Number_PE__c  = '0801112233';
        insert testAccount1;
        System.runas(u){
        Opportunity opp = new Opportunity();
        opp.AccountId = testAccount1.id;
        opp.OwnerId = u.id;
        opp.Opportunity_Type__c = 'Non-Credit';
        opp.Expected_submit_date__c = System.today();
        opp.CloseDate = System.today();
        opp.StageName = 'Analysis';
        opp.Probability = 10;
        opp.Description = 'Test';
        opp.Name = 'Test';
        insert opp;
        }

        PageReference pageRef1 = Page.NonCredit_Pipeline_Mobile;
        pageRef1.getParameters().put('Id', String.valueOf(testAccount1.Id));
        Test.setCurrentPage(pageRef1);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(testAccount1);
        ReportMobileExtension ReportEx1= new ReportMobileExtension(sc);
        ReportEx1.noncredit();   
        
    }
    
}