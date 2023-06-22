@IsTest
public class AccountPlanRevenueExpectationCtrlTest{
    static{
        TestUtils.createAppConfig();
        TestUtils.createStatusCode();        
        TestUtils.createIdType();
        TestUtils.createTriggerMsg();
        TestUtils.createObjUserPermission();
    }
public static List<AccountPlanProductStrategyService.AcctPlanProdStrategyInfo> AcctPlanProdStrategyList;
public static AcctPlanProdStrategy__c prodStrategy;
public static AcctPlanGroupProfile__c groupProfile;
public static AcctPlanCompanyProfile__c companyProfile;
public static AcctPlanCompanyPort__c companyPort;
public static Account account;
public static AcctPlanProdStrategy__c prodStrategy1;
public static AcctPlanProdStrategy__c prodStrategy2;
public static AcctPlanProdStrategy__c prodStrategy3;
public static AcctPlanProdStrategy__c prodStrategy4;
public static AcctPlanProdStrategy__c prodStrategy5;
public static AcctPlanProdStrategy__c prodStrategy6;
public static AcctPlanProdStrategy__c prodStrategy7;
public static AcctPlanProdStrategy__c prodStrategy8;
public static AcctPlanProdStrategy__c prodStrategy9;
public static AcctPlanProdStrategy__c prodStrategy10;
public static AcctPlanProdStrategy__c prodStrategy11;
public static AcctPlanProdStrategy__c prodStrategy12;
public static AcctPlanProdStrategy__c prodStrategy13;
public static AcctPlanProdStrategy__c prodStrategy14;
public static AcctPlanWallet__c wallet;
public static Group__c groupMaster;
public static Account_Plan_Completion__c completion;
    
public static AcctPlanWalletByDomain__c walletByDomain;
public static AcctPlanActionPlan__c actionPlan;
public static AcctPlanNIProject__c niProject;
public static AcctAnnualPerformance__c annualPerformance;
    
        
    public static testMethod void RevenueExpectationTest(){
    
        AccountPlanRevenueExpectation();
    }
    
    static void AccountPlanRevenueExpectation(){
    
        
        
        //Create Account
        account = new Account();
        account.Name='Test AccountPlan Step6' ;
        account.Phone ='050111222';
        account.Mobile_Number_PE__c  = '0801112233';
        insert account;    
        
        groupMaster = new Group__c();
        groupMaster.Name = 'GROUP6';
        insert groupMaster;
        
        //Create Account Plan Group Profile
        groupProfile = new AcctPlanGroupProfile__c();
        groupProfile.Name = 'groupStep6';
        groupProfile.Group__c = groupMaster.Id;
        insert groupProfile;
        
        companyProfile= new AcctPlanCompanyProfile__c();
        //companyProfile.Name = 'comStep6';
        companyProfile.Account__c = account.Id;
        insert companyProfile;
        
        companyPort = new AcctPlanCompanyPort__c();
        companyPort.Account_Plan_Company_Profile__c = companyProfile.Id;
        companyPort.Target_NI_By_RM__c = 100000;
        insert companyPort;      
                   
        wallet = new AcctPlanWallet__c();
        wallet.AcctPlanCompanyProfile__c = companyProfile.Id;
        insert wallet;

        walletByDomain = new AcctPlanWalletByDomain__c();
        walletByDomain.AcctPlanWallet__c = wallet.Id;
        insert walletByDomain;
        
        actionPlan = new AcctPlanActionPlan__c();
        actionPlan.AcctPlanWalletByDomain__c = walletByDomain.Id;
        actionPlan.Objective__c = 'Maintain';
        actionPlan.Status__c = 'Post Board';
        insert actionPlan;
        
        niProject = new AcctPlanNIProject__c();
        niProject.AcctPlanActionPlanID__c  = actionPlan.Id;
        niProject.TypeOfNI__c = 'NIIc';
        niProject.ExpectedIncrementalNIPerYear1Year__c = 50;
        niProject.TypeOfFee__c = 'TF Fee';
        niProject.ExpectedIncrementalFeePerYear1Year__c = 20;
        insert niProject;
        
        completion = new Account_Plan_Completion__c();        
        completion.Account_Plan_Company_Profile__c = companyProfile.Id;
        completion.Step_2_Entered_Fields__c = 2;
        completion.Step_2_Required_Fields__c = 4;
        insert completion;
        
         User SalesOwner = AccountPlanTestUtilities.createUsers(1, 'RM', 'CompanyApproval', 'CompanyApproval@tmbbank.com', AccountPlanTestUtilities.TMB_RM_PROFILE_ID,false, true).get(0);
        
        
         
        // Create an approval request for the account
        Approval.ProcessSubmitRequest req1 = 
            new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(companyProfile.id); 
        req1.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        // Submit on behalf of a specific submitter
        req1.setSubmitterId(SalesOwner.id); 
        
        // Submit the record to specific process and skip the criteria evaluation
        req1.setProcessDefinitionNameOrId('Account_Plan_Approval_Flow');
        req1.setSkipEntryCriteria(true);
        Approval.ProcessResult result = Approval.process(req1);
        
        
        List<Id> newWorkItemIds = result.getNewWorkitemIds();
        // Instantiate the new ProcessWorkitemRequest object and populate it

        Approval.ProcessWorkitemRequest req2 =
            new Approval.ProcessWorkitemRequest();
        req2.setComments('Approving request.');
        req2.setAction('Approve');
        req2.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        // Use the ID from the newly created item to specify the item to be worked
        req2.setWorkitemId(newWorkItemIds.get(0));
        // Submit the request for approval
        Approval.ProcessResult result2 =  Approval.process(req2);
        
            
        
        prodStrategy1 = new AcctPlanProdStrategy__c();
        prodStrategy1.SEQ__c = 1;
        prodStrategy1.Name = '1. NIIc';
        prodStrategy1.WalletSizing__c = 10000;
        prodStrategy1.AnnualizedPerformance__c = 100;
        prodStrategy1.Adjust_NI__c = 150;
        prodStrategy1.ExpectedIncrementalNIFromStep5__c = 10;

        prodStrategy1.AccountPlanYear__c = 2015;   
        prodStrategy1.AcctPlanCompanyProfileID__c = companyProfile.Id;
        //prodStrategy1.AcctPlanCompanyProfileID__r.Name = companyProfile.Name;
        prodStrategy1.AcctPlanGroupProfileID__c = groupProfile.Id;        
        //prodStrategy1.AcctPlanGroupProfileID__r.Name = groupProfile.Name;
        prodStrategy1.AcctPlanWallet__c = wallet.Id;
        prodStrategy1.AspirationSOW__c = 0.2;        
        prodStrategy1.RefreshAsOf__c = Date.today();
        insert prodStrategy1;
        
        prodStrategy2 = new AcctPlanProdStrategy__c();
        prodStrategy2.SEQ__c = 2;
        prodStrategy2.Name = '2. NIId';
        prodStrategy2.WalletSizing__c = 10000;
        prodStrategy2.AnnualizedPerformance__c = 100;
        prodStrategy2.Adjust_NI__c = 150;
        prodStrategy2.ExpectedIncrementalNIFromStep5__c = 10;
        
        prodStrategy2.AccountPlanYear__c = 2015;   
        prodStrategy2.AcctPlanCompanyProfileID__c = companyProfile.Id;
        //prodStrategy2.AcctPlanCompanyProfileID__r.Name = companyProfile.Name;
        prodStrategy2.AcctPlanGroupProfileID__c = groupProfile.Id;        
        //prodStrategy2.AcctPlanGroupProfileID__r.Name = groupProfile.Name;
        prodStrategy2.AcctPlanWallet__c = wallet.Id;
        prodStrategy2.AspirationSOW__c = 0.2;        
        prodStrategy2.RefreshAsOf__c = Date.today();
        insert prodStrategy2;
        
        prodStrategy3 = new AcctPlanProdStrategy__c();
        prodStrategy3.SEQ__c = 3;
        prodStrategy3.Name = '3. Fee';
        prodStrategy3.WalletSizing__c = 10000;
        prodStrategy3.AnnualizedPerformance__c = 100;
        prodStrategy3.Adjust_NI__c = 150;
        prodStrategy3.ExpectedIncrementalNIFromStep5__c = 10;
                
        prodStrategy3.AccountPlanYear__c = 2015;   
        prodStrategy3.AcctPlanCompanyProfileID__c = companyProfile.Id;
        //prodStrategy3.AcctPlanCompanyProfileID__r.Name = companyProfile.Name;
        prodStrategy3.AcctPlanGroupProfileID__c = groupProfile.Id;        
        //prodStrategy3.AcctPlanGroupProfileID__r.Name = groupProfile.Name;
        prodStrategy3.AcctPlanWallet__c = wallet.Id;
        prodStrategy3.AspirationSOW__c = 0.2;        
        prodStrategy3.RefreshAsOf__c = Date.today();
        insert prodStrategy3;
        
        prodStrategy4 = new AcctPlanProdStrategy__c();
        prodStrategy4.SEQ__c = 4;
        prodStrategy4.Name = 'Recurring Fee';
        prodStrategy4.WalletSizing__c = 0;
        prodStrategy4.AnnualizedPerformance__c = 00;
        prodStrategy4.Adjust_NI__c = 0;
        prodStrategy4.ExpectedIncrementalNIFromStep5__c = 0;
                
        prodStrategy4.AccountPlanYear__c = 2015;   
        prodStrategy4.AcctPlanCompanyProfileID__c = companyProfile.Id;
        //prodStrategy4.AcctPlanCompanyProfileID__r.Name = companyProfile.Name;
        prodStrategy4.AcctPlanGroupProfileID__c = groupProfile.Id;        
        //prodStrategy4.AcctPlanGroupProfileID__r.Name = groupProfile.Name;
        prodStrategy4.AcctPlanWallet__c = wallet.Id;
        prodStrategy4.AspirationSOW__c = 0;        
        prodStrategy4.RefreshAsOf__c = Date.today();
        insert prodStrategy4;
        
        prodStrategy5 = new AcctPlanProdStrategy__c();
        prodStrategy5.SEQ__c = 5;
        prodStrategy5.Name = '3.1 TF Fee';
        prodStrategy5.WalletSizing__c = 10000;
        prodStrategy5.AnnualizedPerformance__c = 100;
        prodStrategy5.Adjust_NI__c = 150;
        prodStrategy5.ExpectedIncrementalNIFromStep5__c = 10;
                
        prodStrategy5.AccountPlanYear__c = 2015;   
        prodStrategy5.AcctPlanCompanyProfileID__c = companyProfile.Id;
        //prodStrategy5.AcctPlanCompanyProfileID__r.Name = companyProfile.Name;
        prodStrategy5.AcctPlanGroupProfileID__c = groupProfile.Id;        
        //prodStrategy5.AcctPlanGroupProfileID__r.Name = groupProfile.Name;
        prodStrategy5.AcctPlanWallet__c = wallet.Id;
        prodStrategy5.AspirationSOW__c = 0.2;        
        prodStrategy5.RefreshAsOf__c = Date.today();
        insert prodStrategy5;
        
        prodStrategy6 = new AcctPlanProdStrategy__c();
        prodStrategy6.SEQ__c = 6;
        prodStrategy6.Name = '3.2 FX Fee';
        prodStrategy6.WalletSizing__c = 10000;
        prodStrategy6.AnnualizedPerformance__c = 100;
        prodStrategy6.Adjust_NI__c = 150;
        prodStrategy6.ExpectedIncrementalNIFromStep5__c = 10;
                
        prodStrategy6.AccountPlanYear__c = 2015;   
        prodStrategy6.AcctPlanCompanyProfileID__c = companyProfile.Id;
        //prodStrategy6.AcctPlanCompanyProfileID__r.Name = companyProfile.Name;
        prodStrategy6.AcctPlanGroupProfileID__c = groupProfile.Id;        
        //prodStrategy6.AcctPlanGroupProfileID__r.Name = groupProfile.Name;
        prodStrategy6.AcctPlanWallet__c = wallet.Id;
        prodStrategy6.AspirationSOW__c = 0.2;        
        prodStrategy6.RefreshAsOf__c = Date.today();
        insert prodStrategy6;
        
        prodStrategy7 = new AcctPlanProdStrategy__c();
        prodStrategy7.SEQ__c = 7;
        prodStrategy7.Name = '3.3 L/G Fee';
        prodStrategy7.WalletSizing__c = 10000;
        prodStrategy7.AnnualizedPerformance__c = 100;
        prodStrategy7.Adjust_NI__c = 150;
        prodStrategy7.ExpectedIncrementalNIFromStep5__c = 10;
                
        prodStrategy7.AccountPlanYear__c = 2015;   
        prodStrategy7.AcctPlanCompanyProfileID__c = companyProfile.Id;
        //prodStrategy7.AcctPlanCompanyProfileID__r.Name = companyProfile.Name;
        prodStrategy7.AcctPlanGroupProfileID__c = groupProfile.Id;        
        //prodStrategy7.AcctPlanGroupProfileID__r.Name = groupProfile.Name;
        prodStrategy7.AcctPlanWallet__c = wallet.Id;
        prodStrategy7.AspirationSOW__c = 0.2;        
        prodStrategy7.RefreshAsOf__c = Date.today();
        insert prodStrategy7;
                
        prodStrategy8 = new AcctPlanProdStrategy__c();
        prodStrategy8.SEQ__c = 8;
        prodStrategy8.Name = '3.4 Cash Fee';
        prodStrategy8.WalletSizing__c = 10000;
        prodStrategy8.AnnualizedPerformance__c = 100;
        prodStrategy8.Adjust_NI__c = 150;
        prodStrategy8.ExpectedIncrementalNIFromStep5__c = 10;
                
        prodStrategy8.AccountPlanYear__c = 2015;   
        prodStrategy8.AcctPlanCompanyProfileID__c = companyProfile.Id;
        //prodStrategy8.AcctPlanCompanyProfileID__r.Name = companyProfile.Name;
        prodStrategy8.AcctPlanGroupProfileID__c = groupProfile.Id;        
        //prodStrategy8.AcctPlanGroupProfileID__r.Name = groupProfile.Name;
        prodStrategy8.AcctPlanWallet__c = wallet.Id;
        prodStrategy8.AspirationSOW__c = 0.2;        
        prodStrategy8.RefreshAsOf__c = Date.today();
        insert prodStrategy8;
        
        prodStrategy9 = new AcctPlanProdStrategy__c();
        prodStrategy9.SEQ__c = 9;
        prodStrategy9.Name = '3.5 AS Fee';
        prodStrategy9.WalletSizing__c = 10000;
        prodStrategy9.AnnualizedPerformance__c = 100;
        prodStrategy9.Adjust_NI__c = 150;
        prodStrategy9.ExpectedIncrementalNIFromStep5__c = 10;
                
        prodStrategy9.AccountPlanYear__c = 2015;   
        prodStrategy9.AcctPlanCompanyProfileID__c = companyProfile.Id;
        //prodStrategy9.AcctPlanCompanyProfileID__r.Name = companyProfile.Name;
        prodStrategy9.AcctPlanGroupProfileID__c = groupProfile.Id;        
        //prodStrategy9.AcctPlanGroupProfileID__r.Name = groupProfile.Name;
        prodStrategy9.AcctPlanWallet__c = wallet.Id;
        prodStrategy9.AspirationSOW__c = 0.2;        
        prodStrategy9.RefreshAsOf__c = Date.today();
        insert prodStrategy9;
        
        prodStrategy10 = new AcctPlanProdStrategy__c();
        prodStrategy10.SEQ__c = 10;
        prodStrategy10.Name = 'Non Recurring Fee';
        prodStrategy10.WalletSizing__c = 0;
        prodStrategy10.AnnualizedPerformance__c = 0;
        prodStrategy10.Adjust_NI__c = 0;
        prodStrategy10.ExpectedIncrementalNIFromStep5__c = 0;
                
        prodStrategy10.AccountPlanYear__c = 2015;   
        prodStrategy10.AcctPlanCompanyProfileID__c = companyProfile.Id;
        //prodStrategy10.AcctPlanCompanyProfileID__r.Name = companyProfile.Name;
        prodStrategy10.AcctPlanGroupProfileID__c = groupProfile.Id;        
        //prodStrategy10.AcctPlanGroupProfileID__r.Name = groupProfile.Name;
        prodStrategy10.AcctPlanWallet__c = wallet.Id;
        prodStrategy10.AspirationSOW__c = 0;        
        prodStrategy10.RefreshAsOf__c = Date.today();
        insert prodStrategy10;
        
        prodStrategy11 = new AcctPlanProdStrategy__c();
        prodStrategy11.SEQ__c = 11;
        prodStrategy11.Name = '3.6 Credit Fee';
        prodStrategy11.WalletSizing__c = 10000;
        prodStrategy11.AnnualizedPerformance__c = 100;
        prodStrategy11.Adjust_NI__c = 150;
        prodStrategy11.ExpectedIncrementalNIFromStep5__c = 10;
                
        prodStrategy11.AccountPlanYear__c = 2015;   
        prodStrategy11.AcctPlanCompanyProfileID__c = companyProfile.Id;
        //prodStrategy11.AcctPlanCompanyProfileID__r.Name = companyProfile.Name;
        prodStrategy11.AcctPlanGroupProfileID__c = groupProfile.Id;        
        //prodStrategy11.AcctPlanGroupProfileID__r.Name = groupProfile.Name;
        prodStrategy11.AcctPlanWallet__c = wallet.Id;
        prodStrategy11.AspirationSOW__c = 0.2;        
        prodStrategy11.RefreshAsOf__c = Date.today();
        insert prodStrategy11;
        
        prodStrategy12 = new AcctPlanProdStrategy__c();
        prodStrategy12.SEQ__c = 12;
        prodStrategy12.Name = '3.7 BA Fee';
        prodStrategy12.WalletSizing__c = 10000;
        prodStrategy12.AnnualizedPerformance__c = 100;
        prodStrategy12.Adjust_NI__c = 150;
        prodStrategy12.ExpectedIncrementalNIFromStep5__c = 10;
                
        prodStrategy12.AccountPlanYear__c = 2015;   
        prodStrategy12.AcctPlanCompanyProfileID__c = companyProfile.Id;
        //prodStrategy12.AcctPlanCompanyProfileID__r.Name = companyProfile.Name;
        prodStrategy12.AcctPlanGroupProfileID__c = groupProfile.Id;        
        //prodStrategy12.AcctPlanGroupProfileID__r.Name = groupProfile.Name;
        prodStrategy12.AcctPlanWallet__c = wallet.Id;
        prodStrategy12.AspirationSOW__c = 0.2;        
        prodStrategy12.RefreshAsOf__c = Date.today();
        insert prodStrategy12;
        
        prodStrategy13 = new AcctPlanProdStrategy__c();
        prodStrategy13.SEQ__c = 13;
        prodStrategy13.Name = '3.8 Derivative Fee';
        prodStrategy13.WalletSizing__c = 10000;
        prodStrategy13.AnnualizedPerformance__c = 100;
        prodStrategy13.Adjust_NI__c = 150;
        prodStrategy13.ExpectedIncrementalNIFromStep5__c = 10;
                
        prodStrategy13.AccountPlanYear__c = 2015;   
        prodStrategy13.AcctPlanCompanyProfileID__c = companyProfile.Id;
        //prodStrategy13.AcctPlanCompanyProfileID__r.Name = companyProfile.Name;
        prodStrategy13.AcctPlanGroupProfileID__c = groupProfile.Id;        
        //prodStrategy13.AcctPlanGroupProfileID__r.Name = groupProfile.Name;
        prodStrategy13.AcctPlanWallet__c = wallet.Id;
        prodStrategy13.AspirationSOW__c = 0.2;        
        prodStrategy13.RefreshAsOf__c = Date.today();
        insert prodStrategy13;
        
        prodStrategy14 = new AcctPlanProdStrategy__c();
        prodStrategy14.SEQ__c = 14;
        prodStrategy14.Name = '3.9 IB Fee';
        prodStrategy14.WalletSizing__c = 10000;
        prodStrategy14.AnnualizedPerformance__c = 100;
        prodStrategy14.Adjust_NI__c = 150;
        prodStrategy14.ExpectedIncrementalNIFromStep5__c = 10;
                
        prodStrategy14.AccountPlanYear__c = 2015;   
        prodStrategy14.AcctPlanCompanyProfileID__c = companyProfile.Id;
        //prodStrategy14.AcctPlanCompanyProfileID__r.Name = companyProfile.Name;
        prodStrategy14.AcctPlanGroupProfileID__c = groupProfile.Id;        
        //prodStrategy14.AcctPlanGroupProfileID__r.Name = groupProfile.Name;
        prodStrategy14.AcctPlanWallet__c = wallet.Id;
        prodStrategy14.AspirationSOW__c = 0.2;        
        prodStrategy14.RefreshAsOf__c = Date.today();
        insert prodStrategy14;
        
        
        
        PageReference pageRef = Page.AccountPlanRevenueExpectation;
        pageRef.getParameters().put('CompanyID', String.valueOf(companyProfile.Id));        
        pageRef.getParameters().put('GroupID', String.valueOf(groupProfile.Id));
        pageRef.getParameters().put('WalletID', String.valueOf(wallet.Id));
        Test.setCurrentPage(pageRef);
        
        List<AcctPlanProdStrategy__c> tempProdStrategy = 
            AccountPlanProductStrategySelector.selectProductStrategyByIds(new Set<ID> { companyProfile.Id });
           
        system.debug('tempProdStrategy: ' +tempProdStrategy);
       
        
        AcctPlanProdStrategyList = new List<AccountPlanProductStrategyService.AcctPlanProdStrategyInfo>();
        
        
        for (AcctPlanProdStrategy__c proStrategy : tempProdStrategy) {
            
            AccountPlanProductStrategyService.AcctPlanProdStrategyInfo acctInfo =
            new AccountPlanProductStrategyService.AcctPlanProdStrategyInfo();
            acctInfo.Id = proStrategy.Id;
            acctInfo.SEQ = proStrategy.SEQ__c;
            acctInfo.Name = proStrategy.Name;
            acctInfo.AccountPlanYear = proStrategy.AccountPlanYear__c;
            acctInfo.AcctPlanCompanyProfileID = proStrategy.AcctPlanCompanyProfileID__c;
            acctInfo.AcctPlanGroupProfileID = proStrategy.AcctPlanGroupProfileID__c;
            acctInfo.AcctPlanWallet = proStrategy.AcctPlanWallet__c;
            acctInfo.AnnualizedPerformance = proStrategy.AnnualizedPerformance__c == null ? 0 : proStrategy.AnnualizedPerformance__c;
            acctInfo.AspirationSOW = proStrategy.AspirationSOW__c == null ? 0 : proStrategy.AspirationSOW__c;
            acctInfo.CompareSOW = proStrategy.CompareSOW__c == null ? 0 : proStrategy.CompareSOW__c;
            acctInfo.ExistingSOW = proStrategy.ExistingSOW__c == null ? 0 : proStrategy.ExistingSOW__c; // proStrategy.ExistingSOW__c;             
            acctInfo.ExpectedSOWPercent = proStrategy.ExpectedSOWPercent__c == null ? 0 : proStrategy.ExpectedSOWPercent__c; // proStrategy.ExpectedSOWPercent__c;               
            acctInfo.WalletSizing = proStrategy.WalletSizing__c == null ? 0 : proStrategy.WalletSizing__c;
            acctInfo.TotalCompanyNI = proStrategy.TotalCompanyNI__c == null ? 0 : proStrategy.TotalCompanyNI__c;

            acctInfo.ExpectedIncrementalNI = proStrategy.ExpectedIncrementalNI__c == null ? 0 : proStrategy.ExpectedIncrementalNI__c; // proStrategy.ExpectedIncrementalNI__c; //DA: proStrategy.ExpectedIncrementalNI__c + 5000;
            acctInfo.ExpectedIncrementalNIFromStep5 = proStrategy.ExpectedIncrementalNIFromStep5__c == null ? 0 : proStrategy.ExpectedIncrementalNIFromStep5__c;
            acctInfo.AdjustNI = proStrategy.Adjust_NI__c == null ? 0 : proStrategy.Adjust_NI__c;
            acctInfo.RefreshAsOf = proStrategy.RefreshAsOf__c;

            AcctPlanProdStrategyList.add(acctInfo);
        }
               
        system.debug('AcctPlanProdStrategyList: ' +AcctPlanProdStrategyList);
                
        AccountPlanUtilities.OWNERSEGMENT = 'SE';
       
        ApexPages.StandardController sc = new ApexPages.StandardController(prodStrategy1);
        AccountPlanRevenueExpectationCtrl RevenueExpectCtrl = new AccountPlanRevenueExpectationCtrl(sc);
        RevenueExpectCtrl.AccountPlanProdStrategyInfoDisplay(AcctPlanProdStrategyList);
        RevenueExpectCtrl.Refreshfunction();
        RevenueExpectCtrl.ApprovalExRemoteAction();
    }
    
    
    
 

}