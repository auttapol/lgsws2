@IsTest
public class AccountPlanPortfolioPerformanceCtrlTest{
    static{
        TestUtils.createAppConfig();
        TestUtils.createStatusCode();        
        TestUtils.createIdType();
        TestUtils.createTriggerMsg();
        TestUtils.createObjUserPermission();
        AccountPlanTestUtilities.AccountPlanStatusCode();
    }
    public static AcctPlanCompanyProfile__c companyprofile {get;set;}
    public static AcctPlanPortfolio__c portfolio;
    public static AcctPlanProdStrategy__c prodStrategy;
    public static Account account;
    public static AcctPlanGroupProfile__c groupProfile1;
    public static AcctPlanGroupProfile__c groupProfile2;
    public static AcctPlanCompanyProfile__c companyProfile1;
    public static AcctPlanCompanyProfile__c companyProfile2;
    public static AcctPlanCompanyProfile__c companyProfile3;
    public static AcctPlanCompanyPort__c companyPort;
    public static AcctPlanWallet__c wallet1;
    public static AcctPlanWallet__c wallet2;
    public static AcctPlanWallet__c wallet3;
    public static Group__c groupMaster;    
    //public static User user; 
        

    public static testMethod void PortfolioPerformanceTest(){
    
        AcctPlanPortfolioPerformanceCtrl();
    }
    
    
    static void AcctPlanPortfolioPerformanceCtrl(){
        //Create User
        //user = new User();
        //user.FirstName = 'Test';
        //user.LastName = 'D';
        //insert user;
                
        User SalesOwner = AccountPlanTestUtilities.createUsers(1, 'RM', 'PortfolioMngTest', 'portfoliomng@tmbbank.com', AccountPlanTestUtilities.TMB_RM_PROFILE_ID,false, true).get(0);
        
        //Create Account
        account = new Account();
        account.Name='Test AccountPlan Step6' ;
        account.Phone ='050111222';
        account.Mobile_Number_PE__c  = '0801112233';
        insert account;     
        
        //Create AcctPlanPortfolio__c
        portfolio = new AcctPlanPortfolio__c();
        portfolio.Name ='Portfolio 6';
        portfolio.Year__c = '2015';
        portfolio.TargetNI__c = 2000000;
        portfolio.SalesOwner__c = SalesOwner.Id;
        insert portfolio;    
        
        groupMaster = new Group__c();
        groupMaster.Name = 'GROUP6';
        insert groupMaster;
        
        //Create Account Plan Group Profile
        groupProfile1 = new AcctPlanGroupProfile__c();
        groupProfile1.Name = 'Group AA';
        groupProfile1.Group__c = groupMaster.Id;
        insert groupProfile1;
        
        groupProfile2= new AcctPlanGroupProfile__c();
        groupProfile2.Name = 'Group BB';
        groupProfile2.Group__c = groupMaster.Id;
        insert groupProfile2;
        
        companyProfile1= new AcctPlanCompanyProfile__c();
        //companyProfile1.Name = 'com A';
        companyProfile1.Portfolio__c = portfolio.Id;
        companyProfile1.Account__c = account.Id;
        companyProfile1.AcctPlanGroup__c = groupProfile1.Id;
        companyProfile1.OwnerId = SalesOwner.Id;
        companyProfile1.Year__c = '2016';        
        insert companyProfile1;
        
        companyProfile2= new AcctPlanCompanyProfile__c();
        //companyProfile2.Name = 'com B';
        companyProfile2.Portfolio__c = portfolio.Id;
        companyProfile2.Account__c = account.Id;
        companyProfile2.AcctPlanGroup__c = groupProfile1.Id;        
        companyProfile2.OwnerId = SalesOwner.Id;
        companyProfile2.Year__c = '2016'; 
        insert companyProfile2;
                
        companyProfile3= new AcctPlanCompanyProfile__c();
        //companyProfile3.Name = 'com B';
        companyProfile3.Portfolio__c = portfolio.Id;
        companyProfile3.Account__c = account.Id;
        companyProfile3.AcctPlanGroup__c = groupProfile2.Id;
        insert companyProfile3;
        
        wallet1 = new AcctPlanWallet__c();
        wallet1.AcctPlanCompanyProfile__c = companyProfile1.Id;
        insert wallet1;
        
        wallet2 = new AcctPlanWallet__c();
        wallet2.AcctPlanCompanyProfile__c = companyProfile2.Id;
        insert wallet2;        
        
        wallet3 = new AcctPlanWallet__c();
        wallet3.AcctPlanCompanyProfile__c = companyProfile3.Id;
        insert wallet3;
        
        
        prodStrategy = new AcctPlanProdStrategy__c();
        prodStrategy.SEQ__c = 1;
        prodStrategy.Name = '1. NIIc';
        prodStrategy.WalletSizing__c = 10000;
        prodStrategy.AnnualizedPerformance__c = 100;
        prodStrategy.Adjust_NI__c = 150;
        prodStrategy.ExpectedIncrementalNIFromStep5__c = 10;

        prodStrategy.AccountPlanYear__c = 2015;   
        prodStrategy.AcctPlanCompanyProfileID__c = companyProfile1.Id;
        //prodStrategy.AcctPlanCompanyProfileID__r.Name = companyProfile.Name;
        prodStrategy.AcctPlanGroupProfileID__c = groupProfile1.Id;        
        //prodStrategy.AcctPlanGroupProfileID__r.Name = groupProfile.Name;
        prodStrategy.AcctPlanWallet__c = wallet1.Id;
        prodStrategy.AspirationSOW__c = 0.2;        
        prodStrategy.RefreshAsOf__c = Date.today();
        insert prodStrategy;
       
        
        MockProductStrategy(companyProfile1.Id, groupProfile1.Id, wallet1.Id);
        MockProductStrategy(companyProfile2.Id, groupProfile1.Id, wallet2.Id);
        MockProductStrategy(companyProfile2.Id, groupProfile2.Id, wallet2.Id);
        
        PageReference pageRef = Page.AccountPlanRevenueExpectation;
        pageRef.getParameters().put('CompanyID', String.valueOf(companyProfile1.Id));
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(prodStrategy);
        AccountPlanPortfolioPerformanceCtrl PortfolioPerformanceCtrl = new AccountPlanPortfolioPerformanceCtrl(sc);
        PortfolioPerformanceCtrl.AcctPlanPortfolioPerformanceCtrl();
        PortfolioPerformanceCtrl.Refreshfunction();

        PageReference pageRef2 = Page.AccountPlanRevenueExpectation;
        pageRef2.getParameters().put('PortID', String.valueOf(portfolio.Id));
        Test.setCurrentPage(pageRef2);
        
        ApexPages.StandardController sc2 = new ApexPages.StandardController(prodStrategy);
        AccountPlanPortfolioPerformanceCtrl PortfolioPerformanceCtrl2 = new AccountPlanPortfolioPerformanceCtrl(sc2);
        PortfolioPerformanceCtrl2.AcctPlanPortfolioPerformanceCtrl();
        PortfolioPerformanceCtrl2.Refreshfunction();
    }
    
    static void MockProductStrategy(Id companyProfileId, Id groupProfileId, Id walletId)
    {
        AcctPlanProdStrategy__c prodStrategy1 = new AcctPlanProdStrategy__c();
        prodStrategy1.SEQ__c = 1;
        prodStrategy1.Name = '1. NIIc';
        prodStrategy1.WalletSizing__c = 10000;
        prodStrategy1.AnnualizedPerformance__c = 100;
        prodStrategy1.Adjust_NI__c = 150;
        prodStrategy1.ExpectedIncrementalNIFromStep5__c = 10;

        prodStrategy1.AccountPlanYear__c = 2015;   
        prodStrategy1.AcctPlanCompanyProfileID__c = companyProfileId;
        //prodStrategy1.AcctPlanCompanyProfileID__r.Name = companyProfile.Name;
        prodStrategy1.AcctPlanGroupProfileID__c = groupProfileId;        
        //prodStrategy1.AcctPlanGroupProfileID__r.Name = groupProfile.Name;
        prodStrategy1.AcctPlanWallet__c = walletId;
        prodStrategy1.AspirationSOW__c = 0.2;        
        prodStrategy1.RefreshAsOf__c = Date.today();
        insert prodStrategy1;
        
        AcctPlanProdStrategy__c prodStrategy2 = new AcctPlanProdStrategy__c();
        prodStrategy2.SEQ__c = 2;
        prodStrategy2.Name = '2. NIId';
        prodStrategy2.WalletSizing__c = 10000;
        prodStrategy2.AnnualizedPerformance__c = 100;
        prodStrategy2.Adjust_NI__c = 150;
        prodStrategy2.ExpectedIncrementalNIFromStep5__c = 10;
        
        prodStrategy2.AccountPlanYear__c = 2015;   
        prodStrategy2.AcctPlanCompanyProfileID__c = companyProfileId;
        //prodStrategy2.AcctPlanCompanyProfileID__r.Name = companyProfile.Name;
        prodStrategy2.AcctPlanGroupProfileID__c = groupProfileId;        
        //prodStrategy2.AcctPlanGroupProfileID__r.Name = groupProfile.Name;
        prodStrategy2.AcctPlanWallet__c = walletId;
        prodStrategy2.AspirationSOW__c = 0.2;        
        prodStrategy2.RefreshAsOf__c = Date.today();
        insert prodStrategy2;
        
        AcctPlanProdStrategy__c prodStrategy3 = new AcctPlanProdStrategy__c();
        prodStrategy3.SEQ__c = 3;
        prodStrategy3.Name = '3. Fee';
        prodStrategy3.WalletSizing__c = 10000;
        prodStrategy3.AnnualizedPerformance__c = 100;
        prodStrategy3.Adjust_NI__c = 150;
        prodStrategy3.ExpectedIncrementalNIFromStep5__c = 10;
                
        prodStrategy3.AccountPlanYear__c = 2015;   
        prodStrategy3.AcctPlanCompanyProfileID__c = companyProfileId;
        //prodStrategy3.AcctPlanCompanyProfileID__r.Name = companyProfile.Name;
        prodStrategy3.AcctPlanGroupProfileID__c = groupProfileId;        
        //prodStrategy3.AcctPlanGroupProfileID__r.Name = groupProfile.Name;
        prodStrategy3.AcctPlanWallet__c = walletId;
        prodStrategy3.AspirationSOW__c = 0.2;        
        prodStrategy3.RefreshAsOf__c = Date.today();
        insert prodStrategy3;
        
        AcctPlanProdStrategy__c prodStrategy4 = new AcctPlanProdStrategy__c();
        prodStrategy4.SEQ__c = 4;
        prodStrategy4.Name = 'Recurring Fee';
        prodStrategy4.WalletSizing__c = 0;
        prodStrategy4.AnnualizedPerformance__c = 00;
        prodStrategy4.Adjust_NI__c = 0;
        prodStrategy4.ExpectedIncrementalNIFromStep5__c = 0;
                
        prodStrategy4.AccountPlanYear__c = 2015;   
        prodStrategy4.AcctPlanCompanyProfileID__c = companyProfileId;
        //prodStrategy4.AcctPlanCompanyProfileID__r.Name = companyProfile.Name;
        prodStrategy4.AcctPlanGroupProfileID__c = groupProfileId;        
        //prodStrategy4.AcctPlanGroupProfileID__r.Name = groupProfile.Name;
        prodStrategy4.AcctPlanWallet__c = walletId;
        prodStrategy4.AspirationSOW__c = 0;        
        prodStrategy4.RefreshAsOf__c = Date.today();
        insert prodStrategy4;
        
        AcctPlanProdStrategy__c prodStrategy5 = new AcctPlanProdStrategy__c();
        prodStrategy5.SEQ__c = 5;
        prodStrategy5.Name = '3.1 TF Fee';
        prodStrategy5.WalletSizing__c = 10000;
        prodStrategy5.AnnualizedPerformance__c = 100;
        prodStrategy5.Adjust_NI__c = 150;
        prodStrategy5.ExpectedIncrementalNIFromStep5__c = 10;
                
        prodStrategy5.AccountPlanYear__c = 2015;   
        prodStrategy5.AcctPlanCompanyProfileID__c = companyProfileId;
        //prodStrategy5.AcctPlanCompanyProfileID__r.Name = companyProfile.Name;
        prodStrategy5.AcctPlanGroupProfileID__c = groupProfileId;        
        //prodStrategy5.AcctPlanGroupProfileID__r.Name = groupProfile.Name;
        prodStrategy5.AcctPlanWallet__c = walletId;
        prodStrategy5.AspirationSOW__c = 0.2;        
        prodStrategy5.RefreshAsOf__c = Date.today();
        insert prodStrategy5;
        
        AcctPlanProdStrategy__c prodStrategy6 = new AcctPlanProdStrategy__c();
        prodStrategy6.SEQ__c = 6;
        prodStrategy6.Name = '3.2 FX Fee';
        prodStrategy6.WalletSizing__c = 10000;
        prodStrategy6.AnnualizedPerformance__c = 100;
        prodStrategy6.Adjust_NI__c = 150;
        prodStrategy6.ExpectedIncrementalNIFromStep5__c = 10;
                
        prodStrategy6.AccountPlanYear__c = 2015;   
        prodStrategy6.AcctPlanCompanyProfileID__c = companyProfileId;
        //prodStrategy6.AcctPlanCompanyProfileID__r.Name = companyProfile.Name;
        prodStrategy6.AcctPlanGroupProfileID__c = groupProfileId;        
        //prodStrategy6.AcctPlanGroupProfileID__r.Name = groupProfile.Name;
        prodStrategy6.AcctPlanWallet__c = walletId;
        prodStrategy6.AspirationSOW__c = 0.2;        
        prodStrategy6.RefreshAsOf__c = Date.today();
        insert prodStrategy6;
        
        AcctPlanProdStrategy__c prodStrategy7 = new AcctPlanProdStrategy__c();
        prodStrategy7.SEQ__c = 7;
        prodStrategy7.Name = '3.3 L/G Fee';
        prodStrategy7.WalletSizing__c = 10000;
        prodStrategy7.AnnualizedPerformance__c = 100;
        prodStrategy7.Adjust_NI__c = 150;
        prodStrategy7.ExpectedIncrementalNIFromStep5__c = 10;
                
        prodStrategy7.AccountPlanYear__c = 2015;   
        prodStrategy7.AcctPlanCompanyProfileID__c = companyProfileId;
        //prodStrategy7.AcctPlanCompanyProfileID__r.Name = companyProfile.Name;
        prodStrategy7.AcctPlanGroupProfileID__c = groupProfileId;        
        //prodStrategy7.AcctPlanGroupProfileID__r.Name = groupProfile.Name;
        prodStrategy7.AcctPlanWallet__c = walletId;
        prodStrategy7.AspirationSOW__c = 0.2;        
        prodStrategy7.RefreshAsOf__c = Date.today();
        insert prodStrategy7;
                
        AcctPlanProdStrategy__c prodStrategy8 = new AcctPlanProdStrategy__c();
        prodStrategy8.SEQ__c = 8;
        prodStrategy8.Name = '3.4 Cash Fee';
        prodStrategy8.WalletSizing__c = 10000;
        prodStrategy8.AnnualizedPerformance__c = 100;
        prodStrategy8.Adjust_NI__c = 150;
        prodStrategy8.ExpectedIncrementalNIFromStep5__c = 10;
                
        prodStrategy8.AccountPlanYear__c = 2015;   
        prodStrategy8.AcctPlanCompanyProfileID__c = companyProfileId;
        //prodStrategy8.AcctPlanCompanyProfileID__r.Name = companyProfile.Name;
        prodStrategy8.AcctPlanGroupProfileID__c = groupProfileId;        
        //prodStrategy8.AcctPlanGroupProfileID__r.Name = groupProfile.Name;
        prodStrategy8.AcctPlanWallet__c = walletId;
        prodStrategy8.AspirationSOW__c = 0.2;        
        prodStrategy8.RefreshAsOf__c = Date.today();
        insert prodStrategy8;
        
        AcctPlanProdStrategy__c prodStrategy9 = new AcctPlanProdStrategy__c();
        prodStrategy9.SEQ__c = 9;
        prodStrategy9.Name = '3.5 AS Fee';
        prodStrategy9.WalletSizing__c = 10000;
        prodStrategy9.AnnualizedPerformance__c = 100;
        prodStrategy9.Adjust_NI__c = 150;
        prodStrategy9.ExpectedIncrementalNIFromStep5__c = 10;
                
        prodStrategy9.AccountPlanYear__c = 2015;   
        prodStrategy9.AcctPlanCompanyProfileID__c = companyProfileId;
        //prodStrategy9.AcctPlanCompanyProfileID__r.Name = companyProfile.Name;
        prodStrategy9.AcctPlanGroupProfileID__c = groupProfileId;        
        //prodStrategy9.AcctPlanGroupProfileID__r.Name = groupProfile.Name;
        prodStrategy9.AcctPlanWallet__c = walletId;
        prodStrategy9.AspirationSOW__c = 0.2;        
        prodStrategy9.RefreshAsOf__c = Date.today();
        insert prodStrategy9;
        
        AcctPlanProdStrategy__c prodStrategy10 = new AcctPlanProdStrategy__c();
        prodStrategy10.SEQ__c = 10;
        prodStrategy10.Name = 'Non Recurring Fee';
        prodStrategy10.WalletSizing__c = 0;
        prodStrategy10.AnnualizedPerformance__c = 0;
        prodStrategy10.Adjust_NI__c = 0;
        prodStrategy10.ExpectedIncrementalNIFromStep5__c = 0;
                
        prodStrategy10.AccountPlanYear__c = 2015;   
        prodStrategy10.AcctPlanCompanyProfileID__c = companyProfileId;
        //prodStrategy10.AcctPlanCompanyProfileID__r.Name = companyProfile.Name;
        prodStrategy10.AcctPlanGroupProfileID__c = groupProfileId;        
        //prodStrategy10.AcctPlanGroupProfileID__r.Name = groupProfile.Name;
        prodStrategy10.AcctPlanWallet__c = walletId;
        prodStrategy10.AspirationSOW__c = 0;        
        prodStrategy10.RefreshAsOf__c = Date.today();
        insert prodStrategy10;
        
        AcctPlanProdStrategy__c prodStrategy11 = new AcctPlanProdStrategy__c();
        prodStrategy11.SEQ__c = 11;
        prodStrategy11.Name = '3.6 Credit Fee';
        prodStrategy11.WalletSizing__c = 10000;
        prodStrategy11.AnnualizedPerformance__c = 100;
        prodStrategy11.Adjust_NI__c = 150;
        prodStrategy11.ExpectedIncrementalNIFromStep5__c = 10;
                
        prodStrategy11.AccountPlanYear__c = 2015;   
        prodStrategy11.AcctPlanCompanyProfileID__c = companyProfileId;
        //prodStrategy11.AcctPlanCompanyProfileID__r.Name = companyProfile.Name;
        prodStrategy11.AcctPlanGroupProfileID__c = groupProfileId;        
        //prodStrategy11.AcctPlanGroupProfileID__r.Name = groupProfile.Name;
        prodStrategy11.AcctPlanWallet__c = walletId;
        prodStrategy11.AspirationSOW__c = 0.2;        
        prodStrategy11.RefreshAsOf__c = Date.today();
        insert prodStrategy11;
        
        AcctPlanProdStrategy__c prodStrategy12 = new AcctPlanProdStrategy__c();
        prodStrategy12.SEQ__c = 12;
        prodStrategy12.Name = '3.7 BA Fee';
        prodStrategy12.WalletSizing__c = 10000;
        prodStrategy12.AnnualizedPerformance__c = 100;
        prodStrategy12.Adjust_NI__c = 150;
        prodStrategy12.ExpectedIncrementalNIFromStep5__c = 10;
                
        prodStrategy12.AccountPlanYear__c = 2015;   
        prodStrategy12.AcctPlanCompanyProfileID__c = companyProfileId;
        //prodStrategy12.AcctPlanCompanyProfileID__r.Name = companyProfile.Name;
        prodStrategy12.AcctPlanGroupProfileID__c = groupProfileId;        
        //prodStrategy12.AcctPlanGroupProfileID__r.Name = groupProfile.Name;
        prodStrategy12.AcctPlanWallet__c = walletId;
        prodStrategy12.AspirationSOW__c = 0.2;        
        prodStrategy12.RefreshAsOf__c = Date.today();
        insert prodStrategy12;
        
        AcctPlanProdStrategy__c prodStrategy13 = new AcctPlanProdStrategy__c();
        prodStrategy13.SEQ__c = 13;
        prodStrategy13.Name = '3.8 Derivative Fee';
        prodStrategy13.WalletSizing__c = 10000;
        prodStrategy13.AnnualizedPerformance__c = 100;
        prodStrategy13.Adjust_NI__c = 150;
        prodStrategy13.ExpectedIncrementalNIFromStep5__c = 10;
                
        prodStrategy13.AccountPlanYear__c = 2015;   
        prodStrategy13.AcctPlanCompanyProfileID__c = companyProfileId;
        //prodStrategy13.AcctPlanCompanyProfileID__r.Name = companyProfile.Name;
        prodStrategy13.AcctPlanGroupProfileID__c = groupProfileId;        
        //prodStrategy13.AcctPlanGroupProfileID__r.Name = groupProfile.Name;
        prodStrategy13.AcctPlanWallet__c = walletId;
        prodStrategy13.AspirationSOW__c = 0.2;        
        prodStrategy13.RefreshAsOf__c = Date.today();
        insert prodStrategy13;
        
        AcctPlanProdStrategy__c prodStrategy14 = new AcctPlanProdStrategy__c();
        prodStrategy14.SEQ__c = 14;
        prodStrategy14.Name = '3.9 IB Fee';
        prodStrategy14.WalletSizing__c = 10000;
        prodStrategy14.AnnualizedPerformance__c = 100;
        prodStrategy14.Adjust_NI__c = 150;
        prodStrategy14.ExpectedIncrementalNIFromStep5__c = 10;
                
        prodStrategy14.AccountPlanYear__c = 2015;   
        prodStrategy14.AcctPlanCompanyProfileID__c = companyProfileId;
        //prodStrategy14.AcctPlanCompanyProfileID__r.Name = companyProfile.Name;
        prodStrategy14.AcctPlanGroupProfileID__c = groupProfileId;        
        //prodStrategy14.AcctPlanGroupProfileID__r.Name = groupProfile.Name;
        prodStrategy14.AcctPlanWallet__c = walletId;
        prodStrategy14.AspirationSOW__c = 0.2;        
        prodStrategy14.RefreshAsOf__c = Date.today();
        insert prodStrategy14;
        
    }
    
}