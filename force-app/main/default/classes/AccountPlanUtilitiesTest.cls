@isTest
global class AccountPlanUtilitiesTest {
    static{
        TestUtils.createAppConfig();
        TestUtils.createStatusCode(); 
        TestUtils.createDisqualifiedReason(); 
        TestUtils.CreateAddress();
        AccountPlanTestUtilities.getAcctPlanMode();
        AccountPlanWalletTestUtilities.createStandardFee();
        AccountPlanWalletTestUtilities.createBanks();
        AccountPlanWalletTestUtilities.createCurrencies();
         List<sObject> ls = 
            Test.loadData(AcctPlan_Questionnaire_Template__c.sObjectType /*API Name*/, 'AcctPlanQuestionnaireTemplate' /*Static Resource Name*/);
   
         }
    
    static testmethod void AccountPlanUtilitiesTest(){
      
         User SalesOwner = AccountPlanTestUtilities.createUsers(1, 'RM', 'PortfolioMngTest', 'portfoliomng@tmbbank.com', AccountPlanTestUtilities.TMB_RM_PROFILE_ID,false, true).get(0);
        
          List<Account> AccountList = AccountPlanTestUtilities.createAccounts(5, 'InitiateTest', 'Individual', SalesOwner.id, true, true);
        Group__c mastergroup = AccountPlanTestUtilities.createGroupMaster(1,'Initiatetest', false, true).get(0);
        for(account acct  : AccountList){
            acct.Group__c =mastergroup.id;
        }
        update AccountList;
        AccountPlanTestUtilities.createAccounts(1, 'InitiateNonGroupTest', 'Individual', SalesOwner.id, true, true);
        List<Target__c> TaragetList = AccountPlanTestUtilities.createTargetNI(5,  SalesOwner.id, true);
       
       List<Account> acctForCompanyProfile = new List<Account>();
        acctForCompanyProfile.add(AccountList.get(0));
        system.runAs(SalesOwner){
        List<AcctPlanCompanyProfile__c> comprofileList = AccountPlanTestUtilities.createCompanyProfileByAccount(acctForCompanyProfile, true);
         AcctPlanCompanyProfile__c comprofile = comprofileList.get(0);
             List<group__c> mgroupList = new List <group__c>();
        mgroupList.add(mastergroup);
            AcctPlanGroupProfile__c groupprofile = AccountPlanTestUtilities.createGroupProfilebyGroup(mgroupList,true).get(0);
         comprofile.AcctPlanGroup__c = groupprofile.id;
         update comprofile;
        AcctPlanPortfolio__c portfolio = AccountPlanTestUtilities.createAccountPlanPortfolio(SalesOwner.id, '2014', 10000000, true);
        AcctPlanWallet__c AcctPlanwallet = AccountPlanWalletTestUtilities.createAccountPlanWallet(comprofile.id, true);
        List<AcctPlanContribution__c> contributionlist = AccountPlanTestUtilities.createRenevueContribution(3,null, comprofile.id);
        
        AccountPlanWalletTestUtilities.createWalletCurrency(AcctPlanwallet.id);
        AccountPlanWalletTestUtilities.createQuestionnaireTemplate();
        AccountPlanWalletTestUtilities.createWalletDomainITables(AcctPlanwallet.id);
            AcctPlanPortfolio__c newPort =AccountPlanUtilities.portfolio;
            List <AcctPlanQuestionnaire__c > QuestionnaireList =AccountPlanUtilities.QuestionnaireList;
            List<Account> newAcctList =AccountPlanUtilities.AccountList;
            List<AcctPlanCompanyProfile__c> comlist =AccountPlanUtilities.companyProfileList;
            List <AcctPlanGroupProfile__c>  groupProfileList = AccountPlanUtilities.groupProfileList;
            List <AcctPlanProdStrategy__c>  AcctPlanProdStrategyList = AccountPlanUtilities.AcctPlanProdStrategyList;
            String GroupProfileID = AccountPlanUtilities.GroupProfileID;
            String  CompanyProfileID = AccountPlanUtilities.CompanyProfileID;
            Boolean isSystemAdmin = AccountPlanUtilities.isSystemAdmin;
            boolean ISHASPERMISSION = AccountPlanUtilities.ISHASPERMISSION;
            boolean IsAccountTeamReadWrite = AccountPlanUtilities.IsAccountTeamReadWrite;
            AccountPlanUtilities.QueryPortfolioByID(portfolio.id);
            AccountPlanUtilities.QueryGroupProfileByID(mastergroup.id);
            AccountPlanUtilities.QueryCompanyProfileByID(comprofile.id);
            AccountPlanUtilities.QueryCompanyProfileByGroupID(mastergroup.id);
            AccountPlanUtilities.QueryAccountByOwnerID(SalesOwner.id);
            //new query
            AccountPlanUtilities.QueryAccountByOwnerIDLimit(SalesOwner.id);
            AccountPlanUtilities.QueryAccountByAcctID(AccountList.get(0).id);
            AccountPlanUtilities.QueryAccountByGroupID(mastergroup.id);
            //new query
            AccountPlanUtilities.QueryAccountByGroupIDLimit(mastergroup.id);
            AccountPlanUtilities.QueryTargetNI12monthsbyOwnerID(SalesOwner.id);
            AccountPlanUtilities.QueryTargetNIbyOwnerIDandYear(SalesOwner.id,2015);
            AccountPlanUtilities.QueryContributionByGroupProfileID(groupprofile.id);
            AccountPlanUtilities.QueryProductStrategyByCompanyProfileID(comprofile.id);
            AccountPlanUtilities.QueryProductStrategyByGroupProfileID(groupprofile.id);
            AccountPlanUtilities.QueryAcctPlanCompanyProfileByID(comprofile.id);
            //new query
            AccountPlanUtilities.QueryAcctPlanCompanyProfileByIDLimit(comprofile.id);
            AccountPlanUtilities.QueryQuestionnaireByWalletID(AcctPlanwallet.id);
            AccountPlanUtilities.QueryAccountByCompanyProfile(comprofile.id);
            AccountPlanUtilities.QueryCompanyPortbyPortID(portfolio.id);
            //new query
            AccountPlanUtilities.QueryCompanyPortbyPortIDLimit(portfolio.id);
            AccountPlanUtilities.QueryCompanyPortbyPortIDFlag(portfolio.id);
            AccountPlanUtilities.QueryCompanyPortbyPortIDTarget(portfolio.id);
            AccountPlanUtilities.QueryCompanyPortbyPortIDGroup(portfolio.id);
            
            List<Account_Plan_Fiscal_Year__c> getFiscalYear = AccountPlanTestUtilities.getFiscalYear;
            List<AcctPlanGroupPort__c> createGroupPortbyGroupMaster = AccountPlanTestUtilities.createGroupPortbyGroupMaster(mgroupList,portfolio,true);
            List<AcctPlanCompanyPort__c> createCompanyPortByAccount = AccountPlanTestUtilities.createCompanyPortByAccount(AccountList,portfolio,true);
            List<AcctPlanSupplierOrBuyer__c> CreateSupplierOrBuyer = AccountPlanTestUtilities.CreateSupplierOrBuyer(3,comprofile.id);
            List<Account_Plan_Company_Top_5__c> CreateTop5 = AccountPlanTestUtilities.CreateTop5(3,comprofile.id);
            
            }
        
        
        
     
        
    
    }
    
    static testmethod void AccountPlanWalletUtilitiesTest(){
      
         User SalesOwner = AccountPlanTestUtilities.createUsers(1, 'RM', 'PortfolioMngTest', 'portfoliomng@tmbbank.com', AccountPlanTestUtilities.TMB_RM_PROFILE_ID,false, true).get(0);
        
          List<Account> AccountList = AccountPlanTestUtilities.createAccounts(5, 'InitiateTest', 'Individual', SalesOwner.id, true, true);
        Group__c mastergroup = AccountPlanTestUtilities.createGroupMaster(1,'Initiatetest', false, true).get(0);
        for(account acct  : AccountList){
            acct.Group__c =mastergroup.id;
        }
        update AccountList;
        AccountPlanTestUtilities.createAccounts(1, 'InitiateNonGroupTest', 'Individual', SalesOwner.id, true, true);
        List<Target__c> TaragetList = AccountPlanTestUtilities.createTargetNI(5,  SalesOwner.id, true);
       
       List<Account> acctForCompanyProfile = new List<Account>();
        acctForCompanyProfile.add(AccountList.get(0));
        system.runAs(SalesOwner){
        List<AcctPlanCompanyProfile__c> comprofileList = AccountPlanTestUtilities.createCompanyProfileByAccount(acctForCompanyProfile, true);
         AcctPlanCompanyProfile__c comprofile = comprofileList.get(0);
             List<group__c> mgroupList = new List <group__c>();
        mgroupList.add(mastergroup);
            AcctPlanGroupProfile__c groupprofile = AccountPlanTestUtilities.createGroupProfilebyGroup(mgroupList,true).get(0);
         comprofile.AcctPlanGroup__c = groupprofile.id;
         update comprofile;
        AcctPlanPortfolio__c portfolio = AccountPlanTestUtilities.createAccountPlanPortfolio(SalesOwner.id, '2014', 10000000, true);
        AcctPlanWallet__c AcctPlanwallet = AccountPlanWalletTestUtilities.createAccountPlanWallet(comprofile.id, true);
        List<AcctPlanContribution__c> contributionlist = AccountPlanTestUtilities.createRenevueContribution(3,null, comprofile.id);
        
        AccountPlanWalletTestUtilities.createWalletCurrency(AcctPlanwallet.id);
        AccountPlanWalletTestUtilities.createQuestionnaireTemplate();
        AccountPlanWalletTestUtilities.createWalletDomainITables(AcctPlanwallet.id);
            
             List<AcctPlanWalletCreditFacility__c> creditlist = AccountPlanWalletTestUtilities.CreateCreditFacility(AcctPlanwallet.id);
        List<AcctPlanExistingLongTermLoan__c> longtermlist = AccountPlanWalletTestUtilities.CreateLongTermLoan(AcctPlanwallet.id);    
       
        AcctPlanPortfolio__c newPort =AccountPlanUtilities.portfolio;
        List<AcctPlanWallet__c> walletList = AccountPlanWalletUtilities.walletList;
        List<AcctPlan_Questionnaire_Template__c> questionTemplate1= AccountPlanWalletUtilities.questionTemplate;
        List<AcctPlan_Questionnaire_Template__c> questionTemplate2 =AccountPlanWalletUtilities.queryQuestionnaireTemplate('Domain I');
         List<AcctPlanStandardFee__c> stfList = AccountPlanWalletTestUtilities.stdFeeList;
         AccountPlanWalletTestUtilities.createQuestionniare(AcctPlanwallet.id);
            
            
            
            }
        
        
        
     
        
    
    }
    
    
}