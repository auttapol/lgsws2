@isTest
public class ProductTransactionRisk2Test {
    
    static{
        TestUtils.createAppConfig();
        TestUtils.createStatusCode(); 
        TestUtils.createDisqualifiedReason(); 
		TestUtils.createObjUserPermission();
        TestInit.createCustomSettingTriggerMsg();
    }
    public static testmethod void performanceReportTest(){
        Account acct = TestUtils.createAccounts(1, 'PerformanceRe', 'Individual', true).get(0);
        List<Product2> prodList = new List<Product2>();
        Product2 prod1 = new Product2();
        prod1.Name = 'Prod1';
        prod1.Product_Domain__c = 'Deposit';
        
        Product2 prod2 = new Product2();
        prod2.Name = 'Prod2';
        prod2.Product_Domain__c = 'Funding';
        
        Product2 prod3 = new Product2();
        prod3.Name = 'Prod3';
        prod3.Product_Domain__c = 'Risk';
        
        prodList.add(prod1);
        prodList.add(prod2);
        prodList.add(prod3);
        insert prodList;
        Date todayDate = Date.today();
        
        Product_Trans_Risk__c prodTransRisk = new Product_Trans_Risk__c();
        prodTransRisk.Account__c = acct.id;
        prodTransRisk.As_of_Date__c = todayDate;
        insert prodTransRisk;
        
        List<Product_Fee__c> pfList = new List<Product_Fee__c>();
        Product_Fee__c pf1 = new Product_Fee__c();
        pf1.customer__c = acct.id;
        pf1.Data_Source__c = 'TV';
        pf1.As_Of_Date__c = todayDate;
        
        Product_Fee__c pf2 = new Product_Fee__c();
        pf2.customer__c = acct.id;
        pf2.Data_Source__c = 'TF';
        pf2.As_Of_Date__c = todayDate;
        
        pfList.add(pf1);
        pfList.add(pf2);
        insert pfList;
        
        List<Product_NIM__c> nimList = new List<Product_NIM__c>();
        Product_NIM__c nim1 = new Product_NIM__c();
        nim1.As_Of_Date__c = todayDate;
        nim1.Customer__c = acct.id;
        Product_NIM__c nim2 = new Product_NIM__c();
        nim2.As_Of_Date__c = todayDate;
        nim2.Customer__c = acct.id;
        
        nimList.add(nim1);
        nimList.add(nim2);
        
        insert nimList;
        
        List<Product_Performance__c> perfList = new List<Product_Performance__c>();
        Product_Performance__c perf1 = new Product_Performance__c();
        perf1.Product_Hierachy_Code__c = prod1.id;
        perf1.As_Of_Date__c = todayDate;
        perf1.Account__c = acct.id;
        
        Product_Performance__c perf2 = new Product_Performance__c();
        perf2.Product_Hierachy_Code__c = prod2.id;
        perf2.As_Of_Date__c = todayDate;
        perf2.Account__c = acct.id;
        perf2.Product_Group__c = 'Loan';
        
        Product_Performance__c perf3 = new Product_Performance__c();
        perf3.Product_Hierachy_Code__c = prod2.id;
        perf3.As_Of_Date__c = todayDate;
        perf3.Account__c = acct.id;
        perf3.Product_Group__c = 'Liability';
        
        Product_Performance__c perf4 = new Product_Performance__c();
        perf4.Product_Hierachy_Code__c = prod3.id;
        perf4.As_Of_Date__c = todayDate;
        perf4.Account__c = acct.id;
        perf4.Product_Group__c = 'Loan';
        
        Product_Performance__c perf5 = new Product_Performance__c();
        perf5.Product_Hierachy_Code__c = prod3.id;
        perf5.As_Of_Date__c = todayDate;
        perf5.Account__c = acct.id;
        perf5.Product_Group__c = 'Liability';
        
        perfList.add(perf1);
        perfList.add(perf2);
        perfList.add(perf3);
        perfList.add(perf4);
        perfList.add(perf5);
        insert perfList;
        
        PageReference pr = Page.Performance_Report2;
        pr.getParameters().put('id',acct.id);
            
        Test.setCurrentPage(pr);
        
        Test.startTest();
        	ApexPages.StandardController stdController = new ApexPages.StandardController(acct);
			ProductTransactionRisk2 productTransRisk = new ProductTransactionRisk2(stdController);   
        	productTransRisk.getProductTransRisk();
        	productTransRisk.getTradeFinanceVolumn();
            productTransRisk.getTradeFinanceFee();
        	productTransRisk.getProductInfoDepositInvestment();
        	productTransRisk.getProductInfoFundingBorrowing();
        	productTransRisk.getProductInfoFundingBorrowingLiability();
        	productTransRisk.getProductInfoRiskProtectionLiability();
        	productTransRisk.getProductInfoRiskProtectionLoan();
        Test.stopTest();
    }
    
}