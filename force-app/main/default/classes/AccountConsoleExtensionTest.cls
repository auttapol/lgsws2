@isTest
public class AccountConsoleExtensionTest {
  public static final Id BB_ARM_ID = [SELECT Id FROM Profile WHERE Name = 'TMB BB ARM Profile' LIMIT 1].Id;
  public static final Id ZONE_ROLE_ID = [SELECT Id FROM UserRole WHERE Name = 'CEO' LIMIT 1].Id;
  public static User newUser;

  static void setupData() 
	{
		TestUtils.createIdType();
    TestUtils.createAppConfig();
    TestUtils.createStatusCode();
    TestUtils.createDisqualifiedReason();
    TestUtils.createDateOfBirth();
    Map<String,ID> addressmap = TestUtils.CreateAddress();
    newUser = new User(FirstName = 'FName+i' , LastName = 'LName+i', 
                            UserName='test@tmb.com',
                            Email='test@tmbbank.com', Alias='Testtmb',
                            LocaleSidKey='en_US', LanguageLocaleKey='en_US', EmailEncodingKey='ISO-8859-1', 
                            CommunityNickname='TMBTesttmb1',
                            ProfileId = BB_ARM_ID, TimeZoneSidKey='America/New_York',isActive = true,
                            Employee_ID__c ='MM012');
      insert newUser;
	}
    
  static testMethod void validateAccountConsole() {

    setupData();

    System.runAs(newUser){
      insert new PermissionSetAssignment(PermissionSetId=TestUtils.SetupPermissionSet().Id,AssigneeId=newUser.Id);
    }  
          
    test.startTest();
    system.runAs(newUser){
      Account acct = TestUtils.createAccounts(1,'webviceTESTACCOUNT','Individual', true).get(0);
      ApexPages.StandardController sc = new ApexPages.StandardController(acct);
      PageReference pageRef = Page.DataPartitionDetail;
      Test.setCurrentPage(pageRef);
      ApexPages.currentPage().getParameters().put('type', '1');
      AccountConsoleExtension console = new AccountConsoleExtension(sc);
      AccountConsoleExtension.PieWedgeData piewedgedata = new AccountConsoleExtension.PieWedgeData('test',2000,2000 );
      
    try{
      Product2 TransBankp = new Product2(Name = 'TransBankp',Product_Domain__c = '1. Transactional Banking' );
      Product2 DepVestp = new Product2(Name = 'DepVestp',Product_Domain__c = '2. Deposit and Investment' );
      Product2 FundBorrowp = new Product2(Name = 'FundBorrowp',Product_Domain__c = '3. Funding & Borrowing' );  
      Product2 Riskp = new Product2(Name = 'Riskp',Product_Domain__c = '4. Risk Protection' );
            insert TransBankp;
            insert DepVestp;
            insert FundBorrowp;
            insert Riskp;
    
      //Product_Information_On_Hand__c TransBankId = [select id,Product_Hierachy_Code__r.Id from Product_Information_On_Hand__c where Product_Hierachy_Code__r.Product_Domain__c = '1. Transactional Banking' LIMIT 1];
      Id TransBankId = [SELECT id FROM Product2 where Product_Domain__c = '1. Transactional Banking' LIMIT 1].Id;
      Id DepVestId = [SELECT id FROM Product2 where Product_Domain__c = '2. Deposit and Investment' LIMIT 1].Id;
      Id FundBorrowId = [SELECT id FROM Product2 where Product_Domain__c = '3. Funding & Borrowing' LIMIT 1].Id;
      Id RiskId = [SELECT id FROM Product2 where Product_Domain__c = '4. Risk Protection' LIMIT 1].Id;
      //System.debug('TransBankId '+TransBankId);
        /*System.debug('DepVestId '+DepVestId);
        System.debug('FundBorrowId '+FundBorrowId);
        System.debug('RiskId '+RiskId);*/
        if(TransBankId!= null){
          Product_Information_On_Hand__c TransBank = new Product_Information_On_Hand__c( Account__c =  acct.id,Product_Hierachy_Code__c =  TransBankId );
          //Product_Information_On_Hand__c TransBank = new Product_Information_On_Hand__c( Account__c =  acct.id,Product_Hierachy_Code__c =  '01t90000004tQTbAAM' );
          insert TransBank;
        }
      if(DepVestId!= null){  
          Product_Information_On_Hand__c DepVest = new Product_Information_On_Hand__c( Account__c =  acct.id,Product_Hierachy_Code__c =  DepVestId );
        //Product_Information_On_Hand__c DepVest = new Product_Information_On_Hand__c( Account__c =  acct.id,Product_Hierachy_Code__c =  '01t90000004tQTOAA2' );
        insert DepVest;
      }
      if(FundBorrowId!= null){    
        Product_Information_On_Hand__c FundBorrow = new Product_Information_On_Hand__c( Account__c =  acct.id,Product_Hierachy_Code__c =  FundBorrowId );
        //Product_Information_On_Hand__c FundBorrow = new Product_Information_On_Hand__c( Account__c =  acct.id,Product_Hierachy_Code__c =  '01t90000004tQTFAA2' );
        insert FundBorrow;
      }
      if(RiskId!= null){     
        Product_Information_On_Hand__c Risk = new Product_Information_On_Hand__c( Account__c =  acct.id,Product_Hierachy_Code__c =  RiskId );
        //Product_Information_On_Hand__c Risk = new Product_Information_On_Hand__c( Account__c =  acct.id,Product_Hierachy_Code__c =  '01t90000004tQTUAA2' );
        insert Risk;
      } 
    }catch(Exception ex){
        
    } 
      //console.getLoanClassification();
      //console.getSCFScore();
      //console.getServiceClass();
      console.getPieData();
      console.getOnhand();
      console.getPipelineReportId();
      console.getReportId();
      console.getNonPipelineReportId();
      console.ActivitySummary();
      console.getWallet();
      /*system.assertEquals(1, console.SumTransBank);
      system.assertEquals(1, console.SumDepInvest);
      system.assertEquals(1, console.SumFundBorrow);
      system.assertEquals(1, console.SumRiskProtect);
      */
      console.acct.Loan_Classification__c='NNN';
      //console.getLoanClassification();
      
      console.acct.SCF_Score__c=20;
      //console.getSCFScore();
      
      //console.acct.Service_class__c='Silver';
      //console.getServiceClass();

      //console.acct.Service_class__c='gold';
      //console.getServiceClass();
    
      //console.acct.Service_class__c='platinum';
      //console.getServiceClass();
    }
    test.stopTest();    
  }

  static testMethod void validateAccountConsole1() {

    setupData();

    System.runAs(newUser){
      insert new PermissionSetAssignment(PermissionSetId=TestUtils.SetupPermissionSet().Id,AssigneeId=newUser.Id);
    }  
          
    test.startTest();
    system.runAs(newUser){
      Account acct = TestUtils.createAccounts(1,'webviceTESTACCOUNT','Individual', true).get(0);
      ApexPages.StandardController sc = new ApexPages.StandardController(acct);
      PageReference pageRef = Page.DataPartitionDetail;
      Test.setCurrentPage(pageRef);
      // AccountConsoleExtension.PieWedgeData piewedgedata = new AccountConsoleExtension.PieWedgeData('test',2000,2000 );
          
      ApexPages.currentPage().getParameters().put('type', '2');
      AccountConsoleExtension console1 = new AccountConsoleExtension(sc);
    }
    test.stopTest();    
  }

  static testMethod void validateAccountConsole2() {

    setupData();

    System.runAs(newUser){
      insert new PermissionSetAssignment(PermissionSetId=TestUtils.SetupPermissionSet().Id,AssigneeId=newUser.Id);
    }  
          
    test.startTest();
    system.runAs(newUser){
      Account acct = TestUtils.createAccounts(1,'webviceTESTACCOUNT','Individual', true).get(0);
      ApexPages.StandardController sc = new ApexPages.StandardController(acct);
      PageReference pageRef = Page.DataPartitionDetail;
      Test.setCurrentPage(pageRef);
      // AccountConsoleExtension.PieWedgeData piewedgedata = new AccountConsoleExtension.PieWedgeData('test',2000,2000 );
          
      ApexPages.currentPage().getParameters().put('type', '3');
      AccountConsoleExtension console2 = new AccountConsoleExtension(sc);
    }
    test.stopTest();    
  }

  static testMethod void validateAccountConsole3() {

    setupData();

    System.runAs(newUser){
      insert new PermissionSetAssignment(PermissionSetId=TestUtils.SetupPermissionSet().Id,AssigneeId=newUser.Id);
    }  
          
    test.startTest();
    system.runAs(newUser){
      Account acct = TestUtils.createAccounts(1,'webviceTESTACCOUNT','Individual', true).get(0);
      ApexPages.StandardController sc = new ApexPages.StandardController(acct);
      PageReference pageRef = Page.DataPartitionDetail;
      Test.setCurrentPage(pageRef);
      // AccountConsoleExtension.PieWedgeData piewedgedata = new AccountConsoleExtension.PieWedgeData('test',2000,2000 );

      ApexPages.currentPage().getParameters().put('type', '4');
      AccountConsoleExtension console3 = new AccountConsoleExtension(sc);
    }
    test.stopTest();    
  }

  static testMethod void validateAccountConsole4() {

    setupData();

    System.runAs(newUser){
      insert new PermissionSetAssignment(PermissionSetId=TestUtils.SetupPermissionSet().Id,AssigneeId=newUser.Id);
    }  
          
    test.startTest();
    system.runAs(newUser){
      Account acct = TestUtils.createAccounts(1,'webviceTESTACCOUNT','Individual', true).get(0);
      ApexPages.StandardController sc = new ApexPages.StandardController(acct);
      PageReference pageRef = Page.DataPartitionDetail;
      Test.setCurrentPage(pageRef);
      // AccountConsoleExtension.PieWedgeData piewedgedata = new AccountConsoleExtension.PieWedgeData('test',2000,2000 );

      ApexPages.currentPage().getParameters().put('type', '5');
      AccountConsoleExtension console4 = new AccountConsoleExtension(sc);
    }
    test.stopTest();    
  }

  static testMethod void validateAccountConsole5() {

    setupData();

    System.runAs(newUser){
      insert new PermissionSetAssignment(PermissionSetId=TestUtils.SetupPermissionSet().Id,AssigneeId=newUser.Id);
    }  
          
    test.startTest();
    system.runAs(newUser){
      Account acct = TestUtils.createAccounts(1,'webviceTESTACCOUNT','Individual', true).get(0);
      ApexPages.StandardController sc = new ApexPages.StandardController(acct);
      PageReference pageRef = Page.DataPartitionDetail;
      Test.setCurrentPage(pageRef);
      // AccountConsoleExtension.PieWedgeData piewedgedata = new AccountConsoleExtension.PieWedgeData('test',2000,2000 );

      ApexPages.currentPage().getParameters().put('type', '6');
      AccountConsoleExtension console5 = new AccountConsoleExtension(sc);
    }
    test.stopTest();    
  }

  static testMethod void validateAccountConsole6() {

    setupData();

    System.runAs(newUser){
      insert new PermissionSetAssignment(PermissionSetId=TestUtils.SetupPermissionSet().Id,AssigneeId=newUser.Id);
    }  
          
    test.startTest();
    system.runAs(newUser){
      Account acct = TestUtils.createAccounts(1,'webviceTESTACCOUNT','Individual', true).get(0);
      ApexPages.StandardController sc = new ApexPages.StandardController(acct);
      PageReference pageRef = Page.DataPartitionDetail;
      Test.setCurrentPage(pageRef);
      ApexPages.currentPage().getParameters().put('type', '1');
      // AccountConsoleExtension console = new AccountConsoleExtension(sc);
      // AccountConsoleExtension.PieWedgeData piewedgedata = new AccountConsoleExtension.PieWedgeData('test',2000,2000 );

      ApexPages.currentPage().getParameters().put('type', '7');
      AccountConsoleExtension console6 = new AccountConsoleExtension(sc);
    }
    test.stopTest();    
  }

  static testMethod void validateAccountConsole7() {

    setupData();

    System.runAs(newUser){
      insert new PermissionSetAssignment(PermissionSetId=TestUtils.SetupPermissionSet().Id,AssigneeId=newUser.Id);
    }  
          
    test.startTest();
    system.runAs(newUser){
      Account acct = TestUtils.createAccounts(1,'webviceTESTACCOUNT','Individual', true).get(0);
      ApexPages.StandardController sc = new ApexPages.StandardController(acct);
      PageReference pageRef = Page.DataPartitionDetail;
      Test.setCurrentPage(pageRef);
      ApexPages.currentPage().getParameters().put('type', '1');
      // AccountConsoleExtension console = new AccountConsoleExtension(sc);
      // AccountConsoleExtension.PieWedgeData piewedgedata = new AccountConsoleExtension.PieWedgeData('test',2000,2000 );
    
      ApexPages.currentPage().getParameters().put('type', '8');
      AccountConsoleExtension console7 = new AccountConsoleExtension(sc);
    }
    test.stopTest();    
  }

  static testMethod void validateAccountConsole8() {

    setupData();

    System.runAs(newUser){
      insert new PermissionSetAssignment(PermissionSetId=TestUtils.SetupPermissionSet().Id,AssigneeId=newUser.Id);
    }  
          
    test.startTest();
    system.runAs(newUser){
      Account acct = TestUtils.createAccounts(1,'webviceTESTACCOUNT','Individual', true).get(0);
      ApexPages.StandardController sc = new ApexPages.StandardController(acct);
      PageReference pageRef = Page.DataPartitionDetail;
      Test.setCurrentPage(pageRef);
      ApexPages.currentPage().getParameters().put('type', '1');
      // AccountConsoleExtension console = new AccountConsoleExtension(sc);
      // AccountConsoleExtension.PieWedgeData piewedgedata = new AccountConsoleExtension.PieWedgeData('test',2000,2000 );
    
      ApexPages.currentPage().getParameters().put('type', '9');
      AccountConsoleExtension console8 = new AccountConsoleExtension(sc);
    }
    test.stopTest();    
  }
    
  static testMethod void validateAccountConsole9() {
    setupData();

    System.runAs(newUser){
      insert new PermissionSetAssignment(PermissionSetId=TestUtils.SetupPermissionSet().Id,AssigneeId=newUser.Id);
    }  
          
    test.startTest();
    system.runAs(newUser){
      Account acct = TestUtils.createAccounts(1,'webviceTESTACCOUNT','Individual', true).get(0);
      ApexPages.StandardController sc = new ApexPages.StandardController(acct);
      PageReference pageRef = Page.DataPartitionDetail;
      Test.setCurrentPage(pageRef);
      ApexPages.currentPage().getParameters().put('type', '1');
      // AccountConsoleExtension console = new AccountConsoleExtension(sc);
      // AccountConsoleExtension.PieWedgeData piewedgedata = new AccountConsoleExtension.PieWedgeData('test',2000,2000 );
            
      PageReference pageRef2 = Page.ProductOnHandV2;
      Test.setCurrentPage(pageRef2);
      AccountConsoleExtension console9 = new AccountConsoleExtension(sc);
          
      ApexPages.currentPage().getParameters().put('sectionName', 'ComCust:Product On Hand');
      ApexPages.currentPage().getParameters().put('sectionName2', 'ComCust:Product On Hand (Partition)');
      console9.loadData();        
          
      console9.TransBankReport();
      console9.DepInvestReport();
      console9.FundBorrowReport();
      console9.RiskProtectReport();
      console9.TransBankReportMobile();
      console9.DepInvestReportMobile();
      console9.FundBorrowReportMobile();
      console9.RiskProtectReportMobile();

      console9.logButtonEvent();
      console9.getPieDataAccPlan();
      console9.loadParameter();

      String da = console9.dash;
      String hiddenText = console9.hiddenText;

      console9.loadIncomeEstimateData();
    }
    test.stopTest();    
  }
}